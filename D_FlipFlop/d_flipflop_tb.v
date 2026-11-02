`timescale 1ns/1ps

module d_flipflop_tb;

reg clk, rst, d;
wire q;

d_flipflop uut(
    .clk(clk),
    .rst(rst),
    .d(d),
    .q(q)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    d = 0;

    #10 rst = 0;
    #10 d = 1;
    #20 d = 0;
    #20 d = 1;
    #20 d = 0;

    #20 $finish;
end

initial begin
    $monitor("Time=%0t clk=%b rst=%b d=%b q=%b",
              $time, clk, rst, d, q);
end

endmodule