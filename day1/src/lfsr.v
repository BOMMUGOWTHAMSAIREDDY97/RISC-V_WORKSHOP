`timescale 1ns/1ps

// Activity 1.7: 8-bit Maximal-Length Linear Feedback Shift Register (LFSR)
// Characteristic Polynomial: x^8 + x^6 + x^5 + x^4 + 1 (Taps: 7, 5, 4, 3)
// Produces a maximal cycle of 2^8 - 1 = 255 non-zero pseudo-random states

module lfsr (
    input  wire       clk,
    input  wire       reset,
    input  wire       load_seed,
    input  wire [7:0] seed,
    output reg  [7:0] lfsr_out
);

    wire feedback = lfsr_out[7] ^ lfsr_out[5] ^ lfsr_out[4] ^ lfsr_out[3];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr_out <= 8'h01; // Default non-zero seed
        end else if (load_seed) begin
            lfsr_out <= (seed == 8'h00) ? 8'h01 : seed; // Prevent lockup in all-zero state
        end else begin
            lfsr_out <= {lfsr_out[6:0], feedback};
        end
    end

endmodule

