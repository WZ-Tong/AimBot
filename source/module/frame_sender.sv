module frame_sender (
    input         trig        ,
    input         cam_pclk    ,
    input         cam_href    ,
    input  [15:0] cam_data    ,

    input         rgmii_rxc   ,
    input         rgmii_rx_ctl,
    input  [ 3:0] rgmii_rxd   ,

    output        rgmii_txc   ,
    output        rgmii_tx_ctl,
    output [ 3:0] rgmii_txd
);

    // TODO: Place a fifo here (maybe) to sync camera's data

    wire rgmii_clk; // TODO: use this clock to read data

    rgmii u_rgmii (
        .rgmii_clk   (rgmii_clk   ),
        .rgmii_rxc   (rgmii_rxc   ),
        .rgmii_rx_ctl(rgmii_rx_ctl),
        .rgmii_rxd   (rgmii_rxd   ),
        .rgmii_txc   (rgmii_txc   ),
        .rgmii_tx_ctl(rgmii_tx_ctl),
        .rgmii_txd   (rgmii_txd   )
    );


endmodule : frame_sender
