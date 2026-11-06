`timescale 1ns/1ps

// Activity 1.8: Digital Button Debouncer with Counter Filter
// Integrates counter-based sampling to reject mechanical switch bounce glitches.
// Only transitions output when the input signal remains stable for THRESHOLD clock cycles.

module debounce #(
    parameter integer THRESHOLD = 8
) (
    input  wire clk,
    input  wire reset,
    input  wire noisy_in,
    output reg  debounced_out
);

    // Synchronize input
    reg sync_0;
    reg sync_1;

    // Counter for stable duration
    reg [15:0] count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sync_0        <= 1'b0;
            sync_1        <= 1'b0;
            debounced_out <= 1'b0;
            count         <= 16'd0;
        end else begin
            sync_0 <= noisy_in;
            sync_1 <= sync_0;

            if (sync_1 != debounced_out) begin
                if (count >= THRESHOLD - 1) begin
                    debounced_out <= sync_1;
                    count         <= 16'd0;
                end else begin
                    count <= count + 1'b1;
                end
            end else begin
                count <= 16'd0;
            end
        end
    end

endmodule

