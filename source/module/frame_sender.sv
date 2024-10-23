module frame_sender #(
    parameter LOCAL_MAC = 48'h3C_2B_1A_09_4D_5E,
    parameter LOCAL_IP  = 32'hC0_A8_01_6E      ,
    parameter LOCAL_PORT = 16'hF0F0             ,

    parameter DEST_IP   = 32'hC0_A8_01_69      ,
    parameter DEST_PORT = 16'hA0A0
) (
    input         trig        ,
    input  [48:0] i_pack      ,

    input         rgmii_rxc   ,
    input         rgmii_rx_ctl,
    input  [ 3:0] rgmii_rxd   ,
    output        rgmii_txc   ,
    output        rgmii_tx_ctl,
    output [ 3:0] rgmii_txd
);

    wire cam_clk;
    wire hsync  ;
    wire vsync  ;

    wire [7:0] r;
    wire [7:0] g;
    wire [7:0] b;

    hdmi_unpack u_hdmi_unpack (
        .pack (i_pack ),
        .clk  (cam_clk),
        .hsync(hsync  ),
        .vsync(vsync  ),
        .r    (r      ),
        .g    (g      ),
        .b    (b      )
    );

    async_fifo u_send_buffer (
        .wr_clk      (cam_clk   ),
        .wr_rst      (          ),   // TODO
        .wr_en       (          ),   // TODO
        .wr_data     (          ),   // TODO
        .wr_full     (/*unused*/),
        .almost_full (/*unused*/),
        .rd_clk      (rgmii_clk ),
        .rd_rst      (          ),   // TODO
        .rd_data     (          ),   // TODO
        .rd_en       (          ),   // TODO
        .rd_empty    (/*unused*/),
        .almost_empty(/*unused*/)
    );

    // TODO: Place `udp_sender` here

endmodule : frame_sender
