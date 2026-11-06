`timescale 1ns/1ps

// Activity 2.6: Self-Checking Testbench for ATM Controller FSM

module atm_tb;

    reg        clk;
    reg        reset;
    reg        card_inserted;
    reg [15:0] pin_in;
    reg        pin_submit;
    reg        op_balance;
    reg        op_withdraw;
    reg [15:0] withdraw_amount;
    reg        eject_card;

    wire [2:0]  state;
    wire [15:0] account_balance;
    wire        pin_valid;
    wire        card_locked;
    wire        cash_dispensed;
    wire        insufficient_funds;

    integer pass_count = 0;
    integer fail_count = 0;

    atm uut (
        .clk(clk),
        .reset(reset),
        .card_inserted(card_inserted),
        .pin_in(pin_in),
        .pin_submit(pin_submit),
        .op_balance(op_balance),
        .op_withdraw(op_withdraw),
        .withdraw_amount(withdraw_amount),
        .eject_card(eject_card),
        .state(state),
        .account_balance(account_balance),
        .pin_valid(pin_valid),
        .card_locked(card_locked),
        .cash_dispensed(cash_dispensed),
        .insufficient_funds(insufficient_funds)
    );

    always #5 clk = ~clk;

    initial begin
        clk             = 0;
        reset           = 1;
        card_inserted   = 0;
        pin_in          = 0;
        pin_submit      = 0;
        op_balance      = 0;
        op_withdraw     = 0;
        withdraw_amount = 0;
        eject_card      = 0;

        $display("==============================================================");
        $display(" Starting Activity 2.6: ATM Controller FSM Testbench");
        $display("==============================================================");

        #15;
        @(posedge clk); #1;
        reset = 0;
        @(posedge clk); #1;

        // --- SCENARIO 1: Successful Transaction Flow ---
        $display("\n--- Scenario 1: Authorized User Transaction ---");
        // Insert card
        card_inserted = 1;
        @(posedge clk); #1;

        // Enter correct PIN
        pin_in     = 16'h1234;
        pin_submit = 1;
        @(posedge clk); #1;
        pin_submit = 0;

        if (pin_valid === 1'b1 && account_balance === 16'd5000) begin
            $display("[PASS] PIN Accepted. Initial balance verified (5000)");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] PIN verification failed!");
            fail_count = fail_count + 1;
        end

        // Withdraw 2000
        op_withdraw     = 1;
        withdraw_amount = 16'd2000;
        @(posedge clk); #1;
        op_withdraw     = 0;

        if (cash_dispensed === 1'b1 && account_balance === 16'd3000) begin
            $display("[PASS] Withdrew 2000: Cash dispensed, new balance = 3000");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Withdrawal failed! Dispense=%b, Bal=%0d", cash_dispensed, account_balance);
            fail_count = fail_count + 1;
        end

        // Overdraft attempt: Try to withdraw 4000 (> balance of 3000)
        @(posedge clk); #1;
        op_withdraw     = 1;
        withdraw_amount = 16'd4000;
        @(posedge clk); #1;
        op_withdraw     = 0;

        if (insufficient_funds === 1'b1 && cash_dispensed === 1'b0 && account_balance === 16'd3000) begin
            $display("[PASS] Overdraft blocked: insufficient_funds asserted, balance preserved (3000)");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Overdraft check failed!");
            fail_count = fail_count + 1;
        end

        // Eject card
        eject_card = 1;
        @(posedge clk); #1;
        eject_card = 0;
        card_inserted = 0;
        @(posedge clk); #1;

        if (pin_valid === 1'b0) begin
            $display("[PASS] Card safely ejected, session closed.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Card eject failed!");
            fail_count = fail_count + 1;
        end

        // --- SCENARIO 2: 3 Incorrect PIN Attempts -> Security Lockout ---
        $display("\n--- Scenario 2: 3 Wrong PIN Attempts Lockout ---");
        card_inserted = 1;
        @(posedge clk); #1;

        // Attempt 1: Wrong PIN
        pin_in = 16'h9999; pin_submit = 1; @(posedge clk); #1; pin_submit = 0;
        @(posedge clk); #1;
        // Attempt 2: Wrong PIN
        pin_in = 16'h8888; pin_submit = 1; @(posedge clk); #1; pin_submit = 0;
        @(posedge clk); #1;
        // Attempt 3: Wrong PIN
        pin_in = 16'h7777; pin_submit = 1; @(posedge clk); #1; pin_submit = 0;
        @(posedge clk); #1;

        if (card_locked === 1'b1 && pin_valid === 1'b0) begin
            $display("[PASS] Security lockout triggered: Card locked after 3 invalid attempts.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Security lockout failed! card_locked=%b", card_locked);
            fail_count = fail_count + 1;
        end

        #20;
        $display("==============================================================");
        $display(" ATM Controller Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display(" RESULT: ALL ATM CONTROLLER TESTS PASSED! [PASS]");
        else
            $display(" RESULT: SOME TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule

