# ModelSim Automated Test & Waveform Script for Day 1

vlib work

# Compile all RTL sources
vlog src/alu.v
vlog src/counter.v
vlog src/shifter.v
vlog src/regfile.v
vlog src/full_adder.v
vlog src/adder_sub.v
vlog src/encoder.v
vlog src/decoder.v
vlog src/shiftreg.v
vlog src/lfsr.v
vlog src/edge_detect.v
vlog src/debounce.v

# Compile all Testbenches
vlog tb/alu_tb.v
vlog tb/counter_tb.v
vlog tb/shifter_tb.v
vlog tb/regfile_tb.v
vlog tb/adder_sub_tb.v
vlog tb/encoder_decoder_tb.v
vlog tb/shiftreg_lfsr_tb.v
vlog tb/debounce_edge_tb.v

# Run simulations and dump waveforms
vsim -c -wlf waves/1_1_alu.wlf alu_tb -do "add wave -r /*; run -all; quit"
vsim -c -wlf waves/1_2_counter.wlf counter_tb -do "add wave -r /*; run -all; quit"
vsim -c -wlf waves/1_3_shifter.wlf shifter_tb -do "add wave -r /*; run -all; quit"
vsim -c -wlf waves/1_4_regfile.wlf regfile_tb -do "add wave -r /*; run -all; quit"
vsim -c -wlf waves/1_5_adder_sub.wlf adder_sub_tb -do "add wave -r /*; run -all; quit"
vsim -c -wlf waves/1_6_encoder_decoder.wlf encoder_decoder_tb -do "add wave -r /*; run -all; quit"
vsim -c -wlf waves/1_7_shiftreg_lfsr.wlf shiftreg_lfsr_tb -do "add wave -r /*; run -all; quit"
vsim -c -wlf waves/1_8_debounce_edge.wlf debounce_edge_tb -do "add wave -r /*; run -all; quit"

