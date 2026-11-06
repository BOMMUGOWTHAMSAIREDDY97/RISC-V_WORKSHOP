`timescale 1ns/1ps

// Activity 2.3: Self-Checking Testbench for 16x8 Synchronous FIFO

module fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 16;
    parameter ADDR_WIDTH = 4;

    reg                   clk;
    reg                   reset;
    reg                   wr_en;
    reg  [DATA_WIDTH-1:0] din;
    reg                   rd_en;
    wire [DATA_WIDTH-1:0] dout;
    wire                  full;
    wire                  empty;
    wire                  almost_full;
    wire                  almost_empty;
    wire [ADDR_WIDTH:0]   count;

    integer pass_count = 0;
    integer fail_count = 0;
    integer i;
    reg [DATA_WIDTH-1:0] exp_data;

    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .wr_en(wr_en),
        .din(din),
        .rd_en(rd_en),
        .dout(dout),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .count(count)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        wr_en = 0;
        rd_en = 0;
        din   = 0;

        $display("==============================================================");
        $display(" Starting Activity 2.3: Synchronous FIFO Testbench");
        $display("==============================================================");

        #15;
        @(posedge clk); #1;
        reset = 0;
        @(posedge clk); #1;

        // TEST 1: Reset state
        if (empty === 1'b1 && full === 1'b0 && count === 0) begin
            $display("[PASS] Reset verified: empty=1, full=0, count=0");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Reset state incorrect!");
            fail_count = fail_count + 1;
        end

        // TEST 2: Write 16 elements until FULL
        $display("\nWriting 16 elements (0x10 to 0x1F) into FIFO...");
        for (i = 0; i < DEPTH; i = i + 1) begin
            wr_en = 1;
            din   = 8'h10 + i;
            @(posedge clk); #1;
        end
        wr_en = 0;

        if (full === 1'b1 && empty === 1'b0 && count === DEPTH) begin
            $display("[PASS] FIFO correctly reached FULL state (count = %0d)", count);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] FIFO full state failed! count=%0d, full=%b", count, full);
            fail_count = fail_count + 1;
        end

        // TEST 3: Overflow Protection
        $display("\nAttempting overflow write on FULL FIFO...");
        wr_en = 1;
        din   = 8'hEE;
        @(posedge clk); #1;
        wr_en = 0;
        @(posedge clk); #1;

        if (count === DEPTH && full === 1'b1) begin
            $display("[PASS] Overflow write rejected: count remained %0d, full=1", count);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Overflow protection failed!");
            fail_count = fail_count + 1;
        end

        // TEST 4: Read all 16 elements and verify FIFO order
        $display("\nReading 16 elements and verifying FIFO order...");
        for (i = 0; i < DEPTH; i = i + 1) begin
            rd_en = 1;
            @(posedge clk); #1;
            exp_data = 8'h10 + i;
            if (dout === exp_data) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Data mismatch at element %0d: got 0x%02h, exp 0x%02h",
                         i, dout, exp_data);
                fail_count = fail_count + 1;
            end
        end
        rd_en = 0;
        @(posedge clk); #1;

        if (empty === 1'b1 && full === 1'b0 && count === 0) begin
            $display("[PASS] FIFO reached EMPTY state (count = %0d)", count);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] FIFO empty state failed! count=%0d, empty=%b", count, empty);
            fail_count = fail_count + 1;
        end

        // TEST 5: Underflow Protection
        $display("\nAttempting underflow read on EMPTY FIFO...");
        rd_en = 1;
        @(posedge clk); #1;
        rd_en = 0;
        @(posedge clk); #1;

        if (count === 0 && empty === 1'b1) begin
            $display("[PASS] Underflow read protected: count remained 0, empty=1");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Underflow protection failed!");
            fail_count = fail_count + 1;
        end

        // TEST 6: Simultaneous Read and Write
        $display("\nTesting simultaneous Read and Write...");
        // Preload 2 elements
        wr_en = 1; din = 8'hA1; @(posedge clk); #1;
        din = 8'hA2; @(posedge clk); #1;
        wr_en = 0;

        // Perform simultaneous write of 0xB1 and read of 0xA1
        wr_en = 1; din = 8'hB1;
        rd_en = 1;
        @(posedge clk); #1;
        wr_en = 0;
        rd_en = 0;

        if (dout === 8'hA1 && count === 2) begin
            $display("[PASS] Simultaneous Read/Write succeeded! dout=0x%02h, count remained %0d",
                     dout, count);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Simultaneous Read/Write failed! dout=0x%02h, count=%0d", dout, count);
            fail_count = fail_count + 1;
        end

        #20;
        $display("==============================================================");
        $display(" FIFO Test Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display(" RESULT: ALL FIFO TESTS PASSED! [PASS]");
        else
            $display(" RESULT: SOME TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule

