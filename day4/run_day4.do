# ModelSim Automated Test & Waveform Script for Day 4

vlib work

# Compile all RTL sources
vlog src/forwarding_unit.v
vlog src/hazard_unit.v
vlog src/riscv_5stage.v

# Compile Testbench
vlog tb/riscv_5stage_tb.v

# Run simulation and dump waveforms
vsim -c -wlf waves/4_pipeline_simulation.wlf riscv_5stage_tb -do "add wave -r /*; run -all; quit"

