# Activity 4.5: Hazard Waveform Analysis

**STUDENT:** BOMMU GOWTHAM SAI REDDY
**REG NO:** 9923005065
**DEPT:** ECE  
**PROGRAM:** VERILOG RTL DESIGN AND RISC-V PROCESSOR DEVELOPMENT

---

## 1. Load-Use Hazard Waveform: Stall Bubble Insertion

**Scenario:** Instruction 5 is `LW x5, 0(x0)` and Instruction 6 is `ADD x8, x5, x1`, directly consuming the loaded register `x5`.

The Hazard Detection Unit detects that `id_ex_rd == x5`, `id_ex_mem_read == 1`, and `if_id_rs1 == x5` â†’ `load_use_stall = 1`.

**Observed waveform key signals:**
- `stall_if = 1` â†’ PC held at previous address (not incremented)
- `stall_id = 1` â†’ `IF/ID` pipeline register frozen
- `flush_ex = 1` â†’ `ID/EX` register overwritten with NOP (`0x00000013`)
- `id_ex_mem_read = 0` â†’ Bubble propagated to EX stage
- `stall_count` increments by 1

**Timeline (10ns clock period):**
```
Time:        50ns   60ns   70ns   80ns   90ns  100ns  110ns  120ns
IF stage:    LW     ADD    ADD    NOP    ...
ID stage:    NOP    LW     LW(H)  ADD    NOP    ...
EX stage:    ...    NOP    LW     NOPâ†  ADD    ...
                                   ^
                           stall_if=1 (bubble inserted into EX)
```

---

## 2. Branch Flush Waveform: Speculative Instruction Squash

**Scenario:** Instruction 7 is `BEQ x4, x2, +8` (taken), Instruction 8 is `ADDI x6, x0, 99` (speculative, must be flushed).

The EX stage evaluates `fwd_val_a == fwd_val_b â†’ 7 == 7 = TRUE` â†’ `branch_taken = 1`.

**Observed waveform key signals:**
- `branch_taken = 1` (combinational in EX stage)
- `pc <= branch_target` â†’ PC jumps to `0x24` (instruction index 9)
- `if_id_instr <= 0x00000013` â†’ NOP bubble
- `id_ex_instr <= 0x00000013` â†’ NOP bubble (flushes speculative `ADDI x6`)
- `flush_count` increments by 1
- `registers[6]` remains 0 (never written)

**Timeline:**
```
Time:        70ns   80ns   90ns  100ns  110ns
IF stage:    BEQ    ADDI   NOPâ†  x7    ...
ID stage:    ADD    BEQ    ADDIâ† NOP   x7
EX stage:    SW     ADD    BEQ   NOP   NOP   x7
                           ^
                   branch_taken=1 (flushes ADDI at ID, redirects PC)
```

