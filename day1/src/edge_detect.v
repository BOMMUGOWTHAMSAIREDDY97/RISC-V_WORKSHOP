`timescale 1ns/1ps

// Activity 1.8: Synchronous Edge Detector with 2-Stage Input Synchronizer
// Detects rising edges, falling edges, and any edge transitions.
// Outputs single clock-cycle pulses.

module edge_detect (
    input  wire clk,
    input  wire reset,
    input  wire signal_in,
    output wire rise_pulse,
    output wire fall_pulse,
    output wire any_edge
);

    // 2-stage synchronizer to eliminate input metastability
    reg sync_ff1;
    reg sync_ff2;
    // Delayed flop for edge detection
    reg sync_ff3;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
            sync_ff3 <= 1'b0;
        end else begin
            sync_ff1 <= signal_in;
            sync_ff2 <= sync_ff1;
            sync_ff3 <= sync_ff2;
        end
    end

    // Edge detection logic on synchronized signals
    assign rise_pulse =  sync_ff2 & ~sync_ff3;
    assign fall_pulse = ~sync_ff2 &  sync_ff3;
    assign any_edge   =  sync_ff2 ^  sync_ff3;

endmodule

