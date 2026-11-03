`timescale 1ns/1ps

module elevator_tb;

reg clk, reset;
reg request_valid;
reg [1:0] request_floor;

wire [1:0] current_floor;
wire motor_up, motor_down;
wire door_open, busy;

elevator uut (
    .clk(clk),
    .reset(reset),
    .request_valid(request_valid),
    .request_floor(request_floor),
    .current_floor(current_floor),
    .motor_up(motor_up),
    .motor_down(motor_down),
    .door_open(door_open),
    .busy(busy)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 1;
    request_valid = 0;
    request_floor = 0;

    // Reset
    #10;
    reset = 0;

    // Request Floor 3
    @(negedge clk);
    request_floor = 3;
    request_valid = 1;
    @(negedge clk);
    request_valid = 0;

    // Wait until elevator becomes idle
    wait (busy == 0);
    #10;

    // Request Floor 1
    @(negedge clk);
    request_floor = 1;
    request_valid = 1;
    @(negedge clk);
    request_valid = 0;

    wait (busy == 0);
    #10;

    // Request Floor 0
    @(negedge clk);
    request_floor = 0;
    request_valid = 1;
    @(negedge clk);
    request_valid = 0;

    wait (busy == 0);
    #10;

    $display("Simulation completed successfully");
    $finish;
end

initial begin
    $monitor("Time=%0t | Floor=%0d | Request=%0d | Up=%b | Down=%b | Door=%b | Busy=%b",
        $time, current_floor, request_floor,
        motor_up, motor_down, door_open, busy);
end

endmodule
