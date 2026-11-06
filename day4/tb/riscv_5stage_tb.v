`timescale 1ns/1ps

// Activity 4.1, 4.2, 4.6: Self-Checking Testbench for 5-Stage Pipelined RV32I Processor
// Exercises:
// 1. RAW EX-to-EX forwarding
// 2. RAW MEM-to-EX forwarding
// 3. Load-Use hazard detection and 1-cycle stall bubble insertion
// 4. Branch resolution and speculative instruction flush
// 5. Hardware performance counters & CPI calculation

module riscv_5stage_tb;

    reg clk;
    reg reset;

    wire [31:0] pc;
    wire [31:0] cycle_count;
    wire [31:0] instret_count;
    wire [31:0] stall_count;
    wire [31:0] flush_count;

    integer pass_count = 0;
    integer fail_count = 0;
    integer k;

    riscv_5stage dut (
        .clk(clk),
        .reset(reset),
        .pc_out(pc),
        .cycle_count_out(cycle_count),
        .instret_count_out(instret_count),
        .stall_count_out(stall_count),
        .flush_count_out(flush_count)
    );

    always #5 clk = ~clk;

    // Helper instruction encoders
    function [31:0] enc_i(input integer imm, rs1, funct3, rd, input [6:0] op);
        enc_i = {imm[11:0], rs1[4:0], funct3[2:0], rd[4:0], op};
    endfunction

    function [31:0] enc_r(input integer funct7, rs2, rs1, funct3, rd, input [6:0] op);
        enc_r = {funct7[6:0], rs2[4:0], rs1[4:0], funct3[2:0], rd[4:0], op};
    endfunction

    function [31:0] enc_s(input integer imm, rs2, rs1, funct3, input [6:0] op);
        enc_s = {imm[11:5], rs2[4:0], rs1[4:0], funct3[2:0], imm[4:0], op};
    endfunction

    function [31:0] enc_b(input integer offset, rs2, rs1, funct3, input [6:0] op);
        reg [12:0] b;
        begin
            b = offset;
            enc_b = {b[12], b[10:5], rs2[4:0], rs1[4:0], funct3[2:0], b[4:1], b[11], op};
        end
    endfunction

    initial begin
        clk   = 0;
        reset = 1;

        $display("==============================================================");
        $display(" Starting Day 4: 5-Stage Pipelined RV32I Processor TB");
        $display("==============================================================");

        // Clear memories
        for (k = 0; k < 64; k = k + 1) begin
            dut.instruction_mem[k] = 32'h00000013; // NOP
            dut.data_mem[k]        = 32'd0;
        end

        // -------------------------------------------------------------
        // Instruction Sequence exercising all hazards:
        // -------------------------------------------------------------
        // 0: ADDI x1, x0, 5        (x1 = 5)
        dut.instruction_mem[0] = enc_i(5, 0, 0, 1, 7'b0010011);

        // 1: ADDI x2, x0, 7        (x2 = 7)
        dut.instruction_mem[1] = enc_i(7, 0, 0, 2, 7'b0010011);

        // 2: ADD x3, x1, x2        (x3 = 5 + 7 = 12) -> RAW dependency on x1, x2 (Forwarding)
        dut.instruction_mem[2] = enc_r(0, 2, 1, 0, 3, 7'b0110011);

        // 3: SUB x4, x3, x1        (x4 = 12 - 5 = 7) -> EX-to-EX forwarding of x3 from instr 2!
        dut.instruction_mem[3] = enc_r(7'b0100000, 1, 3, 0, 4, 7'b0110011);

        // 4: SW x3, 0(x0)          (MEM[0] = 12)
        dut.instruction_mem[4] = enc_s(0, 3, 0, 2, 7'b0100011);

        // 5: LW x5, 0(x0)          (x5 = MEM[0] = 12)
        dut.instruction_mem[5] = enc_i(0, 0, 2, 5, 7'b0000011);

        // 6: ADD x8, x5, x1        (x8 = 12 + 5 = 17) -> LOAD-USE HAZARD on x5! (Requires 1 stall cycle)
        dut.instruction_mem[6] = enc_r(0, 1, 5, 0, 8, 7'b0110011);

        // 7: BEQ x4, x2, 8         (7 == 7 -> Branch taken to PC+8, skip instr 8)
        dut.instruction_mem[7] = enc_b(8, 2, 4, 0, 7'b1100011);

        // 8: ADDI x6, x0, 99       (Must be FLUSHED by branch!)
        dut.instruction_mem[8] = enc_i(99, 0, 0, 6, 7'b0010011);

        // 9: ADDI x7, x0, 11       (Branch target: x7 = 11)
        dut.instruction_mem[9] = enc_i(11, 0, 0, 7, 7'b0010011);

        #15;
        @(posedge clk); #1;
        reset = 0;

        // Run until pipeline completes all instructions
        repeat (28) @(posedge clk);
        #1;

        $display("\n==============================================================");
        $display(" 5-STAGE PIPELINE REGISTER & MEMORY AUDIT");
        $display("==============================================================");
        $display(" x1 (ADDI 5)      = %0d (Expected: 5)", dut.registers[1]);
        $display(" x2 (ADDI 7)      = %0d (Expected: 7)", dut.registers[2]);
        $display(" x3 (ADD x1,x2)   = %0d (Expected: 12 - Forwarded)", dut.registers[3]);
        $display(" x4 (SUB x3,x1)   = %0d (Expected: 7  - EX-to-EX Forwarded)", dut.registers[4]);
        $display(" x5 (LW MEM[0])   = %0d (Expected: 12)", dut.registers[5]);
        $display(" x8 (ADD x5,x1)   = %0d (Expected: 17 - Load-Use Stall Handled)", dut.registers[8]);
        $display(" x6 (Skipped)     = %0d (Expected: 0  - Flushed by Branch)", dut.registers[6]);
        $display(" x7 (Target)      = %0d (Expected: 11)", dut.registers[7]);
        $display(" DMEM[0]          = %0d (Expected: 12)", dut.data_mem[0]);

        // Self-checking assertions
        if (dut.registers[1] === 32'd5  &&
            dut.registers[2] === 32'd7  &&
            dut.registers[3] === 32'd12 &&
            dut.registers[4] === 32'd7  &&
            dut.registers[5] === 32'd12 &&
            dut.registers[8] === 32'd17 &&
            dut.registers[6] === 32'd0  &&
            dut.registers[7] === 32'd11 &&
            dut.data_mem[0]  === 32'd12) begin
            $display("\n[PASS] All registers and memory state match expected golden values!");
            pass_count = pass_count + 1;
        end else begin
            $display("\n[FAIL] Functional mismatch detected in registers/memory!");
            fail_count = fail_count + 1;
        end

        // Hazard & Performance Counter checks
        if (dut.stall_count > 0) begin
            $display("[PASS] Load-Use Hazard Unit successfully inserted stall bubble (%0d stall cycle(s))",
                     dut.stall_count);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] No stall cycles recorded for load-use hazard!");
            fail_count = fail_count + 1;
        end

        if (dut.flush_count > 0) begin
            $display("[PASS] Branch Control Unit successfully flushed speculative instruction (%0d flush(es))",
                     dut.flush_count);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] No branch flush recorded!");
            fail_count = fail_count + 1;
        end

        // Check x6 was never updated (proving flush succeeded)
        if (dut.registers[6] === 32'd0) begin
            $display("[PASS] Register x6 remained 0: speculative ADDI was cleanly eliminated.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Speculative instruction leaked into pipeline! x6 = %0d", dut.registers[6]);
            fail_count = fail_count + 1;
        end

        #10;
        $display("\n==============================================================");
        $display(" HARDWARE PERFORMANCE COUNTERS & CPI REPORT");
        $display("==============================================================");
        $display(" Total Clock Cycles      : %0d", cycle_count);
        $display(" Instructions Retired    : %0d", instret_count);
        $display(" Load-Use Stall Cycles   : %0d", stall_count);
        $display(" Branch Flush Events     : %0d", flush_count);
        $display(" Effective Pipeline CPI  : %0.2f", (1.0 * cycle_count) / instret_count);
        $display("==============================================================");
        $display(" 5-Stage Pipeline Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display(" RESULT: ALL 5-STAGE PIPELINE TESTS PASSED! [PASS]");
        else
            $display(" RESULT: SOME TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule

