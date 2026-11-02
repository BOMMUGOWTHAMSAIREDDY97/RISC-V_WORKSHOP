`timescale 1ns/1ps

module half_adder_dff_tb;

reg clk, reset, a, b;
wire sum, carry;

half_adder_dff uut(clk, reset, a, b, sum, carry);

always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 1;
    a = 0; b = 0;

    #10 reset = 0;

    #10 a = 0; b = 0;
    #10 a = 0; b = 1;
    #10 a = 1; b = 0;
    #10 a = 1; b = 1;

    #20 $finish;
end

endmodule