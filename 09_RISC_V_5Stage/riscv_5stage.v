`timescale 1ns/1ps

module riscv_5stage (
    input wire clk,
    input wire reset
);

    // Memories and register file
    reg [31:0] pc;
    reg [31:0] instruction_mem [0:63];
    reg [31:0] data_mem [0:63];
    reg [31:0] registers [0:31];

    // Instruction Fetch / Instruction Decode
    reg [31:0] if_id_instr, if_id_pc;

    // Instruction Decode / Execute
    reg [31:0] id_ex_instr, id_ex_pc;
    reg [31:0] id_ex_rs1_data, id_ex_rs2_data;
    reg [31:0] id_ex_imm;

    // Execute / Memory
    reg [31:0] ex_mem_alu_result;
    reg [31:0] ex_mem_store_data;
    reg [4:0]  ex_mem_rd;
    reg        ex_mem_reg_write;
    reg        ex_mem_mem_read;
    reg        ex_mem_mem_write;
    reg        ex_mem_mem_to_reg;

    // Memory / Write Back
    reg [31:0] mem_wb_alu_result;
    reg [31:0] mem_wb_mem_data;
    reg [4:0]  mem_wb_rd;
    reg        mem_wb_reg_write;
    reg        mem_wb_mem_to_reg;

    integer i;

    // Instruction Decode
    wire [6:0] opcode = if_id_instr[6:0];
    wire [4:0] rs1 = if_id_instr[19:15];
    wire [4:0] rs2 = if_id_instr[24:20];

    wire [31:0] imm_i =
        {{20{if_id_instr[31]}}, if_id_instr[31:20]};

    wire [31:0] imm_s =
        {{20{if_id_instr[31]}},
         if_id_instr[31:25], if_id_instr[11:7]};

    wire [31:0] imm_b =
        {{19{if_id_instr[31]}}, if_id_instr[31],
         if_id_instr[7], if_id_instr[30:25],
         if_id_instr[11:8], 1'b0};

    wire [31:0] decoded_imm =
        (opcode == 7'b0100011) ? imm_s :
        (opcode == 7'b1100011) ? imm_b : imm_i;

    // Hazard Detection
    wire load_use_stall =
        (id_ex_instr[6:0] == 7'b0000011) &&
        (id_ex_instr[11:7] != 0) &&
        ((id_ex_instr[11:7] == rs1) ||
         ((id_ex_instr[11:7] == rs2) &&
          (opcode != 7'b0010011) &&
          (opcode != 7'b0000011)));

    // Execute Stage
    wire [4:0] ex_rs1 = id_ex_instr[19:15];
    wire [4:0] ex_rs2 = id_ex_instr[24:20];
    wire [4:0] ex_rd  = id_ex_instr[11:7];

    wire [31:0] wb_value =
        mem_wb_mem_to_reg ? mem_wb_mem_data :
                            mem_wb_alu_result;

    // Forwarding Unit
    reg [31:0] forward_a;
    reg [31:0] forward_b;

    always @(*) begin
        forward_a = id_ex_rs1_data;
        forward_b = id_ex_rs2_data;

        // Forward from EX/MEM
        if (ex_mem_reg_write && !ex_mem_mem_to_reg &&
            ex_mem_rd != 0 && ex_mem_rd == ex_rs1)
            forward_a = ex_mem_alu_result;
        else if (mem_wb_reg_write &&
                 mem_wb_rd != 0 && mem_wb_rd == ex_rs1)
            forward_a = wb_value;

        if (ex_mem_reg_write && !ex_mem_mem_to_reg &&
            ex_mem_rd != 0 && ex_mem_rd == ex_rs2)
            forward_b = ex_mem_alu_result;
        else if (mem_wb_reg_write &&
                 mem_wb_rd != 0 && mem_wb_rd == ex_rs2)
            forward_b = wb_value;
    end

    reg [31:0] alu_result;
    reg [31:0] alu_operand_b;
    reg branch_taken;
    reg [31:0] branch_target;

    always @(*) begin
        alu_result = 0;
        alu_operand_b = forward_b;
        branch_taken = 0;
        branch_target = id_ex_pc;

        case (id_ex_instr[6:0])

            // R-type
            7'b0110011: begin
                case (id_ex_instr[14:12])
                    3'b000: begin
                        if (id_ex_instr[31:25] == 7'b0100000)
                            alu_result = forward_a - forward_b;
                        else
                            alu_result = forward_a + forward_b;
                    end
                    3'b111: alu_result = forward_a & forward_b;
                    3'b110: alu_result = forward_a | forward_b;
                    default: alu_result = 0;
                endcase
            end

            // ADDI
            7'b0010011: begin
                alu_result = forward_a + id_ex_imm;
            end

            // LW
            7'b0000011: begin
                alu_result = forward_a + id_ex_imm;
            end

            // SW
            7'b0100011: begin
                alu_result = forward_a + id_ex_imm;
            end

            // BEQ
            7'b1100011: begin
                branch_taken = (forward_a == forward_b);
                branch_target = id_ex_pc + id_ex_imm;
            end

            default: alu_result = 0;
        endcase
    end

    // Main Pipeline
    always @(posedge clk or posedge reset) begin

        if (reset) begin
            pc <= 0;

            if_id_instr <= 32'h00000013;
            if_id_pc <= 0;

            id_ex_instr <= 32'h00000013;
            id_ex_pc <= 0;
            id_ex_rs1_data <= 0;
            id_ex_rs2_data <= 0;
            id_ex_imm <= 0;

            ex_mem_alu_result <= 0;
            ex_mem_store_data <= 0;
            ex_mem_rd <= 0;
            ex_mem_reg_write <= 0;
            ex_mem_mem_read <= 0;
            ex_mem_mem_write <= 0;
            ex_mem_mem_to_reg <= 0;

            mem_wb_alu_result <= 0;
            mem_wb_mem_data <= 0;
            mem_wb_rd <= 0;
            mem_wb_reg_write <= 0;
            mem_wb_mem_to_reg <= 0;

            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 0;

        end else begin

            // WB Stage: Write Back
            if (mem_wb_reg_write && mem_wb_rd != 0)
                registers[mem_wb_rd] <= wb_value;

            registers[0] <= 0;

            // MEM Stage: Memory Access
            if (ex_mem_mem_write)
                data_mem[ex_mem_alu_result[7:2]]
                    <= ex_mem_store_data;

            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_mem_data <=
                ex_mem_mem_read ?
                data_mem[ex_mem_alu_result[7:2]] : 0;

            mem_wb_rd <= ex_mem_rd;
            mem_wb_reg_write <= ex_mem_reg_write;
            mem_wb_mem_to_reg <= ex_mem_mem_to_reg;

            // EX Stage: Execute
            ex_mem_alu_result <= alu_result;
            ex_mem_store_data <= forward_b;
            ex_mem_rd <= ex_rd;

            ex_mem_reg_write <=
                (id_ex_instr[6:0] == 7'b0110011) ||
                (id_ex_instr[6:0] == 7'b0010011) ||
                (id_ex_instr[6:0] == 7'b0000011);

            ex_mem_mem_read <=
                (id_ex_instr[6:0] == 7'b0000011);

            ex_mem_mem_write <=
                (id_ex_instr[6:0] == 7'b0100011);

            ex_mem_mem_to_reg <=
                (id_ex_instr[6:0] == 7'b0000011);

            // Branch: Flush incorrect instructions
            if (branch_taken) begin
                pc <= branch_target;

                if_id_instr <= 32'h00000013;
                if_id_pc <= 0;

                id_ex_instr <= 32'h00000013;
                id_ex_pc <= 0;
                id_ex_rs1_data <= 0;
                id_ex_rs2_data <= 0;
                id_ex_imm <= 0;
            end

            // Load-use hazard: Insert a bubble
            else if (load_use_stall) begin
                id_ex_instr <= 32'h00000013;
                id_ex_pc <= 0;
                id_ex_rs1_data <= 0;
                id_ex_rs2_data <= 0;
                id_ex_imm <= 0;

                // Hold PC and IF/ID
            end

            else begin

                // ID Stage: Decode and read registers
                id_ex_instr <= if_id_instr;
                id_ex_pc <= if_id_pc;

                id_ex_rs1_data <=
                    (rs1 == 0) ? 0 : registers[rs1];

                id_ex_rs2_data <=
                    (rs2 == 0) ? 0 : registers[rs2];

                id_ex_imm <= decoded_imm;

                // IF Stage: Fetch instruction
                if_id_instr <= instruction_mem[pc[7:2]];
                if_id_pc <= pc;
                pc <= pc + 4;
            end
        end
    end

endmodule
