`timescale 1ns/1ps

// Activity 2.7: 4-Way Round-Robin Arbiter
// Guarantees fairness and starvation-free bus access across 4 requesting agents.
// Rotating priority pointer advances after each grant.

module arbiter (
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] req,
    output reg  [3:0] grant
);

    reg [1:0] priority_ptr; // Points to the requester with highest priority

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            grant        <= 4'b0000;
            priority_ptr <= 2'b00;
        end else begin
            grant <= 4'b0000;

            case (priority_ptr)
                2'd0: begin
                    if      (req[0]) begin grant <= 4'b0001; priority_ptr <= 2'd1; end
                    else if (req[1]) begin grant <= 4'b0010; priority_ptr <= 2'd2; end
                    else if (req[2]) begin grant <= 4'b0100; priority_ptr <= 2'd3; end
                    else if (req[3]) begin grant <= 4'b1000; priority_ptr <= 2'd0; end
                end

                2'd1: begin
                    if      (req[1]) begin grant <= 4'b0010; priority_ptr <= 2'd2; end
                    else if (req[2]) begin grant <= 4'b0100; priority_ptr <= 2'd3; end
                    else if (req[3]) begin grant <= 4'b1000; priority_ptr <= 2'd0; end
                    else if (req[0]) begin grant <= 4'b0001; priority_ptr <= 2'd1; end
                end

                2'd2: begin
                    if      (req[2]) begin grant <= 4'b0100; priority_ptr <= 2'd3; end
                    else if (req[3]) begin grant <= 4'b1000; priority_ptr <= 2'd0; end
                    else if (req[0]) begin grant <= 4'b0001; priority_ptr <= 2'd1; end
                    else if (req[1]) begin grant <= 4'b0010; priority_ptr <= 2'd2; end
                end

                2'd3: begin
                    if      (req[3]) begin grant <= 4'b1000; priority_ptr <= 2'd0; end
                    else if (req[0]) begin grant <= 4'b0001; priority_ptr <= 2'd1; end
                    else if (req[1]) begin grant <= 4'b0010; priority_ptr <= 2'd2; end
                    else if (req[2]) begin grant <= 4'b0100; priority_ptr <= 2'd3; end
                end
            endcase
        end
    end

endmodule

