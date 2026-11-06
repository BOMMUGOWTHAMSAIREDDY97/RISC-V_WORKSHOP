# Activity 3.4: RV32I Processor Waveform Execution Analysis

**Student:** Bommu Gowtham Sai Reddy  
**Program:** Verilog RTL Design and RISC-V Processor Development  
**Trainer:** Yuvaraj Seenipandi, Infoziant (Kalasalingam University)

---

## Single-Cycle RV32I Microarchitecture Datapath Flow

In a single-cycle implementation, each instruction executes in exactly one clock cycle ($CPI = 1$). All combinational path operations—instruction fetch, operand decode and register read, ALU computation, memory access, and writeback multiplexing—settle within the clock period prior to the rising clock edge, where state registers ($PC$, Register File, and Data Memory) are synchronously updated.

```
+----+       +------+       +---------+       +-----+       +------+       +----+
| PC | ----> | IMEM | ----> | RegFile | ----> | ALU | ----> | DMEM | ----> | WB |
+----+       +------+       +---------+       +-----+       +------+       +----+
```

---

## Detailed Signal Breakdown for 5 Key Instructions

### 1. `ADDI x3, x3, 1` (I-Type Arithmetic)
- **Machine Word:** `0x00118193`
- **Decode Fields:**
  - `opcode`: `7'b0010011` (OP-IMM)
  - `rd`: `5'd3` (`x3`)
  - `funct3`: `3'b000` (ADDI)
  - `rs1`: `5'd3` (`x3`)
  - `imm_i`: `32'd1` (`0x00000001`)
- **Datapath Execution:**
  - **Register Read:** Port 1 reads current value of `x3` (e.g., `0x00000004`).
  - **ALU Control & Execution:** `alu_src = 1` selects immediate operand. ALU executes `ADD`: `0x00000004 + 0x00000001 = 0x00000005`.
  - **Data Memory:** `mem_read = 0`, `mem_write = 0`. Data memory is inactive.
  - **Writeback:** `result_src = 2'b00` routes `alu_result` to register write port. `reg_write = 1` latches `0x00000005` into register `x3` at next `posedge clk`.
  - **Next PC:** `pc_next = pc + 4`.

---

### 2. `SW x2, 0(x4)` (S-Type Store Word)
- **Machine Word:** `0x00222023`
- **Decode Fields:**
  - `opcode`: `7'b0100011` (STORE)
  - `funct3`: `3'b010` (SW, word)
  - `rs1`: `5'd4` (`x4`, base memory address)
  - `rs2`: `5'd2` (`x2`, data source)
  - `imm_s`: `32'd0` (`0x00000000`)
- **Datapath Execution:**
  - **Register Read:** `reg_rd1` reads base address from `x4` (e.g., `0x00000010`). `reg_rd2` reads store data from `x2` (e.g., `0x00000037`).
  - **ALU Execution:** `alu_src = 1`, computes effective byte memory address: `base + imm_s = 0x00000010 + 0 = 0x00000010`.
  - **Memory Write:** `mem_write = 1`. Memory word index `alu_result[9:2] = 4`. At `posedge clk`, `dmem[4]` latches `0x00000037`.
  - **Writeback:** `reg_write = 0` (no register writeback occurs).
  - **Next PC:** `pc_next = pc + 4`.

---

### 3. `LW x5, 0(x2)` (I-Type Load Word)
- **Machine Word:** `0x00012283`
- **Decode Fields:**
  - `opcode`: `7'b0000011` (LOAD)
  - `rd`: `5'd5` (`x5`)
  - `funct3`: `3'b010` (LW)
  - `rs1`: `5'd2` (`x2`, base address pointer)
  - `imm_i`: `32'd0` (`0x00000000`)
- **Datapath Execution:**
  - **Register Read:** `reg_rd1` reads base pointer from `x2`.
  - **ALU Execution:** `alu_src = 1`. Computes effective address: `x2 + 0`.
  - **Memory Access:** `mem_read = 1`. Word index `alu_result[9:2]` reads `dmem`. Data out appears asynchronously on `dmem_rdata` (e.g., `0x0000004E`).
  - **Writeback:** `result_src = 2'b01` directs memory data to writeback mux. `reg_write = 1` commits value to `x5` at the clock edge.
  - **Next PC:** `pc_next = pc + 4`.

---

### 4. `BLT x5, x1, -24` (B-Type Conditional Branch)
- **Machine Word:** `0xfe12c4e3`
- **Decode Fields:**
  - `opcode`: `7'b1100011` (BRANCH)
  - `funct3`: `3'b100` (BLT, signed less than)
  - `rs1`: `5'd5` (`x5`, loop index)
  - `rs2`: `5'd1` (`x1`, loop bound = 8)
  - `imm_b`: `32'hFFFFFFE8` (signed offset -24 bytes)
- **Datapath Execution:**
  - **Register Read:** `reg_rd1` reads `x5` (`5`), `reg_rd2` reads `x1` (`8`).
  - **Branch Evaluator:** Evaluates signed condition: `($signed(x5) < $signed(x1)) -> 5 < 8` is TRUE (`1'b1`).
  - **Branch Target Generation:** Adds branch displacement: `target = pc + imm_b = 0x0000002C - 24 = 0x00000014`.
  - **Control Action:** `branch_taken = 1`, `reg_write = 0`, `mem_write = 0`.
  - **Next PC:** Multiplexer selects `branch_target`, setting `pc_next = 0x00000014`.

---

### 5. `JAL x0, -12` (J-Type Unconditional Jump)
- **Machine Word:** `0xff5ff06f`
- **Decode Fields:**
  - `opcode`: `7'b1101111` (JAL)
  - `rd`: `5'd0` (`x0`, discard return address)
  - `imm_j`: `32'hFFFFFFF4` (signed offset -12 bytes)
- **Datapath Execution:**
  - **Jump Target Generation:** `jal_target = pc + imm_j = 0x00000018 - 12 = 0x0000000C`.
  - **Return Address:** Computes `pc + 4 = 0x0000001C`.
  - **Writeback:** `reg_write = 1`, but since `rd == x0`, register write is suppressed by the hardwired zero check (`rd != 5'd0`).
  - **Next PC:** `pc_next = 0x0000000C`. The processor redirects control unconditionally to the loop header in single cycle.

