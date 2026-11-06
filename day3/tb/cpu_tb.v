`timescale 1ns/1ps

// Activity 3.3: Comprehensive Self-Checking Testbench for RV32I CPU
// Executes Program 1 (Sum 1..N), Program 2 (Fibonacci), and Program 3 (Max Array)

module cpu_tb;

    reg clk;
    reg reset;

    wire [31:0] pc;
    wire [31:0] instr;
    wire [31:0] alu_result;
    wire [31:0] dmem_data;
    wire        reg_write;

    integer pass_count = 0;
    integer fail_count = 0;
    integer i;

    cpu uut (
        .clk(clk),
        .reset(reset),
        .pc_out(pc),
        .instr_out(instr),
        .alu_result_out(alu_result),
        .dmem_data_out(dmem_data),
        .reg_write_out(reg_write)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;

        $display("==============================================================");
        $display(" Starting Activity 3.3: RV32I Processor Self-Checking TB");
        $display("==============================================================");

        // =====================================================================
        // TEST 1: Execute Program 1 (Sum 1 to 10 = 55)
        // =====================================================================
        $display("\n--- Running Program 1: Sum(1..10) ---");
        $readmemh("src/program1_sum.hex", uut.imem);
        uut.dmem[0] = 32'd0;

        reset = 1;
        #20;
        @(posedge clk); #1;
        reset = 0;

        // Run for 90 cycles (enough to finish loop)
        repeat (90) @(posedge clk);
        #1;

        if (uut.dmem[0] === 32'd55 && uut.registers[2] === 32'd55) begin
            $display("[PASS] Program 1 (Sum 1..10): Result = %0d (0x%08h) stored at dmem[0]",
                     uut.dmem[0], uut.dmem[0]);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Program 1 failed! dmem[0] = %0d, x2 = %0d (expected 55)",
                     uut.dmem[0], uut.registers[2]);
            fail_count = fail_count + 1;
        end

        // =====================================================================
        // TEST 2: Execute Program 2 (Fibonacci Sequence: 0, 1, 1, 2, 3, 5, 8, 13)
        // =====================================================================
        $display("\n--- Running Program 2: Fibonacci Generator ---");
        $readmemh("src/program2_fib.hex", uut.imem);
        for (i = 0; i < 8; i = i + 1)
            uut.dmem[i] = 32'd0;

        reset = 1;
        #20;
        @(posedge clk); #1;
        reset = 0;

        // Run for 120 cycles
        repeat (120) @(posedge clk);
        #1;

        begin : fib_check
            reg [31:0] golden_fib [0:7];
            integer match;
            golden_fib[0] = 0; golden_fib[1] = 1; golden_fib[2] = 1; golden_fib[3] = 2;
            golden_fib[4] = 3; golden_fib[5] = 5; golden_fib[6] = 8; golden_fib[7] = 13;
            match = 1;

            for (i = 0; i < 8; i = i + 1) begin
                if (uut.dmem[i] !== golden_fib[i]) begin
                    match = 0;
                    $display("[FAIL] Fib[%0d]: got %0d, exp %0d", i, uut.dmem[i], golden_fib[i]);
                end
            end

            if (match) begin
                $display("[PASS] Program 2 (Fibonacci): First 8 terms verified in dmem[0..7]: 0, 1, 1, 2, 3, 5, 8, 13");
                pass_count = pass_count + 1;
            end else begin
                fail_count = fail_count + 1;
            end
        end

        // =====================================================================
        // TEST 3: Execute Program 3 (Find Maximum in Array [12, 45, 23, 78, 34])
        // =====================================================================
        $display("\n--- Running Program 3: Find Maximum in Array ---");
        $readmemh("src/program3_max.hex", uut.imem);
        uut.dmem[0]  = 32'd12;
        uut.dmem[1]  = 32'd45;
        uut.dmem[2]  = 32'd23;
        uut.dmem[3]  = 32'd78;
        uut.dmem[4]  = 32'd34;
        uut.dmem[25] = 32'd0;  // Destination for max at byte offset 100

        reset = 1;
        #20;
        @(posedge clk); #1;
        reset = 0;

        // Run for 100 cycles
        repeat (100) @(posedge clk);
        #1;

        if (uut.dmem[25] === 32'd78 && uut.registers[3] === 32'd78) begin
            $display("[PASS] Program 3 (Max Array): Found max value %0d correctly at dmem[25]",
                     uut.dmem[25]);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Program 3 failed! dmem[25] = %0d, x3 = %0d (expected 78)",
                     uut.dmem[25], uut.registers[3]);
            fail_count = fail_count + 1;
        end

        #20;
        $display("==============================================================");
        $display(" RV32I CPU Test Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display(" RESULT: ALL RISC-V CPU PROGRAMS PASSED! [PASS]");
        else
            $display(" RESULT: SOME TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule

