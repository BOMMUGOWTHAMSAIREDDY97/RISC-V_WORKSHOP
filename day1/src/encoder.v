`timescale 1ns/1ps

// Activity 1.6: 8-to-3 Priority Encoder with Valid Output
// Includes two implementation architectures:
//   1. encoder_casez : Implemented with casez statement
//   2. encoder_ifelse: Implemented with priority if-else chain
// Bit 7 has the highest priority, Bit 0 has the lowest priority.

module encoder_casez (
    input  wire [7:0] in,
    output reg  [2:0] code,
    output reg        valid
);

    always @(*) begin
        valid = 1'b1;
        casez (in)
            8'b1???????: code = 3'b111;
            8'b01??????: code = 3'b110;
            8'b001?????: code = 3'b101;
            8'b0001????: code = 3'b100;
            8'b00001???: code = 3'b011;
            8'b000001??: code = 3'b010;
            8'b0000001?: code = 3'b001;
            8'b00000001: code = 3'b000;
            default: begin
                code  = 3'b000;
                valid = 1'b0;
            end
        endcase
    end

endmodule

module encoder_ifelse (
    input  wire [7:0] in,
    output reg  [2:0] code,
    output reg        valid
);

    always @(*) begin
        valid = 1'b1;
        if      (in[7]) code = 3'b111;
        else if (in[6]) code = 3'b110;
        else if (in[5]) code = 3'b101;
        else if (in[4]) code = 3'b100;
        else if (in[3]) code = 3'b011;
        else if (in[2]) code = 3'b010;
        else if (in[1]) code = 3'b001;
        else if (in[0]) code = 3'b000;
        else begin
            code  = 3'b000;
            valid = 1'b0;
        end
    end

endmodule

