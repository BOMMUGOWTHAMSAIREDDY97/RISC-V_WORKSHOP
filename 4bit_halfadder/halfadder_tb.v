`timescale 1ns/1ps

module halfadder_tb;

reg A, B;
wire Sum, Carry;

halfadder uut (
    .A(A),
    .B(B),
    .Sum(Sum),
    .Carry(Carry)
);

initial begin
    A = 0; B = 0;
    #10 A = 0; B = 1;
    #10 A = 1; B = 0;
    #10 A = 1; B = 1;
    #10 $finish;
end

initial begin
    $monitor("Time=%0t A=%b B=%b Sum=%b Carry=%b",
             $time, A, B, Sum, Carry);
end

endmodule