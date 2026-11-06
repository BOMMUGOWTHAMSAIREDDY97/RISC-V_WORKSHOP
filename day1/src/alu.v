`timescale 1ns/1ps

// Activity 1.1: Parameterized ALU with Flag Generation
// Supports: ADD, SUB, AND, OR, XOR, SLT, SLL, SRL
// Output Flags: Zero, Negative, Carry, Overflow

module alu #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [3:0]       alu_ctrl,
    output reg  [WIDTH-1:0] result,
    output wire             zero,
    output wire             negative,
    output reg              carry,
    output reg              overflow
);

    // ALU Operation Control Encodings
    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_XOR = 4'b0100;
    localparam ALU_SLT = 4'b0101;
    localparam ALU_SLL = 4'b0110;
    localparam ALU_SRL = 4'b0111;

    // Internal calculation registers
    reg [WIDTH:0] ext_result;

    always @(*) begin
        result     = {WIDTH{1'b0}};
        carry      = 1'b0;
        overflow   = 1'b0;
        ext_result = {(WIDTH+1){1'b0}};

        case (alu_ctrl)
            ALU_ADD: begin
                ext_result = {1'b0, a} + {1'b0, b};
                result     = ext_result[WIDTH-1:0];
                carry      = ext_result[WIDTH];
                // Signed overflow: signs of inputs match, but result sign differs
                overflow   = (~(a[WIDTH-1] ^ b[WIDTH-1])) & (a[WIDTH-1] ^ result[WIDTH-1]);
            end

            ALU_SUB: begin
                ext_result = {1'b0, a} - {1'b0, b};
                result     = ext_result[WIDTH-1:0];
                carry      = ext_result[WIDTH]; // Borrow flag
                // Signed overflow: operands have opposite signs and result sign != a sign
                overflow   = (a[WIDTH-1] ^ b[WIDTH-1]) & (a[WIDTH-1] ^ result[WIDTH-1]);
            end

            ALU_AND: begin
                result = a & b;
            end

            ALU_OR: begin
                result = a | b;
            end

            ALU_XOR: begin
                result = a ^ b;
            end

            ALU_SLT: begin
                result = ($signed(a) < $signed(b)) ? {{(WIDTH-1){1'b0}}, 1'b1} : {WIDTH{1'b0}};
            end

            ALU_SLL: begin
                result = a << b[4:0];
            end

            ALU_SRL: begin
                result = a >> b[4:0];
            end

            default: begin
                result = {WIDTH{1'b0}};
            end
        endcase
    end

    // Flag outputs
    assign zero     = (result == {WIDTH{1'b0}});
    assign negative = result[WIDTH-1];

endmodule

