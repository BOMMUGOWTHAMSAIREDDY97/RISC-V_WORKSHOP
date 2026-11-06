`timescale 1ns/1ps

module atm_controller_tb;

reg clk, reset;
reg card_insert, pin_enter, withdraw;
reg [15:0] pin;
reg [7:0] amount, balance;

wire cash_dispense, card_return;
wire pin_error, insufficient_balance;
wire transaction_done;

atm_controller uut(
    .clk(clk),
    .reset(reset),
    .card_insert(card_insert),
    .pin(pin),
    .pin_enter(pin_enter),
    .withdraw(withdraw),
    .amount(amount),
    .balance(balance),
    .cash_dispense(cash_dispense),
    .card_return(card_return),
    .pin_error(pin_error),
    .insufficient_balance(insufficient_balance),
    .transaction_done(transaction_done)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 1;
    card_insert = 0;
    pin_enter = 0;
    withdraw = 0;
    pin = 0;
    amount = 0;
    balance = 200;

    #10 reset = 0;

    // Test 1: Successful withdrawal
    @(negedge clk);
    card_insert = 1;
    @(negedge clk);
    card_insert = 0;
    pin = 1234;
    pin_enter = 1;
    @(negedge clk);
    pin_enter = 0;

    repeat(2) @(negedge clk);
    amount = 100;
    withdraw = 1;
    @(negedge clk);
    withdraw = 0;

    repeat(5) @(negedge clk);

    // Test 2: Invalid PIN
    card_insert = 1;
    @(negedge clk);
    card_insert = 0;
    pin = 1111;
    pin_enter = 1;
    @(negedge clk);
    pin_enter = 0;

    repeat(4) @(negedge clk);

    // Test 3: Insufficient balance
    card_insert = 1;
    @(negedge clk);
    card_insert = 0;
    pin = 1234;
    pin_enter = 1;
    @(negedge clk);
    pin_enter = 0;

    repeat(2) @(negedge clk);
    amount = 250;
    withdraw = 1;
    @(negedge clk);
    withdraw = 0;

    repeat(5) @(negedge clk);

    $display("ATM simulation completed");
    $finish;
end

initial begin
    $monitor("Time=%0t PIN=%d Amount=%d Balance=%d Cash=%b PIN_Error=%b Insufficient=%b Done=%b",
        $time, pin, amount, balance, cash_dispense,
        pin_error, insufficient_balance, transaction_done);
end

endmodule
