`timescale 1ns/1ps

// Activity 4.1b & 4.2: Hazard Detection & Pipeline Stall/Flush Unit
// Resolves Load-Use RAW hazards via single-cycle stall and branch mispredictions via pipeline flush.

module hazard_unit (
    input  wire [4:0] if_id_rs1,
    input  wire [4:0] if_id_rs2,
    input  wire       if_id_use_rs2,
    input  wire [4:0] id_ex_rd,
    input  wire       id_ex_mem_read,
    input  wire       branch_taken,
    output wire       stall_if,
    output wire       stall_id,
    output wire       flush_id,
    output wire       flush_ex
);

    // Load-Use hazard condition:
    // If instruction in EX stage is a Load, and the instruction in ID stage consumes the loaded register
    wire load_use_detected = id_ex_mem_read && (id_ex_rd != 5'd0) &&
                             ((id_ex_rd == if_id_rs1) || (if_id_use_rs2 && (id_ex_rd == if_id_rs2)));

    // Stall controls
    assign stall_if = load_use_detected;
    assign stall_id = load_use_detected;

    // Flush controls
    assign flush_id = branch_taken;
    assign flush_ex = load_use_detected || branch_taken;

endmodule

