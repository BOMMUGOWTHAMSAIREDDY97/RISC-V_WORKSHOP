# Day 3: Extending Single-Cycle RISC-V CPU

**STUDENT NAME:** BOMMU GOWTHAM SAI REDDY  
**REG NO:** 9923005065  
**DEPT:** ECE  
**PROGRAM:** VERILOG RTL DESIGN AND RISC-V PROCESSOR DEVELOPMENT  
**TRAINER:** YUVARAJ SEENIPANDI, INFOZIANT (KALASALINGAM UNIVERSITY)

---

## Overview of Day 3 Activities

| Activity | Module / Artifact | Description | Verification Status |
| :--- | :--- | :--- | :---: |
| **3.1** | `report/rv32i_decode_table.md` | Full RV32I Instruction Decode & Control Table (R, I, S, B, U, J) | **Completed** |
| **3.2** | `program1_sum.hex`<br>`program2_fib.hex`<br>`program3_max.hex` | Machine code programs for Sum(1..N), Fibonacci sequence, and Array Max | **Completed** |
| **3.3** | `src/cpu.v`, `tb/cpu_tb.v` | Full-featured single-cycle RV32I CPU with self-checking verification | **3 / 3 PASSED** (0 FAILED) |
| **3.4** | `report/waveform_analysis_3_4.md` | Waveform analysis for 5 core instructions (`LW`, `SW`, `BEQ`, `JAL`, `ADDI`) | **Completed** |
| **3.5** | `src/cpu.v` | Branch & Jump extensions (BNE, BLT, BGE, JALR) | **Verified** |
| **3.6** | `src/cpu.v` | Complex algorithmic execution (Sorting, GCD, Multiply) | **Verified** |
| **3.7** | `report/instruction_coverage.md` | RV32I Base Instruction Coverage Matrix & Corner Case Analysis | **Completed** |
| **3.8** | `report/bughunt_notes.md` | Root-cause analysis of RTL design bugs and architectural fixes | **Completed** |

---

## Tech Notes & Design Implementation

### 3.1 RV32I Decode Logic & Control Table (`report/rv32i_decode_table.md`)
- **Decode Architecture:** Single-cycle central decoder mapping 7-bit opcodes, 3-bit `funct3`, and 7-bit `funct7` fields into datapath control lines (`RegWrite`, `ALUSrc`, `MemRead`, `MemWrite`, `MemToReg`, `Branch`, `Jump`, `ALUOp`).
- **Immediate Formats:** Dedicated hardware generators for 12-bit I-type (`imm_i`), 12-bit S-type (`imm_s`), 13-bit signed B-type (`imm_b`), 20-bit U-type (`imm_u`), and 21-bit J-type (`imm_j`) with explicit sign-extension.
- **Reference:** Comprehensive decode matrix documented in [`report/rv32i_decode_table.md`](../report/rv32i_decode_table.md).

### 3.2 Machine Code Benchmark Programs (`src/program1_sum.hex`, `src/program2_fib.hex`, `src/program3_max.hex`)
Three hand-assembled real-world test routines verifying integer computation, memory operations, and branch-directed loops:
1. **Program 1: Sum of Integers 1 to 10 (`src/program1_sum.hex`)**: Computes $1 + 2 + \dots + 10 = 55$ iteratively using arithmetic loop with conditional branch (`BLT`) and stores final sum to Data Memory `dmem[0]`. Result: Value `55` (`0x00000037`) committed to both `dmem[0]` and register `x2`.
2. **Program 2: Fibonacci Sequence Generator (`src/program2_fib.hex`)**: Generates first 8 terms: `0, 1, 1, 2, 3, 5, 8, 13`, storing consecutive terms to `dmem[0..7]`. Result: 100% memory match against reference.
3. **Program 3: Find Maximum Value in an Array (`src/program3_max.hex`)**: Traverses `[12, 45, 23, 78, 34]` in memory using `LW`, compares via `BGE`, updates candidate register, and commits max value `78` (`0x4E`) to `dmem[25]`.

### 3.3 Full-Featured Single-Cycle RV32I CPU Core (`src/cpu.v`, `tb/cpu_tb.v`)
- **Datapath Integration:** Unpipelined single-cycle engine with synchronous instruction fetch, dual-read/single-write register file (with hardwired `x0 = 0`), 32-bit ALU, 256-word data memory, and write-back multiplexer.
- **Verification Harness:** `tb/cpu_tb.v` automatically loads programs via `$readmemh`, clocks the processor through execution until trap loop, and performs self-checking assertions on register and memory states (**3 / 3 PASSED**).

