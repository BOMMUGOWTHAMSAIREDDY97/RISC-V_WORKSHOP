`timescale 1ns/1ps

// Activity 1.5: 8-bit Ripple-Carry Adder/Subtractor using Generate Loop
// mode = 0 : Addition (a + b)
// mode = 1 : Subtraction (a - b = a + ~b + 1)
// Outputs: result, carry_out, overflow

module adder_sub #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             mode, // 0 = Add, 1 = Subtract
    output wire [WIDTH-1:0] result,
    output wire             carry_out,
    output wire             overflow
);

    wire [WIDTH-1:0] b_mod;
    wire [WIDTH:0]   carry_chain;

    assign carry_chain[0] = mode;
    assign b_mod          = b ^ {WIDTH{mode}};

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_fa
            full_adder fa_inst (
                .a(a[i]),
                .b(b_mod[i]),
                .cin(carry_chain[i]),
                .sum(result[i]),
                .cout(carry_chain[i+1])
            );
        end
    endgenerate

    assign carry_out = carry_chain[WIDTH];

    // Signed overflow: signs of input operands (with effective b) match, but result sign differs
    assign overflow  = (~(a[WIDTH-1] ^ b_mod[WIDTH-1])) & (a[WIDTH-1] ^ result[WIDTH-1]);

endmodule

