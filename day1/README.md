# Day 1: Combinational & Sequential Building Blocks

**Student Name:** Bommu Gowtham Sai Reddy  
**Program:** Verilog RTL Design and RISC-V Processor Development  
**Trainer:** Yuvaraj Seenipandi, Infoziant (Kalasalingam University)

---

## Overview of Day 1 Activities

| Activity | Module Name | Description | Testbench Verification Status |
| :--- | :--- | :--- | :--- |
| **1.1** | `alu.v` | 32-bit Parameterized ALU with Zero, Negative, Carry, and Overflow flags | **27 / 27 PASSED** (0 FAILED) |
| **1.2** | `counter.v` | 8-bit Up/Down Counter with Synchronous Reset, Enable, and Parallel Load | **15 / 15 PASSED** (0 FAILED) |
| **1.3** | `shifter.v` | 32-bit Single-Cycle Barrel Shifter (SLL, SRL, SRA by 0–31) | **480 / 480 PASSED** (0 FAILED) |
| **1.4** | `regfile.v` | 32x32-bit Register File (2 Read, 1 Write, Hardwired x0=0, Internal Bypass) | **264 / 264 PASSED** (0 FAILED) |
| **1.5** | `adder_sub.v` | 8-bit Ripple-Carry Adder/Subtractor with Generate Loops & Overflow | **512 / 512 PASSED** (0 FAILED) |
| **1.6** | `encoder.v`, `decoder.v` | 8-to-3 Priority Encoder (`casez` vs `if-else`) and 3-to-8 Decoder | **272 / 272 PASSED** (0 FAILED) |
| **1.7** | `shiftreg.v`, `lfsr.v` | Universal Shift Register & 8-bit Maximal-Length LFSR (255 States) | **6 / 6 PASSED** (0 FAILED) |
| **1.8** | `debounce.v`, `edge_detect.v` | Button Debouncer Counter & 2-Stage Synchronized Edge Detector | **6 / 6 PASSED** (0 FAILED) |

---

## Tech Notes & Design Approach

### 1.1 Parameterized ALU (`src/alu.v`, `tb/alu_tb.v`)
- **Design Approach:** Implemented a parameterized $N$-bit ALU (default `WIDTH = 32`) supporting RV32I arithmetic and logical operations (`ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLT`, `SLL`, `SRL`). Flag computation uses an $(N+1)$-bit extended adder vector for precise unsigned carry detection, signed MSB comparison for two's-complement overflow detection ($V = (A_{msb} \oplus B_{msb} \oplus \text{sub}) \ \& \ (A_{msb} \oplus \text{sum}_{msb})$), and reduction NOR for zero flag.
- **Verification:** Self-checking testbench applying 27 corner cases (positive/negative overflow, zero sum, signed comparison `SLT`, shift limits 0 and 31).
- **Issues Faced & Fixes:** Distinguishing unsigned carry vs signed overflow in subtraction: resolved by extending operand $A$ and $\sim B + 1$ cleanly in $(N+1)$ bits.

### 1.2 Up/Down Counter (`src/counter.v`, `tb/counter_tb.v`)
- **Design Approach:** Synchronous 8-bit counter with synchronous active-high reset, synchronous load, enable, and direction selection (`up_down`). Implements strict priority: `reset > load > enable`.
- **Verification:** 15 test vectors verifying rollover from `0xFF -> 0x00` in up-count mode and `0x00 -> 0xFF` in down-count mode, load override, and enable gating.

### 1.3 Barrel Shifter (`src/shifter.v`, `tb/shifter_tb.v`)
- **Design Approach:** Single-cycle 32-bit barrel shifter supporting Logical Left (`SLL`), Logical Right (`SRL`), and Arithmetic Right (`SRA`). Arithmetic right shift utilizes `$signed(din) >>> shamt` to preserve sign bits across negative inputs.
- **Verification:** 480 test cases sweeping all shift amounts from 0 to 31 across 5 distinct test patterns (including positive numbers, negative numbers `0x80000000`, alternating bitmasks `0xAAAAAAAA`). Verified 100% against behavioral model.

### 1.4 Register File (`src/regfile.v`, `tb/regfile_tb.v`)
- **Design Approach:** 32 registers of 32 bits each, dual asynchronous read ports (`rs1`, `rs2`), and single synchronous write port (`rd`). Register `x0` is permanently hardwired to `32'b0`. Built-in internal write-bypass (forwarding) logic forwards write data to read ports when reading and writing the same non-zero register in the same clock cycle.
- **Verification:** 14 directed tests verifying hardwired `x0` rejection, internal bypass, read-after-write, plus 250 randomized read/write operations compared against a golden array model.

### 1.5 Ripple-Carry Adder/Subtractor (`src/adder_sub.v`, `src/full_adder.v`, `tb/adder_sub_tb.v`)
- **Design Approach:** Pure structural implementation using 8 instantiated full adders (`full_adder.v`) generated using a Verilog `generate` loop. Subtraction is performed via two's complement inversion (`b_xor = b ^ {WIDTH{sub}}`) and asserting initial carry-in (`c_in = sub`).
- **Verification:** Exhaustive 512 test vectors covering all $256$ inputs with addition and subtraction, verifying carry-out and two's complement overflow.

### 1.6 Priority Encoder & Decoder (`src/encoder.v`, `src/decoder.v`, `tb/encoder_decoder_tb.v`)
- **Design Approach:** 
  1. Priority encoder comparing `casez` with wildcard matching (`8'b1???????` down to `8'b00000001`) versus an explicit cascaded `if-else` ladder.
  2. 3-to-8 active-high decoder with active-high enable.
- **Verification:** Exhaustive simulation of all 256 8-bit input patterns proving `encoder_casez` and `encoder_ifelse` yield 100% identical functional results and synthesis equivalence.

### 1.7 Universal Shift Register & LFSR (`src/shiftreg.v`, `src/lfsr.v`, `tb/shiftreg_lfsr_tb.v`)
- **Design Approach:** 
  1. 8-bit Universal Shift Register supporting Parallel Load (`11`), Shift Left (`01`), Shift Right (`10`), and Hold (`00`).
  2. 8-bit Linear Feedback Shift Register (LFSR) with characteristic polynomial $x^8 + x^6 + x^5 + x^4 + 1$ (taps at bit positions 7, 5, 4, 3) achieving the maximal period of $2^8 - 1 = 255$ unique non-zero pseudo-random states.
- **Verification:** Verified full 255-state trajectory without repeating or entering the locked 0 state, and confirming return to initial seed on exactly cycle 255.

### 1.8 Debouncer & Edge Detector (`src/debounce.v`, `src/edge_detect.v`, `tb/debounce_edge_tb.v`)
- **Design Approach:** Counter-based debounce filter that requires inputs to remain steady for a configured duration threshold before asserting output, coupled with a 2-stage synchronizer and flip-flop delay edge detector generating clean 1-cycle pulses (`rise_pulse`, `fall_pulse`).
- **Verification:** Injected bounce bursts of 1–3 cycles verifying zero false triggers, followed by stable activation and deactivation verifying exactly one rising edge pulse and one falling edge pulse.

---

## Simulation & Waveform Instructions

### Running in ModelSim / QuestaSim
Open ModelSim in the project directory:
```tcl
cd day1
do run_day1.do
```

To view waveform screenshots:
All simulation waveforms are captured as `.png` images in `waves/` (e.g. `waves/1.1.png`).

