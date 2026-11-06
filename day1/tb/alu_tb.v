`timescale 1ns/1ps

// Testbench for Activity 1.1: Parameterized ALU
// Includes >= 25 self-checking test vectors with corner cases

module alu_tb;

    localparam WIDTH = 32;

    reg  [WIDTH-1:0] a;
    reg  [WIDTH-1:0] b;
    reg  [3:0]       alu_ctrl;
    wire [WIDTH-1:0] result;
    wire             zero;
    wire             negative;
    wire             carry;
    wire             overflow;

    integer pass_count = 0;
    integer fail_count = 0;
    integer test_num   = 0;

    // Instantiate ALU
    alu #(.WIDTH(WIDTH)) uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero),
        .negative(negative),
        .carry(carry),
        .overflow(overflow)
    );

    // ALU Control Constants
    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_XOR = 4'b0100;
    localparam ALU_SLT = 4'b0101;
    localparam ALU_SLL = 4'b0110;
    localparam ALU_SRL = 4'b0111;

    task check_alu;
        input [WIDTH-1:0] exp_result;
        input             exp_zero;
        input             exp_negative;
        input             exp_carry;
        input             exp_overflow;
        input [127:0]     test_name;
        begin
            test_num = test_num + 1;
            #5;
            if ((result === exp_result) &&
                (zero === exp_zero) &&
                (negative === exp_negative) &&
                (carry === exp_carry) &&
                (overflow === exp_overflow)) begin
                $display("[PASS] Test %02d (%0s): a=0x%08h, b=0x%08h -> res=0x%08h [Z=%b N=%b C=%b V=%b]",
                         test_num, test_name, a, b, result, zero, negative, carry, overflow);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Test %02d (%0s): a=0x%08h, b=0x%08h -> res=0x%08h (exp 0x%08h) [Z=%b/%b N=%b/%b C=%b/%b V=%b/%b]",
                         test_num, test_name, a, b, result, exp_result,
                         zero, exp_zero, negative, exp_negative, carry, exp_carry, overflow, exp_overflow);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $display("==============================================================");
        $display("       Starting Activity 1.1: Parameterized ALU Self-Checking TB");
        $display("==============================================================");

        // --- ADD Tests ---
        // 1. Simple addition
        a = 32'd15; b = 32'd25; alu_ctrl = ALU_ADD;
        check_alu(32'd40, 1'b0, 1'b0, 1'b0, 1'b0, "ADD Simple");

        // 2. Add yielding zero
        a = 32'd0; b = 32'd0; alu_ctrl = ALU_ADD;
        check_alu(32'd0, 1'b1, 1'b0, 1'b0, 1'b0, "ADD Zero Result");

        // 3. Unsigned carry-out corner case
        a = 32'hFFFF_FFFF; b = 32'd1; alu_ctrl = ALU_ADD;
        check_alu(32'd0, 1'b1, 1'b0, 1'b1, 1'b0, "ADD Max Value Overflow to Zero");

        // 4. Positive signed overflow (0x7FFFFFFF + 1 = 0x80000000)
        a = 32'h7FFF_FFFF; b = 32'd1; alu_ctrl = ALU_ADD;
        check_alu(32'h8000_0000, 1'b0, 1'b1, 1'b0, 1'b1, "ADD Positive Overflow");

        // 5. Negative signed overflow (0x80000000 + 0x80000000 = 0x00000000 with V=1)
        a = 32'h8000_0000; b = 32'h8000_0000; alu_ctrl = ALU_ADD;
        check_alu(32'h0000_0000, 1'b1, 1'b0, 1'b1, 1'b1, "ADD Negative Overflow");

        // --- SUB Tests ---
        // 6. Simple subtraction
        a = 32'd50; b = 32'd20; alu_ctrl = ALU_SUB;
        check_alu(32'd30, 1'b0, 1'b0, 1'b0, 1'b0, "SUB Simple");

        // 7. Subtraction to zero
        a = 32'd100; b = 32'd100; alu_ctrl = ALU_SUB;
        check_alu(32'd0, 1'b1, 1'b0, 1'b0, 1'b0, "SUB Equal to Zero");

        // 8. Negative result with borrow
        a = 32'd10; b = 32'd20; alu_ctrl = ALU_SUB;
        check_alu(-32'd10, 1'b0, 1'b1, 1'b1, 1'b0, "SUB Negative with Borrow");

        // 9. Negative signed overflow (0x80000000 - 1 = 0x7FFFFFFF with V=1)
        a = 32'h8000_0000; b = 32'd1; alu_ctrl = ALU_SUB;
        check_alu(32'h7FFF_FFFF, 1'b0, 1'b0, 1'b0, 1'b1, "SUB Underflow to Pos");

        // 10. Subtracting negative number (0x7FFFFFFF - (-1)) -> overflow
        a = 32'h7FFF_FFFF; b = 32'hFFFF_FFFF; alu_ctrl = ALU_SUB;
        check_alu(32'h8000_0000, 1'b0, 1'b1, 1'b1, 1'b1, "SUB Negative Overflw");

        // --- Bitwise AND Tests ---
        // 11. AND simple
        a = 32'hF0F0_AAAA; b = 32'h0F0F_AAAA; alu_ctrl = ALU_AND;
        check_alu(32'h0000_AAAA, 1'b0, 1'b0, 1'b0, 1'b0, "AND Simple");

        // 12. AND all zeros
        a = 32'h5555_5555; b = 32'hAAAA_AAAA; alu_ctrl = ALU_AND;
        check_alu(32'h0000_0000, 1'b1, 1'b0, 1'b0, 1'b0, "AND All Zeros");

        // 13. AND all ones
        a = 32'hFFFF_FFFF; b = 32'hFFFF_FFFF; alu_ctrl = ALU_AND;
        check_alu(32'hFFFF_FFFF, 1'b0, 1'b1, 1'b0, 1'b0, "AND All Ones");

        // --- Bitwise OR Tests ---
        // 14. OR simple
        a = 32'hF0F0_0000; b = 32'h0F0F_0000; alu_ctrl = ALU_OR;
        check_alu(32'hFFFF_0000, 1'b0, 1'b1, 1'b0, 1'b0, "OR Simple");

        // 15. OR with zero
        a = 32'd0; b = 32'h1234_5678; alu_ctrl = ALU_OR;
        check_alu(32'h1234_5678, 1'b0, 1'b0, 1'b0, 1'b0, "OR with Zero");

        // --- Bitwise XOR Tests ---
        // 16. XOR identical numbers -> zero
        a = 32'hDEAD_BEEF; b = 32'hDEAD_BEEF; alu_ctrl = ALU_XOR;
        check_alu(32'h0000_0000, 1'b1, 1'b0, 1'b0, 1'b0, "XOR Self Cancel");

        // 17. XOR toggle bits
        a = 32'hFFFF_0000; b = 32'hAAAA_5555; alu_ctrl = ALU_XOR;
        check_alu(32'h5555_5555, 1'b0, 1'b0, 1'b0, 1'b0, "XOR Toggle");

        // --- SLT (Set Less Than) Signed Tests ---
        // 18. Positive < Positive (true)
        a = 32'd5; b = 32'd10; alu_ctrl = ALU_SLT;
        check_alu(32'd1, 1'b0, 1'b0, 1'b0, 1'b0, "SLT Pos < Pos (True)");

        // 19. Positive < Positive (false)
        a = 32'd10; b = 32'd5; alu_ctrl = ALU_SLT;
        check_alu(32'd0, 1'b1, 1'b0, 1'b0, 1'b0, "SLT Pos < Pos (False)");

        // 20. Negative < Positive (true)
        a = -32'd10; b = 32'd5; alu_ctrl = ALU_SLT;
        check_alu(32'd1, 1'b0, 1'b0, 1'b0, 1'b0, "SLT Neg < Pos (True)");

        // 21. Positive < Negative (false)
        a = 32'd5; b = -32'd10; alu_ctrl = ALU_SLT;
        check_alu(32'd0, 1'b1, 1'b0, 1'b0, 1'b0, "SLT Pos < Neg (False)");

        // 22. Equal numbers (false)
        a = -32'd50; b = -32'd50; alu_ctrl = ALU_SLT;
        check_alu(32'd0, 1'b1, 1'b0, 1'b0, 1'b0, "SLT Equal (False)");

        // --- SLL (Logical Shift Left) Tests ---
        // 23. Shift by 0
        a = 32'h0000_0001; b = 32'd0; alu_ctrl = ALU_SLL;
        check_alu(32'h0000_0001, 1'b0, 1'b0, 1'b0, 1'b0, "SLL Shift by 0");

        // 24. Shift by 4
        a = 32'h0000_000F; b = 32'd4; alu_ctrl = ALU_SLL;
        check_alu(32'h0000_00F0, 1'b0, 1'b0, 1'b0, 1'b0, "SLL Shift by 4");

        // 25. Shift by max (31)
        a = 32'h0000_0001; b = 32'd31; alu_ctrl = ALU_SLL;
        check_alu(32'h8000_0000, 1'b0, 1'b1, 1'b0, 1'b0, "SLL Shift by 31");

        // --- SRL (Logical Shift Right) Tests ---
        // 26. Shift right by 4
        a = 32'hF000_0000; b = 32'd4; alu_ctrl = ALU_SRL;
        check_alu(32'h0F00_0000, 1'b0, 1'b0, 1'b0, 1'b0, "SRL Shift by 4");

        // 27. Shift right by 31 (drops MSB to LSB)
        a = 32'h8000_0000; b = 32'd31; alu_ctrl = ALU_SRL;
        check_alu(32'h0000_0001, 1'b0, 1'b0, 1'b0, 1'b0, "SRL Shift by 31");

        // Final Report
        #10;
        $display("==============================================================");
        $display(" ALU Test Results: %0d PASSED, %0d FAILED (Total %0d)", pass_count, fail_count, test_num);
        if (fail_count == 0)
            $display(" RESULT: ALL TESTS PASSED SUCCESSFULLY! [PASS]");
        else
            $display(" RESULT: SOME TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule

