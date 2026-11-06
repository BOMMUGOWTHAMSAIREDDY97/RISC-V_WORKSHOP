`timescale 1ns/1ps

// Activity 2.8a: Single-Port Synchronous RAM (64 x 32-bit)
// Parameterized depth and width with synchronous read and write.

module ram #(
    parameter integer DATA_WIDTH = 32,
    parameter integer ADDR_WIDTH = 6,
    parameter integer DEPTH      = 64
) (
    input  wire                  clk,
    input  wire                  we,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [DATA_WIDTH-1:0] din,
    output reg  [DATA_WIDTH-1:0] dout
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= din;
        end
        dout <= mem[addr];
    end

endmodule

