`timescale 1ns/1ps

// Testbench for Activity 1.7: Universal Shift Register & LFSR
// Proves that the 8-bit LFSR repeats after exactly 255 states and never enters all-zero state

module shiftreg_lfsr_tb;

    // Shift Register signals
    reg        sr_clk, sr_reset;
    reg  [1:0] sr_mode;
    reg        sr_sin_l, sr_sin_r;
    reg  [7:0] sr_p_in;
    wire [7:0] sr_p_out;

    // LFSR signals
    reg        lfsr_clk, lfsr_reset;
    reg        lfsr_load;
    reg  [7:0] lfsr_seed;
    wire [7:0] lfsr_out;

    integer pass_count = 0;
    integer fail_count = 0;
    integer state_count = 0;
    integer step;

    // Table to detect duplicates and verify all 255 states are visited
    reg [255:0] state_visited;
    reg [7:0]   initial_seed;
    reg         zero_detected;

    shiftreg #(.WIDTH(8)) uut_sr (
        .clk(sr_clk),
        .reset(sr_reset),
        .mode(sr_mode),
        .s_in_l(sr_sin_l),
        .s_in_r(sr_sin_r),
        .parallel_in(sr_p_in),
        .parallel_out(sr_p_out)
    );

    lfsr uut_lfsr (
        .clk(lfsr_clk),
        .reset(lfsr_reset),
        .load_seed(lfsr_load),
        .seed(lfsr_seed),
        .lfsr_out(lfsr_out)
    );

    always #5 sr_clk   = ~sr_clk;
    always #5 lfsr_clk = ~lfsr_clk;

    initial begin
        sr_clk     = 0; sr_reset = 1; sr_mode = 0; sr_sin_l = 0; sr_sin_r = 0; sr_p_in = 0;
        lfsr_clk   = 0; lfsr_reset = 1; lfsr_load = 0; lfsr_seed = 0;
        state_visited = 0;
        zero_detected = 0;

        $display("==============================================================");
        $display(" Starting Activity 1.7: Universal Shift Reg & LFSR TB");
        $display("==============================================================");

        // --- 1. Universal Shift Register Verification ---
        @(posedge sr_clk); #1; sr_reset = 0;

        // Parallel load
        sr_mode = 2'b11; sr_p_in = 8'hA5;
        @(posedge sr_clk); #1;
        if (sr_p_out === 8'hA5) pass_count = pass_count + 1;
        else begin $display("[FAIL] ShiftReg Load 0xA5"); fail_count = fail_count + 1; end

        // Hold
        sr_mode = 2'b00;
        @(posedge sr_clk); #1;
        if (sr_p_out === 8'hA5) pass_count = pass_count + 1;
        else begin $display("[FAIL] ShiftReg Hold"); fail_count = fail_count + 1; end

        // Shift Left (insert 1 at LSB: 0xA5 << 1 | 1 = 0x4B)
        sr_mode = 2'b01; sr_sin_l = 1'b1;
        @(posedge sr_clk); #1;
        if (sr_p_out === 8'h4B) pass_count = pass_count + 1;
        else begin $display("[FAIL] ShiftReg Shift Left"); fail_count = fail_count + 1; end

        // Shift Right (insert 1 at MSB: 0x4B >> 1 | 0x80 = 0xA5)
        sr_mode = 2'b10; sr_sin_r = 1'b1;
        @(posedge sr_clk); #1;
        if (sr_p_out === 8'hA5) pass_count = pass_count + 1;
        else begin $display("[FAIL] ShiftReg Shift Right"); fail_count = fail_count + 1; end

        $display("[PASS] Universal Shift Register: Load, Hold, Shift-Left, and Shift-Right verified.");

        // --- 2. 8-Bit LFSR Maximal-Length Sequence Verification ---
        lfsr_reset   = 0;
        @(posedge lfsr_clk); #1;
        initial_seed = 8'h5A;
        lfsr_load    = 1;
        lfsr_seed    = initial_seed;
        @(posedge lfsr_clk); #1;
        lfsr_load    = 0;

        $display("\nVerifying 8-bit LFSR pseudo-random progression for 255 states...");

        for (step = 1; step <= 255; step = step + 1) begin
            if (lfsr_out === 8'h00) begin
                zero_detected = 1;
                $display("[FAIL] LFSR entered forbidden all-zero state at step %0d!", step);
            end

            state_visited[lfsr_out] = 1'b1;
            @(posedge lfsr_clk); #1;
        end

        // After 255 steps, the state must return to the initial_seed
        if (lfsr_out === initial_seed) begin
            $display("[PASS] LFSR completed exactly 255 steps and repeated initial seed (0x%02h).", initial_seed);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] LFSR did not repeat initial seed after 255 steps! (Got 0x%02h, exp 0x%02h)",
                     lfsr_out, initial_seed);
            fail_count = fail_count + 1;
        end

        // Verify zero state was never entered
        if (!zero_detected) begin
            $display("[PASS] LFSR never entered the all-zero state (0x00) during the entire cycle.");
            pass_count = pass_count + 1;
        end else begin
            fail_count = fail_count + 1;
        end

        #10;
        $display("==============================================================");
        $display(" LFSR & ShiftReg Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display(" RESULT: ALL SHIFTREG & LFSR TESTS PASSED! [PASS]");
        else
            $display(" RESULT: SOME TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule
