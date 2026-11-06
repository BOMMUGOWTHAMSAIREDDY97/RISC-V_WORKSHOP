`timescale 1ns/1ps

// Activity 2.8b: Digital Watchdog Timer
// Periodically refreshed by 'kick' (heartbeat).
// Asserts 'timeout_expired' and generates 'reset_pulse' if not serviced within TIMEOUT_VAL cycles.

module watchdog #(
    parameter integer DEFAULT_TIMEOUT = 10
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        kick,             // Heartbeat service pulse
    input  wire [15:0] timeout_val,      // Programmable timeout limit
    output reg         timeout_expired,
    output reg         reset_pulse
);

    reg [15:0] count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count           <= 16'd0;
            timeout_expired <= 1'b0;
            reset_pulse     <= 1'b0;
        end else begin
            reset_pulse <= 1'b0;

            if (kick) begin
                count           <= 16'd0;
                timeout_expired <= 1'b0;
            end else if (count >= timeout_val - 1) begin
                timeout_expired <= 1'b1;
                reset_pulse     <= 1'b1;
                count           <= 16'd0; // Auto-reload after firing reset pulse
            end else begin
                count <= count + 1'b1;
            end
        end
    end

endmodule

