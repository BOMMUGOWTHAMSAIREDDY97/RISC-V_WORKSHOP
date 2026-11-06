`timescale 1ns/1ps

// Activity 2.3: Parameterized Synchronous FIFO Memory
// Depth = 16, Width = 8-bit
// Features: Full, Empty, Almost Full, Almost Empty flags, and overflow/underflow protection.

module fifo #(
    parameter integer DATA_WIDTH = 8,
    parameter integer DEPTH      = 16,
    parameter integer ADDR_WIDTH = 4   // 2^ADDR_WIDTH = DEPTH
) (
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] din,
    input  wire                  rd_en,
    output reg  [DATA_WIDTH-1:0] dout,
    output wire                  full,
    output wire                  empty,
    output wire                  almost_full,
    output wire                  almost_empty,
    output reg  [ADDR_WIDTH:0]   count
);

    // Memory array
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Read and Write pointers
    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;

    // Status flags
    assign empty        = (count == 0);
    assign full         = (count == DEPTH);
    assign almost_empty = (count <= 1);
    assign almost_full  = (count >= DEPTH - 1);

    // Effective write and read operations (gated with protection)
    wire do_write = wr_en && (!full || rd_en);
    wire do_read  = rd_en && !empty;

    // Synchronous write & pointer logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_ptr <= {ADDR_WIDTH{1'b0}};
            rd_ptr <= {ADDR_WIDTH{1'b0}};
            dout   <= {DATA_WIDTH{1'b0}};
            count  <= {(ADDR_WIDTH+1){1'b0}};
        end else begin
            // Memory Write
            if (do_write) begin
                mem[wr_ptr] <= din;
                wr_ptr      <= (wr_ptr == DEPTH - 1) ? {ADDR_WIDTH{1'b0}} : wr_ptr + 1'b1;
            end

            // Memory Read
            if (do_read) begin
                dout   <= mem[rd_ptr];
                rd_ptr <= (rd_ptr == DEPTH - 1) ? {ADDR_WIDTH{1'b0}} : rd_ptr + 1'b1;
            end

            // Count tracking
            case ({do_write, do_read})
                2'b10: count <= count + 1'b1; // Write only
                2'b01: count <= count - 1'b1; // Read only
                default: count <= count;      // Both or neither
            endcase
        end
    end

endmodule

