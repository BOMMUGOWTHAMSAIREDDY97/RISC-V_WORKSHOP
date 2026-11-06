`timescale 1ns/1ps

// Day 3: Full-Featured Single-Cycle RV32I Processor
// Supports R-type, I-type, S-type, B-type (BEQ, BNE, BLT, BGE), U-type (LUI, AUIPC), J-type (JAL, JALR)

module cpu (
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] pc_out,
    output wire [31:0] instr_out,
    output wire [31:0] alu_result_out,
    output wire [31:0] dmem_data_out,
    output wire        reg_write_out
);

    // =========================================================================
    // 1. Program Counter (PC)
    // =========================================================================
    reg  [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4 = pc + 32'd4;

    assign pc_out = pc;

    // =========================================================================
    // 2. Instruction Memory (Internal 256-word RAM for programs)
    // =========================================================================
    reg [31:0] imem [0:255];
    wire [31:0] instr = imem[pc[9:2]];
    assign instr_out = instr;

    // =========================================================================
    // 3. Instruction Fields & Immediate Generation
    // =========================================================================
    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd     = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire [6:0] funct7 = instr[31:25];

    wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] imm_u = {instr[31:12], 12'b0};
    wire [31:0] imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

    // =========================================================================
    // 4. Control Unit & Decoder
    // =========================================================================
    reg       reg_write;
    reg       mem_write;
    reg       mem_read;
    reg       alu_src;     // 0: rs2, 1: immediate
    reg       branch_inst;
    reg       jump_inst;
    reg       jalr_inst;
    reg       lui_inst;
    reg       auipc_inst;
    reg [1:0] result_src;  // 0: ALU, 1: Mem, 2: PC+4, 3: U-Immediate
    reg [3:0] alu_ctrl;

    assign reg_write_out = reg_write;

    always @(*) begin
        reg_write   = 1'b0;
        mem_write   = 1'b0;
        mem_read    = 1'b0;
        alu_src     = 1'b0;
        branch_inst = 1'b0;
        jump_inst   = 1'b0;
        jalr_inst   = 1'b0;
        lui_inst    = 1'b0;
        auipc_inst  = 1'b0;
        result_src  = 2'b00;
        alu_ctrl    = 4'b0000;

        case (opcode)
            7'b0110011: begin // R-Type
                reg_write  = 1'b1;
                alu_src    = 1'b0;
                result_src = 2'b00;
                case (funct3)
                    3'b000: alu_ctrl = (funct7[5]) ? 4'b0001 : 4'b0000; // SUB : ADD
                    3'b001: alu_ctrl = 4'b0110;                         // SLL
                    3'b010: alu_ctrl = 4'b0101;                         // SLT
                    3'b100: alu_ctrl = 4'b0100;                         // XOR
                    3'b101: alu_ctrl = (funct7[5]) ? 4'b1000 : 4'b0111; // SRA : SRL
                    3'b110: alu_ctrl = 4'b0011;                         // OR
                    3'b111: alu_ctrl = 4'b0010;                         // AND
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            7'b0010011: begin // I-Type Arithmetic
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                result_src = 2'b00;
                case (funct3)
                    3'b000: alu_ctrl = 4'b0000;                         // ADDI
                    3'b001: alu_ctrl = 4'b0110;                         // SLLI
                    3'b010: alu_ctrl = 4'b0101;                         // SLTI
                    3'b100: alu_ctrl = 4'b0100;                         // XORI
                    3'b101: alu_ctrl = (funct7[5]) ? 4'b1000 : 4'b0111; // SRAI : SRLI
                    3'b110: alu_ctrl = 4'b0011;                         // ORI
                    3'b111: alu_ctrl = 4'b0010;                         // ANDI
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            7'b0000011: begin // Load (LW)
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_read   = 1'b1;
                result_src = 2'b01; // From Data Memory
                alu_ctrl   = 4'b0000; // ADD (rs1 + offset)
            end

            7'b0100011: begin // Store (SW)
                mem_write = 1'b1;
                alu_src   = 1'b1;
                alu_ctrl  = 4'b0000; // ADD (rs1 + offset)
            end

            7'b1100011: begin // Branch (BEQ, BNE, BLT, BGE)
                branch_inst = 1'b1;
                alu_src     = 1'b0;
                alu_ctrl    = 4'b0001; // SUB for comparison
            end

            7'b1101111: begin // JAL
                reg_write  = 1'b1;
                jump_inst  = 1'b1;
                result_src = 2'b10; // PC + 4
            end

            7'b1100111: begin // JALR
                reg_write  = 1'b1;
                jump_inst  = 1'b1;
                jalr_inst  = 1'b1;
                alu_src    = 1'b1;
                result_src = 2'b10; // PC + 4
                alu_ctrl   = 4'b0000;
            end

            7'b0110111: begin // LUI
                reg_write  = 1'b1;
                lui_inst   = 1'b1;
                result_src = 2'b11; // Imm_U directly
            end

            7'b0010111: begin // AUIPC
                reg_write  = 1'b1;
                auipc_inst = 1'b1;
                result_src = 2'b00; // ALU computes PC + imm_u
                alu_ctrl   = 4'b0000;
            end

            default: ;
        endcase
    end

    // =========================================================================
    // 5. Register File (32 x 32-bit, x0 hardwired to 0)
    // =========================================================================
    reg [31:0] registers [0:31];
    wire [31:0] reg_rd1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    wire [31:0] reg_rd2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];
    wire [31:0] writeback_data;

    integer r;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (r = 0; r < 32; r = r + 1)
                registers[r] <= 32'd0;
        end else if (reg_write && rd != 5'd0) begin
            registers[rd] <= writeback_data;
        end
    end

    // =========================================================================
    // 6. ALU & Operand Multiplexing
    // =========================================================================
    wire [31:0] alu_op_a = (auipc_inst) ? pc : reg_rd1;
    wire [31:0] immediate = (opcode == 7'b0100011) ? imm_s :
                            (opcode == 7'b1100011) ? imm_b :
                            (opcode == 7'b0110111 || opcode == 7'b0010111) ? imm_u :
                            (opcode == 7'b1101111) ? imm_j : imm_i;

    wire [31:0] alu_op_b = (alu_src) ? immediate : reg_rd2;

    reg [31:0] alu_result;
    always @(*) begin
        case (alu_ctrl)
            4'b0000: alu_result = alu_op_a + alu_op_b;                        // ADD
            4'b0001: alu_result = alu_op_a - alu_op_b;                        // SUB
            4'b0010: alu_result = alu_op_a & alu_op_b;                        // AND
            4'b0011: alu_result = alu_op_a | alu_op_b;                        // OR
            4'b0100: alu_result = alu_op_a ^ alu_op_b;                        // XOR
            4'b0101: alu_result = ($signed(alu_op_a) < $signed(alu_op_b)) ? 32'd1 : 32'd0; // SLT
            4'b0110: alu_result = alu_op_a << alu_op_b[4:0];                  // SLL
            4'b0111: alu_result = alu_op_a >> alu_op_b[4:0];                  // SRL
            4'b1000: alu_result = $signed(alu_op_a) >>> alu_op_b[4:0];         // SRA
            default: alu_result = 32'd0;
        endcase
    end
    assign alu_result_out = alu_result;

    // =========================================================================
    // 7. Branch Condition Evaluator
    // =========================================================================
    reg branch_taken;
    always @(*) begin
        branch_taken = 1'b0;
        if (branch_inst) begin
            case (funct3)
                3'b000: branch_taken = (reg_rd1 == reg_rd2);                   // BEQ
                3'b001: branch_taken = (reg_rd1 != reg_rd2);                   // BNE
                3'b100: branch_taken = ($signed(reg_rd1) < $signed(reg_rd2));  // BLT
                3'b101: branch_taken = ($signed(reg_rd1) >= $signed(reg_rd2)); // BGE
                3'b110: branch_taken = (reg_rd1 < reg_rd2);                   // BLTU
                3'b111: branch_taken = (reg_rd1 >= reg_rd2);                  // BGEU
                default: branch_taken = 1'b0;
            endcase
        end
    end

    // Next PC computation
    wire [31:0] branch_target = pc + imm_b;
    wire [31:0] jal_target    = pc + imm_j;
    wire [31:0] jalr_target   = (reg_rd1 + imm_i) & ~32'd1;

    assign pc_next = (jalr_inst)    ? jalr_target :
                     (jump_inst)    ? jal_target :
                     (branch_taken) ? branch_target : pc_plus_4;

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'd0;
        else
            pc <= pc_next;
    end

    // =========================================================================
    // 8. Data Memory (Internal 256-word Synchronous RAM)
    // =========================================================================
    reg [31:0] dmem [0:255];
    always @(posedge clk) begin
        if (mem_write)
            dmem[alu_result[9:2]] <= reg_rd2;
    end

    wire [31:0] dmem_rdata = dmem[alu_result[9:2]];
    assign dmem_data_out = dmem_rdata;

    // =========================================================================
    // 9. Writeback Multiplexer
    // =========================================================================
    assign writeback_data = (result_src == 2'b00) ? alu_result :
                            (result_src == 2'b01) ? dmem_rdata :
                            (result_src == 2'b10) ? pc_plus_4 :
                            (result_src == 2'b11) ? imm_u : 32'd0;

endmodule

