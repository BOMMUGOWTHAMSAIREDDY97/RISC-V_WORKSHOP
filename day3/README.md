# Day 3: Extending Single-Cycle RISC-V CPU

**Student Name:** Bommu Gowtham Sai Reddy  
**Program:** Verilog RTL Design and RISC-V Processor Development  
**Trainer:** Yuvaraj Seenipandi, Infoziant (Kalasalingam University)

---

## Overview of Day 3 Activities

| Activity | Module / Artifact | Description | Verification Status |
| :--- | :--- | :--- | :---: |
| **3.1** | `report/rv32i_decode_table.md` | Full RV32I Instruction Decode & Control Table (R, I, S, B, U, J) | **Completed** |
| **3.2** | `program1_sum.hex`<br>`program2_fib.hex`<br>`program3_max.hex` | Machine code programs for Sum(1..N), Fibonacci sequence, and Array Max | **Completed** |
| **3.3** | `src/cpu.v`, `tb/cpu_tb.v` | Full-featured single-cycle RV32I CPU with self-checking verification | **3 / 3 PASSED** (0 FAILED) |
| **3.4** | `report/waveform_analysis_3_4.md` | Waveform analysis for 5 core instructions (`LW`, `SW`, `BEQ`, `JAL`, `ADDI`) | **Completed** |
| **3.7** | `report/instruction_coverage.md` | RV32I Base Instruction Coverage Matrix & Corner Case Analysis | **Completed** |
| **3.8** | `report/bughunt_notes.md` | Root-cause analysis of RTL design bugs and architectural fixes | **Completed** |

---

## Technical Summary of Programs Verified

### 1. Program 1: Sum of Integers 1 to 10 (`src/program1_sum.hex`)
- Computes $1 + 2 + \dots + 10 = 55$ iteratively using arithmetic loop with conditional branch (`BLT`) and stores the final sum to Data Memory at `dmem[0]`.
- **Result:** Value `55` (`0x00000037`) verified in both `dmem[0]` and register `x2`.

### 2. Program 2: Fibonacci Sequence Generator (`src/program2_fib.hex`)
- Generates the first 8 numbers of the Fibonacci sequence: `0, 1, 1, 2, 3, 5, 8, 13`.
- Continuously stores sequence terms into consecutive Data Memory word slots `dmem[0]` through `dmem[7]`.
- **Result:** All 8 words in memory matched golden reference array 100%.

### 3. Program 3: Find Maximum Value in an Array (`src/program3_max.hex`)
- Traverses an unsorted array stored in memory: `[12, 45, 23, 78, 34]`.
- Iteratively loads each element with `LW`, compares against the running maximum with `BGE`, updates register `x3` on larger elements, and writes the maximum to `dmem[25]`.
- **Result:** Successfully extracted and committed max value `78` to memory and registers.

---

## Simulation & Waveform Instructions

### Running in ModelSim / QuestaSim
Open ModelSim in the project directory:
```tcl
cd day3
do run_day3.do
```

To view waveform screenshots:
All simulation waveforms are captured as `.png` images in `waves/` (e.g. `waves/3 (1).png`).

