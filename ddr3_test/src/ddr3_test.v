module ddr3_test
(
    input wire clk,
    input wire rst,
    input wire [3:0] key_n,
    output wire [5:0] led_n,

    output wire [14:0] ddr_addr,
    output wire [2:0] ddr_ba,
    output wire ddr_cs_n,
    output wire ddr_ras_n,
    output wire ddr_cas_n,
    output wire ddr_we_n,
    output wire ddr_clk,
    output wire ddr_clk_n,
    output wire ddr_cke,
    output wire ddr_odt,
    output wire ddr_reset_n,
    output wire [3:0] ddr_dqm,
    inout wire [31:0] ddr_dq,
    inout wire [3:0] ddr_dqs,
    inout wire [3:0] ddr_dqs_n
);

    wire pll_lock, memory_clk, pll_stop;

    Gowin_PLL Gowin_PLL_i(
        .clkin(clk),
        .reset(rst),
        .lock(pll_lock),
        .enclk0(1'b1),
        .clkout0(),
        .enclk2(pll_stop),
        .clkout2(memory_clk)
    );

    wire reset = rst || !pll_lock;

    // DRAM Test.
    localparam ST_INIT = 0;
    localparam ST_WRITE = 1;
    localparam ST_START_READ = 2;
    localparam ST_READ_CHECK = 3;
    localparam ST_NEXT_PATTERN = 4;
    localparam ST_DONE = 5;
    localparam ST_ERROR = 6;

    localparam PATT_0 = 0;
    localparam PATT_5 = 1;
    localparam PATT_A = 2;
    localparam PATT_F = 3;
    localparam PATT_ADDR = 4;

    localparam DRAM_READ = 3'b001;
    localparam DRAM_WRITE = 3'b000;

    wire init_calib_complete;
    wire dram_clk, reset_dram;
    reg [27:0] app_addr;
    reg [2:0] app_cmd;
    reg app_en;
    wire app_rdy;
    reg [255:0] app_wdf_data;
    reg app_wdf_end;
    reg app_wdf_wren;
    reg [31:0] app_wdf_mask;
    wire app_wdf_rdy;
    wire [255:0] app_rd_data;
    wire app_rd_data_valid;

    DDR3_Memory_Interface_Top DDR3_Memory_Interface_Top_i(
        .clk(clk),
        .pll_stop(pll_stop),
        .memory_clk(memory_clk),
        .pll_lock(pll_lock),
        .rst_n(~reset),

        .clk_out(dram_clk),
        .ddr_rst(reset_dram),
        .cmd_ready(app_rdy),
        .cmd(app_cmd),
        .cmd_en(app_en && app_rdy),  // FIXME: does not work without && app_rdy
        .addr({1'b0, app_addr}),
        .wr_data_rdy(app_wdf_rdy),
        .wr_data(app_wdf_data),
        .wr_data_en(app_wdf_wren && app_wdf_rdy),  // FIXME: does not work without && app_wdf_rdy
        .wr_data_end(app_wdf_end),
        .wr_data_mask(app_wdf_mask),
        .rd_data(app_rd_data),
        .rd_data_valid(app_rd_data_valid),
        .rd_data_end(),

        .burst(1'b1),
        .sr_req(1'b0),
        .sr_ack(),
        .ref_req(1'b0),
        .ref_ack(),

        .init_calib_complete(init_calib_complete),

        .O_ddr_addr(ddr_addr),
        .O_ddr_ba(ddr_ba),
        .O_ddr_cs_n(ddr_cs_n),
        .O_ddr_ras_n(ddr_ras_n),
        .O_ddr_cas_n(ddr_cas_n),
        .O_ddr_we_n(ddr_we_n),
        .O_ddr_clk(ddr_clk),
        .O_ddr_clk_n(ddr_clk_n),
        .O_ddr_cke(ddr_cke),
        .O_ddr_odt(ddr_odt),
        .O_ddr_reset_n(ddr_reset_n),
        .O_ddr_dqm(ddr_dqm),
        .IO_ddr_dq(ddr_dq),
        .IO_ddr_dqs(ddr_dqs),
        .IO_ddr_dqs_n(ddr_dqs_n)
    );

    localparam DRAM_MIN_ADDR = 28'h0000000;
    localparam DRAM_MAX_ADDR = 28'hffffff8;
    localparam DRAM_FREQ = 100000000;

    reg [27:0] dram_addr;

    reg dram_pass;
    integer dram_state;
    integer dram_pattern_state;
    reg [27:0] dram_pattern_addr;

    function [255:0] gen_patt;
        input integer state;
        input wire [27:0] addr;
    begin
        case (state)
            PATT_0: gen_patt = 256'h0000000000000000000000000000000000000000000000000000000000000000;
            PATT_5: gen_patt = 256'h5555555555555555555555555555555555555555555555555555555555555555;
            PATT_A: gen_patt = 256'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
            PATT_F: gen_patt = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            default: gen_patt = {addr[27:3], 7'h1D, addr[27:3], 7'h19, addr[27:3], 7'h15, addr[27:3], 7'h11,
                                 addr[27:3], 7'h0C, addr[27:3], 7'h08, addr[27:3], 7'h04, addr[27:3], 7'h00};
            endcase
    end
    endfunction

    reg dram_addr_acked, dram_wdata_acked;
    wire dram_addr_fire = app_en && app_rdy;
    wire dram_wdata_fire = app_wdf_wren && app_wdf_rdy;
    wire dram_addr_ack = dram_addr_acked || dram_addr_fire;
    wire dram_wdata_ack = dram_wdata_acked || dram_wdata_fire;
    reg [31:0] dram_wdt;
    wire [255:0] dram_patt = gen_patt(dram_pattern_state, dram_addr);

    integer i;
    reg [7:0] dram_error;

    always @ (posedge dram_clk or posedge reset_dram)
    begin
        if (reset_dram)
        begin
            dram_pass <= 1'b0;
            dram_state <= ST_INIT;
            dram_pattern_state <= PATT_0;
            dram_addr <= DRAM_MIN_ADDR;
            dram_addr_acked <= 1'b0;
            dram_wdata_acked <= 1'b0;
            app_addr <= DRAM_MIN_ADDR;
            app_cmd <= DRAM_READ;
            app_en <= 1'b0;
            app_wdf_data <= 0;
            app_wdf_end <= 1'b0;
            app_wdf_wren <= 1'b0;
            app_wdf_mask <= 0;
            dram_wdt <= 0;

            dram_error <= 8'h00;
        end
        else
        begin
            if (dram_wdt == 5 * DRAM_FREQ - 1)
            begin
                // The Watch Dog times out.
                dram_state <= ST_ERROR;
            end
            dram_wdt <= dram_wdt + 1;

            case (dram_state)
            ST_INIT:
            begin
                if (init_calib_complete)
                begin
                    dram_state <= ST_WRITE;
                    dram_wdt <= 0;
                end
            end
            ST_WRITE:
            begin
                if (!dram_addr_acked)
                begin
                    app_addr <= dram_addr;
                    app_cmd <= DRAM_WRITE;
                    app_en <= 1'b1;
                end

                if (dram_addr_fire)
                begin
                    dram_addr_acked <= 1'b1;
                    app_en <= 1'b0;
                end

                if (!dram_wdata_acked)
                begin
                    app_wdf_data <= gen_patt(dram_pattern_state, dram_addr);
                    app_wdf_mask <= 0;
                    app_wdf_end <= 1'b1;
                    app_wdf_wren <= 1'b1;
                end

                if (dram_wdata_fire)
                begin
                    dram_wdata_acked <= 1'b1;
                    app_wdf_wren <= 1'b0;
                end

                if (dram_addr_ack && dram_wdata_ack)
                begin
                    dram_addr_acked <= 1'b0;
                    dram_wdata_acked <= 1'b0;
                    dram_wdt <= 0;

                    if (dram_addr == DRAM_MAX_ADDR)
                    begin
                        dram_addr <= DRAM_MIN_ADDR;
                        app_addr <= DRAM_MIN_ADDR;
                        app_cmd <= DRAM_READ;
                        app_en <= 1'b1;
                        dram_state <= ST_READ_CHECK;
                    end
                    else
                    begin
                        app_addr <= dram_addr + 8;
                        dram_addr <= dram_addr + 8;
                        app_cmd <= DRAM_WRITE;
                        app_en <= 1'b1;
                        app_wdf_data <= gen_patt(dram_pattern_state, dram_addr + 8);
                        app_wdf_mask <= 0;
                        app_wdf_end <= 1'b1;
                        app_wdf_wren <= 1'b1;
                    end
                end
            end
            ST_READ_CHECK:
            begin
                if (!dram_addr_acked)
                begin
                    app_addr <= dram_addr;
                    app_cmd <= DRAM_READ;
                    app_en <= 1'b1;
                end

                if (dram_addr_fire)
                begin
                    dram_addr_acked <= 1'b1;
                    app_en <= 1'b0;
                end

                if (dram_addr_acked && app_rd_data_valid)
                begin
                    dram_addr_acked <= 1'b0;
                    dram_wdt <= 0;

                    for (i = 0; i < 8; i = i + 1)
                    begin
                        dram_error[i] <= app_rd_data[32 * i +: 32] != dram_patt[32 * i +: 32];
                    end

                    if (dram_addr == DRAM_MAX_ADDR)
                    begin
                        dram_addr <= DRAM_MIN_ADDR;
                        dram_state <= ST_NEXT_PATTERN;
                    end
                    else
                    begin
                        app_addr <= dram_addr + 8;
                        dram_addr <= dram_addr + 8;
                        app_cmd <= DRAM_READ;
                        app_en <= 1'b1;
                    end
                end
            end
            ST_NEXT_PATTERN:
            begin
                dram_wdt <= 0;
                dram_state <= ST_WRITE;
                case (dram_pattern_state)
                PATT_0: dram_pattern_state <= PATT_5;
                PATT_5: dram_pattern_state <= PATT_A;
                PATT_A: dram_pattern_state <= PATT_F;
                PATT_F: dram_pattern_state <= PATT_ADDR;
                PATT_ADDR:
                begin
                    // dram_state <= ST_DONE;
                    dram_pattern_state <= PATT_0;
                    dram_pass <= 1'b1;
                end
                default: dram_pattern_state <= PATT_0;
                endcase
            end
            ST_DONE:
            begin
                dram_wdt <= 0;
            end
            ST_ERROR:
            begin
                dram_wdt <= 0;
                dram_pass <= 1'b0;
            end
            default:
            begin
                dram_state <= ST_INIT;
                dram_addr <= DRAM_MIN_ADDR;
            end
            endcase

            if (|dram_error)
            begin
                dram_state <= ST_ERROR;
                app_en <= 1'b0;
                app_wdf_wren <= 1'b0;
            end
        end
    end

    assign led_n = ~{1'b0, dram_pass, dram_state != ST_ERROR, app_wdf_rdy, app_rdy, init_calib_complete};
endmodule
