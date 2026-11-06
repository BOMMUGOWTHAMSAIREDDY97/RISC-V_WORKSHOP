`timescale 1ns/1ps

module elevator(
    input clk,
    input reset,
    input request_valid,
    input [1:0] request_floor,

    output reg [1:0] current_floor,
    output motor_up,
    output motor_down,
    output door_open,
    output busy
);

reg [1:0] target_floor;
reg [1:0] state;
reg [1:0] door_count;

parameter IDLE = 2'b00,
          UP   = 2'b01,
          DOWN = 2'b10,
          DOOR = 2'b11;

assign motor_up   = (state == UP);
assign motor_down = (state == DOWN);
assign door_open  = (state == DOOR);
assign busy       = (state != IDLE);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_floor <= 0;
        target_floor <= 0;
        state <= IDLE;
        door_count <= 0;
    end
    else begin
        case (state)

            IDLE: begin
                if (request_valid) begin
                    target_floor <= request_floor;

                    if (request_floor > current_floor)
                        state <= UP;
                    else if (request_floor < current_floor)
                        state <= DOWN;
                    else begin
                        state <= DOOR;
                        door_count <= 0;
                    end
                end
            end

            UP: begin
                if (current_floor < target_floor) begin
                    current_floor <= current_floor + 1'b1;

                    if (current_floor + 1'b1 == target_floor) begin
                        state <= DOOR;
                        door_count <= 0;
                    end
                end
            end

            DOWN: begin
                if (current_floor > target_floor) begin
                    current_floor <= current_floor - 1'b1;

                    if (current_floor - 1'b1 == target_floor) begin
                        state <= DOOR;
                        door_count <= 0;
                    end
                end
            end

            DOOR: begin
                if (door_count == 2) begin
                    state <= IDLE;
                    door_count <= 0;
                end
                else begin
                    door_count <= door_count + 1'b1;
                end
            end

        endcase
    end
end

endmodule