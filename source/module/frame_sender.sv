module frame_sender #(
    parameter CAM_ID     = 6'b000000            ,

    parameter LOCAL_MAC  = 48'h01_02_03_04_05_06,
    parameter LOCAL_IP   = 32'hC0_A8_02_65      ,
    parameter LOCAL_PORT = 16'h1F90             ,

    parameter DEST_IP    = 32'hC0_A8_02_64      ,
    parameter DEST_PORT  = 16'h1F90
) (
    input         rstn        ,
    input         trig        ,
    input  [48:0] i_pack      ,
    output        connected   ,

    input         rgmii_rxc   ,
    input         rgmii_rx_ctl,
    input  [ 3:0] rgmii_rxd   ,
    output        rgmii_txc   ,
    output        rgmii_tx_ctl,
    output [ 3:0] rgmii_txd
);

    localparam PACKET_DATA_LEN = 16'd1280; // (1280/3) * 3(RGB)

    wire cam_clk;
    wire hsync  ;
    wire vsync  ;

    wire [7:0] r;
    wire [7:0] g;
    wire [7:0] b;
    wire [9:0] y;

    wire [15:0] index;
    assign index = {CAM_ID, y};

    hdmi_unpack u_hdmi_unpack (
        .pack (i_pack ),
        .clk  (cam_clk),
        .hsync(hsync  ),
        .vsync(vsync  ),
        .r    (r      ),
        .g    (g      ),
        .b    (b      ),
        .y    (y      )
    );

    wire rgmii_clk /*synthesis PAP_MARK_DEBUG="true"*/;

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

    wire        tx_read_en    ;
    wire        tx_valid      ;
    wire [ 7:0] tx_data       ;
    wire [15:0] tx_data_len   ;
    wire        rx_valid      ;
    wire [ 7:0] rx_data       ;
    wire [15:0] rx_data_len   ;
    udp_sender #(
        .LOCAL_MAC (LOCAL_MAC ),
        .LOCAL_IP  (LOCAL_IP  ),
        .LOCAL_PORT(LOCAL_PORT),
        .DEST_IP   (DEST_IP   ),
        .DEST_PORT (DEST_PORT )
    ) u_udp_sender (
        .rgmii_clk   (rgmii_clk      ),
        .arp_rstn    (rstn           ),
        .trig        (1'b1           ),
        .index       (index          ),
        .tx_read_en  (tx_read_en     ),
        .tx_valid    (1'b1           ),
        .tx_data     (08'hA5         ),
        .tx_data_len (PACKET_DATA_LEN),
        .rx_valid    (/*unused*/     ),
        .rx_data     (/*unused*/     ),
        .rx_data_len (/*unused*/     ),
        .rx_error    (/*unused*/     ),
        .connected   (connected      ),
        .rgmii_rxc   (rgmii_rxc      ),
        .rgmii_rx_ctl(rgmii_rx_ctl   ),
        .rgmii_rxd   (rgmii_rxd      ),
        .rgmii_txc   (rgmii_txc      ),
        .rgmii_tx_ctl(rgmii_tx_ctl   ),
        .rgmii_txd   (rgmii_txd      )
    );

endmodule : frame_sender
