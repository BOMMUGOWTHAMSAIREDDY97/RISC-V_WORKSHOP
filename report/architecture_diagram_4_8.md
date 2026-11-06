# Activity 4.8: Architecture Diagram & Demo Notes

**STUDENT:** BOMMU GOWTHAM SAI REDDY
**REG NO:** 9923005065
**DEPT:** ECE  
**PROGRAM:** VERILOG RTL DESIGN AND RISC-V PROCESSOR DEVELOPMENT  
**TRAINER:** YUVARAJ SEENIPANDI, INFOZIANT (KALASALINGAM UNIVERSITY)

---

## 1. 5-Stage RV32I Pipeline Architecture Diagram

```
         â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
         â”‚                    5-Stage Pipelined RV32I Processor                                         â”‚
         â”‚                                                                                               â”‚
         â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”  IF/ID  â”Œâ”€â”€â”€â”€â”€â”€â”  ID/EX  â”Œâ”€â”€â”€â”€â”€â”€â”  EX/MEM  â”Œâ”€â”€â”€â”€â”€â”€â”  MEM/WB  â”Œâ”€â”€â”€â”€â”€â”€â”          â”‚
         â”‚  â”‚  IF  â”‚â•â•â•â•â•â•â•â•>â”‚  ID  â”‚â•â•â•â•â•â•â•â•â•>â”‚  EX  â”‚â•â•â•â•â•â•â•â•â•â•>â”‚ MEM  â”‚â•â•â•â•â•â•â•â•â•â•>â”‚  WB  â”‚          â”‚
         â”‚  â””â”€â”€â”€â”€â”€â”€â”˜         â””â”€â”€â”€â”€â”€â”€â”˜          â””â”€â”€â”€â”€â”€â”€â”˜           â””â”€â”€â”€â”€â”€â”€â”˜          â””â”€â”€â”€â”€â”€â”€â”˜          â”‚
         â”‚     â”‚               â”‚   â”‚              â”‚   â–²              â”‚                 â”‚                â”‚
         â”‚     â–¼               â–¼   â”‚              â”‚   â”‚              â–¼                 â”‚                â”‚
         â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”       â”Œâ”€â”€â”€â”€â”€â”€â”â”‚         â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”           â”‚                â”‚
         â”‚  â”‚ IMEM â”‚       â”‚RegFilâ”‚â”‚         â”‚ Forwarding â”‚    â”‚   DMEM   â”‚           â”‚                â”‚
         â”‚  â””â”€â”€â”€â”€â”€â”€â”˜       â””â”€â”€â”€â”€â”€â”€â”˜â”‚         â”‚   Unit     â”‚    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜           â”‚                â”‚
         â”‚                   â–²     â”‚         â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜          â”‚                â”‚                â”‚
         â”‚                   â”‚     â”‚               â–² â–²               â”‚                â”‚                â”‚
         â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â”‚               â”‚ â”‚               â”‚                â”‚                â”‚
         â”‚  â”‚  WB Bypass           â”‚        EX/MEMâ”€â”˜ â””â”€MEM/WB       â”‚                â–¼                â”‚
         â”‚  â”‚  (MEM/WB Forward)    â”‚               Forwarding Paths  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€>  RegFile             â”‚
         â”‚  â”‚                      â–¼                                                 Write              â”‚
         â”‚  â”‚            â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                                                          â”‚
         â”‚  â”‚            â”‚  Hazard Detection â”‚â—„â”€â”€â”€â”€ id_ex_mem_read, branch_taken                       â”‚
         â”‚  â”‚            â”‚  & Stall/Flush    â”‚                                                          â”‚
         â”‚  â”‚            â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜                                                          â”‚
         â”‚  â”‚                   â”‚                                                                       â”‚
         â”‚  â”‚     stall_if â”€â”€â”€â”€â”€â”¤   flush_id/flush_ex â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€>               â”‚
         â”‚  â””â”€â”€â”€â”€â”€â”€â”€ stall PC   â””â”€â”€â”€â”€â”€â”€â”€â”€ Flush IF/ID stage registers (insert NOP bubbles)             â”‚
         â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

---

## 2. Pipeline Stage Descriptions

| Stage | Purpose | Inputs | Outputs |
| :--- | :--- | :--- | :--- |
| **IF (Instruction Fetch)** | Fetch instruction from IMEM at PC address. Advance PC by 4 or redirect to branch target. | PC | Instruction word, PC value |
| **ID (Instruction Decode)** | Decode opcode, extract register addresses, sign-extend immediate, read register file. | IF/ID pipeline register | Control signals, rs1/rs2 data, immediate, rd |
| **EX (Execute)** | ALU computation with forwarded operands. Branch evaluation. Jump target computation. | ID/EX pipeline register, Forwarding Mux outputs | ALU result, branch taken, branch target |
| **MEM (Memory Access)** | Load: read data memory. Store: write data memory. | EX/MEM pipeline register | ALU result pass-through, loaded data word |
| **WB (Write-Back)** | Mux between ALU result and loaded memory data. Write to destination register. | MEM/WB pipeline register | Writeback data to register file |

---

## 3. Hazard Resolution Summary

| Hazard Type | Cause | Hardware Resolution | Pipeline Impact |
| :--- | :--- | :--- | :--- |
| **EX-to-EX RAW Forwarding** | Instruction $n+1$ reads register written by instruction $n$ | Forwarding Unit routes EX/MEM ALU result back to EX ALU input | Zero cycle penalty |
| **MEM-to-EX RAW Forwarding** | Instruction $n+2$ reads register written by instruction $n$ | Forwarding Unit routes MEM/WB result back to EX ALU input | Zero cycle penalty |
| **Load-Use Stall** | Instruction $n+1$ needs loaded data from instruction $n$ (LW) | Hazard Unit: stall PC + IF/ID, insert NOP bubble into EX | +1 cycle CPI penalty |
| **Branch Flush (Taken)** | Branch evaluated in EX stage, 2 instructions already fetched | Branch Unit: flush IF and ID stage registers, redirect PC to target | +2 cycle CPI penalty |

---

## 4. Demo Notes & Key Observations

1. **Forwarding Eliminates Most Hazards:** Data forwarding from EX/MEM and MEM/WB eliminates the vast majority of RAW (Read-After-Write) data hazards, allowing back-to-back dependent instructions to execute with zero additional stall cycles. This is visible in the testbench where `ADD x3, x1, x2` followed by `SUB x4, x3, x1` produces the correct result without stalls.

2. **Load-Use Stall Is Unavoidable:** A single-cycle stall is mandatory when a Load instruction is immediately followed by an instruction that reads the loaded register. No amount of forwarding can bypass this â€” the data doesn't emerge from the DMEM until the end of the MEM stage, one cycle too late for the forwarding path.

3. **Branch Penalty Trade-Off:** The design uses **predict-not-taken** branch prediction. Taken branches cause 2 wasted pipeline bubbles. Modern processors use sophisticated branch predictors (BTB + BHT) to reduce this to near-zero average penalty.

4. **Performance Counters Confirm Correct Hazard Handling:** The hardware `stall_count` and `flush_count` counters provide cycle-accurate evidence of hazard detection and resolution without manual waveform inspection.

