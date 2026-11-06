# Activity 3.7: RV32I Instruction Coverage Matrix

**STUDENT:** BOMMU GOWTHAM SAI REDDY
**REG NO:** 9923005065
**DEPT:** ECE  
**PROGRAM:** VERILOG RTL DESIGN AND RISC-V PROCESSOR DEVELOPMENT  
**TRAINER:** YUVARAJ SEENIPANDI, INFOZIANT (KALASALINGAM UNIVERSITY)

---

## 1. Instruction Set Coverage Summary

| Instruction Category | Total in RV32I Base | Implemented in Core | Verified in Testbench | Verification Vector / Hex Program |
| :--- | :---: | :---: | :---: | :--- |
| **R-Type Arithmetic/Logic** | 10 | 10 (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND) | 10 | `alu_tb.v`, `program1_sum.hex`, `program2_fib.hex`, `program3_max.hex` |
| **I-Type Arithmetic/Logic** | 9 | 9 (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI) | 9 | `cpu_tb.v`, `program1_sum.hex`, `program2_fib.hex`, `program3_max.hex` |
| **Load Instructions** | 5 | LW (Word) | Verified | `program3_max.hex` (Array loading) |
| **Store Instructions** | 3 | SW (Word) | Verified | `program1_sum.hex`, `program2_fib.hex`, `program3_max.hex` |
| **Branch Instructions** | 6 | BEQ, BNE, BLT, BGE, BLTU, BGEU | Verified | Loop condition evaluation in `program1`, `program2`, `program3` |
| **Upper Immediate** | 2 | LUI, AUIPC | Verified | `cpu_tb.v` directed execution |
| **Jump Instructions** | 2 | JAL, JALR | Verified | Loop repetition & function jumps |

---

## 2. Corner Case Coverage Table

| Corner Case Scenario | Mechanism Tested | Expected Behavior | Verification Status |
| :--- | :--- | :--- | :---: |
| **Register x0 Hardwired Zero** | Attempt to write non-zero value to `x0` (`ADDI x0, x0, 10`) | `x0` remains strictly `32'b0` at all times | **PASSED** |
| **Immediate Sign Extension** | Negative immediate decoding in `ADDI`, `LW`, `SW` | Negative immediates extend MSB 1s correctly across bits [31:12] | **PASSED** |
| **Backward Branch Displacement** | Negative jump target calculation in loop | Signed displacement added to PC without truncation | **PASSED** |
| **Word Alignment of PC Target** | JAL / JALR branch targets | Bit 0 forced to 0 to prevent unaligned instruction fetch | **PASSED** |
| **Load-to-Use Data Hazard** | Loading memory and consuming immediately in single-cycle | Single-cycle datapath completes memory access within clock period | **PASSED** |

