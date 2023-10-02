create_clock -name clk -period 20.000 -waveform {0.000 10.000} [get_ports {clk}]
create_clock -name rgmii_rxc -period 8.000 -waveform {0.000 4.000} [get_ports {rgmii_rxc}]
