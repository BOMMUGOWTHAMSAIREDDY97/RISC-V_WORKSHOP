`timescale 1ns/1ps

// Activity 2.7: Self-Checking Testbench for 4-Way Round-Robin Arbiter

module arbiter_tb;

    reg        clk;
    reg        reset;
    reg  [3:0] req;
    wire [3:0] grant;

    integer pass_count = 0;
    integer fail_count = 0;

    arbiter uut (
        .clk(clk),
        .reset(reset),
        .req(req),
        .grant(grant)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        req   = 4'b0000;

        $display("==============================================================");
        $display(" Starting Activity 2.7: 4-Way Round-Robin Arbiter Testbench");
        $display("==============================================================");

        #15;
        @(posedge clk); #1;
        reset = 0;

        // TEST 1: Individual isolated requests
        $display("\nTest 1: Testing individual isolated requests...");
        req = 4'b0001; @(posedge clk); #1;
        if (grant === 4'b0001) pass_count = pass_count + 1;
        else begin $display("[FAIL] Req 0 grant failed"); fail_count = fail_count + 1; end

        req = 4'b0100; @(posedge clk); #1;
        if (grant === 4'b0100) pass_count = pass_count + 1;
        else begin $display("[FAIL] Req 2 grant failed"); fail_count = fail_count + 1; end

        // TEST 2: Full Contention (All 4 Requesters assert 4'b1111 continuously)
        // Must rotate: 0 -> 1 -> 2 -> 3 -> 0
        $display("\nTest 2: Full contention (all 4 agents requesting simultaneously)...");
        // Reset to align to known priority 0
        reset = 1; @(posedge clk); #1; reset = 0;

        req = 4'b1111;
        @(posedge clk); #1;
        if (grant === 4'b0001) begin
            $display("[PASS] Cycle 1: Grant -> Agent 0 (4'b0001)");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Cycle 1: Expected Agent 0, got %b", grant);
            fail_count = fail_count + 1;
        end

        @(posedge clk); #1;
        if (grant === 4'b0010) begin
            $display("[PASS] Cycle 2: Grant -> Agent 1 (4'b0010)");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Cycle 2: Expected Agent 1, got %b", grant);
            fail_count = fail_count + 1;
        end

        @(posedge clk); #1;
        if (grant === 4'b0100) begin
            $display("[PASS] Cycle 3: Grant -> Agent 2 (4'b0100)");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Cycle 3: Expected Agent 2, got %b", grant);
            fail_count = fail_count + 1;
        end

        @(posedge clk); #1;
        if (grant === 4'b1000) begin
            $display("[PASS] Cycle 4: Grant -> Agent 3 (4'b1000)");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Cycle 4: Expected Agent 3, got %b", grant);
            fail_count = fail_count + 1;
        end

        // Rotation back to Agent 0
        @(posedge clk); #1;
        if (grant === 4'b0001) begin
            $display("[PASS] Cycle 5: Grant rotated back -> Agent 0 (4'b0001)");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Cycle 5: Expected Agent 0, got %b", grant);
            fail_count = fail_count + 1;
        end

        // TEST 3: Partial contention (Agent 1 and Agent 3 only)
        $display("\nTest 3: Partial contention between Agent 1 and Agent 3...");
        req = 4'b1010;
        @(posedge clk); #1;
        if (grant === 4'b0010) pass_count = pass_count + 1;
        @(posedge clk); #1;
        if (grant === 4'b1000) pass_count = pass_count + 1;
        @(posedge clk); #1;
        if (grant === 4'b0010) pass_count = pass_count + 1;

        #20;
        $display("==============================================================");
        $display(" Arbiter Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display(" RESULT: ALL ROUND-ROBIN ARBITER TESTS PASSED! [PASS]");
        else
            $display(" RESULT: SOME TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule

