module frame_sender (
    input         trig        ,
    input  [49:0] i_pack      ,

    input         rgmii_rxc   ,
    input         rgmii_rx_ctl,
    input  [ 3:0] rgmii_rxd   ,

    output        rgmii_txc   ,
    output        rgmii_tx_ctl,
    output [ 3:0] rgmii_txd
);

    wire cam_clk  ;
    wire rgmii_clk;

    wire href ;
    wire hsync;
    wire vsync;

    wire [7:0] r;
    wire [7:0] g;
    wire [7:0] b;

    wire       tx_valid;
    wire [7:0] tx_data ;
    wire       rx_error;
    wire       rx_valid;
    wire [7:0] rx_data ;

    hdmi_unpack u_hdmi_unpack (
        .pack (i_pack ),
        .clk  (cam_clk),
        .href (href   ),
        .hsync(hsync  ),
        .vsync(vsync  ),
        .r    (r      ),
        .g    (g      ),
        .b    (b      )
    );

    rgmii u_rgmii (
        .rgmii_clk   (rgmii_clk   ),
        .rgmii_rxc   (rgmii_rxc   ),
        .rgmii_rx_ctl(rgmii_rx_ctl),
        .rgmii_rxd   (rgmii_rxd   ),
        .rgmii_txc   (rgmii_txc   ),
        .rgmii_tx_ctl(rgmii_tx_ctl),
        .rgmii_txd   (rgmii_txd   ),
        .tx_valid    (tx_valid    ),
        .tx_data     (tx_data     ),
        .rx_error    (rx_error    ),
        .rx_valid    (rx_valid    ),
        .rx_data     (rx_data     )
    );


endmodule : frame_sender
