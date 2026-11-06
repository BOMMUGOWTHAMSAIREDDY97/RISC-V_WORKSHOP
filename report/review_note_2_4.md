# Activity 2.4: FSM Design, Encoding & Memory Architecture Review

**STUDENT:** BOMMU GOWTHAM SAI REDDY
**REG NO:** 9923005065
**DEPT:** ECE  
**PROGRAM:** VERILOG RTL DESIGN AND RISC-V PROCESSOR DEVELOPMENT  
**TRAINER:** YUVARAJ SEENIPANDI, INFOZIANT (KALASALINGAM UNIVERSITY)

---

## 1. FSM State Encoding Analysis: Binary vs. One-Hot vs. Gray

When implementing Finite State Machines (FSMs) in digital RTL design, selecting the optimal state encoding scheme directly dictates flip-flop utilization, combinational fan-in, decoding delay, and maximum clock operating frequency ($F_{max}$).

### Detailed Comparison Matrix

| Metric | Binary Encoding | One-Hot Encoding | Gray Code Encoding |
| :--- | :--- | :--- | :--- |
| **Number of Flip-Flops for $N$ States** | $\lceil \log_2 N \rceil$ | $N$ | $\lceil \log_2 N \rceil$ |
| **Combinational Decode Logic** | Complex (multiple gates / wide ANDs) | Extremely Simple (single flip-flop bit per state) | Moderate |
| **Bit Transitions per Adjacent State** | $1$ to $\lceil \log_2 N \rceil$ bits (multiple) | Exactly 2 bits (1 turns off, 1 turns on) | Exactly 1 bit |
| **Dynamic Switching Power** | Moderate to High | Low to Moderate | Lowest |
| **Susceptibility to Critical-Path Delay** | Higher next-state logic depth | Minimum logic depth (shallow LUTs) | Low for consecutive sequential states |
| **Primary Platform Recommendation** | **ASIC** (where silicon area / standard-cell gates are precious) | **FPGA** (LUT-rich, register-abundant architecture) | **Counters & CDC Pointers** |

### Synthesis & Architecture Takeaways
1. **FPGA Realization (One-Hot Default):**
   Modern FPGAs (such as Intel Cyclone/Arria and AMD Spartan/Artix) feature a high ratio of flip-flops to Look-Up Tables (LUTs). One-hot encoding assigns each state its own dedicated register. Next-state equations collapse into simple wide OR/AND gates fitting directly into single 4-to-6 input LUTs without cascading. This drastically reduces propagation delay and yields the highest $F_{max}$.
2. **ASIC Standard-Cell Optimization (Binary Default):**
   In ASIC synthesis (e.g., TSMC or Synopsys Design Compiler), D-flip-flops occupy significantly more silicon real estate than combinational logic gates. For large state spaces, binary encoding minimizes gate count and reduces routing congestion.
3. **Gray Encoding for Sequential Pipelines:**
   Gray coding ensures that only one state bit flips between consecutive states. This eliminates intermediate switching transients, drastically cuts dynamic power consumption, and eliminates false decode glitches.

---

## 2. Moore vs. Mealy FSM Architectural Trade-Offs

| Characteristic | Moore FSM | Mealy FSM |
| :--- | :--- | :--- |
| **Output Dependency** | Strictly on current state: $Y = f(S)$ | On current state AND inputs: $Y = g(S, X)$ |
| **Output Response Timing** | Synchronous to clock edge (1 clock cycle latency) | Immediate/asynchronous response within same clock cycle |
| **Glitch Vulnerability** | **Immune to input glitches** (outputs change only on state transitions) | **Vulnerable to input hazards/glitches** that propagate directly to outputs |
| **Number of Required States** | Typically more states (e.g., 5 states for 4-bit sequence) | Fewer states (e.g., 4 states for 4-bit sequence) |
| **Design Retiming Strategy** | Output register can be cleanly merged into datapath | Requires output registering stage to prevent timing path chaining |

### Practical Design Guidelines:
- In high-speed synchronous interfaces, pure Mealy outputs must be avoided when driving external control buses or cross-module interfaces, as combinational input glitches or setup-time margins can easily violate downstream timing constraints.
- When single-cycle latency is mandatory (such as early branch prediction or handshaking ready/valid loops), register retiming (pipelining the Mealy output) provides the best balance between speed and glitch-free operation.

---

## 3. FIFO Memory Architecture: Synchronous vs. Asynchronous (CDC)

### Synchronous FIFO
- **Architecture:** Shared single clock domain for both read and write operations (`wr_clk == rd_clk`).
- **Pointer Comparison:** Binary write and read pointers directly compare against each other. An additional upper bit ($N+1$ bits for $2^N$ depth) or an integrated up/down counter (`count`) accurately monitors fill level, enabling straightforward generation of `empty`, `full`, `almost_empty`, and `almost_full` flags.
- **Safety:** Single-clock operation eliminates metastability hazards.

### Asynchronous Dual-Clock FIFO & Clock Domain Crossing (CDC)
When data must cross between independent or plesiochronous clock domains (`wr_clk` $\ne$ `rd_clk`):
1. **The Metastability Problem:**
   Directly sampling a multi-bit binary counter across asynchronous clock domains will result in sampling errors due to routing skew. If multiple bits change simultaneously (e.g., `0011` to `0100` flips 3 bits), the receiving registers can capture corrupted intermediate states (`0000`, `0111`, etc.), causing catastrophic FIFO corruption.
2. **Gray Code Pointer Solution:**
   Converting binary pointers to Gray code (`gray = bin ^ (bin >> 1)`) guarantees that **only one bit changes per clock cycle**. Therefore, even if a setup/hold timing violation occurs at the boundary, the receiving domain will sample either the old pointer or the new pointer, never an undefined or corrupt value.
3. **2-Flip-Flop Synchronizers:**
   The Gray code pointers are synchronized into the opposite clock domain using a cascaded 2-stage D-flip-flop synchronizer. This drastically increases the Mean Time Between Failures (MTBF) to decades.
4. **Flag Generation:**
   - `wr_full` is evaluated in the `wr_clk` domain by comparing the local write Gray pointer with the 2-FF synchronized read Gray pointer.
   - `rd_empty` is evaluated in the `rd_clk` domain by comparing the local read Gray pointer with the 2-FF synchronized write Gray pointer.

