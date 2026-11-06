`timescale 1ns/1ps

// Activity 1.3: 32-bit Single-Cycle Barrel Shifter
// Supports:
//   mode 2'b00: Logical Left Shift (SLL)
//   mode 2'b01: Logical Right Shift (SRL)
//   mode 2'b10: Arithmetic Right Shift (SRA)

module shifter (
    input  wire [31:0] in_data,
    input  wire [4:0]  shift_amount,
    input  wire [1:0]  shift_mode,    // 00: SLL, 01: SRL, 10: SRA
    output reg  [31:0] out_data
);

    localparam MODE_SLL = 2'b00;
    localparam MODE_SRL = 2'b01;
    localparam MODE_SRA = 2'b10;

    // Logarithmic barrel shifter stages for single-cycle high-speed execution
    // Stage 4: shift by 16, Stage 3: shift by 8, Stage 2: shift by 4, Stage 1: shift by 2, Stage 0: shift by 1

    always @(*) begin
        case (shift_mode)
            MODE_SLL: begin
                out_data = in_data << shift_amount;
            end

            MODE_SRL: begin
                out_data = in_data >> shift_amount;
            end

            MODE_SRA: begin
                out_data = $signed(in_data) >>> shift_amount;
            end

            default: begin
                out_data = in_data;
            end
        endcase
    end

endmodule

