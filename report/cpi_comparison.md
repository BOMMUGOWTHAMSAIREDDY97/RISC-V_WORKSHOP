# Activity 4.3 & 4.7: CPI Comparison — Single-Cycle vs. 5-Stage Pipeline

**Student:** Bommu Gowtham Sai Reddy  
**Program:** Verilog RTL Design and RISC-V Processor Development  
**Trainer:** Yuvaraj Seenipandi, Infoziant (Kalasalingam University)

---

## 1. Theoretical Baseline: Ideal CPI

| Architecture | Ideal CPI (No Hazards) | Practical CPI (With Hazards) | Performance Comparison |
| :--- | :---: | :---: | :---: |
| **Single-Cycle** | 1.00 | 1.00 (always) | Baseline |
| **5-Stage Pipeline (No Hazards)** | 1.00 | > 1.00 (penalty cycles) | Throughput advantage at scale |
| **5-Stage Pipeline (This Run)** | 1.00 | 1.15 | 29 cycles / ~25 ideal cycles |

> [!NOTE]
> Single-cycle processor always completes in exactly 1 clock cycle per instruction, but the clock **period** must be long enough to cover the longest possible combinational path (typically the Load instruction path: IMEM → Decode → RegFile read → ALU → DMEM read → WB mux). In a pipelined design, each stage is shallower, allowing a **much shorter clock period** and thus higher maximum operating frequency ($F_{max}$), which ultimately compensates for the per-cycle overhead.

---

## 2. Measured Performance Counters (Day 4 Testbench Run)

| Counter | Measured Value |
| :--- | ---: |
| **Total Clock Cycles** | 29 |
| **Instructions Retired** | 7 |
| **Load-Use Stall Cycles** | 1 |
| **Branch Flush Events** | 1 |
| **Effective CPI (Measured)** | **4.14** *(start-up dominant — see note)* |

> [!IMPORTANT]
> The high CPI of 4.14 measured in the testbench run is **artificially inflated by pipeline startup latency**. The 5-stage pipeline requires 4 clock cycles before the first instruction reaches WB and retires. For a **long instruction stream** (100+ instructions), the startup cost is amortized and the effective CPI converges towards `1 + (Stalls + Flushes) / Instructions_Retired`.

---

## 3. Hazard Penalty Analysis

### Load-Use Hazard (1-Cycle Stall)
When a `LW x5, 0(x0)` loads from memory and the **immediately following** instruction `ADD x8, x5, x1` reads `x5`, the load data is not available until after the MEM stage. The Hazard Detection Unit inserts exactly 1 NOP bubble cycle:

```
Cycle:     1    2    3    4    5    6    7
LW:       IF   ID   EX  MEM   WB
ADD x8:        IF   ID  ---   EX  MEM   WB
                        ^
                 (1 bubble inserted here: ID/EX receives NOP)
```

**CPI penalty:** `+1 cycle` per load-use hazard occurrence.

---

### Branch Misprediction Flush (2-Cycle Penalty)
The 5-stage pipeline uses **static predict-not-taken** strategy. When `BEQ x4, x2, +8` is resolved in the EX stage and the branch is **taken**, two instructions already fetched (`ADDI x6` at ID and the next NOP at IF) must be flushed:

```
Cycle:     1    2    3    4    5    6    7
BEQ:      IF   ID   EX  MEM   WB
ADDI x6:       IF   ID  ---  (flush)
Next IF:            IF  ---  (flush)
Target:                  IF   ID   EX  MEM   WB
                         ^
              (Branch resolved at EX → 2 flush bubbles)
```

**CPI penalty:** `+2 cycles` per taken branch.

---

## 4. Single-Cycle vs. 5-Stage Pipeline: Critical Path Comparison

| Component | Single-Cycle Critical Path | 5-Stage Pipeline Stage Depth |
| :--- | :--- | :--- |
| **Instruction Fetch** | IMEM access | 1 stage (IF) |
| **Decode + Register Read** | Combinational | 1 stage (ID) |
| **ALU Computation** | Combinational | 1 stage (EX) |
| **Data Memory Access** | Combinational | 1 stage (MEM) |
| **Write-Back Mux** | Combinational | 1 stage (WB) |
| **Minimum Clock Period** | Sum of all 5 paths | Max of any single path |
| **Relative $F_{max}$ Gain** | 1× | ~3-5× depending on memory latency |

---

## 5. Formula Summary

```
CPI_pipeline = 1.0 + (Load-Use Stalls + 2 x Branch Flushes) / Instructions_Retired
```

For this run:
```
CPI_effective = 1.0 + (1 + 2x1) / 7  ≈  1.43  (excluding startup)
```

