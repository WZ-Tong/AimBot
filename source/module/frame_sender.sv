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

    wire       rgmii_clk     ;
    wire       rgmii_tx_valid;
    wire [7:0] rgmii_tx_data ;
    wire       rgmii_rx_error;
    wire       rgmii_rx_valid;
    wire [7:0] rgmii_rx_data ;

    rgmii u_rgmii (
        .rgmii_clk   (rgmii_clk     ),
        .tx_valid    (rgmii_tx_valid),
        .tx_data     (rgmii_tx_data ),
        .rx_error    (rgmii_rx_error),
        .rx_valid    (rgmii_rx_valid),
        .rx_data     (rgmii_rx_data ),
        .rgmii_rxc   (rgmii_rxc     ),
        .rgmii_rx_ctl(rgmii_rx_ctl  ),
        .rgmii_rxd   (rgmii_rxd     ),
        .rgmii_txc   (rgmii_txc     ),
        .rgmii_tx_ctl(rgmii_tx_ctl  ),
        .rgmii_txd   (rgmii_txd     )
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
