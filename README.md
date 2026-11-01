# 4-Bit Arithmetic Logic Unit (ALU) in Verilog HDL

A 4-bit Arithmetic Logic Unit (ALU) implemented in Verilog HDL supporting arithmetic and bitwise logical operations, accompanied by a comprehensive testbench for simulation and verification using ModelSim / QuestaSim.

---

## 📌 Features

- **Data Width**: 4-bit operands (`A`, `B`) and 4-bit result output.
- **Control**: 3-bit opcode selector.
- **Status Flags**:
  - `carry_borrow`: Carry out for Addition (`temp[4]`), Borrow flag for Subtraction (`A < B`).
  - `zero`: Active-high flag asserted when `result == 4'b0000`.

---

## ⚙️ Operation Table

| Opcode (`opcode[2:0]`) | Operation | Description | Flags Affected |
| :---: | :---: | :--- | :--- |
| `000` | **ADD** | Addition: `temp = A + B` | `carry_borrow` (carry out), `zero` |
| `001` | **SUB** | Subtraction: `result = A - B` | `carry_borrow` (borrow: `A < B`), `zero` |
| `010` | **AND** | Bitwise AND: `result = A & B` | `zero` |
| `011` | **OR** | Bitwise OR: `result = A \| B` | `zero` |
| `100` | **XOR** | Bitwise XOR: `result = A ^ B` | `zero` |
| Others | **Default** | Clears output (`4'b0000`) | `zero` |

---

## 📁 Repository Structure

```
.
├── alu4.v          # 4-bit ALU module design (Verilog HDL)
├── alu4_tb.v       # Testbench for functional simulation and verification
├── .gitignore      # Ignores ModelSim/Questa compilation and simulation artifacts
└── README.md       # Project documentation
```

---

## 🚀 Simulation & Verification

The design can be simulated using ModelSim, QuestaSim, Icarus Verilog, or any standard Verilog simulator.

### Running with ModelSim / QuestaSim:
```tcl
# Create and map work library
vlib work
vmap work work

# Compile design and testbench
vlog alu4.v alu4_tb.v

# Run simulation
vsim -c alu4_tb -do "run -all; quit"
```

### Running with Icarus Verilog (open-source alternative):
```bash
iverilog -o alu_sim alu4.v alu4_tb.v
vvp alu_sim
```

---

## 📄 License
This project is open-source under the MIT License.
