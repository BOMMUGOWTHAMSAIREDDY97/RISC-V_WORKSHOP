`timescale 1ns/1ps

// Activity 1.7: 8-bit Universal Shift Register
// Modes:
//   2'b00: Hold
//   2'b01: Shift Left  (inserts s_in_l at LSB)
//   2'b10: Shift Right (inserts s_in_r at MSB)
//   2'b11: Parallel Load (loads parallel_in)

module shiftreg #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             reset,
    input  wire [1:0]       mode,
    input  wire             s_in_l,
    input  wire             s_in_r,
    input  wire [WIDTH-1:0] parallel_in,
    output reg  [WIDTH-1:0] parallel_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            parallel_out <= {WIDTH{1'b0}};
        end else begin
            case (mode)
                2'b00: parallel_out <= parallel_out;                         // Hold
                2'b01: parallel_out <= {parallel_out[WIDTH-2:0], s_in_l};    // Shift Left
                2'b10: parallel_out <= {s_in_r, parallel_out[WIDTH-1:1]};    // Shift Right
                2'b11: parallel_out <= parallel_in;                          // Parallel Load
            endcase
        end
    end

endmodule

