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

endmodule : frame_sender
