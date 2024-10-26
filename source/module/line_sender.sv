module line_sender #(
    parameter H_ACT      = 1280                 ,

    parameter LOCAL_MAC  = 48'h01_02_03_04_05_06,
    parameter LOCAL_IP   = 32'hC0_A8_02_65      ,
    parameter LOCAL_PORT = 16'h1F90             ,

    parameter DEST_IP    = 32'hC0_A8_02_64      ,
    parameter DEST_PORT  = 16'h1F90
) (
    output        rgmii_clk   ,
    input         rstn        ,
    input         trig        ,
    output        read_en     ,
    input  [ 5:0] cam_id      ,
    input  [ 9:0] cam_row     ,
    input         cam_valid   ,
    input  [15:0] cam_data    ,
    output        connected   ,

    input         rgmii_rxc   ,
    input         rgmii_rx_ctl,
    input  [ 3:0] rgmii_rxd   ,
    output        rgmii_txc   ,
    output        rgmii_tx_ctl,
    output [ 3:0] rgmii_txd
);

    wire        tx_read_en ;
    wire        tx_valid   ;
    wire [ 7:0] tx_data    ;
    wire [15:0] tx_data_len;
    wire        rx_valid   ;
    wire [ 7:0] rx_data    ;
    wire [15:0] rx_data_len;
    udp_sender #(
        .LOCAL_MAC (LOCAL_MAC ),
        .LOCAL_IP  (LOCAL_IP  ),
        .LOCAL_PORT(LOCAL_PORT),
        .DEST_IP   (DEST_IP   ),
        .DEST_PORT (DEST_PORT )
    ) u_udp_sender (
        .rgmii_clk   (rgmii_clk        ),
        .arp_rstn    (rstn             ),
        .trig        (trig             ),
        .index       ({cam_id, cam_row}),
        .tx_read_en  (tx_read_en       ),
        .tx_valid    (cam_valid        ),
        .tx_data     (/*TODO*/         ),
        .tx_data_len (H_ACT[15:0]      ),
        .rx_valid    (/*unused*/       ),
        .rx_data     (/*unused*/       ),
        .rx_data_len (/*unused*/       ),
        .rx_error    (/*unused*/       ),
        .connected   (connected        ),
        .rgmii_rxc   (rgmii_rxc        ),
        .rgmii_rx_ctl(rgmii_rx_ctl     ),
        .rgmii_rxd   (rgmii_rxd        ),
        .rgmii_txc   (rgmii_txc        ),
        .rgmii_tx_ctl(rgmii_tx_ctl     ),
        .rgmii_txd   (rgmii_txd        )
    );

endmodule : line_sender