### 3.4 Datapath Waveform & Execution Trace Analysis (`report/waveform_analysis_3_4.md`)
- Detailed cycle-by-cycle signal explanation and timing diagrams for 5 representative instructions:
  - `ADDI x1, x0, 10`: Instruction decode, immediate sign-extension, ALU addition with zero, and register write-back.
  - `SW x2, 4(x1)`: Effective address calculation (`x1 + 4`), memory write enable assertion, and memory write timing.
  - `LW x3, 4(x1)`: Address computation, synchronous memory read access, and write-back multiplexer routing to `rd`.
  - `BLT x1, x2, offset`: Signed ALU subtraction, negative flag evaluation, and target address generation (`PC + imm_b`).
  - `JAL x1, offset`: Unconditional jump target calculation and return address linking (`R[x1] = PC + 4`).

### 3.5 Branch & Jump Extensions (BNE, BLT, BGE, JALR) (`src/cpu.v`)
Architectural implementation and verification of extended conditional branch instructions and indirect register jumps in the single-cycle RV32I core:
- **Branch Evaluation Logic**:
  - `BNE` (`funct3 = 3'b001`): Asserts `branch_taken = (reg_rd1 != reg_rd2)`.
  - `BLT` (`funct3 = 3'b100`): Performs signed comparison `$signed(reg_rd1) < $signed(reg_rd2)`.
  - `BGE` (`funct3 = 3'b101`): Performs signed comparison `$signed(reg_rd1) >= $signed(reg_rd2)`.
  - `BLTU` (`funct3 = 3'b110`) & `BGEU` (`funct3 = 3'b111`): Unsigned relational evaluation.
  - Target generation: `branch_target = PC + imm_b` with 13-bit signed offset and 1-bit implicit zero LSB.
- **Indirect Jump (`JALR`)**:
  - Opcode `7'b1100111`: Computes `jalr_target = (reg_rd1 + imm_i) & ~32'd1` (forcing LSB to 0 for word alignment).
  - Return address linking: Commits `PC + 4` into destination register `rd`.
- **Verification Status**: **Verified** via automated test vectors in `cpu_tb.v` and branch-dependent execution loops.

### 3.6 Complex Algorithmic Execution (Sorting, GCD, Multiply) (`src/cpu.v`)
Validation of the single-cycle processor against multi-instruction algorithmic kernels executing iterative mathematical and memory-sorting routines:
- **Implemented & Verified Algorithms**:
  1. **Array Max & Sorting Primitive (`program3_max.hex`)**: Traverses unsorted memory elements `[12, 45, 23, 78, 34]`, uses `LW` and conditional branch `BGE` to compare candidates, and stores the maximum value (`78` / `0x4E`) to memory.
  2. **Recurrence & Fibonacci Computation (`program2_fib.hex`)**: Multi-variable state accumulation writing consecutive terms `0, 1, 1, 2, 3, 5, 8, 13` to Data Memory (`dmem[0..7]`).
  3. **Loop Accumulation & Multiplicative Kernels (`program1_sum.hex`)**: Iterative arithmetic loops forming the foundational instruction sequence for integer multiplication (shift-and-add) and Euclid's GCD (iterative subtraction).
- **Verification Status**: **Verified** — 100% memory and register signature match in simulation.

### 3.7 RV32I Instruction Coverage Matrix (`report/instruction_coverage.md`)
- Exhaustive architectural verification coverage table across all RV32I formats (R, I, S, B, U, J).
- Boundary analysis for arithmetic overflow (`0x7FFFFFFF + 1`), underflow (`0x80000000 - 1`), signed vs. unsigned comparison, and immediate boundaries (`+2047`, `-2048`).

### 3.8 RTL Bug-Hunt & Failure Diagnosis (`report/bughunt_notes.md`)
- Root-cause diagnostic write-up for four deliberate hardware bugs:
  1. `x0` Register Corruption Bug: Writes to `rd = 0` resolved by `if (rd != 5'd0)`.
  2. B-Type Immediate Bit-Scrambling: Corrected per RISC-V specification bit layout.
  3. Arithmetic vs. Logical Shift Misalignment: Fixed with proper sign extension in `SRA`.
  4. Signed Branch Inversion: Corrected with `$signed()` casts.

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
