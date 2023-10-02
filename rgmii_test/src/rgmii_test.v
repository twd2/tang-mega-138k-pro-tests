module rgmii_test
(
    input wire clk,
    input wire rst,
    input wire [3:0] key_n,
    output wire [5:0] led_n,

    output wire rgmii_clk,
    output reg rgmii_rst_n,
    input wire rgmii_rxc,
    input wire rgmii_rx_ctl,
    input wire [3:0] rgmii_rxd,
    output wire rgmii_txc,
    output wire rgmii_tx_ctl,
    output wire [3:0] rgmii_txd,
    output wire mdc,
    inout wire mdio
);

    wire gtx_clk;
    wire lock;

    Gowin_PLL Gowin_PLL_i(
        .clkin(clk),
        .reset(rst),
        .lock(lock),
        .clkout0(rgmii_clk),
        .clkout1(gtx_clk)
    );

    wire reset = rst || !lock;

    reg [5:0] led_reg;
    reg [31:0] counter;

    always @ (posedge gtx_clk or posedge reset)
    begin
        if (reset)
        begin
            led_reg <= 0;
            counter <= 0;
        end
        else
        begin
            if (counter == 125000000 - 1)
            begin
                led_reg <= led_reg + 1;
                counter <= 0;
            end
            else
            begin
                counter <= counter + 1;
            end
        end
    end

    assign led_n = ~led_reg;

    reg [31:0] rgmii_counter;

    always @ (posedge rgmii_clk or posedge reset)
    begin
        if (reset)
        begin
            rgmii_counter <= 0;
            rgmii_rst_n <= 1'b0;
        end
        else
        begin
            if (rgmii_counter == 25000000 / 2 - 1)
            begin
                rgmii_rst_n <= 1'b1;
            end
            else
            begin
                rgmii_counter <= rgmii_counter + 1;
            end
        end
    end

    wire mdio_i, mdio_o, mdio_en;
    assign mdio_i = mdio;
    assign mdio = mdio_en ? mdio_o : 1'bz;

    wire eth_tx_clk;
    reg eth_tx_valid;
    wire eth_tx_ready;
    reg [7:0] eth_tx_data;
    reg eth_tx_last;
    wire eth_tx_error = 1'b0;

    Triple_Speed_Ethernet_MAC_Top Triple_Speed_Ethernet_MAC_Top_i(
        .rgmii_rxc(rgmii_rxc),
        .rgmii_rx_ctl(rgmii_rx_ctl),
        .rgmii_rxd(rgmii_rxd),
        .gtx_clk(gtx_clk),
        .rgmii_txc(rgmii_txc),
        .rgmii_tx_ctl(rgmii_tx_ctl),
        .rgmii_txd(rgmii_txd),
        .speedis1000(1'b1),
        .speedis10(1'b0),
        .duplex_status(1'b1),
        .rstn(~reset),

        .rx_mac_clk(),
        .rx_mac_valid(),
        .rx_mac_data(),
        .rx_mac_last(),
        .rx_mac_error(),
        .rx_statistics_valid(),
        .rx_statistics_vector(),

        .tx_mac_clk(eth_tx_clk),
        .tx_mac_valid(eth_tx_valid),
        .tx_mac_data(eth_tx_data),
        .tx_mac_last(eth_tx_last),
        .tx_mac_error(eth_tx_error),
        .tx_mac_ready(eth_tx_ready),
        .tx_collision(),
        .tx_retransmit(),
        .tx_statistics_valid(),
        .tx_statistics_vector(),

        .rx_fcs_fwd_ena(1'b0),
        .rx_jumbo_ena(1'b0),
        .rx_pause_req(),
        .rx_pause_val(),
        .tx_fcs_fwd_ena(1'b0),
        .tx_ifg_delay_ena(1'b0),
        .tx_ifg_delay(8'd0),
        .tx_pause_req(1'b0),
        .tx_pause_val(16'b0),
        .tx_pause_source_addr(48'd0),

        .clk(clk),
        .miim_phyad(5'd0),
        .miim_regad(5'd0),
        .miim_wrdata(16'd0),
        .miim_wren(1'b0),
        .miim_rden(1'b0),
        .miim_rddata(),
        .miim_rddata_valid(),
        .miim_busy(),
        .mdc(mdc),
        .mdio_in(mdio_i),
        .mdio_out(mdio_o),
        .mdio_oen(mdio_en)
    );

    localparam FRAME_LEN = 64;
    wire [511:0] frame_data = 512'h00000060dd86001069641f8cffffffffffff;
    // wire [511:0] frame_data = 512'h140000450008001069641f8cffffffffffff;
    reg [511:0] frame;
    reg [31:0] frame_counter;

    always @ (posedge eth_tx_clk or posedge reset)
    begin
        if (reset)
        begin
            frame <= frame_data;
            frame_counter <= 0;
        end
        else
        begin
            if (!eth_tx_valid || eth_tx_ready)
            begin
                eth_tx_valid <= 1'b1;
                eth_tx_data <= frame[7:0];

                if (frame_counter == FRAME_LEN - 1)
                begin
                    eth_tx_last <= 1'b1;
                    frame <= frame_data;
                    frame_counter <= 0;
                end
                else
                begin
                    eth_tx_last <= 1'b0;
                    frame <= {8'd0, frame[511:8]};
                    frame_counter <= frame_counter + 1;
                end
            end
        end
    end

endmodule
