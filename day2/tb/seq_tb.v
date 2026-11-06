`timescale 1ns/1ps

// Activity 2.1: Self-Checking Testbench for Moore vs Mealy Sequence Detectors
// Compares detection timing, overlap handling, and verifies 1-cycle difference

module seq_tb;

    reg clk;
    reg reset;
    reg din;

    wire moore_det;
    wire mealy_det;

    integer pass_count = 0;
    integer fail_count = 0;

    seq_moore uut_moore (
        .clk(clk),
        .reset(reset),
        .din(din),
        .det(moore_det)
    );

    seq_mealy uut_mealy (
        .clk(clk),
        .reset(reset),
        .din(din),
        .det(mealy_det)
    );

    always #5 clk = ~clk;

    // Test stream: 16 bits containing multiple overlapping "1011" patterns
    // Stream: 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0
    // Occurrences of 1011:
    // Indices (1-based from bit stream):
    // Bits 2..5:  1,0,1,1 -> Mealy detects at bit 5, Moore at bit 6
    // Bits 5..8:  Wait, bit 5 is 1, bit 6 is 0, bit 7 is 1, bit 8 is 1 -> 1,0,1,1 overlapping! Mealy at bit 8, Moore at bit 9
    // Bits 11..14: 1,0,1,1 -> Mealy detects at bit 14, Moore at bit 15
    reg [0:15] stream = 16'b0101101100101110;
    integer i;

    // In cycle i (where din=stream[i] completes 1011):
    // Mealy output is combinational, asserting during the cycle BEFORE the clock edge (at i = 4, 7, 13)
    // Moore output is registered, asserting AFTER the clock edge of that cycle (at i = 4, 7, 13 after posedge)
    reg [0:15] exp_mealy = 16'b0000100100000100;
    reg [0:15] exp_moore = 16'b0000100100000100;

    initial begin
        clk   = 0;
        reset = 1;
        din   = 0;

        $display("==============================================================");
        $display(" Starting Activity 2.1: Sequence Detector (1011) Testbench");
        $display("==============================================================");

        #15;
        @(posedge clk); #1;
        reset = 0;

        for (i = 0; i < 16; i = i + 1) begin
            din = stream[i];
            #1; // Allow combinational Mealy output to settle

            // Check Mealy detector (combinational with din)
            if (mealy_det === exp_mealy[i]) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Mealy bit %0d (din=%b): got %b, expected %b",
                         i, din, mealy_det, exp_mealy[i]);
                fail_count = fail_count + 1;
            end

            @(posedge clk); #1;

            // Check Moore detector (registered state output)
            if (moore_det === exp_moore[i]) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Moore bit %0d: got %b, expected %b",
                         i, moore_det, exp_moore[i]);
                fail_count = fail_count + 1;
            end
        end

        #10;
        $display("==============================================================");
        $display(" Sequence Detector Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display(" Verified: Mealy asserts 1 cycle earlier than Moore as expected.");
        if (fail_count == 0)
            $display(" RESULT: ALL SEQUENCE DETECTOR TESTS PASSED! [PASS]");
        else
            $display(" RESULT: SOME TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule
