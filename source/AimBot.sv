`timescale 1ns / 1ps

module AimBot #(
    parameter V_BOX_WIDTH = 1'b1,
    parameter H_BOX_WIDTH = 1'b1,
    parameter N_BOX       = 1'b1
) (
    input        clk          ,
    input        rstn         ,
    input        cam_switch   ,
    input        wb_switch    ,
    input        dw_switch    ,
    input        wb_rstn      ,

    inout        cam1_scl     ,
    inout        cam1_sda     ,
    input        cam1_vsync     /*synthesis PAP_MARK_DEBUG="true"*/,
    input        cam1_href      /*synthesis PAP_MARK_DEBUG="true"*/,
    input        cam1_pclk      /*synthesis PAP_MARK_DEBUG="true"*/,
    input  [7:0] cam1_data    ,
    output       cam1_rstn    ,

    inout        cam2_scl     ,
    inout        cam2_sda     ,
    input        cam2_vsync   ,
    input        cam2_href    ,
    input        cam2_pclk    ,
    input  [7:0] cam2_data    ,
    output       cam2_rstn    ,

    output       hdmi_clk     ,
    output       hdmi_hsync   ,
    output       hdmi_vsync   ,
    output       hdmi_de      ,
    output [7:0] hdmi_r       ,
    output [7:0] hdmi_g       ,
    output [7:0] hdmi_b       ,

    output       hdmi_rstn    ,
    output       hdmi_scl     ,
    inout        hdmi_sda     ,

    input        rgmii1_rxc   ,
    input        rgmii1_rx_ctl,
    input  [3:0] rgmii1_rxd   ,

    output       rgmii1_txc   ,
    output       rgmii1_tx_ctl,
    output [3:0] rgmii1_txd   ,

    input        rgmii2_rxc   ,
    input        rgmii2_rx_ctl,
    input  [3:0] rgmii2_rxd   ,

    output       rgmii2_txc   ,
    output       rgmii2_tx_ctl,
    output [3:0] rgmii2_txd   ,

    // Debug signals
    output       hdmi_inited  ,
    output       cam_inited   ,
    output       frame_tick   ,
    output       connected
);

    wire clk10, clk25;
    clk_div #(.DIV(5)) u_clk10_gen (
        .i_clk(clk  ),
        .o_clk(clk10)
    );
    clk_div #(.DIV(2)) u_clk25_gen (
        .i_clk(clk  ),
        .o_clk(clk25)
    );

    // HDMI configure
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

    wire cam1_inited, cam2_inited;
    wire cam1_pclk_565, cam2_pclk_565;
    wire cam1_href_565, cam2_href_565;
    assign cam_inited = cam1_inited && cam2_inited;

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

    wire [48:0] disp_pack_1;
    hdmi_display u_cam1_disp (
        .clk    (cam1_pclk_565),
        .rstn   (rstn         ),
        .i_vsync(cam1_vsync   ),
        .i_data (cam1_data_565),
        .i_href (cam1_href_565),
        .o_pack (disp_pack_1  )
    );

    wire [48:0] disp_pack_2;
    hdmi_display u_cam2_disp (
        .clk    (cam2_pclk_565),
        .rstn   (rstn         ),
        .i_vsync(cam2_vsync   ),
        .i_data (cam2_data_565),
        .i_href (cam2_href_565),
        .o_pack (disp_pack_2  )
    );

    wire [48:0] disp_pack;
    pack_switch u_switch_cam (
        .clk     (clk        ),
        .switch  (cam_switch ),
        .i_pack_1(disp_pack_1),
        .i_pack_2(disp_pack_2),
        .o_pack  (disp_pack  )
    );

    wire [48:0] wb_pack;
    white_balance #(
        .H_ACT(1280),
        .V_ACT(720 )
    ) u_white_balance (
        .i_pack(disp_pack),
        .wb_en (~wb_rstn ),
        .o_pack(wb_pack  )
    );

    wire [48:0] wbs_pack;
    pack_switch u_switch_white_balance (
        .clk     (clk      ),
        .switch  (wb_switch),
        .i_pack_1(wb_pack  ),
        .i_pack_2(disp_pack),
        .o_pack  (wbs_pack )
    );

    wire [48:0] win_pack;
    draw_window #(
        .V_BOX_WIDTH(40),
        .H_BOX_WIDTH(20),
        .N_BOX      (1 )
    ) u_draw_window (
        .i_pack  (wbs_pack  ),
        .o_pack  (win_pack  ),
        .start_xs(11'd100   ),
        .start_ys(10'd200   ),
        .end_xs  (11'd200   ),
        .end_ys  (10'd400   ),
        .colors  (24'hFFFFFF)
    );

    wire [48:0] wins_pack;
    pack_switch u_switch_draw_window (
        .clk     (clk      ),
        .switch  (dw_switch),
        .i_pack_1(win_pack ),
        .i_pack_2(wbs_pack ),
        .o_pack  (wins_pack)
    );

    hdmi_unpack u_hdmi_output (
        .pack (wins_pack ),
        .clk  (hdmi_clk  ),
        .hsync(hdmi_hsync),
        .vsync(hdmi_vsync),
        .de   (hdmi_de   ),
        .r    (hdmi_r    ),
        .g    (hdmi_g    ),
        .b    (hdmi_b    )
    );

    tick #(.TICK(30)) u_frame_tick (
        .clk (hdmi_clk  ),
        .rstn(rstn      ),
        .trig(hdmi_vsync),
        .tick(frame_tick)
    );

    wire send1_conn;
    frame_sender #(
        .CAM_ID    (6'b111000            ),
        .LOCAL_MAC (48'h01_02_03_04_05_06),
        .LOCAL_IP  (32'hC0_A8_02_65      ),
        .LOCAL_PORT(16'h1F92             ),
        .DEST_IP   (32'hC0_A8_02_64      ),
        .DEST_PORT (16'h1F91             )
    ) u_cam1_sender (
        .rstn        (rstn         ),
        .trig        (/*TODO*/     ),
        .i_pack      (disp_pack_1  ),
        .connected   (send1_conn   ),
        .rgmii_rxc   (rgmii1_rxc   ),
        .rgmii_rx_ctl(rgmii1_rx_ctl),
        .rgmii_rxd   (rgmii1_rxd   ),
        .rgmii_txc   (rgmii1_txc   ),
        .rgmii_tx_ctl(rgmii1_tx_ctl),
        .rgmii_txd   (rgmii1_txd   )
    );

    wire send2_conn;
    frame_sender #(
        .CAM_ID    (6'b000001            ),
        .LOCAL_MAC (48'h01_02_03_04_05_06),
        .LOCAL_IP  (32'hC0_A8_02_65      ),
        .LOCAL_PORT(16'h1F90             ),
        .DEST_IP   (32'hC0_A8_02_64      ),
        .DEST_PORT (16'h1F90             )
    ) u_cam2_sender (
        .rstn        (rstn         ),
        .trig        (/*TODO*/     ),
        .i_pack      (disp_pack_2  ),
        .connected   (send2_conn   ),
        .rgmii_rxc   (rgmii2_rxc   ),
        .rgmii_rx_ctl(rgmii2_rx_ctl),
        .rgmii_rxd   (rgmii2_rxd   ),
        .rgmii_txc   (rgmii2_txc   ),
        .rgmii_tx_ctl(rgmii2_tx_ctl),
        .rgmii_txd   (rgmii2_txd   )
    );

    assign connected = send1_conn && send2_conn;

endmodule : AimBot
