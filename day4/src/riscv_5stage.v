`timescale 1ns/1ps

// Day 4: High-Performance 5-Stage Pipelined RV32I Processor
// Integrated with Forwarding Unit, Hazard Detection (Stall/Flush), and Performance Counters

module riscv_5stage (
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] pc_out,
    output wire [31:0] cycle_count_out,
    output wire [31:0] instret_count_out,
    output wire [31:0] stall_count_out,
    output wire [31:0] flush_count_out
);

    // =========================================================================
    // 0. Performance Counters
    // =========================================================================
    reg [31:0] cycle_count;
    reg [31:0] instret_count;
    reg [31:0] stall_count;
    reg [31:0] flush_count;

    assign cycle_count_out   = cycle_count;
    assign instret_count_out = instret_count;
    assign stall_count_out   = stall_count;
    assign flush_count_out   = flush_count;

    // =========================================================================
    // Memories and Register File
    // =========================================================================
    reg [31:0] pc;
    assign pc_out = pc;

    reg [31:0] instruction_mem [0:63];
    reg [31:0] data_mem        [0:63];
    reg [31:0] registers       [0:31];

    // Pipeline Registers
    // IF/ID
    reg [31:0] if_id_instr;
    reg [31:0] if_id_pc;

    // ID/EX
    reg [31:0] id_ex_instr;
    reg [31:0] id_ex_pc;
    reg [31:0] id_ex_rs1_data;
    reg [31:0] id_ex_rs2_data;
    reg [31:0] id_ex_imm;
    reg [4:0]  id_ex_rs1;
    reg [4:0]  id_ex_rs2;
    reg [4:0]  id_ex_rd;
    reg        id_ex_reg_write;
    reg        id_ex_mem_read;
    reg        id_ex_mem_write;
    reg        id_ex_mem_to_reg;
    reg        id_ex_alu_src;

    // EX/MEM
    reg [31:0] ex_mem_alu_result;
    reg [31:0] ex_mem_store_data;
    reg [4:0]  ex_mem_rd;
    reg        ex_mem_reg_write;
    reg        ex_mem_mem_read;
    reg        ex_mem_mem_write;
    reg        ex_mem_mem_to_reg;

    // MEM/WB
    reg [31:0] mem_wb_alu_result;
    reg [31:0] mem_wb_mem_data;
    reg [4:0]  mem_wb_rd;
    reg        mem_wb_reg_write;
    reg        mem_wb_mem_to_reg;

    integer i;

    // =========================================================================
    // 1. Decode Logic in ID Stage
    // =========================================================================
    wire [6:0] id_opcode = if_id_instr[6:0];
    wire [4:0] id_rs1    = if_id_instr[19:15];
    wire [4:0] id_rs2    = if_id_instr[24:20];
    wire [4:0] id_rd     = if_id_instr[11:7];
    wire [2:0] id_funct3 = if_id_instr[14:12];

    wire id_use_rs2 = (id_opcode == 7'b0110011) || // R-Type
                      (id_opcode == 7'b0100011) || // Store
                      (id_opcode == 7'b1100011);   // Branch

    wire [31:0] imm_i = {{20{if_id_instr[31]}}, if_id_instr[31:20]};
    wire [31:0] imm_s = {{20{if_id_instr[31]}}, if_id_instr[31:25], if_id_instr[11:7]};
    wire [31:0] imm_b = {{19{if_id_instr[31]}}, if_id_instr[31], if_id_instr[7],
                         if_id_instr[30:25], if_id_instr[11:8], 1'b0};

    wire [31:0] id_decoded_imm = (id_opcode == 7'b0100011) ? imm_s :
                                 (id_opcode == 7'b1100011) ? imm_b : imm_i;

    // Control signals decoded in ID
    wire id_ctrl_reg_write  = (id_opcode == 7'b0110011) || (id_opcode == 7'b0010011) || (id_opcode == 7'b0000011);
    wire id_ctrl_mem_read   = (id_opcode == 7'b0000011);
    wire id_ctrl_mem_write  = (id_opcode == 7'b0100011);
    wire id_ctrl_mem_to_reg = (id_opcode == 7'b0000011);
    wire id_ctrl_alu_src    = (id_opcode != 7'b0110011) && (id_opcode != 7'b1100011);

    // =========================================================================
    // 2. Hazard Detection Unit
    // =========================================================================
    wire stall_if, stall_id, flush_id, flush_ex;
    reg  branch_taken;
    reg  [31:0] branch_target;

    hazard_unit u_hazard (
        .if_id_rs1(id_rs1),
        .if_id_rs2(id_rs2),
        .if_id_use_rs2(id_use_rs2),
        .id_ex_rd(id_ex_rd),
        .id_ex_mem_read(id_ex_mem_read),
        .branch_taken(branch_taken),
        .stall_if(stall_if),
        .stall_id(stall_id),
        .flush_id(flush_id),
        .flush_ex(flush_ex)
    );

    // =========================================================================
    // 3. Forwarding Unit in EX Stage
    // =========================================================================
    wire [1:0] forward_a_sel;
    wire [1:0] forward_b_sel;

    forwarding_unit u_forward (
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .forward_a(forward_a_sel),
        .forward_b(forward_b_sel)
    );

    // Writeback value
    wire [31:0] wb_value = mem_wb_mem_to_reg ? mem_wb_mem_data : mem_wb_alu_result;

    // Forwarding Muxes
    wire [31:0] fwd_val_a = (forward_a_sel == 2'b10) ? ex_mem_alu_result :
                            (forward_a_sel == 2'b01) ? wb_value : id_ex_rs1_data;

    wire [31:0] fwd_val_b = (forward_b_sel == 2'b10) ? ex_mem_alu_result :
                            (forward_b_sel == 2'b01) ? wb_value : id_ex_rs2_data;

    // ALU Operands
    wire [31:0] alu_op_a = fwd_val_a;
    wire [31:0] alu_op_b = (id_ex_alu_src) ? id_ex_imm : fwd_val_b;

    // ALU Execution
    reg [31:0] ex_alu_result;
    always @(*) begin
        ex_alu_result = 32'd0;
        branch_taken  = 1'b0;
        branch_target = id_ex_pc + id_ex_imm;

        case (id_ex_instr[6:0])
            7'b0110011: begin // R-Type
                case (id_ex_instr[14:12])
                    3'b000: ex_alu_result = (id_ex_instr[31:25] == 7'b0100000) ?
                                            (alu_op_a - alu_op_b) : (alu_op_a + alu_op_b);
                    3'b111: ex_alu_result = alu_op_a & alu_op_b;
                    3'b110: ex_alu_result = alu_op_a | alu_op_b;
                    3'b100: ex_alu_result = alu_op_a ^ alu_op_b;
                    3'b010: ex_alu_result = ($signed(alu_op_a) < $signed(alu_op_b)) ? 32'd1 : 32'd0;
                    default: ex_alu_result = 32'd0;
                endcase
            end

            7'b0010011: begin // ADDI / I-Type
                case (id_ex_instr[14:12])
                    3'b000: ex_alu_result = alu_op_a + alu_op_b;
                    3'b111: ex_alu_result = alu_op_a & alu_op_b;
                    3'b110: ex_alu_result = alu_op_a | alu_op_b;
                    3'b100: ex_alu_result = alu_op_a ^ alu_op_b;
                    default: ex_alu_result = alu_op_a + alu_op_b;
                endcase
            end

            7'b0000011: begin // LW
                ex_alu_result = alu_op_a + alu_op_b;
            end

            7'b0100011: begin // SW
                ex_alu_result = alu_op_a + alu_op_b;
            end

            7'b1100011: begin // BEQ
                if (id_ex_instr[14:12] == 3'b000)
                    branch_taken = (fwd_val_a == fwd_val_b);
            end

            default: ex_alu_result = 32'd0;
        endcase
    end

    // Register file read with WB-to-ID internal forwarding (bypass)
    wire [31:0] rf_rd1 = (id_rs1 == 5'd0) ? 32'd0 :
                         (mem_wb_reg_write && (mem_wb_rd == id_rs1)) ? wb_value :
                         registers[id_rs1];

    wire [31:0] rf_rd2 = (id_rs2 == 5'd0) ? 32'd0 :
                         (mem_wb_reg_write && (mem_wb_rd == id_rs2)) ? wb_value :
                         registers[id_rs2];

    // =========================================================================
    // 4. Synchronous Pipeline Register Clocking & Control
    // =========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'd0;

            if_id_instr <= 32'h00000013; // NOP (addi x0, x0, 0)
            if_id_pc    <= 32'd0;

            id_ex_instr      <= 32'h00000013;
            id_ex_pc         <= 32'd0;
            id_ex_rs1_data   <= 32'd0;
            id_ex_rs2_data   <= 32'd0;
            id_ex_imm        <= 32'd0;
            id_ex_rs1        <= 5'd0;
            id_ex_rs2        <= 5'd0;
            id_ex_rd         <= 5'd0;
            id_ex_reg_write  <= 1'b0;
            id_ex_mem_read   <= 1'b0;
            id_ex_mem_write  <= 1'b0;
            id_ex_mem_to_reg <= 1'b0;
            id_ex_alu_src    <= 1'b0;

            ex_mem_alu_result <= 32'd0;
            ex_mem_store_data <= 32'd0;
            ex_mem_rd         <= 5'd0;
            ex_mem_reg_write  <= 1'b0;
            ex_mem_mem_read   <= 1'b0;
            ex_mem_mem_write  <= 1'b0;
            ex_mem_mem_to_reg <= 1'b0;

            mem_wb_alu_result <= 32'd0;
            mem_wb_mem_data   <= 32'd0;
            mem_wb_rd         <= 5'd0;
            mem_wb_reg_write  <= 1'b0;
            mem_wb_mem_to_reg <= 1'b0;

            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'd0;

            cycle_count   <= 32'd0;
            instret_count <= 32'd0;
            stall_count   <= 32'd0;
            flush_count   <= 32'd0;

        end else begin
            // Performance Counters
            cycle_count <= cycle_count + 1'b1;
            if (stall_if)
                stall_count <= stall_count + 1'b1;
            if (branch_taken)
                flush_count <= flush_count + 1'b1;
            if (mem_wb_reg_write && mem_wb_rd != 5'd0)
                instret_count <= instret_count + 1'b1;

            // --- WB Stage ---
            if (mem_wb_reg_write && mem_wb_rd != 5'd0)
                registers[mem_wb_rd] <= wb_value;

            registers[0] <= 32'd0; // Strict hardwired x0=0

            // --- MEM Stage ---
            if (ex_mem_mem_write)
                data_mem[ex_mem_alu_result[7:2]] <= ex_mem_store_data;

            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_mem_data   <= ex_mem_mem_read ? data_mem[ex_mem_alu_result[7:2]] : 32'd0;
            mem_wb_rd         <= ex_mem_rd;
            mem_wb_reg_write  <= ex_mem_reg_write;
            mem_wb_mem_to_reg <= ex_mem_mem_to_reg;

            // --- EX Stage ---
            ex_mem_alu_result <= ex_alu_result;
            ex_mem_store_data <= fwd_val_b;
            ex_mem_rd         <= id_ex_rd;
            ex_mem_reg_write  <= id_ex_reg_write;
            ex_mem_mem_read   <= id_ex_mem_read;
            ex_mem_mem_write  <= id_ex_mem_write;
            ex_mem_mem_to_reg <= id_ex_mem_to_reg;

            // --- Control Hazard: Branch Taken (Flush IF and ID) ---
            if (branch_taken) begin
                pc <= branch_target;

                if_id_instr <= 32'h00000013; // Bubble
                if_id_pc    <= 32'd0;

                id_ex_instr      <= 32'h00000013; // Bubble
                id_ex_pc         <= 32'd0;
                id_ex_rs1_data   <= 32'd0;
                id_ex_rs2_data   <= 32'd0;
                id_ex_imm        <= 32'd0;
                id_ex_rs1        <= 5'd0;
                id_ex_rs2        <= 5'd0;
                id_ex_rd         <= 5'd0;
                id_ex_reg_write  <= 1'b0;
                id_ex_mem_read   <= 1'b0;
                id_ex_mem_write  <= 1'b0;
                id_ex_mem_to_reg <= 1'b0;
                id_ex_alu_src    <= 1'b0;
            end
            // --- Data Hazard: Load-Use Stall (Insert NOP bubble into EX, Hold PC and IF/ID) ---
            else if (stall_if) begin
                id_ex_instr      <= 32'h00000013; // Bubble into EX
                id_ex_pc         <= 32'd0;
                id_ex_rs1_data   <= 32'd0;
                id_ex_rs2_data   <= 32'd0;
                id_ex_imm        <= 32'd0;
                id_ex_rs1        <= 5'd0;
                id_ex_rs2        <= 5'd0;
                id_ex_rd         <= 5'd0;
                id_ex_reg_write  <= 1'b0;
                id_ex_mem_read   <= 1'b0;
                id_ex_mem_write  <= 1'b0;
                id_ex_mem_to_reg <= 1'b0;
                id_ex_alu_src    <= 1'b0;
            end
            // --- Normal Pipeline Advance ---
            else begin
                // ID Stage -> EX Stage (use WB-bypassed register reads)
                id_ex_instr      <= if_id_instr;
                id_ex_pc         <= if_id_pc;
                id_ex_rs1_data   <= rf_rd1;
                id_ex_rs2_data   <= rf_rd2;
                id_ex_imm        <= id_decoded_imm;
                id_ex_rs1        <= id_rs1;
                id_ex_rs2        <= id_rs2;
                id_ex_rd         <= id_rd;
                id_ex_reg_write  <= id_ctrl_reg_write;
                id_ex_mem_read   <= id_ctrl_mem_read;
                id_ex_mem_write  <= id_ctrl_mem_write;
                id_ex_mem_to_reg <= id_ctrl_mem_to_reg;
                id_ex_alu_src    <= id_ctrl_alu_src;

                // IF Stage -> ID Stage
                if_id_instr <= instruction_mem[pc[7:2]];
                if_id_pc    <= pc;
                pc          <= pc + 32'd4;
            end
        end
    end

endmodule
