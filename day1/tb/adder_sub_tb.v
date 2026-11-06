`timescale 1ns/1ps

// Testbench for Activity 1.5: 8-bit Ripple-Carry Adder/Subtractor
// Compares structural generate-based design against behavioral '+' and '-' operators

module adder_sub_tb;

    localparam WIDTH = 8;

    reg  [WIDTH-1:0] a;
    reg  [WIDTH-1:0] b;
    reg              mode;
    wire [WIDTH-1:0] result;
    wire             carry_out;
    wire             overflow;

    integer pass_count = 0;
    integer fail_count = 0;
    integer test_num   = 0;
    integer iter;

    reg [WIDTH:0]   behav_ext;
    reg [WIDTH-1:0] exp_result;
    reg             exp_carry;
    reg             exp_overflow;
    reg [WIDTH-1:0] b_eff;

    adder_sub #(.WIDTH(WIDTH)) uut (
        .a(a),
        .b(b),
        .mode(mode),
        .result(result),
        .carry_out(carry_out),
        .overflow(overflow)
    );

    initial begin
        $display("==============================================================");
        $display(" Starting Activity 1.5: Adder/Subtractor Self-Checking TB");
        $display("==============================================================");

        // Run 512 test vectors (256 adds, 256 subs)
        for (iter = 0; iter < 512; iter = iter + 1) begin
            a    = $random;
            b    = $random;
            mode = (iter < 256) ? 1'b0 : 1'b1;

            #5;

            // Compute behavioral reference
            if (mode == 1'b0) begin
                behav_ext    = {1'b0, a} + {1'b0, b};
                exp_result   = behav_ext[WIDTH-1:0];
                exp_carry    = behav_ext[WIDTH];
                b_eff        = b;
                exp_overflow = (~(a[7] ^ b_eff[7])) & (a[7] ^ exp_result[7]);
            end else begin
                behav_ext    = {1'b0, a} + {1'b0, ~b} + 9'd1;
                exp_result   = behav_ext[WIDTH-1:0];
                exp_carry    = behav_ext[WIDTH];
                b_eff        = ~b;
                exp_overflow = (~(a[7] ^ b_eff[7])) & (a[7] ^ exp_result[7]);
            end

            test_num = test_num + 1;
            if ((result === exp_result) &&
                (carry_out === exp_carry) &&
                (overflow === exp_overflow)) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Op %0d (%0s): a=0x%02h, b=0x%02h -> res=0x%02h (exp 0x%02h) cout=%b/%b v=%b/%b",
                         test_num, (mode ? "SUB" : "ADD"), a, b, result, exp_result,
                         carry_out, exp_carry, overflow, exp_overflow);
                fail_count = fail_count + 1;
            end
        end

        #10;
        $display("==============================================================");
        $display(" Adder/Subtractor Results: %0d PASSED, %0d FAILED (Total %0d)", pass_count, fail_count, test_num);
        if (fail_count == 0)
            $display(" RESULT: ALL ADDER/SUBTRACTOR TESTS PASSED! [PASS]");
        else
            $display(" RESULT: SOME TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule

