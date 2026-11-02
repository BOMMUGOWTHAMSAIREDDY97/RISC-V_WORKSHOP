`timescale 1ns/1ps

module half_adder_dff(
input clk, reset,
input a, b,
output reg sum, carry
);

wire s, c;

assign s = a ^ b;
assign c = a & b;

always @(posedge clk or posedge reset)
begin
    if(reset) begin
        sum <= 0;
        carry <= 0;
    end
    else begin
        sum <= s;
        carry <= c;
    end
end

endmodule