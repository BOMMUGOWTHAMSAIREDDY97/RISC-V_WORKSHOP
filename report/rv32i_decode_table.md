# Activity 3.1: RV32I Instruction Decode & Control Table

**STUDENT:** BOMMU GOWTHAM SAI REDDY
**REG NO:** 9923005065
**DEPT:** ECE  
**PROGRAM:** VERILOG RTL DESIGN AND RISC-V PROCESSOR DEVELOPMENT  
**TRAINER:** YUVARAJ SEENIPANDI, INFOZIANT (KALASALINGAM UNIVERSITY)

---

## 1. Instruction Formats in RV32I

| Format | Bit [31:25] | Bit [24:20] | Bit [19:15] | Bit [14:12] | Bit [11:7] | Bit [6:0] | Description |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **R-Type** | funct7 | rs2 | rs1 | funct3 | rd | opcode | Register-Register Arithmetic/Logical |
| **I-Type** | imm[11:0] | rs1 | funct3 | rd | opcode | Register-Immediate, Loads, JALR |
| **S-Type** | imm[11:5] | rs2 | rs1 | funct3 | imm[4:0] | opcode | Store Operations (SW, SH, SB) |
| **B-Type** | imm[12\|10:5] | rs2 | rs1 | funct3 | imm[4:1\|11] | opcode | Conditional Branches (BEQ, BNE, BLT, BGE) |
| **U-Type** | imm[31:12] | rd | opcode | Upper Immediate (LUI, AUIPC) |
| **J-Type** | imm[20\|10:1\|11\|19:12] | rd | opcode | Unconditional Jump (JAL) |

---

## 2. Immediate Generation Formats

| Format | Verilog Immediate Extension Logic | Range / Alignment |
| :--- | :--- | :--- |
| **I-Imm** | `imm_i = {{20{instr[31]}}, instr[31:20]};` | Signed 12-bit $[-2048, 2047]$ |
| **S-Imm** | `imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};` | Signed 12-bit $[-2048, 2047]$ |
| **B-Imm** | `imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};` | Signed 13-bit, 2-byte aligned |
| **U-Imm** | `imm_u = {instr[31:12], 12'b0};` | Unsigned 32-bit (upper 20 bits) |
| **J-Imm** | `imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};` | Signed 21-bit, 2-byte aligned |

---

## 3. Comprehensive RV32I Control Matrix

| Instruction | Type | Opcode (6:0) | funct3 | funct7 | RegWrite | ALUSrc | MemRead | MemWrite | Branch | Jump | ALUOp | ALU Control (Operation) | ResultSrc |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- | :---: |
| **ADD** | R | `0110011` | `000` | `0000000` | 1 | 0 (rs2) | 0 | 0 | 0 | 0 | 2'b10 | `4'b0000` (ADD) | 0 (ALU) |
| **SUB** | R | `0110011` | `000` | `0100000` | 1 | 0 (rs2) | 0 | 0 | 0 | 0 | 2'b10 | `4'b0001` (SUB) | 0 (ALU) |
| **AND** | R | `0110011` | `111` | `0000000` | 1 | 0 (rs2) | 0 | 0 | 0 | 0 | 2'b10 | `4'b0010` (AND) | 0 (ALU) |
| **OR** | R | `0110011` | `110` | `0000000` | 1 | 0 (rs2) | 0 | 0 | 0 | 0 | 2'b10 | `4'b0011` (OR) | 0 (ALU) |
| **XOR** | R | `0110011` | `100` | `0000000` | 1 | 0 (rs2) | 0 | 0 | 0 | 0 | 2'b10 | `4'b0100` (XOR) | 0 (ALU) |
| **SLT** | R | `0110011` | `010` | `0000000` | 1 | 0 (rs2) | 0 | 0 | 0 | 0 | 2'b10 | `4'b0101` (SLT) | 0 (ALU) |
| **SLL** | R | `0110011` | `001` | `0000000` | 1 | 0 (rs2) | 0 | 0 | 0 | 0 | 2'b10 | `4'b0110` (SLL) | 0 (ALU) |
| **SRL** | R | `0110011` | `101` | `0000000` | 1 | 0 (rs2) | 0 | 0 | 0 | 0 | 2'b10 | `4'b0111` (SRL) | 0 (ALU) |
| **SRA** | R | `0110011` | `101` | `0100000` | 1 | 0 (rs2) | 0 | 0 | 0 | 0 | 2'b10 | `4'b1000` (SRA) | 0 (ALU) |
| **ADDI** | I | `0010011` | `000` | - | 1 | 1 (Imm) | 0 | 0 | 0 | 0 | 2'b11 | `4'b0000` (ADD) | 0 (ALU) |
| **SLTI** | I | `0010011` | `010` | - | 1 | 1 (Imm) | 0 | 0 | 0 | 0 | 2'b11 | `4'b0101` (SLT) | 0 (ALU) |
| **ANDI** | I | `0010011` | `111` | - | 1 | 1 (Imm) | 0 | 0 | 0 | 0 | 2'b11 | `4'b0010` (AND) | 0 (ALU) |
| **ORI** | I | `0010011` | `110` | - | 1 | 1 (Imm) | 0 | 0 | 0 | 0 | 2'b11 | `4'b0011` (OR) | 0 (ALU) |
| **XORI** | I | `0010011` | `100` | - | 1 | 1 (Imm) | 0 | 0 | 0 | 0 | 2'b11 | `4'b0100` (XOR) | 0 (ALU) |
| **LW** | I | `0000011` | `010` | - | 1 | 1 (Imm) | 1 | 0 | 0 | 0 | 2'b00 | `4'b0000` (ADD) | 1 (Mem) |
| **SW** | S | `0100011` | `010` | - | 0 | 1 (Imm) | 0 | 1 | 0 | 0 | 2'b00 | `4'b0000` (ADD) | X |
| **BEQ** | B | `1100011` | `000` | - | 0 | 0 (rs2) | 0 | 0 | 1 | 0 | 2'b01 | `4'b0001` (SUB) | X |
| **BNE** | B | `1100011` | `001` | - | 0 | 0 (rs2) | 0 | 0 | 1 | 0 | 2'b01 | `4'b0001` (SUB) | X |
| **BLT** | B | `1100011` | `100` | - | 0 | 0 (rs2) | 0 | 0 | 1 | 0 | 2'b01 | `4'b0101` (SLT) | X |
| **BGE** | B | `1100011` | `101` | - | 0 | 0 (rs2) | 0 | 0 | 1 | 0 | 2'b01 | `4'b0101` (SLT) | X |
| **LUI** | U | `0110111` | - | - | 1 | 1 (Imm) | 0 | 0 | 0 | 0 | 2'b11 | `4'b1001` (PASS_B)| 0 (ALU) |
| **AUIPC**| U | `0010111` | - | - | 1 | 1 (Imm) | 0 | 0 | 0 | 0 | 2'b00 | `4'b0000` (ADD) | 0 (ALU=PC+imm) |
| **JAL** | J | `1101111` | - | - | 1 | X | 0 | 0 | 0 | 1 | X | X | 2 (PC+4) |
| **JALR**| I | `1100111` | `000` | - | 1 | 1 (Imm) | 0 | 0 | 0 | 1 | 2'b00 | `4'b0000` (ADD) | 2 (PC+4) |

