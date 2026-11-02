# Verilog HDL Digital Design Projects

A collection of digital logic designs and verification testbenches implemented in Verilog HDL, simulated using ModelSim / QuestaSim.

---

## 📁 Repository Structure

```
Projects/
│
├── 4bit_halfadder/
│   ├── design.v
│   └── testbench.v
│
├── Alu_4bit/
│   ├── alu4.v
│   └── alu4_tb.v
│
├── D_FlipFlop/
│   ├── d_flipflop.v
│   └── d_flipflop_tb.v
│
├── Half_Adder_DFF/
│   ├── half_adder_dff.v
│   └── half_adder_dff_tb.v
│
└── README.md
```

---

## 🛠️ Modules Overview

### 1. 4-Bit Half Adder (`4bit_halfadder/`)
Performs parallel bitwise addition on two 4-bit operands (`A` and `B`) without taking an incoming carry into account.
- **Files**: [`design.v`](4bit_halfadder/design.v), [`testbench.v`](4bit_halfadder/testbench.v)
- **Logic Equations**:
  - `Sum[i]   = A[i] ^ B[i]` (Bitwise XOR)
  - `Carry[i] = A[i] & B[i]` (Bitwise AND)
- **Truth Table (Per-Bit)**:

| `A[i]` | `B[i]` | `Sum[i]` | `Carry[i]` |
| :---: | :---: | :---: | :---: |
| 0 | 0 | 0 | 0 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |

---

### 2. 4-Bit Arithmetic Logic Unit (`Alu_4bit/`)
Performs arithmetic and bitwise logical operations controlled by a 3-bit opcode selector.
- **Files**: [`alu4.v`](Alu_4bit/alu4.v), [`alu4_tb.v`](Alu_4bit/alu4_tb.v)
- **Inputs**: 4-bit operands `A`, `B`, 3-bit `opcode`
- **Outputs**: 4-bit `result`, 1-bit `carry_borrow`, 1-bit `zero` flag

| Opcode (`opcode[2:0]`) | Operation | Description | Flags Affected |
| :---: | :---: | :--- | :--- |
| `000` | **ADD** | Addition: `temp = A + B` | `carry_borrow` (carry out), `zero` |
| `001` | **SUB** | Subtraction: `result = A - B` | `carry_borrow` (borrow: `A < B`), `zero` |
| `010` | **AND** | Bitwise AND: `result = A & B` | `zero` |
| `011` | **OR** | Bitwise OR: `result = A \| B` | `zero` |
| `100` | **XOR** | Bitwise XOR: `result = A ^ B` | `zero` |
| Others | **Default** | Clears output (`4'b0000`) | `zero` |

---

### 3. D Flip-Flop (`D_FlipFlop/`)
Positive-edge triggered D flip-flop with active-high asynchronous reset.
- **Files**: [`d_flipflop.v`](D_FlipFlop/d_flipflop.v), [`d_flipflop_tb.v`](D_FlipFlop/d_flipflop_tb.v)
- **Ports**:
  - `clk`: Clock signal
  - `rst`: Asynchronous active-high reset
  - `d`: Data input
  - `q`: Registered output
- **Functionality**: When `rst = 1`, `q` is cleared to `0`. On `posedge clk` with `rst = 0`, `q <= d`.

---

### 4. Half Adder with D Flip-Flop (`Half_Adder_DFF/`)
Sequential half adder circuit combining combinational logic with edge-triggered output registration.
- **Files**: [`half_adder_dff.v`](Half_Adder_DFF/half_adder_dff.v), [`half_adder_dff_tb.v`](Half_Adder_DFF/half_adder_dff_tb.v)
- **Ports**:
  - `clk`, `reset`: Clock and asynchronous active-high reset
  - `a`, `b`: 1-bit operands
  - `sum`, `carry`: Registered outputs captured on the clock edge
- **Functionality**:
  - Combinational logic: `s = a ^ b`, `c = a & b`
  - Registered outputs: On rising clock edge (`posedge clk`), `sum <= s` and `carry <= c`. When `reset = 1`, `sum <= 0` and `carry <= 0`.

---

## 🚀 Simulation & Verification

Each directory contains a self-checking or monitored testbench that can be simulated using ModelSim, QuestaSim, or Icarus Verilog.

### Running with ModelSim / QuestaSim

```tcl
# Navigate to the target project directory (e.g. Alu_4bit)
cd Alu_4bit

# Create and map work library
vlib work
vmap work work

# Compile design and testbench
vlog alu4.v alu4_tb.v

# Run simulation
vsim -c alu4_tb -do "run -all; quit"
```

### Running with Icarus Verilog

```bash
# Example: 4-bit Half Adder
cd 4bit_halfadder
iverilog -o sim design.v testbench.v
vvp sim
```

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
