module rgmii (
    output       rgmii_clk   ,

    input        rgmii_rxc   ,
    input        rgmii_rx_ctl,
    input  [3:0] rgmii_rxd   ,

    output       rgmii_txc   ,
    output       rgmii_tx_ctl,
    output [3:0] rgmii_txd
);

    wire       mac_tx_data_valid;
    wire [7:0] mac_tx_data      ;
    wire       mac_rx_error     ;
    wire       mac_rx_data_valid;
    wire [7:0] mac_rx_data      ;

    // TODO: Place `udp_ip_mac_top` here

    rgmii_interface u_rgmii_interface (
        .rst              (/*unused*/       ),
        .rgmii_clk        (rgmii_clk        ),
        .rgmii_clk_90p    (/*unused*/       ),
        .mac_tx_data_valid(mac_tx_data_valid),
        .mac_tx_data      (mac_tx_data      ),
        .mac_rx_error     (mac_rx_error     ),
        .mac_rx_data_valid(mac_rx_data_valid),
        .mac_rx_data      (mac_rx_data      ),
        .rgmii_rxc        (rgmii_rxc        ),
        .rgmii_rx_ctl     (rgmii_rx_ctl     ),
        .rgmii_rxd        (rgmii_rxd        ),
        .rgmii_txc        (rgmii_txc        ),
        .rgmii_tx_ctl     (rgmii_tx_ctl     ),
        .rgmii_txd        (rgmii_txd        )
    );

endmodule : rgmii
