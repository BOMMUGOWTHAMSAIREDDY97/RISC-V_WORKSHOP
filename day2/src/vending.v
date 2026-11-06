`timescale 1ns/1ps

// Activity 2.2: Vending Machine FSM
// Accepts coins: 5, 10, 20 INR
// Item price = 20 INR
// Dispenses item when balance >= 20. If balance == 25, returns 5 INR change.

module vending (
    input  wire       clk,
    input  wire       reset,
    input  wire       coin_5,
    input  wire       coin_10,
    input  wire       coin_20,
    output reg        dispense,
    output reg  [4:0] change,   // 0 or 5
    output reg  [5:0] balance   // current accumulated balance
);

    // States representing current accumulated balance
    localparam [2:0] S_0  = 3'b000,
                     S_5  = 3'b001,
                     S_10 = 3'b010,
                     S_15 = 3'b011;

    reg [2:0] state, next_state;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state    <= S_0;
            dispense <= 1'b0;
            change   <= 5'd0;
            balance  <= 6'd0;
        end else begin
            state <= next_state;

            // Output generation based on transitions
            dispense <= 1'b0;
            change   <= 5'd0;

            case (state)
                S_0: begin
                    if (coin_20) begin
                        dispense <= 1'b1;
                        change   <= 5'd0;
                        balance  <= 6'd0;
                    end else if (coin_10) begin
                        balance <= 6'd10;
                    end else if (coin_5) begin
                        balance <= 6'd5;
                    end else begin
                        balance <= 6'd0;
                    end
                end

                S_5: begin
                    if (coin_20) begin
                        dispense <= 1'b1;
                        change   <= 5'd5; // 5 + 20 = 25 -> dispense + 5 change
                        balance  <= 6'd0;
                    end else if (coin_10) begin
                        balance <= 6'd15;
                    end else if (coin_5) begin
                        balance <= 6'd10;
                    end
                end

                S_10: begin
                    if (coin_20) begin
                        dispense <= 1'b1;
                        change   <= 5'd10; // 10 + 20 = 30 -> dispense + 10 change
                        balance  <= 6'd0;
                    end else if (coin_10) begin
                        dispense <= 1'b1;  // 10 + 10 = 20 -> dispense
                        change   <= 5'd0;
                        balance  <= 6'd0;
                    end else if (coin_5) begin
                        balance <= 6'd15;
                    end
                end

                S_15: begin
                    if (coin_20) begin
                        dispense <= 1'b1;
                        change   <= 5'd15; // 15 + 20 = 35 -> dispense + 15 change
                        balance  <= 6'd0;
                    end else if (coin_10) begin
                        dispense <= 1'b1;  // 15 + 10 = 25 -> dispense + 5 change
                        change   <= 5'd5;
                        balance  <= 6'd0;
                    end else if (coin_5) begin
                        dispense <= 1'b1;  // 15 + 5 = 20 -> dispense
                        change   <= 5'd0;
                        balance  <= 6'd0;
                    end
                end

                default: begin
                    balance <= 6'd0;
                end
            endcase
        end
    end

    // Next-state logic
    always @(*) begin
        next_state = state;
        case (state)
            S_0: begin
                if (coin_20)      next_state = S_0;
                else if (coin_10) next_state = S_10;
                else if (coin_5)  next_state = S_5;
            end

            S_5: begin
                if (coin_20)      next_state = S_0;
                else if (coin_10) next_state = S_15;
                else if (coin_5)  next_state = S_10;
            end

            S_10: begin
                if (coin_20)      next_state = S_0;
                else if (coin_10) next_state = S_0;
                else if (coin_5)  next_state = S_15;
            end

            S_15: begin
                if (coin_20)      next_state = S_0;
                else if (coin_10) next_state = S_0;
                else if (coin_5)  next_state = S_0;
            end

            default: next_state = S_0;
        endcase
    end

endmodule

