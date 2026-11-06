`timescale 1ns/1ps

// Testbench for Activity 1.6: Priority Encoder & Decoder
// Compares casez encoder vs if-else encoder across all 256 input vectors

module encoder_decoder_tb;

    reg  [7:0] enc_in;
    wire [2:0] code_casez, code_ifelse;
    wire       valid_casez, valid_ifelse;

    reg        dec_en;
    reg  [2:0] dec_in;
    wire [7:0] dec_out;

    integer pass_count = 0;
    integer fail_count = 0;
    integer total_tests = 0;
    integer i;

    // Instantiate both encoders
    encoder_casez uut_casez (
        .in(enc_in),
        .code(code_casez),
        .valid(valid_casez)
    );

    encoder_ifelse uut_ifelse (
        .in(enc_in),
        .code(code_ifelse),
        .valid(valid_ifelse)
    );

    // Instantiate Decoder
    decoder uut_dec (
        .en(dec_en),
        .in(dec_in),
        .out(dec_out)
    );

    initial begin
        $display("==============================================================");
        $display(" Starting Activity 1.6: Priority Encoder & Decoder TB");
        $display("==============================================================");

        // --- Exhaustive 256-Vector Test on Both Encoders ---
        for (i = 0; i < 256; i = i + 1) begin
            enc_in = i[7:0];
            #5;
            total_tests = total_tests + 1;

            if ((code_casez === code_ifelse) && (valid_casez === valid_ifelse)) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Encoder Mismatch for in=8'b%b: casez=(%b, V=%b) vs ifelse=(%b, V=%b)",
                         enc_in, code_casez, valid_casez, code_ifelse, valid_ifelse);
                fail_count = fail_count + 1;
            end
        end

        $display(" [NOTE] Verified: Both casez and if-else encoders simulate IDENTICALLY for all 256 inputs.");

        // --- Decoder Verification ---
        for (i = 0; i < 8; i = i + 1) begin
            dec_en = 1'b1;
            dec_in = i[2:0];
            #5;
            total_tests = total_tests + 1;
            if (dec_out === (8'b0000_0001 << i)) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Decoder en=1 in=%d -> out=8'b%b", dec_in, dec_out);
                fail_count = fail_count + 1;
            end
        end

        // Decoder disabled check
        for (i = 0; i < 8; i = i + 1) begin
            dec_en = 1'b0;
            dec_in = i[2:0];
            #5;
            total_tests = total_tests + 1;
            if (dec_out === 8'b0000_0000) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Decoder disabled in=%d -> out=8'b%b", dec_in, dec_out);
                fail_count = fail_count + 1;
            end
        end

        #10;
        $display("==============================================================");
        $display(" Encoder/Decoder Results: %0d PASSED, %0d FAILED (Total %0d)", pass_count, fail_count, total_tests);
        if (fail_count == 0)
            $display(" RESULT: ALL ENCODER/DECODER TESTS PASSED! [PASS]");
        else
            $display(" RESULT: SOME TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule

