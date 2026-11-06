`timescale 1ns/1ps

// Activity 1.8: Self-Checking Testbench for Debouncer and Edge Detector
// Verifies bounce rejection and precise single-cycle pulse generation.

module debounce_edge_tb;

    reg clk;
    reg reset;
    reg noisy_btn;

    wire debounced_btn;
    wire rise_pulse;
    wire fall_pulse;
    wire any_edge;

    integer pass_count = 0;
    integer fail_count = 0;
    integer rise_pulse_count = 0;
    integer fall_pulse_count = 0;

    // Instantiate debouncer with THRESHOLD = 5 clock cycles
    debounce #(.THRESHOLD(5)) uut_debounce (
        .clk(clk),
        .reset(reset),
        .noisy_in(noisy_btn),
        .debounced_out(debounced_btn)
    );

    // Instantiate edge detector connected to debounced signal
    edge_detect uut_edge_detect (
        .clk(clk),
        .reset(reset),
        .signal_in(debounced_btn),
        .rise_pulse(rise_pulse),
        .fall_pulse(fall_pulse),
        .any_edge(any_edge)
    );

    // Clock generator: 10ns period (100MHz)
    always #5 clk = ~clk;

    // Pulse monitors to track total number of generated edge pulses
    always @(posedge clk) begin
        if (!reset) begin
            if (rise_pulse) rise_pulse_count = rise_pulse_count + 1;
            if (fall_pulse) fall_pulse_count = fall_pulse_count + 1;
        end
    end

    initial begin
        clk       = 0;
        reset     = 1;
        noisy_btn = 0;

        $display("==============================================================");
        $display(" Starting Activity 1.8: Debounce & Edge Detector Testbench");
        $display("==============================================================");

        // Reset sequence
        #25;
        @(posedge clk); #1;
        reset = 0;
        @(posedge clk); #1;

        // Check initial state
        if (debounced_btn === 1'b0 && rise_pulse === 1'b0) begin
            $display("[PASS] Reset state: debounced_btn = 0, rise_pulse = 0");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Reset state incorrect!");
            fail_count = fail_count + 1;
        end

        // TEST 1: Short noise spikes (< threshold of 5 cycles) must be rejected
        $display("\nTest 1: Injecting noise spikes (< 5 cycles)...");
        noisy_btn = 1; #20; // 2 clock cycles
        noisy_btn = 0; #30; // 3 clock cycles
        noisy_btn = 1; #30; // 3 clock cycles
        noisy_btn = 0; #50; // 5 clock cycles idle

        if (debounced_btn === 1'b0 && rise_pulse_count == 0) begin
            $display("[PASS] Short noise spikes successfully rejected (no false trigger)");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] False trigger detected on noise spikes!");
            fail_count = fail_count + 1;
        end

        // TEST 2: Switch bounce on press followed by stable HIGH
        $display("\nTest 2: Switch contact bounce followed by stable press...");
        // Bounces for 2-3 cycles each
        noisy_btn = 1; #15;
        noisy_btn = 0; #10;
        noisy_btn = 1; #20;
        noisy_btn = 0; #15;
        // Now stable HIGH for 12 clock cycles (> 5 threshold cycles)
        noisy_btn = 1; #120;

        @(posedge clk); #1;
        if (debounced_btn === 1'b1) begin
            $display("[PASS] Debouncer asserted after stable press duration");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Debouncer failed to assert on stable press!");
            fail_count = fail_count + 1;
        end

        if (rise_pulse_count == 1) begin
            $display("[PASS] Exactly ONE rising edge pulse generated during noisy press");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Expected 1 rising pulse, got %0d!", rise_pulse_count);
            fail_count = fail_count + 1;
        end

        // TEST 3: Switch bounce on release followed by stable LOW
        $display("\nTest 3: Switch contact bounce on release...");
        // Bounces for 1-2 cycles
        noisy_btn = 0; #15;
        noisy_btn = 1; #10;
        noisy_btn = 0; #20;
        noisy_btn = 1; #10;
        // Now stable LOW for 12 clock cycles
        noisy_btn = 0; #120;

        @(posedge clk); #1;
        if (debounced_btn === 1'b0) begin
            $display("[PASS] Debouncer de-asserted after stable release duration");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Debouncer failed to de-assert on stable release!");
            fail_count = fail_count + 1;
        end

        if (fall_pulse_count == 1) begin
            $display("[PASS] Exactly ONE falling edge pulse generated during noisy release");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Expected 1 falling pulse, got %0d!", fall_pulse_count);
            fail_count = fail_count + 1;
        end

        #20;
        $display("==============================================================");
        $display(" Debounce & Edge Detect Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display(" RESULT: ALL DEBOUNCE & EDGE DETECT TESTS PASSED! [PASS]");
        else
            $display(" RESULT: SOME TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule

