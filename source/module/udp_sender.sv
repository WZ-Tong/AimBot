module udp_sender #(
    parameter LOCAL_MAC = 48'h11_11_11_11_11_11,
    parameter LOCAL_IP  = 32'hC0_A8_01_6E      , //192.168.1.110
    parameter LOCL_PORT = 16'h8080             ,

    parameter DEST_IP   = 32'hC0_A8_01_69      , //192.168.1.105
    parameter DEST_PORT = 16'h8080
) (
    input        rstn        ,
    input        trig        ,
    input  [7:0] data        ,

    // Hardware
    input        rgmii_rxc   ,
    input        rgmii_rx_ctl,
    input  [3:0] rgmii_rxd   ,
    output       rgmii_txc   ,
    output       rgmii_tx_ctl,
    output [3:0] rgmii_txd
);

    wire       rgmii_clk;
    wire       tx_valid ;
    wire [7:0] tx_data  ;
    wire       rx_error ;
    wire       rx_valid ;
    wire [7:0] rx_data  ;

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

    wire        app_data_in_valid  ;
    wire [ 7:0] app_data_in        ;
    wire [15:0] app_data_length    ;
    wire        app_data_request   ;
    wire        udp_send_ack       ;
    wire        arp_req            ;
    wire        arp_found          ;
    wire        mac_not_exist      ;
    wire        mac_send_end       ;
    wire [ 7:0] udp_rec_rdata      ;
    wire [15:0] udp_rec_data_length;
    wire        udp_rec_data_valid ;
    wire        mac_data_valid     ;
    wire [ 7:0] mac_tx_data        ;
    wire        rx_en              ;
    wire [ 7:0] mac_rx_datain      ;

    udp_ip_mac_top #(
        .LOCAL_MAC(LOCAL_MAC),
        .LOCAL_IP (LOCAL_IP ),
        .LOCL_PORT(LOCL_PORT),
        .DEST_IP  (DEST_IP  ),
        .DEST_PORT(DEST_PORT)
    ) u_udp_ip_mac_top (
        .rgmii_clk          (rgmii_clk          ),
        .rstn               (rstn               ),
        // APP
        .app_data_in_valid  (app_data_in_valid  ),
        .app_data_in        (app_data_in        ),
        .app_data_length    (app_data_length    ),
        .app_data_request   (app_data_request   ),
        // ARP
        .arp_req            (arp_req            ),
        .arp_found          (arp_found          ),
        // MAC
        .mac_not_exist      (mac_not_exist      ),
        .mac_send_end       (mac_send_end       ),
        .mac_data_valid     (mac_data_valid     ),
        .mac_tx_data        (mac_tx_data        ),
        .rx_en              (rx_en              ),
        .mac_rx_datain      (mac_rx_datain      ),
        // UDP
        .udp_send_ack       (udp_send_ack       ),
        .udp_rec_rdata      (udp_rec_rdata      ),
        .udp_rec_data_length(udp_rec_data_length),
        .udp_rec_data_valid (udp_rec_data_valid )
    );


endmodule : udp_sender
