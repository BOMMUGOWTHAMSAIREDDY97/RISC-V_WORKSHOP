`timescale 1ns/1ps

// Activity 2.5: Self-Checking Testbench for Traffic Light Controller

module traffic_light_tb;

    reg clk;
    reg reset;
    reg ped_btn;

    wire main_red;
    wire main_yellow;
    wire main_green;
    wire ped_walk;
    wire ped_dont_walk;

    integer pass_count = 0;
    integer fail_count = 0;
    integer step;

    traffic_light #(
        .GREEN_TIME(6),
        .YELLOW_TIME(2),
        .RED_TIME(4)
    ) uut (
        .clk(clk),
        .reset(reset),
        .ped_btn(ped_btn),
        .main_red(main_red),
        .main_yellow(main_yellow),
        .main_green(main_green),
        .ped_walk(ped_walk),
        .ped_dont_walk(ped_dont_walk)
    );

    always #5 clk = ~clk;

    // Safety assertion monitor: Safety invariants must hold at EVERY clock edge
    always @(posedge clk) begin
        if (!reset) begin
            // Safety 1: Main Green and Main Red must never be active together
            if (main_green && main_red) begin
                $display("[FAIL] CRITICAL SAFETY VIOLATION: Main Green and Main Red both HIGH!");
                fail_count = fail_count + 1;
            end
            // Safety 2: Pedestrian Walk and Main Green must never be active together
            if (ped_walk && main_green) begin
                $display("[FAIL] CRITICAL SAFETY VIOLATION: Pedestrian Walk and Main Green both HIGH!");
                fail_count = fail_count + 1;
            end
            // Safety 3: Exactly one main light must be active
            if ((main_green + main_yellow + main_red) != 1) begin
                $display("[FAIL] Inconsistent light state!");
                fail_count = fail_count + 1;
            end
        end
    end

    initial begin
        clk     = 0;
        reset   = 1;
        ped_btn = 0;

        $display("==============================================================");
        $display(" Starting Activity 2.5: Traffic Light Controller Testbench");
        $display("==============================================================");

        #15;
        @(posedge clk); #1;
        reset = 0;

        // TEST 1: Initial state after reset should be Main GREEN
        @(posedge clk); #1;
        if (main_green === 1'b1 && ped_walk === 1'b0) begin
            $display("[PASS] Reset state: Main Green active, Pedestrian Walk inactive");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Initial state incorrect!");
            fail_count = fail_count + 1;
        end

        // TEST 2: Autonomous full cycle without pedestrian button
        $display("\nVerifying autonomous Green -> Yellow -> Red -> Green sequence...");
        // Green duration is 6 cycles
        repeat(5) @(posedge clk);
        #1;
        if (main_green === 1'b1) pass_count = pass_count + 1;

        // Transition into Yellow (cycle 6)
        @(posedge clk); #1;
        if (main_yellow === 1'b1) begin
            $display("[PASS] Transitioned to Yellow correctly.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Failed to enter Yellow!");
            fail_count = fail_count + 1;
        end

        // Yellow duration is 2 cycles -> Red
        repeat(2) @(posedge clk); #1;
        if (main_red === 1'b1 && ped_walk === 1'b1) begin
            $display("[PASS] Entered Red state: Pedestrian Walk is granted.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Failed to enter Red/Pedestrian Walk!");
            fail_count = fail_count + 1;
        end

        // Red duration is 4 cycles -> Green
        repeat(4) @(posedge clk); #1;
        if (main_green === 1'b1) begin
            $display("[PASS] Returned to Green state after Red timeout.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Failed to return to Green!");
            fail_count = fail_count + 1;
        end

        // TEST 3: Pedestrian Request Button interrupt
        $display("\nTesting Pedestrian Request Button assertion during Green...");
        @(posedge clk); #1;
        ped_btn = 1;
        @(posedge clk); #1;
        ped_btn = 0;

        // Wait until Yellow then Red
        repeat(4) @(posedge clk); #1;
        if (main_yellow === 1'b1 || main_red === 1'b1) begin
            $display("[PASS] Pedestrian button accelerated transition towards Red.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Pedestrian button did not initiate transition!");
            fail_count = fail_count + 1;
        end

        // Complete the pedestrian crossing cycle
        repeat(6) @(posedge clk); #1;
        if (main_green === 1'b1) begin
            $display("[PASS] Completed pedestrian crossing and restored normal traffic flow.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Failed to restore normal flow!");
            fail_count = fail_count + 1;
        end

        #20;
        $display("==============================================================");
        $display(" Traffic Light Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display(" RESULT: ALL TRAFFIC LIGHT TESTS PASSED! [PASS]");
        else
            $display(" RESULT: SOME TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule

