# Verilog HDL Digital Design Projects

A collection of digital logic designs, state machine controllers, and verification testbenches implemented in Verilog HDL, simulated using ModelSim / QuestaSim.

---

## 📁 Repository Structure

```
Projects/
│
├── 4bit_halfadder/
│   ├── design.v
│   └── testbench.v
│
├── 4_Floor_Elevator/
│   ├── elevator.v
│   └── elevator_tb.v
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
├── Washing_Machine/
│   ├── washing_machine.v
│   └── washing_machine_tb.v
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

### 2. 4-Floor Elevator Controller (`4_Floor_Elevator/`)
Finite State Machine (FSM) based controller for a 4-floor passenger elevator with motor direction and door timing control.
- **Files**: [`elevator.v`](4_Floor_Elevator/elevator.v), [`elevator_tb.v`](4_Floor_Elevator/elevator_tb.v)
- **Inputs**: `clk`, `reset`, `request_valid`, `request_floor[1:0]` (Floors 0 to 3)
- **Outputs**: `current_floor[1:0]`, `motor_up`, `motor_down`, `door_open`, `busy`
- **FSM States**:
  - `IDLE (00)`: Waits for `request_valid`. Evaluates target floor against current floor.
  - `UP (01)`: Asserts `motor_up`, increments floor on each clock cycle until reaching target floor.
  - `DOWN (10)`: Asserts `motor_down`, decrements floor on each clock cycle until reaching target floor.
  - `DOOR (11)`: Asserts `door_open`, holds for door countdown cycles before returning to `IDLE`.

---

### 3. 4-Bit Arithmetic Logic Unit (`Alu_4bit/`)
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

### 4. D Flip-Flop (`D_FlipFlop/`)
Positive-edge triggered D flip-flop with active-high asynchronous reset.
- **Files**: [`d_flipflop.v`](D_FlipFlop/d_flipflop.v), [`d_flipflop_tb.v`](D_FlipFlop/d_flipflop_tb.v)
- **Ports**:
  - `clk`: Clock signal
  - `rst`: Asynchronous active-high reset
  - `d`: Data input
  - `q`: Registered output
- **Functionality**: When `rst = 1`, `q` is cleared to `0`. On `posedge clk` with `rst = 0`, `q <= d`.

---

### 5. Half Adder with D Flip-Flop (`Half_Adder_DFF/`)
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

### 6. Washing Machine Controller (`Washing_Machine/`)
Synthesizable Moore Finite State Machine controller managing a multi-stage automatic washing cycle with sensor handshaking.
- **Files**: [`washing_machine.v`](Washing_Machine/washing_machine.v), [`washing_machine_tb.v`](Washing_Machine/washing_machine_tb.v)
- **Inputs**: `clk`, `reset`, `start`, `water_full`, `wash_done`, `drain_done`, `rinse_done`, `spin_done`
- **Outputs**: `water_valve`, `wash_motor`, `drain_pump`, `spin_motor`, `cycle_done`
- **Cycle Stages & FSM Sequence**:

| State | Encoding | Trigger Condition | Active Actuator Output |
| :--- | :---: | :--- | :--- |
| `IDLE` | `000` | `start = 1` | None |
| `FILL` | `001` | `water_full = 1` | `water_valve = 1` |
| `WASH` | `010` | `wash_done = 1` | `wash_motor = 1` |
| `DRAIN` | `011` | `drain_done = 1` | `drain_pump = 1` |
| `RINSE` | `100` | `rinse_done = 1` | `water_valve = 1` / rinse |
| `SPIN` | `101` | `spin_done = 1` | `spin_motor = 1` |
| `DONE` | `110` | `start = 1` (restart) | `cycle_done = 1` |

---

## 🚀 Simulation & Verification

Follow these step-by-step commands in the ModelSim / QuestaSim Transcript console:

### ModelSim / QuestaSim Simulation Commands

| Step | Command | Description |
| :---: | :--- | :--- |
| **01** | `pwd` | Verify current working directory |
| **02** | `vlib work` | Create the local design library |
| **03** | `vmap work work` | Map the library as default work library |
| **04** | `vlog <testbench>.v <design>.v` | Compile design and testbench files |
| **05** | `vsim work.<testbench_module>` | Load testbench for simulation |
| **06** | `add wave -r *` | Add all signals recursively to waveform window |
| **07** | `run -all` | Execute simulation run |
| **08** | `wave zoomfull` | Zoom to fit all waveforms in window |

---

### Running Each Module in ModelSim

- **4-Floor Elevator Controller (`4_Floor_Elevator/`)**:
  ```tcl
  cd 4_Floor_Elevator
  pwd
  vlib work
  vmap work work
  vlog elevator_tb.v elevator.v
  vsim work.elevator_tb
  add wave -r *
  run -all
  wave zoomfull
  ```

- **Washing Machine Controller (`Washing_Machine/`)**:
  ```tcl
  cd Washing_Machine
  pwd
  vlib work
  vmap work work
  vlog washing_machine_tb.v washing_machine.v
  vsim work.washing_machine_tb
  add wave -r *
  run -all
  wave zoomfull
  ```

- **4-Bit ALU (`Alu_4bit/`)**:
  ```tcl
  cd Alu_4bit
  pwd
  vlib work
  vmap work work
  vlog alu4_tb.v alu4.v
  vsim work.alu4_tb
  add wave -r *
  run -all
  wave zoomfull
  ```

- **4-Bit Half Adder (`4bit_halfadder/`)**:
  ```tcl
  cd 4bit_halfadder
  pwd
  vlib work
  vmap work work
  vlog testbench.v design.v
  vsim work.half_adder4_tb
  add wave -r *
  run -all
  wave zoomfull
  ```

- **D Flip-Flop (`D_FlipFlop/`)**:
  ```tcl
  cd D_FlipFlop
  pwd
  vlib work
  vmap work work
  vlog d_flipflop_tb.v d_flipflop.v
  vsim work.d_flipflop_tb
  add wave -r *
  run -all
  wave zoomfull
  ```

- **Half Adder with DFF (`Half_Adder_DFF/`)**:
  ```tcl
  cd Half_Adder_DFF
  pwd
  vlib work
  vmap work work
  vlog half_adder_dff_tb.v half_adder_dff.v
  vsim work.half_adder_dff_tb
  add wave -r *
  run -all
  wave zoomfull
  ```
