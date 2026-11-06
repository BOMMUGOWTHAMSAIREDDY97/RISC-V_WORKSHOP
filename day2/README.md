# Day 2: FSM Controllers and Memory Design

**Student Name:** Bommu Gowtham Sai Reddy  
**Program:** Verilog RTL Design and RISC-V Processor Development  
**Trainer:** Yuvaraj Seenipandi, Infoziant (Kalasalingam University)

---

## Overview of Day 2 Activities

| Activity | Module Name | Description | Testbench Verification Status |
| :--- | :--- | :--- | :--- |
| **2.1** | `seq_moore.v`, `seq_mealy.v` | Overlapping Sequence Detector (`1011`) comparing Moore vs. Mealy timing | **32 / 32 PASSED** (0 FAILED) |
| **2.2** | `vending.v` | Vending Machine FSM accepting ₹5, ₹10, ₹20 coins with change return | **8 / 8 PASSED** (0 FAILED) |
| **2.3** | `fifo.v` | 16x8 Synchronous FIFO with Full, Empty, Almost flags, and protections | **22 / 22 PASSED** (0 FAILED) |
| **2.4** | `report/review_note_2_4.md` | Tech Notes: Binary vs One-Hot vs Gray, Moore vs Mealy, and CDC FIFO | **Completed** |
| **2.5** | `traffic_light.v` | Traffic Light Controller with pedestrian request button & state timers | **6 / 6 PASSED** (0 FAILED) |
| **2.6** | `atm.v` | ATM Controller FSM with 3-attempt PIN lock, balance check, withdrawal | **5 / 5 PASSED** (0 FAILED) |
| **2.7** | `arbiter.v` | 4-Way Round-Robin Arbiter with rotating priority & starvation freedom | **10 / 10 PASSED** (0 FAILED) |
| **2.8** | `ram.v`, `watchdog.v` | Single-Port 64x32 RAM and Digital Heartbeat Watchdog Timer | **23 / 23 PASSED** (0 FAILED) |

---

## Tech Notes & Key Learnings

### 2.1 Sequence Detector (`src/seq_moore.v`, `src/seq_mealy.v`, `tb/seq_tb.v`)
- **Analysis:** Both detectors were tested using identical incoming bitstreams containing overlapping sequences (`1011011`). 
- **Observation:** The Mealy FSM asserted its detection signal asynchronously in the very cycle the 4th bit arrived, whereas the Moore FSM asserted its detection signal on the following clock cycle upon entering state `S_1011`. Overlapping patterns were seamlessly detected by routing next-state transitions to prefix states (`S_1` or `S_10`).

### 2.2 Vending Machine FSM (`src/vending.v`, `tb/vending_tb.v`)
- **Design:** Accumulates coin inputs (5, 10, 20 INR) towards a 20 INR item price. Correctly computes exact change (e.g., 5 + 20 = 25 INR dispenses product and issues 5 INR change).
- **Verification:** Exhaustively verified all coin addition combinations, dispensing signals, and reset aborts.

### 2.3 Synchronous FIFO (`src/fifo.v`, `tb/fifo_tb.v`)
- **Design:** Implemented dual circular pointers (`wr_ptr`, `rd_ptr`) and a tracking counter to determine fill level. Enforces hardware overflow and underflow protection: writes during `full` are discarded unless a concurrent read occurs, and reads during `empty` are suppressed.
- **Verification:** Tested full fill (16 elements), overflow rejection, complete drain, underflow rejection, and simultaneous concurrent read/write keeping depth constant.

### 2.4 Design Review Report
- Documented in detail in `report/review_note_2_4.md` covering FSM state encoding trade-offs for ASIC vs FPGA, glitch immunity, and asynchronous FIFO clock-domain crossing (CDC) synchronization with Gray codes and 2-FF synchronizers.

### 2.5 Traffic Light Controller (`src/traffic_light.v`, `tb/traffic_light_tb.v`)
- **Design:** Built-in hardware timers manage Green (6 cycles), Yellow (2 cycles), and Red (4 cycles) states. Integrates an asynchronous pedestrian button latch that safely curtails Green duration to service pedestrians without violating yellow safety margins.
- **Safety Monitor:** Self-checking testbench continuously verified that Main Green and Main Red/Pedestrian Walk were never active concurrently.

### 2.6 ATM Controller FSM (`src/atm.v`, `tb/atm_tb.v`)
- **Design:** Multi-state secure transaction pipeline: `IDLE -> PIN_CHECK -> TRANSACT -> DISPENSE / EJECT / LOCKED`. Enforces a strict 3-attempt limit for invalid PINs before permanently locking the card session. Supports balance inquiries and account overdraft protections.

### 2.7 Round-Robin Arbiter (`src/arbiter.v`, `tb/arbiter_tb.v`)
- **Design:** A rotating priority pointer grants access to the highest priority requester and rotates priority to `(granted_id + 1)` on each grant.
- **Verification:** Continuous simultaneous 4-way contention (`4'b1111`) verified cyclic rotation without starving any channel.

### 2.8 Single-Port RAM & Watchdog Timer (`src/ram.v`, `src/watchdog.v`, `tb/ram_watchdog_tb.v`)
- **Design:** 64-word x 32-bit synchronous memory array and an auto-reloading watchdog timer that triggers system reset pulses if unserviced before timeout.

---

## Simulation & Waveform Instructions

### Running in ModelSim / QuestaSim
Open ModelSim in the project directory:
```tcl
cd day2
do run_day2.do
```

To view waveform screenshots:
All simulation waveforms are captured as `.png` images in `waves/` (e.g. `waves/2.1.png`).

