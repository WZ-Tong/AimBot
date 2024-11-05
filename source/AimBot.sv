`timescale 1ns / 1ps

module AimBot #(
    parameter  BOX_NUM    = 1                    ,
    parameter  BOX_WIDTH  = 1                    ,

    parameter  LOCAL_MAC  = 48'h01_02_03_04_05_06,
    parameter  LOCAL_IP   = 32'hC0_A8_02_65      ,
    parameter  LOCAL_PORT = 16'h1F90             ,
    parameter  DEST_IP    = 32'hC0_A8_02_64      ,
    parameter  DEST_PORT  = 16'h1F90             ,

    localparam H_ACT      = 1280                 ,
    localparam V_ACT      = 720                  ,
    localparam KEY_HOLD   = 500_000
) (
    input        clk          ,

    // Ctrl key
    input        cam_key      ,
    input        balance_key  ,
    input        gray_key     ,
    input        gammar_key   ,
    input        box_key      ,
    input        binary_key   ,
    input        balance_rstn ,

    // Cam1 ctrl/data
    inout        cam1_scl     ,
    inout        cam1_sda     ,
    input        cam1_vsync   ,
    input        cam1_href    ,
    input        cam1_pclk    ,
    input  [7:0] cam1_data    ,
    output       cam1_rstn    ,

    // Cam2 ctrl/data
    inout        cam2_scl     ,
    inout        cam2_sda     ,
    input        cam2_vsync   ,
    input        cam2_href    ,
    input        cam2_pclk    ,
    input  [7:0] cam2_data    ,
    output       cam2_rstn    ,

    // HDMI Disp data
    output       hdmi_clk     ,
    output       hdmi_hsync   ,
    output       hdmi_vsync   ,
    output       hdmi_de      ,
    output [7:0] hdmi_r       ,
    output [7:0] hdmi_g       ,
    output [7:0] hdmi_b       ,

    // HDMI Ctrl
    output       hdmi_rstn    ,
    output       hdmi_scl     ,
    inout        hdmi_sda     ,

    // RGMII Interface 1
    input        rgmii1_rxc   ,
    input        rgmii1_rx_ctl,
    input  [3:0] rgmii1_rxd   ,
    output       rgmii1_txc   ,
    output       rgmii1_tx_ctl,
    output [3:0] rgmii1_txd   ,

    // Debug signals
    output       io_init      ,
    output       net_conn     ,
    output       cam_tick     ,
    output       line_err     ,
    output       udp_err      ,
    output       udp_busy     ,

    // Cortex debugger
    input        swclk        ,
    inout        swdio
);

    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT);

    wire clk10, clk25;
    wire pll_lock, rstn;
    pll u_pll (
        .clkin1  (clk     ),
        .clkout0 (clk10   ),
        .clkout1 (clk25   ),
        .pll_lock(pll_lock)
    );
    assign rstn = pll_lock;

    // HDMI configure
    wire hdmi_inited;
    hdmi_ctrl u_hdmi_ctrl (
        .clk10    (clk10      ),
        .rstn     (rstn       ),
        .inited   (hdmi_inited),
        .iic_rstn (hdmi_rstn  ),
        .iic_i_scl(/*unused*/ ),
        .iic_i_sda(/*unused*/ ),
        .iic_o_scl(hdmi_scl   ),
        .iic_o_sda(hdmi_sda   )
    );

    // OV5640 configure & read
    wire [15:0] cam1_data_565, cam2_data_565;

    wire cam1_pclk_565, cam2_pclk_565;
    wire cam1_href_565, cam2_href_565;

    wire cam_inited ;
    wire cam1_inited, cam2_inited;
    assign cam_inited = cam1_inited && cam2_inited;

    assign io_init = hdmi_inited && cam_inited;

    ov5640_reader u_cam1_reader (
        .clk25   (clk25        ),
        .rstn    (rstn         ),
        .vsync   (cam1_vsync   ),
        .href    (cam1_href    ),
        .pclk    (cam1_pclk    ),
        .data    (cam1_data    ),
        .inited  (cam1_inited  ),
        .href_565(cam1_href_565),
        .pclk_565(cam1_pclk_565),
        .data_565(cam1_data_565),
        .cfg_scl (cam1_scl     ),
        .cfg_sda (cam1_sda     ),
        .cfg_rstn(cam1_rstn    )
    );

    wire [PACK_SIZE-1:0] disp_pack_1;
    hdmi_display u_cam1_disp (
        .clk    (cam1_pclk_565),
        .rstn   (rstn         ),
        .i_vsync(cam1_vsync   ),
        .i_data (cam1_data_565),
        .i_href (cam1_href_565),
        .o_pack (disp_pack_1  )
    );

    ov5640_reader u_cam2_reader (
        .clk25   (clk25        ),
        .rstn    (rstn         ),
        .vsync   (cam2_vsync   ),
        .href    (cam2_href    ),
        .pclk    (cam2_pclk    ),
        .data    (cam2_data    ),
        .inited  (cam2_inited  ),
        .href_565(cam2_href_565),
        .pclk_565(cam2_pclk_565),
        .data_565(cam2_data_565),
        .cfg_scl (cam2_scl     ),
        .cfg_sda (cam2_sda     ),
        .cfg_rstn(cam2_rstn    )
    );

    wire [PACK_SIZE-1:0] disp_pack_2;
    hdmi_display u_cam2_disp (
        .clk    (cam2_pclk_565),
        .rstn   (rstn         ),
        .i_vsync(cam2_vsync   ),
        .i_data (cam2_data_565),
        .i_href (cam2_href_565),
        .o_pack (disp_pack_2  )
    );

    wire [PACK_SIZE-1:0] hdmi_cam1;
    frame_process #(
        .H_ACT   (H_ACT   ),
        .V_ACT   (V_ACT   ),
        .KEY_TICK(KEY_HOLD)
    ) u_cam1_process (
        .clk           (clk          ),
        .rstn          (rstn         ),
        .balance_update(~balance_rstn),
        .balance_key   (balance_key  ),
        .gamma_key     (gamma_key    ),
        .gray_key      (gray_key     ),
        .bin_key       (binary_key   ),
        .i_pack        (disp_pack_1  ),
        .o_pack        (hdmi_cam1    )
    );

    wire [PACK_SIZE-1:0] hdmi_cam2;

    logic gamma_key;
    frame_process #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_cam2_process (
        .clk           (clk          ),
        .rstn          (rstn         ),
        .balance_update(~balance_rstn),
        .balance_key   (balance_key  ),
        .gamma_key     (gamma_key    ),
        .gray_key      (gray_key     ),
        .bin_key       (binary_key   ),
        .i_pack        (disp_pack_2  ),
        .o_pack        (hdmi_cam2    )
    );

    wire [PACK_SIZE-1:0] hdmi_pack;
    cam_switch #(
        .H_ACT(H_ACT   ),
        .V_ACT(V_ACT   ),
        .TICK (KEY_HOLD),
        .DELAY(16      )
    ) u_cam_switch (
        .clk       (clk      ),
        .rstn      (rstn     ),
        .main_pack (hdmi_cam1),
        .minor_pack(hdmi_cam2),
        .key       (cam_key  ),
        .pack      (hdmi_pack)
    );

    wire box_en;
    key_to_switch #(
        .TICK(KEY_HOLD),
        .INIT(1'b1    )
    ) u_box_en (
        .clk   (clk    ),
        .rstn  (rstn   ),
        .key   (box_key),
        .switch(box_en )
    );

    wire [BOX_NUM*$clog2(H_ACT)-1:0] dw_start_xs;
    wire [BOX_NUM*$clog2(V_ACT)-1:0] dw_start_ys;
    wire [BOX_NUM*$clog2(H_ACT)-1:0] dw_end_xs  ;
    wire [BOX_NUM*$clog2(V_ACT)-1:0] dw_end_ys  ;
    wire [           BOX_NUM*24-1:0] dw_colors  ;

    wire [PACK_SIZE-1:0] dw_pack;
    draw_window #(
        .BOX_WIDTH(BOX_WIDTH),
        .BOX_NUM  (BOX_NUM  )
    ) u_draw_window (
        .en      (box_en     ),
        .i_pack  (hdmi_pack  ),
        .o_pack  (dw_pack    ),
        .start_xs(dw_start_xs),
        .start_ys(dw_start_ys),
        .end_xs  (dw_end_xs  ),
        .end_ys  (dw_end_ys  ),
        .colors  (dw_colors  )
    );

    hdmi_unpack #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_hdmi_output (
        .pack (dw_pack   ),
        .clk  (hdmi_clk  ),
        .hsync(hdmi_hsync),
        .vsync(hdmi_vsync),
        .de   (hdmi_de   ),
        .r    (hdmi_r    ),
        .g    (hdmi_g    ),
        .b    (hdmi_b    )
    );

    tick #(.TICK(4)) u_cam_tick (
        .clk (clk                  ),
        .rstn(rstn                 ),
        .trig(cam1_vsync^cam2_vsync),
        .tick(cam_tick             )
    );

    wire rgmii_clk;
    wire udp_tx_re;

    wire lb_trig;

    wire        udp_trig;
    wire [ 7:0] ub_data ;
    wire [10:0] ub_row  ;

    wire       ub_id ;
    wire [3:0] ub_cnt;

    line_swap_buffer #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_udp_swap_buffer (
        .rstn     (rstn     ),
        .cam1_pack(hdmi_cam1),
        .cam2_pack(hdmi_cam2),
        .trig     (lb_trig  ),
        .aquire   (udp_trig ),
        .rclk     (rgmii_clk),
        .read_en  (udp_tx_re),
        .cam_data (ub_data  ),
        .cam_row  (ub_row   ),
        .cam_id   (ub_id    ),
        .cnt      (ub_cnt   ),
        .error    (line_err ),
        .busy     (udp_busy )
    );
    wire [15:0] ub_index;
    assign ub_index = {ub_id, ub_cnt, ub_row};

    wire        udp_rx_valid   ;
    wire [ 7:0] udp_rx_data    ;
    wire [15:0] udp_rx_data_len;
    wire        udp_rx_end     ;
    udp_packet #(
        .LOCAL_MAC (LOCAL_MAC ),
        .LOCAL_IP  (LOCAL_IP  ),
        .LOCAL_PORT(LOCAL_PORT),
        .DEST_IP   (DEST_IP   ),
        .DEST_PORT (DEST_PORT )
    ) u_udp_packet (
        .rgmii_clk   (rgmii_clk      ),
        .arp_rstn    (rstn           ),
        .trig        (udp_trig       ),
        .index       (ub_index       ),
        // TX
        .tx_read_en  (udp_tx_re      ),
        .tx_data     (ub_data        ),
        .tx_data_len (16'd1280       ),
        // RX
        .rx_valid    (udp_rx_valid   ),
        .rx_data     (udp_rx_data    ),
        .rx_data_len (udp_rx_data_len),
        .rx_error    (/*unused*/     ),
        .rx_end      (udp_rx_end     ),
        // Hardware
        .connected   (net_conn       ),
        .rgmii_rxc   (rgmii1_rxc     ),
        .rgmii_rx_ctl(rgmii1_rx_ctl  ),
        .rgmii_rxd   (rgmii1_rxd     ),
        .rgmii_txc   (rgmii1_txc     ),
        .rgmii_tx_ctl(rgmii1_tx_ctl  ),
        .rgmii_txd   (rgmii1_txd     )
    );

    localparam DRAW_BOX_DATA_BYTE = 6;

    localparam UDP_READ_CAPACITY = DRAW_BOX_DATA_BYTE * BOX_NUM;

    wire [UDP_READ_CAPACITY*8-1:0] udp_data;

    wire udp_cap_err;
    udp_reader #(.CAPACITY(UDP_READ_CAPACITY)) u_udp_reader (
        .clk   (rgmii_clk      ),
        .rstn  (rstn           ),
        .valid (udp_rx_valid   ),
        .i_data(udp_rx_data    ),
        .i_len (udp_rx_data_len),
        .error (udp_cap_err    ),
        .o_data(udp_data       ),
        .rx_end(udp_rx_end     ),
        .trig  (lb_trig        )
    );

    rst_gen #(.TICK(KEY_HOLD)) u_udp_err_gen (
        .clk  (clk        ),
        .i_rst(udp_cap_err),
        .o_rst(udp_err    )
    );

    if (H_ACT==1280 && V_ACT==720) begin : g_draw_box_720
        udp_parser #(
            .BOX_NUM(BOX_NUM),
            .H_ACT(H_ACT),
            .V_ACT(V_ACT),
            .C_DEP(2    )
        ) u_udp_parser_720 (
            .udp_data(udp_data   ),
            .start_xs(dw_start_xs),
            .start_ys(dw_start_ys),
            .end_xs  (dw_end_xs  ),
            .end_ys  (dw_end_ys  ),
            .colors  (dw_colors  )
        );
    end else begin : g_draw_box_default
        assign start_xs = 'b0;
        assign start_ys = 'b0;
        assign end_xs   = 'b0;
        assign end_ys   = 'b0;
        assign colors   = 'b0;
    end

    soc u_soc (
        .clk  (clk  ),
        .rstn (rstn ),
        .swclk(swclk),
        .swdio(swdio)
    );

endmodule : AimBot
