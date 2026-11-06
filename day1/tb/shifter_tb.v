`timescale 1ns/1ps

// Testbench for Activity 1.3: 32-bit Barrel Shifter
// Verifies all 0 to 31 shift amounts against a behavioral reference model

module shifter_tb;

    reg  [31:0] in_data;
    reg  [4:0]  shift_amount;
    reg  [1:0]  shift_mode;
    wire [31:0] out_data;

    integer pass_count = 0;
    integer fail_count = 0;
    integer total_tests = 0;
    integer sh;
    integer pat;

    shifter uut (
        .in_data(in_data),
        .shift_amount(shift_amount),
        .shift_mode(shift_mode),
        .out_data(out_data)
    );

    // Reference model function
    function [31:0] ref_model;
        input [31:0] data;
        input [4:0]  shamt;
        input [1:0]  mode;
        begin
            case (mode)
                2'b00: ref_model = data << shamt;
                2'b01: ref_model = data >> shamt;
                2'b10: ref_model = $signed(data) >>> shamt;
                default: ref_model = data;
            endcase
        end
    endfunction

    reg [31:0] test_patterns [0:4];
    reg [31:0] exp_data;

    initial begin
        test_patterns[0] = 32'h8000_0001; // Sign bit set + LSB set
        test_patterns[1] = 32'hAAAA_5555; // Alternating bits
        test_patterns[2] = 32'h7FFF_FFFF; // Max positive signed
        test_patterns[3] = 32'hFFFF_FFFF; // All ones
        test_patterns[4] = 32'h1234_5678; // General test vector

        $display("==============================================================");
        $display("     Starting Activity 1.3: 32-bit Barrel Shifter Testbench");
        $display("==============================================================");

        // Test all 3 modes for all 5 patterns across all 32 shift amounts (0 to 31)
        for (pat = 0; pat < 5; pat = pat + 1) begin
            in_data = test_patterns[pat];

            // 1. SLL tests
            shift_mode = 2'b00;
            for (sh = 0; sh < 32; sh = sh + 1) begin
                shift_amount = sh[4:0];
                #5;
                exp_data = ref_model(in_data, shift_amount, shift_mode);
                total_tests = total_tests + 1;
                if (out_data === exp_data) begin
                    pass_count = pass_count + 1;
                end else begin
                    $display("[FAIL] SLL: in=0x%08h, sh=%02d -> out=0x%08h (exp 0x%08h)",
                             in_data, sh, out_data, exp_data);
                    fail_count = fail_count + 1;
                end
            end

            // 2. SRL tests
            shift_mode = 2'b01;
            for (sh = 0; sh < 32; sh = sh + 1) begin
                shift_amount = sh[4:0];
                #5;
                exp_data = ref_model(in_data, shift_amount, shift_mode);
                total_tests = total_tests + 1;
                if (out_data === exp_data) begin
                    pass_count = pass_count + 1;
                end else begin
                    $display("[FAIL] SRL: in=0x%08h, sh=%02d -> out=0x%08h (exp 0x%08h)",
                             in_data, sh, out_data, exp_data);
                    fail_count = fail_count + 1;
                end
            end

            // 3. SRA tests
            shift_mode = 2'b10;
            for (sh = 0; sh < 32; sh = sh + 1) begin
                shift_amount = sh[4:0];
                #5;
                exp_data = ref_model(in_data, shift_amount, shift_mode);
                total_tests = total_tests + 1;
                if (out_data === exp_data) begin
                    pass_count = pass_count + 1;
                end else begin
                    $display("[FAIL] SRA: in=0x%08h, sh=%02d -> out=0x%08h (exp 0x%08h)",
                             in_data, sh, out_data, exp_data);
                    fail_count = fail_count + 1;
                end
            end
        end

        #10;
        $display("==============================================================");
        $display(" Barrel Shifter Results: %0d PASSED, %0d FAILED (Total %0d)", pass_count, fail_count, total_tests);
        if (fail_count == 0)
            $display(" RESULT: ALL SHIFT TESTS PASSED SUCCESSFULLY! [PASS]");
        else
            $display(" RESULT: SOME SHIFT TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule

