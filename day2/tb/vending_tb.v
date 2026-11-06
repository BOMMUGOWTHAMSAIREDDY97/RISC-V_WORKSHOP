`timescale 1ns/1ps

// Activity 2.2: Self-Checking Testbench for Vending Machine FSM

module vending_tb;

    reg        clk;
    reg        reset;
    reg        coin_5;
    reg        coin_10;
    reg        coin_20;

    wire       dispense;
    wire [4:0] change;
    wire [5:0] balance;

    integer pass_count = 0;
    integer fail_count = 0;

    vending uut (
        .clk(clk),
        .reset(reset),
        .coin_5(coin_5),
        .coin_10(coin_10),
        .coin_20(coin_20),
        .dispense(dispense),
        .change(change),
        .balance(balance)
    );

    always #5 clk = ~clk;

    task insert_coin(input integer val);
        begin
            coin_5  = (val == 5);
            coin_10 = (val == 10);
            coin_20 = (val == 20);
            @(posedge clk); #1;
            coin_5  = 0;
            coin_10 = 0;
            coin_20 = 0;
        end
    endtask

    initial begin
        clk     = 0;
        reset   = 1;
        coin_5  = 0;
        coin_10 = 0;
        coin_20 = 0;

        $display("==============================================================");
        $display(" Starting Activity 2.2: Vending Machine FSM Testbench");
        $display("==============================================================");

        #15;
        @(posedge clk); #1;
        reset = 0;

        // TEST 1: Direct 20 INR coin
        $display("\nTest 1: Inserting 20 INR directly...");
        insert_coin(20);
        if (dispense === 1'b1 && change === 5'd0) begin
            $display("[PASS] 20 INR: Dispensed item with 0 change.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] 20 INR failed! Dispense=%b, Change=%0d", dispense, change);
            fail_count = fail_count + 1;
        end

        // TEST 2: Two 10 INR coins (10 + 10 = 20)
        $display("\nTest 2: Inserting 10 INR + 10 INR...");
        insert_coin(10);
        if (balance === 6'd10 && dispense === 1'b0) begin
            $display("[PASS] Balance is 10 INR, not dispensed yet.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] First 10 INR failed! Balance=%0d", balance);
            fail_count = fail_count + 1;
        end

        insert_coin(10);
        if (dispense === 1'b1 && change === 5'd0) begin
            $display("[PASS] Second 10 INR: Dispensed item with 0 change.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Second 10 INR failed! Dispense=%b, Change=%0d", dispense, change);
            fail_count = fail_count + 1;
        end

        // TEST 3: Four 5 INR coins (5 + 5 + 5 + 5 = 20)
        $display("\nTest 3: Inserting 4 x 5 INR coins...");
        insert_coin(5); // 5
        insert_coin(5); // 10
        insert_coin(5); // 15
        if (balance === 6'd15 && dispense === 1'b0) begin
            $display("[PASS] Balance accumulated to 15 INR correctly.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] 15 INR balance failed! Balance=%0d", balance);
            fail_count = fail_count + 1;
        end

        insert_coin(5); // 20 -> dispense
        if (dispense === 1'b1 && change === 5'd0) begin
            $display("[PASS] Fourth 5 INR: Dispensed item with 0 change.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Fourth 5 INR failed! Dispense=%b, Change=%0d", dispense, change);
            fail_count = fail_count + 1;
        end

        // TEST 4: 10 INR + 5 INR + 10 INR = 25 INR -> Dispense + 5 INR change
        $display("\nTest 4: Inserting 10 + 5 + 10 = 25 INR (expect dispense + 5 change)...");
        insert_coin(10);
        insert_coin(5);
        insert_coin(10);
        if (dispense === 1'b1 && change === 5'd5) begin
            $display("[PASS] 25 INR: Dispensed item with 5 INR change returned.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] 25 INR transaction failed! Dispense=%b, Change=%0d", dispense, change);
            fail_count = fail_count + 1;
        end

        // TEST 5: 5 INR + 20 INR = 25 INR -> Dispense + 5 INR change
        $display("\nTest 5: Inserting 5 + 20 = 25 INR...");
        insert_coin(5);
        insert_coin(20);
        if (dispense === 1'b1 && change === 5'd5) begin
            $display("[PASS] 5 + 20 INR: Dispensed item with 5 INR change returned.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] 5 + 20 INR failed! Dispense=%b, Change=%0d", dispense, change);
            fail_count = fail_count + 1;
        end

        // TEST 6: Reset aborts active balance
        $display("\nTest 6: Testing reset abort during transaction...");
        insert_coin(10);
        reset = 1;
        @(posedge clk); #1;
        reset = 0;
        @(posedge clk); #1;
        if (balance === 6'd0 && dispense === 1'b0) begin
            $display("[PASS] Reset successfully aborted transaction and cleared balance.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Reset abort failed! Balance=%0d", balance);
            fail_count = fail_count + 1;
        end

        #20;
        $display("==============================================================");
        $display(" Vending Machine Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display(" RESULT: ALL VENDING MACHINE TESTS PASSED! [PASS]");
        else
            $display(" RESULT: SOME TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule

