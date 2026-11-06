`timescale 1ns/1ps

// Testbench for Activity 1.2: 8-bit Up/Down Counter

module counter_tb;

    localparam WIDTH = 8;

    reg              clk;
    reg              reset;
    reg              enable;
    reg              up_down;
    reg              load;
    reg  [WIDTH-1:0] load_data;
    wire [WIDTH-1:0] count;

    integer pass_count = 0;
    integer fail_count = 0;
    integer test_num   = 0;

    // Instantiate Counter
    counter #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .up_down(up_down),
        .load(load),
        .load_data(load_data),
        .count(count)
    );

    // Clock generator: 10 ns period
    always #5 clk = ~clk;

    task check_count;
        input [WIDTH-1:0] exp_count;
        input [127:0]     test_name;
        begin
            test_num = test_num + 1;
            if (count === exp_count) begin
                $display("[PASS] Test %02d (%0s): count = 0x%02h", test_num, test_name, count);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Test %02d (%0s): count = 0x%02h (expected 0x%02h)", test_num, test_name, count, exp_count);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        clk       = 0;
        reset     = 1;
        enable    = 0;
        up_down   = 1;
        load      = 0;
        load_data = 8'h00;

        $display("==============================================================");
        $display("     Starting Activity 1.2: Up/Down Counter Self-Checking TB");
        $display("==============================================================");

        // 1. Synchronous Reset Test
        @(posedge clk);
        #1;
        check_count(8'h00, "Synchronous Reset");

        // 2. Parallel Load Test
        reset     = 0;
        load      = 1;
        load_data = 8'hA5;
        @(posedge clk);
        #1;
        check_count(8'hA5, "Parallel Load 0xA5");

        // 3. Counter Disabled Test
        load   = 0;
        enable = 0;
        @(posedge clk);
        #1;
        check_count(8'hA5, "Counter Disabled (Hold Value)");

        // 4. Count Up Tests (A5 -> A6 -> A7)
        enable  = 1;
        up_down = 1;
        @(posedge clk); #1; check_count(8'hA6, "Count Up 1");
        @(posedge clk); #1; check_count(8'hA7, "Count Up 2");
        @(posedge clk); #1; check_count(8'hA8, "Count Up 3");

        // 5. Count Down Tests (A8 -> A7 -> A6)
        up_down = 0;
        @(posedge clk); #1; check_count(8'hA7, "Count Down 1");
        @(posedge clk); #1; check_count(8'hA6, "Count Down 2");
        @(posedge clk); #1; check_count(8'hA5, "Count Down 3");

        // 6. Rollover Up Test (Load 0xFE -> 0xFF -> 0x00)
        load      = 1;
        load_data = 8'hFE;
        @(posedge clk);
        #1;
        load    = 0;
        up_down = 1;
        check_count(8'hFE, "Load 0xFE");
        @(posedge clk); #1; check_count(8'hFF, "Count Up to 0xFF");
        @(posedge clk); #1; check_count(8'h00, "Rollover Up to 0x00");

        // 7. Rollover Down Test (0x00 -> 0xFF)
        up_down = 0;
        @(posedge clk); #1; check_count(8'hFF, "Rollover Down to 0xFF");
        @(posedge clk); #1; check_count(8'hFE, "Count Down from 0xFF");

        // 8. Synchronous Reset Override while counting
        reset = 1;
        @(posedge clk); #1; check_count(8'h00, "Reset Priority over Enable");

        #10;
        $display("==============================================================");
        $display(" Counter Test Results: %0d PASSED, %0d FAILED (Total %0d)", pass_count, fail_count, test_num);
        if (fail_count == 0)
            $display(" RESULT: ALL TESTS PASSED SUCCESSFULLY! [PASS]");
        else
            $display(" RESULT: SOME TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule

