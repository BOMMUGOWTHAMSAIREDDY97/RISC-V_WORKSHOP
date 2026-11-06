`timescale 1ns/1ps

// Activity 2.1: Overlapping Sequence Detector (1011) - Mealy FSM
// Output 'det' depends on current state AND current input 'din'
// Detects pattern 1 cycle earlier than Moore

module seq_mealy (
    input  wire clk,
    input  wire reset,
    input  wire din,
    output reg  det
);

    localparam [1:0] S_IDLE = 2'b00,
                     S_1    = 2'b01,
                     S_10   = 2'b10,
                     S_101  = 2'b11;

    reg [1:0] state, next_state;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // Next-state and output logic
    always @(*) begin
        det = 1'b0;
        case (state)
            S_IDLE: begin
                next_state = din ? S_1 : S_IDLE;
            end
            S_1: begin
                next_state = din ? S_1 : S_10;
            end
            S_10: begin
                next_state = din ? S_101 : S_IDLE;
            end
            S_101: begin
                if (din) begin
                    det = 1'b1;         // Sequence 1011 detected!
                    next_state = S_1;   // Overlap: trailing '1' forms prefix of next pattern
                end else begin
                    next_state = S_10;  // 1010 has suffix 10
                end
            end
            default: next_state = S_IDLE;
        endcase
    end

endmodule

