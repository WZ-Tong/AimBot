`timescale 1ns / 1ps

module AimBot (
    input        clk          ,
    input        rstn         ,
    input        cam_switch   ,
    input        wb_switch    ,
    input        dw_switch    ,
    input        send_switch  ,
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

    // Debug signals
    output       hdmi_inited  ,
    output       cam_inited   ,
    output       frame_tick   ,
    output       rgmii_conn   ,
    output       line_err     ,
    output       udp_err
);

    localparam H_ACT = 1280;
    localparam V_ACT = 720 ;

    wire clk10, clk25;
    clk_div #(.DIV(5)) u_clk10_gen (
        .i_clk(clk  ),
        .o_clk(clk10)
    );
    clk_div #(.DIV(2)) u_clk25_gen (
        .i_clk(clk  ),
        .o_clk(clk25)
    );

    wire clk250 /*synthesis PAP_MARK_DEBUG="true"*/;
    debug_pll u_clk250_gen (
        .clkin1  (clk       ),
        .pll_lock(/*unused*/),
        .clkout0 (clk250    )
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

    wire [48:0] disp_pack_1;
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

    wire [48:0] disp_pack_2;
    hdmi_display u_cam2_disp (
        .clk    (cam2_pclk_565),
        .rstn   (rstn         ),
        .i_vsync(cam2_vsync   ),
        .i_data (cam2_data_565),
        .i_href (cam2_href_565),
        .o_pack (disp_pack_2  )
    );

    wire [48:0] hdmi_cam1;
    frame_process #(
        .N_BOX      (1    ),
        .V_BOX_WIDTH(2    ),
        .H_BOX_WIDTH(2    ),
        .H_ACT      (H_ACT),
        .V_ACT      (V_ACT)
    ) u_cam1_process (
        .clk      (clk        ),
        .wb_en    (~wb_rstn   ),
        .wb_switch(wb_switch  ),
        .dw_switch(dw_switch  ),
        .i_pack   (disp_pack_1),
        .o_pack   (hdmi_cam1  ),
        .start_xs (11'd100    ),
        .start_ys (10'd100    ),
        .end_xs   (11'd300    ),
        .end_ys   (10'd300    ),
        .colors   (24'hFF0000 )
    );

    wire [48:0] hdmi_cam2;
    frame_process #(
        .N_BOX      (1    ),
        .V_BOX_WIDTH(2    ),
        .H_BOX_WIDTH(2    ),
        .H_ACT      (H_ACT),
        .V_ACT      (V_ACT)
    ) u_cam2_process (
        .clk      (clk        ),
        .wb_en    (~wb_rstn   ),
        .wb_switch(wb_switch  ),
        .dw_switch(dw_switch  ),
        .i_pack   (disp_pack_2),
        .o_pack   (hdmi_cam2  ),
        .start_xs (11'd100    ),
        .start_ys (10'd100    ),
        .end_xs   (11'd200    ),
        .end_ys   (10'd500    ),
        .colors   (24'hFF0000 )
    );

    wire [48:0] hdmi_pack;
    pack_switch u_switch_cam (
        .clk     (clk       ),
        .switch  (cam_switch),
        .i_pack_1(hdmi_cam1 ),
        .i_pack_2(hdmi_cam2 ),
        .o_pack  (hdmi_pack )
    );

    hdmi_unpack u_hdmi_output (
        .pack (hdmi_pack ),
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

    wire rgmii_clk /*synthesis PAP_MARK_DEBUG="true"*/;
    wire udp_tx_re   /*synthesis PAP_MARK_DEBUG="true"*/;

    wire lb_trig;
    trig_gen #(.TICK(1000)) u_trig_gen (
        .clk   (rgmii_clk  ),
        .rstn  (rstn       ),
        .switch(send_switch),
        .trig  (lb_trig    )
    );

    wire        udp_trig;
    wire [ 7:0] lb_data ;
    wire [10:0] lb_row  ;
    line_buffer #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_line_buffer (
        .rstn    (rstn     ),
        .cam_pack(hdmi_pack),
        .trig    (lb_trig  ),
        .aquire  (udp_trig ),
        .rclk    (rgmii_clk),
        .read_en (udp_tx_re),
        .cam_data(lb_data  ),
        .cam_row (lb_row   ),
        .error   (line_err )
    );

    wire lb_id_1;
    assign lb_id_1 = 1'b1;

    wire [4:0] lb_id_5;
    assign lb_id_5 = lb_id_1 ? 5'b10_000 : 5'b01_000;

    wire        udp_rx_valid   ;
    wire [ 7:0] udp_rx_data    ;
    wire [15:0] udp_rx_data_len;
    wire        udp_rx_err     ;

    udp_packet #(
        .LOCAL_MAC (48'h01_02_03_04_05_06),
        .LOCAL_IP  (32'hC0_A8_02_65      ),
        .LOCAL_PORT(16'h1F90             ),
        .DEST_IP   (32'hC0_A8_02_64      ),
        .DEST_PORT (16'h1F90             )
    ) u_udp_packet_1 (
        .rgmii_clk   (rgmii_clk        ),
        .arp_rstn    (rstn             ),
        .trig        (udp_trig         ),
        .index       ({lb_id_5, lb_row}),
        // TX
        .tx_read_en  (udp_tx_re        ),
        .tx_data     (lb_data          ),
        .tx_data_len (16'd1280         ),
        // RX
        .rx_valid    (udp_rx_valid     ),
        .rx_data     (udp_rx_data      ),
        .rx_data_len (udp_rx_data_len  ),
        .rx_error    (udp_rx_err       ),
        // Hardware
        .connected   (rgmii_conn       ),
        .rgmii_rxc   (rgmii1_rxc       ),
        .rgmii_rx_ctl(rgmii1_rx_ctl    ),
        .rgmii_rxd   (rgmii1_rxd       ),
        .rgmii_txc   (rgmii1_txc       ),
        .rgmii_tx_ctl(rgmii1_tx_ctl    ),
        .rgmii_txd   (rgmii1_txd       )
    );

    localparam UDP_READ_CAPACITY = 1;

    wire udp_cap_err;

    wire [UDP_READ_CAPACITY*8-1:0] udp_read_data /*synthesis PAP_MARK_DEBUG="true"*/;
    udp_reader #(.CAPACITY(UDP_READ_CAPACITY)) u_udp_reader (
        .clk     (rgmii_clk      ),
        .rstn    (rstn           ),
        .valid   (udp_rx_valid   ),
        .i_data  (udp_rx_data    ),
        .data_len(udp_rx_data_len),
        .o_data  (udp_read_data  ),
        .cap_err (udp_cap_err    )
    );

    rst_gen #(.TICK(125_000_000)) u_rx_err_gen (
        .clk  (rgmii_clk              ),
        .i_rst(udp_rx_err||udp_cap_err),
        .o_rst(udp_err                )
    );

endmodule : AimBot
