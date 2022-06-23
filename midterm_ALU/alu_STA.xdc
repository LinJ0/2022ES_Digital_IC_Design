#set_max_delay 10
#create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]
create_clock -period 20.0 -name vclk

set_input_delay  0.1   -clock vclk [all_inputs] 
set_output_delay 0.1    -clock vclk [all_outputs] 