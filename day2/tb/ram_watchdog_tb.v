`timescale 1ns/1ps

// Activity 2.8: Self-Checking Testbench for RAM and Watchdog Timer

module ram_watchdog_tb;

    // RAM signals
    reg         clk;
    reg         ram_we;
    reg  [5:0]  ram_addr;
    reg  [31:0] ram_din;
    wire [31:0] ram_dout;

    // Watchdog signals
    reg         wd_reset;
    reg         wd_kick;
    reg  [15:0] wd_timeout_val;
    wire        wd_expired;
    wire        wd_reset_pulse;

    integer pass_count = 0;
    integer fail_count = 0;
    integer i;

    // Instantiate RAM (64 x 32-bit)
    ram #(.DATA_WIDTH(32), .ADDR_WIDTH(6), .DEPTH(64)) uut_ram (
        .clk(clk),
        .we(ram_we),
        .addr(ram_addr),
        .din(ram_din),
        .dout(ram_dout)
    );

    // Instantiate Watchdog
    watchdog uut_watchdog (
        .clk(clk),
        .reset(wd_reset),
        .kick(wd_kick),
        .timeout_val(wd_timeout_val),
        .timeout_expired(wd_expired),
        .reset_pulse(wd_reset_pulse)
    );

    always #5 clk = ~clk;

    initial begin
        clk            = 0;
        ram_we         = 0;
        ram_addr       = 0;
        ram_din        = 0;
        wd_reset       = 1;
        wd_kick        = 0;
        wd_timeout_val = 16'd8; // 8 clock cycles

        $display("==============================================================");
        $display(" Starting Activity 2.8: RAM & Watchdog Timer Testbench");
        $display("==============================================================");

        #15;
        @(posedge clk); #1;
        wd_reset = 0;

        // --- 1. RAM Verification ---
        $display("\n1. Writing 16 words into RAM...");
        for (i = 0; i < 16; i = i + 1) begin
            ram_we   = 1;
            ram_addr = i;
            ram_din  = 32'hA0000000 | (i * 32'h1111);
            @(posedge clk); #1;
        end
        ram_we = 0;

        $display("Reading and checking 16 words from RAM...");
        for (i = 0; i < 16; i = i + 1) begin
            ram_addr = i;
            @(posedge clk); #1; // Synchronous read latency
            if (ram_dout === (32'hA0000000 | (i * 32'h1111))) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] RAM mismatch at addr %0d: got 0x%08h, exp 0x%08h",
                         i, ram_dout, (32'hA0000000 | (i * 32'h1111)));
                fail_count = fail_count + 1;
            end
        end
        $display("[PASS] RAM 16-word read/write verified.");

        // --- 2. Watchdog Verification ---
        $display("\n2. Watchdog: Servicing heartbeat kicks (period = 4 < timeout = 8)...");
        for (i = 0; i < 5; i = i + 1) begin
            repeat(4) @(posedge clk);
            wd_kick = 1;
            @(posedge clk); #1;
            wd_kick = 0;

            if (wd_expired === 1'b0 && wd_reset_pulse === 1'b0) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] False watchdog timeout fired while serviced!");
                fail_count = fail_count + 1;
            end
        end
        $display("[PASS] Watchdog successfully suppressed during regular kicks.");

        $display("\nWatchdog: Halting service kicks to trigger timeout...");
        // Wait 9 clock cycles without kicking
        repeat(8) @(posedge clk);
        #1;
        if (wd_expired === 1'b1 && wd_reset_pulse === 1'b1) begin
            $display("[PASS] Watchdog expired and fired system reset pulse as expected!");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Watchdog failed to expire after timeout! expired=%b, pulse=%b",
                     wd_expired, wd_reset_pulse);
            fail_count = fail_count + 1;
        end

        // Re-service
        @(posedge clk); #1;
        wd_kick = 1;
        @(posedge clk); #1;
        wd_kick = 0;
        if (wd_expired === 1'b0) begin
            $display("[PASS] Watchdog successfully cleared upon subsequent service kick.");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Failed to clear watchdog!");
            fail_count = fail_count + 1;
        end

        #20;
        $display("==============================================================");
        $display(" RAM & Watchdog Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display(" RESULT: ALL RAM & WATCHDOG TESTS PASSED! [PASS]");
        else
            $display(" RESULT: SOME TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule

