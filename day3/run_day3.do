# ModelSim Automated Test & Waveform Script for Day 3

vlib work

# Compile CPU and Testbench
vlog src/cpu.v
vlog tb/cpu_tb.v

# Run simulation and dump waveforms
vsim -c -wlf waves/3_cpu_simulation.wlf cpu_tb -do "add wave -r /*; run -all; quit"

