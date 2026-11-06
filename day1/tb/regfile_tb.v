`timescale 1ns/1ps

// Testbench for Activity 1.4: 32 x 32 Register File with Internal Bypass
// Includes directed tests (x0 write, bypass, back-to-back writes)
// and a randomized stress test of 250 operations

module regfile_tb;

    reg         clk;
    reg         rst;
    reg         we;
    reg  [4:0]  rs1;
    reg  [4:0]  rs2;
    reg  [4:0]  rd;
    reg  [31:0] wr_data;
    wire [31:0] rd_data1;
    wire [31:0] rd_data2;

    integer pass_count = 0;
    integer fail_count = 0;
    integer test_num   = 0;
    integer op;

    // Golden model software state
    reg [31:0] shadow_reg [0:31];
    integer k;

    reg [31:0] exp_rd1, exp_rd2;

    regfile uut (
        .clk(clk),
        .rst(rst),
        .we(we),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wr_data(wr_data),
        .rd_data1(rd_data1),
        .rd_data2(rd_data2)
    );

    // Clock generator: 10 ns period
    always #5 clk = ~clk;

    task check_ports;
        input [31:0]  exp1;
        input [31:0]  exp2;
        input [127:0] test_name;
        begin
            test_num = test_num + 1;
            #1;
            if ((rd_data1 === exp1) && (rd_data2 === exp2)) begin
                $display("[PASS] Test %03d (%0s): rd1=0x%08h, rd2=0x%08h", test_num, test_name, rd_data1, rd_data2);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Test %03d (%0s): rd1=0x%08h (exp 0x%08h), rd2=0x%08h (exp 0x%08h)",
                         test_num, test_name, rd_data1, exp1, rd_data2, exp2);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        clk     = 0;
        rst     = 1;
        we      = 0;
        rs1     = 0;
        rs2     = 0;
        rd      = 0;
        wr_data = 0;

        for (k = 0; k < 32; k = k + 1)
            shadow_reg[k] = 32'd0;

        $display("==============================================================");
        $display("   Starting Activity 1.4: Register File Self-Checking TB");
        $display("==============================================================");

        // --- DIRECTED TESTS ---
        // 1. Reset check
        @(posedge clk);
        #1; rst = 0;
        check_ports(32'd0, 32'd0, "Reset Check");

        // 2. x0 Write Invariance Test (Writing 0xDEADBEEF to x0 must not change x0)
        we      = 1;
        rd      = 5'd0;
        wr_data = 32'hDEAD_BEEF;
        rs1     = 5'd0;
        rs2     = 5'd0;
        check_ports(32'd0, 32'd0, "x0 Bypass Invariance (rd=0, we=1)");
        @(posedge clk);
        #1;
        we      = 0;
        check_ports(32'd0, 32'd0, "x0 Hardwire Read After Write");

        // 3. Normal Write & Read on Different Registers
        we      = 1;
        rd      = 5'd5;
        wr_data = 32'h1234_5678;
        @(posedge clk);
        #1;
        we      = 1;
        rd      = 5'd10;
        wr_data = 32'h8765_4321;
        @(posedge clk);
        #1;
        we  = 0;
        rs1 = 5'd5;
        rs2 = 5'd10;
        check_ports(32'h1234_5678, 32'h8765_4321, "Normal Read x5 and x10");

        // 4. Internal Write Bypass Test (Read same cycle as write to x5)
        we      = 1;
        rd      = 5'd5;
        wr_data = 32'hAAAA_BBBB;
        rs1     = 5'd5;
        rs2     = 5'd10; // Read old x10
        check_ports(32'hAAAA_BBBB, 32'h8765_4321, "Bypass Port 1 (Same Cycle Write)");
        @(posedge clk); #1;

        // 5. Internal Write Bypass Test on Port 2
        we      = 1;
        rd      = 5'd10;
        wr_data = 32'hCCCC_DDDD;
        rs1     = 5'd5; // Now reads updated x5 (0xAAAABBBB)
        rs2     = 5'd10; // Bypasses new x10 (0xCCCCDDDD)
        check_ports(32'hAAAA_BBBB, 32'hCCCC_DDDD, "Bypass Port 2 (Same Cycle Write)");
        @(posedge clk); #1;

        // 6. Back-to-back writes to consecutive registers
        for (k = 1; k < 16; k = k + 1) begin
            we      = 1;
            rd      = k[4:0];
            wr_data = 32'h1000_0000 + k;
            shadow_reg[k] = wr_data;
            @(posedge clk); #1;
        end
        we = 0;
        for (k = 1; k < 16; k = k + 2) begin
            rs1 = k[4:0];
            rs2 = (k + 1);
            check_ports(shadow_reg[rs1], shadow_reg[rs2], "Back-to-back Read Verification");
        end

        // --- RANDOMIZED STRESS TEST (250 Operations) ---
        $display("\n--- Starting 250 Random Operations with Golden Model Check ---");
        for (op = 0; op < 250; op = op + 1) begin
            we      = $random % 2;
            rd      = $random % 32;
            rs1     = $random % 32;
            rs2     = $random % 32;
            wr_data = {$random, $random};

            // Calculate expected combinational read data with bypass & x0 rule
            exp_rd1 = (rs1 == 5'd0)       ? 32'd0 :
                      (we && (rd == rs1)) ? wr_data : shadow_reg[rs1];

            exp_rd2 = (rs2 == 5'd0)       ? 32'd0 :
                      (we && (rd == rs2)) ? wr_data : shadow_reg[rs2];

            #2;
            test_num = test_num + 1;
            if ((rd_data1 === exp_rd1) && (rd_data2 === exp_rd2)) begin
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Random Op %0d: we=%b rd=%0d rs1=%0d rs2=%0d -> rd1=0x%08h (exp 0x%08h) rd2=0x%08h (exp 0x%08h)",
                         op, we, rd, rs1, rs2, rd_data1, exp_rd1, rd_data2, exp_rd2);
                fail_count = fail_count + 1;
            end

            // Synchronous update of golden model on clock edge
            @(posedge clk);
            if (we && (rd != 5'd0))
                shadow_reg[rd] = wr_data;
            #1;
        end

        #10;
        $display("==============================================================");
        $display(" Register File Results: %0d PASSED, %0d FAILED (Total %0d)", pass_count, fail_count, test_num);
        if (fail_count == 0)
            $display(" RESULT: ALL REGISTER FILE TESTS PASSED! [PASS]");
        else
            $display(" RESULT: SOME REGISTER FILE TESTS FAILED! [FAIL]");
        $display("==============================================================");
        $finish;
    end

endmodule
