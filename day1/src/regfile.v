`timescale 1ns/1ps

// Activity 1.4: 32 x 32 Register File with Internal Write Bypass
// Two asynchronous read ports, one synchronous write port
// Register x0 is hardwired to 0
// Internal bypass: read in the same cycle as write to the same address returns new write data

module regfile (
    input  wire        clk,
    input  wire        rst,
    input  wire        we,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [31:0] wr_data,
    output wire [31:0] rd_data1,
    output wire [31:0] rd_data2
);

    reg [31:0] registers [0:31];
    integer i;

    // Synchronous write port with synchronous active-high reset
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'd0;
        end else if (we && (rd != 5'd0)) begin
            registers[rd] <= wr_data;
        end
    end

    // Asynchronous read port 1 with x0 hardwire and internal write bypass
    assign rd_data1 = (rs1 == 5'd0)           ? 32'd0 :
                      (we && (rd == rs1))     ? wr_data :
                                                registers[rs1];

    // Asynchronous read port 2 with x0 hardwire and internal write bypass
    assign rd_data2 = (rs2 == 5'd0)           ? 32'd0 :
                      (we && (rd == rs2))     ? wr_data :
                                                registers[rs2];

endmodule

