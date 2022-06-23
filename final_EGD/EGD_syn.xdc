create_clock -name clk -period 20.0 -waveform {0.000 10.000} [get_ports clk]

set_input_delay   -clock clk  0.1 [all_inputs] -clock_fall
set_output_delay  -clock clk  0.1 [all_outputs] -clock_fall