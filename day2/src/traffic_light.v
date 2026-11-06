`timescale 1ns/1ps

// Activity 2.5: Traffic Light Controller FSM with Pedestrian Request
// Controls Main Street (Red, Yellow, Green) and Pedestrian Crosswalk (Walk, Don't Walk)
// Features internal cycle timers and pedestrian button interrupt handling.

module traffic_light #(
    parameter integer GREEN_TIME  = 10,
    parameter integer YELLOW_TIME = 3,
    parameter integer RED_TIME    = 8
) (
    input  wire clk,
    input  wire reset,
    input  wire ped_btn,       // Pedestrian push button
    output reg  main_red,
    output reg  main_yellow,
    output reg  main_green,
    output reg  ped_walk,
    output reg  ped_dont_walk
);

    localparam [1:0] S_GREEN  = 2'b00,
                     S_YELLOW = 2'b01,
                     S_RED    = 2'b10;

    reg [1:0] state, next_state;
    reg [7:0] timer;
    reg       ped_pending;

    // Pedestrian request latch
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ped_pending <= 1'b0;
        end else begin
            if (ped_btn && state != S_RED)
                ped_pending <= 1'b1;
            else if (state == S_RED)
                ped_pending <= 1'b0; // Request serviced during RED state
        end
    end

    // State & Timer register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_GREEN;
            timer <= 8'd0;
        end else begin
            if (state != next_state) begin
                state <= next_state;
                timer <= 8'd0;
            end else begin
                timer <= timer + 1'b1;
            end
        end
    end

    // Next-state logic
    always @(*) begin
        next_state = state;
        case (state)
            S_GREEN: begin
                // Transition to YELLOW if time elapsed OR if pedestrian request pending after min green time
                if (timer >= GREEN_TIME - 1 || (ped_pending && timer >= 3))
                    next_state = S_YELLOW;
            end

            S_YELLOW: begin
                if (timer >= YELLOW_TIME - 1)
                    next_state = S_RED;
            end

            S_RED: begin
                if (timer >= RED_TIME - 1)
                    next_state = S_GREEN;
            end

            default: next_state = S_GREEN;
        endcase
    end

    // Output decode logic
    always @(*) begin
        main_green    = 1'b0;
        main_yellow   = 1'b0;
        main_red      = 1'b0;
        ped_walk      = 1'b0;
        ped_dont_walk = 1'b1;

        case (state)
            S_GREEN: begin
                main_green    = 1'b1;
                ped_dont_walk = 1'b1;
            end

            S_YELLOW: begin
                main_yellow   = 1'b1;
                ped_dont_walk = 1'b1;
            end

            S_RED: begin
                main_red      = 1'b1;
                ped_walk      = 1'b1;
                ped_dont_walk = 1'b0;
            end
        endcase
    end

endmodule

