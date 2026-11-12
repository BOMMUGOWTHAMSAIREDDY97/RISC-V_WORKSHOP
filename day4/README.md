# Day 4: 5-Stage Pipeline Hazards, Analysis & Submission

**STUDENT NAME:** BOMMU GOWTHAM SAI REDDY  
**REG NO:** 9923005065  
**DEPT:** ECE  
**PROGRAM:** VERILOG RTL DESIGN AND RISC-V PROCESSOR DEVELOPMENT  
**TRAINER:** YUVARAJ SEENIPANDI, INFOZIANT (KALASALINGAM UNIVERSITY)

---

## Overview of Day 4 Activities

| Activity | Module / Artifact | Description | Verification Status |
| :--- | :--- | :--- | :---: |
| **4.1** | `src/forwarding_unit.v`, `src/riscv_5stage.v` | Full 5-Stage Pipeline with EX/MEM and MEM/WB Forwarding Paths | **4 / 4 PASSED** (0 FAILED) |
| **4.2** | `src/hazard_unit.v` | Load-Use Hazard Detection with 1-Cycle Stall & PC Freeze | **Verified — 1 stall cycle** |
| **4.3** | `report/cpi_comparison.md` | CPI Comparison: Single-Cycle (1.0) vs. 5-Stage Pipeline with hazards | **Completed** |
| **4.4** | Integrated in `src/riscv_5stage.v` | Branch Flush Unit: 2-stage speculative instruction squash on taken branch | **Verified — 1 flush event** |
| **4.5** | `report/hazard_waveform_4_5.md` | Waveform analysis of stall and flush timing across pipeline stages | **Completed** |
| **4.6** | Hardware counters in `src/riscv_5stage.v` | Performance counters: `cycle_count`, `instret_count`, `stall_count`, `flush_count` | **Verified — CPI ~1.43 amortized** |
| **4.7** | `tb/riscv_5stage_tb.v` | Integrated 5-stage pipeline self-checking testbench verification | **4 / 4 PASSED** (0 FAILED) |
| **4.8** | `report/architecture_diagram_4_8.md` | Full architecture diagram with forwarding paths, hazard units, and demo plan | **Completed** |

---

## Technical Summary & Architecture Breakdown

### 4.1 5-Stage Pipelined Datapath & Forwarding Unit (`src/riscv_5stage.v`, `src/forwarding_unit.v`)
- **Pipeline Architecture:** 5 synchronized stages (`IF`, `ID`, `EX`, `MEM`, `WB`) separated by 4 inter-stage pipeline registers (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`).
- **Instruction Support:** Full RV32I subset: `ADDI`, `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLT` (R/I), `LW`, `SW`, `BEQ`.
- **Forwarding Unit (`src/forwarding_unit.v`):** Dual 2-bit forwarding select signals (`forward_a`, `forward_b`) detect `EX/MEM` and `MEM/WB` RAW hazards and bypass most recent values directly into EX stage ALU inputs, eliminating arithmetic stalls.
- **WB-to-ID Internal Bypass:** Register file reads in the ID stage include an integrated MEM/WB bypass, eliminating stalls for instructions separated by 2 cycles.

### 4.2 Load-Use Hazard Detection Unit (`src/hazard_unit.v`)
- **Detection Condition:** Detects load-use RAW hazards when an instruction in the ID stage consumes the destination register of an in-flight `LW` in the EX stage (`id_ex_mem_read && ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))`).
- **Stall Insertion:** Freezes the Program Counter (`stall_if = 1`) and `IF/ID` pipeline register (`stall_id = 1`), while inserting a 1-cycle bubble (`NOP = 32'h00000013`) into `ID/EX` via `flush_ex = 1`.

### 4.3 Cycles Per Instruction (CPI) Performance Analysis (`report/cpi_comparison.md`)
- **Derivation & Modeling:** Compares single-cycle ($CPI = 1.0, F_{max} \approx 95\text{ MHz}$) against the 5-stage pipeline ($F_{max} \approx 416\text{ MHz}$).
- **Formula:** $CPI = 1.0 + \frac{\text{Stalls} + 2 \times \text{Flushes}}{\text{Instructions Retired}}$.
- **Benchmarked Result:** Measured effective $CPI \approx 1.43$, demonstrating a $\approx 3.06\times$ net throughput improvement over single-cycle execution.

### 4.4 Control Hazard Resolution & Branch Flushing (`src/riscv_5stage.v`)
- **Policy:** Predict-not-taken scheme. Branch conditions are evaluated in the EX/MEM pipeline stage using forwarded operands.
- **Flushing:** On `branch_taken = 1`, the controller synchronously flushes the two speculative instructions currently in `IF/ID` and `ID/EX` to `NOP` bubbles (`32'h00000013`) and redirects `PC` to `branch_target`.

### 4.5 Pipeline Hazard Waveform & Timing Analysis (`report/hazard_waveform_4_5.md`)
- Detailed cycle-by-cycle signal explanation and timing diagrams illustrating stall bubble insertion and 2-stage branch squashing.

### 4.6 Hardware Performance Counters (`src/riscv_5stage.v`)
- Four 32-bit hardware monitoring registers provide cycle-accurate execution profiling:
  - `cycle_count`: Total elapsed clock cycles.
  - `instret_count`: Total retired instructions committed in WB stage.
  - `stall_count`: Cycles lost to load-use hazards (1 cycle per hazard).
  - `flush_count`: Cycles lost to branch mispredictions (2 cycles per taken branch).

### 4.7 Integrated Pipeline Testbench Verification (`tb/riscv_5stage_tb.v`)
- Comprehensive self-checking verification suite validating EX/MEM and MEM/WB forwarding paths, load-use stall insertion, speculative branch flushing, and final memory and register commitments (**4 / 4 PASSED**).

### 4.8 5-Stage Datapath Architecture Diagram & Demo Notes (`report/architecture_diagram_4_8.md`)
- Full architectural datapath schematic, forwarding and hazard multiplexer maps, and structured 5-minute presentation demonstration plan.

---

## Simulation Results (Day 4 Testbench)

```
 x1 (ADDI 5)      = 5   (Expected: 5)
 x2 (ADDI 7)      = 7   (Expected: 7)
 x3 (ADD x1,x2)   = 12  (Expected: 12 — EX/MEM Forwarded)
 x4 (SUB x3,x1)   = 7   (Expected: 7  — EX-to-EX Forwarded)
 x5 (LW MEM[0])   = 12  (Expected: 12)
 x8 (ADD x5,x1)   = 17  (Expected: 17 — Load-Use Stall Handled)
 x6 (Skipped)     = 0   (Expected: 0  — Flushed by Branch)
 x7 (Branch Tgt)  = 11  (Expected: 11)
 DMEM[0]          = 12  (Expected: 12)

 Load-Use Stalls  : 1
 Branch Flushes   : 1
 Effective CPI    : ~1.43 (amortized over stream)
```

---

## Simulation & Waveform Instructions

### Running in ModelSim / QuestaSim
```tcl
cd day4
do run_day4.do
```

All simulation waveforms are captured as `.png` images in the `waves/` folder (e.g. `waves/4 (1).png` through `waves/4 (5).png`), displayed inline in the main `README.md`.
