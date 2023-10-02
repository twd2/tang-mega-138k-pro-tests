//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.9 Beta-5
//Part Number: GW5AST-LV138FPG676AES
//Device: GW5AST-138
//Device Version: B
//Created Time: Sat Sep 30 22:46:53 2023

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	Triple_Speed_Ethernet_MAC_Top your_instance_name(
		.rgmii_rxc(rgmii_rxc_i), //input rgmii_rxc
		.rgmii_rx_ctl(rgmii_rx_ctl_i), //input rgmii_rx_ctl
		.rgmii_rxd(rgmii_rxd_i), //input [3:0] rgmii_rxd
		.gtx_clk(gtx_clk_i), //input gtx_clk
		.rgmii_txc(rgmii_txc_o), //output rgmii_txc
		.rgmii_tx_ctl(rgmii_tx_ctl_o), //output rgmii_tx_ctl
		.rgmii_txd(rgmii_txd_o), //output [3:0] rgmii_txd
		.speedis1000(speedis1000_i), //input speedis1000
		.speedis10(speedis10_i), //input speedis10
		.duplex_status(duplex_status_i), //input duplex_status
		.rstn(rstn_i), //input rstn
		.rx_mac_clk(rx_mac_clk_o), //output rx_mac_clk
		.rx_mac_valid(rx_mac_valid_o), //output rx_mac_valid
		.rx_mac_data(rx_mac_data_o), //output [7:0] rx_mac_data
		.rx_mac_last(rx_mac_last_o), //output rx_mac_last
		.rx_mac_error(rx_mac_error_o), //output rx_mac_error
		.rx_statistics_valid(rx_statistics_valid_o), //output rx_statistics_valid
		.rx_statistics_vector(rx_statistics_vector_o), //output [26:0] rx_statistics_vector
		.tx_mac_clk(tx_mac_clk_o), //output tx_mac_clk
		.tx_mac_valid(tx_mac_valid_i), //input tx_mac_valid
		.tx_mac_data(tx_mac_data_i), //input [7:0] tx_mac_data
		.tx_mac_last(tx_mac_last_i), //input tx_mac_last
		.tx_mac_error(tx_mac_error_i), //input tx_mac_error
		.tx_mac_ready(tx_mac_ready_o), //output tx_mac_ready
		.tx_collision(tx_collision_o), //output tx_collision
		.tx_retransmit(tx_retransmit_o), //output tx_retransmit
		.tx_statistics_valid(tx_statistics_valid_o), //output tx_statistics_valid
		.tx_statistics_vector(tx_statistics_vector_o), //output [28:0] tx_statistics_vector
		.rx_fcs_fwd_ena(rx_fcs_fwd_ena_i), //input rx_fcs_fwd_ena
		.rx_jumbo_ena(rx_jumbo_ena_i), //input rx_jumbo_ena
		.rx_pause_req(rx_pause_req_o), //output rx_pause_req
		.rx_pause_val(rx_pause_val_o), //output [15:0] rx_pause_val
		.tx_fcs_fwd_ena(tx_fcs_fwd_ena_i), //input tx_fcs_fwd_ena
		.tx_ifg_delay_ena(tx_ifg_delay_ena_i), //input tx_ifg_delay_ena
		.tx_ifg_delay(tx_ifg_delay_i), //input [7:0] tx_ifg_delay
		.tx_pause_req(tx_pause_req_i), //input tx_pause_req
		.tx_pause_val(tx_pause_val_i), //input [15:0] tx_pause_val
		.tx_pause_source_addr(tx_pause_source_addr_i), //input [47:0] tx_pause_source_addr
		.clk(clk_i), //input clk
		.miim_phyad(miim_phyad_i), //input [4:0] miim_phyad
		.miim_regad(miim_regad_i), //input [4:0] miim_regad
		.miim_wrdata(miim_wrdata_i), //input [15:0] miim_wrdata
		.miim_wren(miim_wren_i), //input miim_wren
		.miim_rden(miim_rden_i), //input miim_rden
		.miim_rddata(miim_rddata_o), //output [15:0] miim_rddata
		.miim_rddata_valid(miim_rddata_valid_o), //output miim_rddata_valid
		.miim_busy(miim_busy_o), //output miim_busy
		.mdc(mdc_o), //output mdc
		.mdio_in(mdio_in_i), //input mdio_in
		.mdio_out(mdio_out_o), //output mdio_out
		.mdio_oen(mdio_oen_o) //output mdio_oen
	);

//--------Copy end-------------------
