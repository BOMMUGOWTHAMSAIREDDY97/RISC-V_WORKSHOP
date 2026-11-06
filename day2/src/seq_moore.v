`timescale 1ns/1ps

// Activity 2.1: Overlapping Sequence Detector (1011) - Moore FSM
// Output 'det' is asserted in state S_1011 (depends ONLY on current state)

module seq_moore (
    input  wire clk,
    input  wire reset,
    input  wire din,
    output wire det
);

    localparam [2:0] S_IDLE = 3'b000,
                     S_1    = 3'b001,
                     S_10   = 3'b010,
                     S_101  = 3'b011,
                     S_1011 = 3'b100;

    reg [2:0] state, next_state;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        case (state)
            S_IDLE: next_state = din ? S_1   : S_IDLE;
            S_1:    next_state = din ? S_1   : S_10;
            S_10:   next_state = din ? S_101 : S_IDLE;
            S_101:  next_state = din ? S_1011: S_10;
            S_1011: next_state = din ? S_1   : S_10; // Overlapping sequence transition
            default: next_state = S_IDLE;
        endcase
    end

    // Moore output logic: depends ONLY on state
    assign det = (state == S_1011);

endmodule

