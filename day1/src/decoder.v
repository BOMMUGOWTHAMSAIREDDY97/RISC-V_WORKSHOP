`timescale 1ns/1ps

// Activity 1.6: 3-to-8 Decoder with Enable Input

module decoder (
    input  wire       en,
    input  wire [2:0] in,
    output wire [7:0] out
);

    assign out = (en) ? (8'b0000_0001 << in) : 8'b0000_0000;

endmodule

