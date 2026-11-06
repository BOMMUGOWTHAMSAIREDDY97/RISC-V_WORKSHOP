# ModelSim Automated Test & Waveform Script for Day 2

vlib work

# Compile all RTL sources
vlog src/seq_moore.v
vlog src/seq_mealy.v
vlog src/vending.v
vlog src/fifo.v
vlog src/traffic_light.v
vlog src/atm.v
vlog src/arbiter.v
vlog src/ram.v
vlog src/watchdog.v

# Compile all Testbenches
vlog tb/seq_tb.v
vlog tb/vending_tb.v
vlog tb/fifo_tb.v
vlog tb/traffic_light_tb.v
vlog tb/atm_tb.v
vlog tb/arbiter_tb.v
vlog tb/ram_watchdog_tb.v

# Run simulations and dump waveforms
vsim -c -wlf waves/2_1_seq.wlf seq_tb -do "add wave -r /*; run -all; quit"
vsim -c -wlf waves/2_2_vending.wlf vending_tb -do "add wave -r /*; run -all; quit"
vsim -c -wlf waves/2_3_fifo.wlf fifo_tb -do "add wave -r /*; run -all; quit"
vsim -c -wlf waves/2_5_traffic_light.wlf traffic_light_tb -do "add wave -r /*; run -all; quit"
vsim -c -wlf waves/2_6_atm.wlf atm_tb -do "add wave -r /*; run -all; quit"
vsim -c -wlf waves/2_7_arbiter.wlf arbiter_tb -do "add wave -r /*; run -all; quit"
vsim -c -wlf waves/2_8_ram_watchdog.wlf ram_watchdog_tb -do "add wave -r /*; run -all; quit"

