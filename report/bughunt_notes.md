# Activity 3.8: Processor Bug-Hunt & Root Cause Analysis

**Student:** Bommu Gowtham Sai Reddy  
**Program:** Verilog RTL Design and RISC-V Processor Development  
**Trainer:** Yuvaraj Seenipandi, Infoziant (Kalasalingam University)

---

## 1. Bug #1: Register x0 Overwrite Hazard
- **Symptoms:** Loop counters and subsequent arithmetic operations produced completely corrupted results. In particular, expressions relying on `x0` as a ground zero constant (`ADD rd, x0, rs2`) produced non-zero offsets.
- **Root Cause:** The Register File write-enable block executed `registers[rd] <= writeback_data` unconditionally whenever `reg_write == 1`. When instructions like `JAL x0, target` executed, the return address (`PC + 4`) was erroneously written into register `x0`.
- **RTL Fix:** Enforced explicit address filtering in the Register File write logic:
  ```verilog
  if (reg_write && rd != 5'd0) begin
      registers[rd] <= writeback_data;
  end
  ```
  Additionally, read ports were guarded to guarantee reading `32'b0` when `rs1 == 0` or `rs2 == 0`.

---

## 2. Bug #2: Immediate Field Bit Scrambling in B-Type and J-Type Instructions
- **Symptoms:** Branch and Jump instructions jumped to wildly incorrect memory addresses, causing PC to branch into unmapped memory addresses or throw simulator out-of-bounds errors.
- **Root Cause:** RISC-V B-type and J-type instruction encodings do not place immediate bits in contiguous order. For instance, in B-type, bit 31 is `imm[12]`, bit 7 is `imm[11]`, bits [30:25] are `imm[10:5]`, and bits [11:8] are `imm[4:1]`, with `imm[0]` implicitly zero. A naive slice `instr[31:20]` produced invalid target offsets.
- **RTL Fix:** Correctly implemented the bit-shuffling extraction according to the RISC-V specification:
  ```verilog
  wire [31:0] imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
  wire [31:0] imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
  ```

---

## 3. Bug #3: Unsigned Extension of Arithmetic Right Shift (SRA / SRAI)
- **Symptoms:** Negative numbers shifted right filled upper bits with `0`s instead of preserving the sign bit (`1`), turning negative values into large positive integers.
- **Root Cause:** In Verilog, the operator `>>>` only performs arithmetic shift if the left-hand operand is explicitly typed as `signed`. If applied to a standard `wire [31:0]` vector, Verilog treats it as unsigned and performs a logical shift (`SRL`).
- **RTL Fix:** Explicitly cast operands using the `$signed()` system function:
  ```verilog
  alu_result = $signed(alu_op_a) >>> alu_op_b[4:0];
  ```

---

## 4. Bug #4: Signed vs. Unsigned Comparison in Branch Instructions (BLT vs. BLTU)
- **Symptoms:** Negative loop indices or signed values were evaluated incorrectly in conditional branches (e.g., `-5` was treated as $> +10$).
- **Root Cause:** Using standard relational operators (`<`, `>=`) on Verilog `wire [31:0]` compares operands as unsigned 32-bit values.
- **RTL Fix:** Separated signed and unsigned branch evaluation:
  ```verilog
  case (funct3)
      3'b100: branch_taken = ($signed(reg_rd1) < $signed(reg_rd2)); // BLT (signed)
      3'b110: branch_taken = (reg_rd1 < reg_rd2);                  // BLTU (unsigned)
  endcase
  ```

