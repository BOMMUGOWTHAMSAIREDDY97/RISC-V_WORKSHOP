`timescale 1ns/1ps

// Activity 4.1a: 5-Stage Pipeline Forwarding Unit (Bypass Logic)
// Detects RAW hazards across EX/MEM and MEM/WB stages and routes most up-to-date operands.

module forwarding_unit (
    input  wire [4:0] id_ex_rs1,
    input  wire [4:0] id_ex_rs2,
    input  wire [4:0] ex_mem_rd,
    input  wire       ex_mem_reg_write,
    input  wire [4:0] mem_wb_rd,
    input  wire       mem_wb_reg_write,
    output reg  [1:0] forward_a,
    output reg  [1:0] forward_b
);

    // Forwarding for Operand A (rs1)
    always @(*) begin
        forward_a = 2'b00; // Default: Register read from ID/EX register

        // EX Hazard (Priority 1 - most recent)
        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs1)) begin
            forward_a = 2'b10;
        end
        // MEM Hazard (Priority 2)
        else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs1)) begin
            forward_a = 2'b01;
        end
    end

    // Forwarding for Operand B (rs2)
    always @(*) begin
        forward_b = 2'b00; // Default: Register read from ID/EX register

        // EX Hazard (Priority 1)
        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs2)) begin
            forward_b = 2'b10;
        end
        // MEM Hazard (Priority 2)
        else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs2)) begin
            forward_b = 2'b01;
        end
    end

endmodule

