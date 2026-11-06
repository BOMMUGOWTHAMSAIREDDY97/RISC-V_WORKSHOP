`timescale 1ns/1ps

// Activity 1.2: 8-bit Up/Down Counter with Synchronous Reset, Enable, and Parallel Load

module counter #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             reset,     // Synchronous active-high reset
    input  wire             enable,    // Count enable
    input  wire             up_down,   // 1 = Count Up, 0 = Count Down
    input  wire             load,      // Parallel load enable
    input  wire [WIDTH-1:0] load_data, // Data for parallel load
    output reg  [WIDTH-1:0] count      // Counter output
);

    always @(posedge clk) begin
        if (reset) begin
            count <= {WIDTH{1'b0}};
        end else if (load) begin
            count <= load_data;
        end else if (enable) begin
            if (up_down)
                count <= count + 1'b1;
            else
                count <= count - 1'b1;
        end
    end

endmodule

