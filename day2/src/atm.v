`timescale 1ns/1ps

// Activity 2.6: Advanced ATM Controller FSM
// Features: PIN Verification (3-attempt lockout), Balance Inquiry, Withdrawal with Overdraft Protection

module atm (
    input  wire        clk,
    input  wire        reset,
    input  wire        card_inserted,
    input  wire [15:0] pin_in,
    input  wire        pin_submit,
    input  wire        op_balance,       // Inquiry
    input  wire        op_withdraw,      // Cash Withdrawal
    input  wire [15:0] withdraw_amount,
    input  wire        eject_card,

    output reg  [2:0]  state,
    output reg  [15:0] account_balance,
    output reg         pin_valid,
    output reg         card_locked,
    output reg         cash_dispensed,
    output reg         insufficient_funds
);

    localparam [2:0] S_IDLE       = 3'b000,
                     S_PIN_CHECK  = 3'b001,
                     S_TRANSACT   = 3'b010,
                     S_DISPENSE   = 3'b011,
                     S_LOCKED     = 3'b100,
                     S_EJECT      = 3'b101;

    localparam [15:0] CORRECT_PIN    = 16'h1234;
    localparam [15:0] INITIAL_BAL    = 16'd5000; // Starting with 5000 units

    reg [1:0] pin_attempts;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state              <= S_IDLE;
            account_balance    <= INITIAL_BAL;
            pin_valid          <= 1'b0;
            card_locked        <= 1'b0;
            cash_dispensed     <= 1'b0;
            insufficient_funds <= 1'b0;
            pin_attempts       <= 2'd0;
        end else begin
            cash_dispensed     <= 1'b0;
            insufficient_funds <= 1'b0;

            case (state)
                S_IDLE: begin
                    pin_valid   <= 1'b0;
                    card_locked <= 1'b0;
                    pin_attempts<= 2'd0;
                    if (card_inserted)
                        state <= S_PIN_CHECK;
                end

                S_PIN_CHECK: begin
                    if (pin_submit) begin
                        if (pin_in == CORRECT_PIN) begin
                            pin_valid <= 1'b1;
                            state     <= S_TRANSACT;
                        end else begin
                            if (pin_attempts >= 2'd2) begin
                                card_locked <= 1'b1;
                                state       <= S_LOCKED;
                            end else begin
                                pin_attempts <= pin_attempts + 1'b1;
                            end
                        end
                    end
                end

                S_TRANSACT: begin
                    if (eject_card) begin
                        state <= S_EJECT;
                    end else if (op_withdraw) begin
                        if (withdraw_amount <= account_balance) begin
                            account_balance <= account_balance - withdraw_amount;
                            cash_dispensed  <= 1'b1;
                            state           <= S_DISPENSE;
                        end else begin
                            insufficient_funds <= 1'b1;
                        end
                    end
                end

                S_DISPENSE: begin
                    // 1 cycle cash pulse then return to transact
                    state <= S_TRANSACT;
                end

                S_LOCKED: begin
                    // Remains locked until reset or card removed
                    if (!card_inserted)
                        state <= S_IDLE;
                end

                S_EJECT: begin
                    pin_valid <= 1'b0;
                    if (!card_inserted)
                        state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule

