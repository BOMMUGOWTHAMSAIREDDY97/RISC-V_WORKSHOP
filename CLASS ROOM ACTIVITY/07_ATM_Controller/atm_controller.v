
`timescale 1ns/1ps

module atm_controller(
    input clk,
    input reset,
    input card_insert,
    input [15:0] pin,
    input pin_enter,
    input withdraw,
    input [7:0] amount,
    input [7:0] balance,

    output reg cash_dispense,
    output reg card_return,
    output reg pin_error,
    output reg insufficient_balance,
    output reg transaction_done
);

parameter IDLE     = 3'b000,
          PIN      = 3'b001,
          VERIFY   = 3'b010,
          MENU     = 3'b011,
          CHECK    = 3'b100,
          DISPENSE = 3'b101,
          DONE     = 3'b110,
          ERROR    = 3'b111;

reg [2:0] state;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        cash_dispense <= 0;
        card_return <= 0;
        pin_error <= 0;
        insufficient_balance <= 0;
        transaction_done <= 0;
    end
    else begin
        cash_dispense <= 0;
        card_return <= 0;
        pin_error <= 0;
        insufficient_balance <= 0;
        transaction_done <= 0;

        case(state)

            IDLE: begin
                if (card_insert)
                    state <= PIN;
            end

            PIN: begin
                if (pin_enter)
                    state <= VERIFY;
            end

            VERIFY: begin
                if (pin == 16'd1234)
                    state <= MENU;
                else
                    state <= ERROR;
            end

            MENU: begin
                if (withdraw)
                    state <= CHECK;
            end

            CHECK: begin
                if (amount <= balance)
                    state <= DISPENSE;
                else
                    state <= ERROR;
            end

            DISPENSE: begin
                cash_dispense <= 1;
                state <= DONE;
            end

            DONE: begin
                card_return <= 1;
                transaction_done <= 1;
                state <= IDLE;
            end

            ERROR: begin
                if (pin != 16'd1234)
                    pin_error <= 1;
                else
                    insufficient_balance <= 1;

                card_return <= 1;
                state <= IDLE;
            end

            default: state <= IDLE;

        endcase
    end
end

endmodule
