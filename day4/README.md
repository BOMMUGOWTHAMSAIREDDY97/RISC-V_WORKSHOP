# Day 4: 5-Stage Pipeline Hazards, Analysis & Submission

**Student Name:** Bommu Gowtham Sai Reddy  
**Program:** Verilog RTL Design and RISC-V Processor Development  
**Trainer:** Yuvaraj Seenipandi, Infoziant (Kalasalingam University)

---

## Overview of Day 4 Activities

| Activity | Module / Artifact | Description | Verification Status |
| :--- | :--- | :--- | :---: |
| **4.1** | `src/forwarding_unit.v`, `src/riscv_5stage.v` | Full 5-Stage Pipeline with EX/MEM and MEM/WB Forwarding Paths | **4 / 4 PASSED** (0 FAILED) |
| **4.1** | `src/hazard_unit.v` | Load-Use Hazard Detection with 1-Cycle Stall & PC Freeze | **Verified — 1 stall cycle** |
| **4.2** | Integrated in `src/riscv_5stage.v` | Branch Flush Unit: 2-stage speculative instruction squash on taken branch | **Verified — 1 flush event** |
| **4.3** | `report/cpi_comparison.md` | CPI Comparison: Single-Cycle (1.0) vs. 5-Stage Pipeline with hazards | **Completed** |
| **4.5** | `report/hazard_waveform_4_5.md` | Waveform analysis of stall and flush timing across pipeline stages | **Completed** |
| **4.6** | Hardware counters in `riscv_5stage.v` | Performance counters: `cycle_count`, `instret_count`, `stall_count`, `flush_count` | **Verified — CPI ~1.43 amortized** |
| **4.8** | `report/architecture_diagram_4_8.md` | Full architecture diagram with forwarding paths, hazard units, and pipeline stage summary | **Completed** |

---

## Technical Summary

### 5-Stage Pipeline Design (`src/riscv_5stage.v`)
- **Full instruction support:** `ADDI`, `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLT` (R/I), `LW`, `SW`, `BEQ` (expandable).
- **Forwarding Unit (`src/forwarding_unit.v`):** Dual 2-bit forwarding select signals (`forward_a`, `forward_b`) detect EX/MEM and MEM/WB RAW hazards and bypass most recent values directly into EX stage ALU inputs.
- **WB-to-ID Internal Bypass:** Register file reads in the ID stage include an additional MEM/WB bypass, eliminating the need for a 3-cycle stall on instructions separated by 2 cycles.
- **Hazard Unit (`src/hazard_unit.v`):** Detects load-use RAW hazard by checking `id_ex_mem_read` with the destination register matching IF/ID rs1 or rs2. Issues `stall_if`, `stall_id`, and `flush_ex` signals to freeze the fetch/decode registers and insert NOP bubbles.
- **Branch Resolution:** Branch condition evaluated in the EX stage with forwarded operands. `branch_taken` triggers an immediate PC redirect and synchronous flush of the IF/ID and ID/EX pipeline registers.
- **Hardware Performance Counters:** Four 32-bit cycle-accurate counters provide real-time CPI measurement: `cycle_count`, `instret_count`, `stall_count`, `flush_count`.

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

