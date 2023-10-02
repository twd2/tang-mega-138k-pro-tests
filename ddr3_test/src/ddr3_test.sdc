create_clock -name clk -period 20.000 -waveform {0.000 10.000} [get_ports {clk}]

create_clock -name memory_clk -period 2.5 -waveform {0 1.25} [get_nets {memory_clk}]
create_clock -name ui_clk -period 10.0 -waveform {0.0 5.0} [get_pins {DDR3_Memory_Interface_Top_i/gw3_top/u_ddr_phy_top/fclkdiv/CLKOUT}]
set_clock_groups -asynchronous -group [get_clocks {clk}] -group [get_clocks {ui_clk}]
set_clock_groups -asynchronous -group [get_clocks {ui_clk}] -group [get_clocks {memory_clk}]
