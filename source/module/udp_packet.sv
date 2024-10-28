module udp_packet #(
    parameter LOCAL_MAC  = 48'h11_11_11_11_11_11,
    parameter LOCAL_IP   = 32'hC0_A8_01_6E      , //192.168.1.110
    parameter LOCAL_PORT = 16'h8080             ,

    parameter DEST_IP    = 32'hC0_A8_01_69      , //192.168.1.105
    parameter DEST_PORT  = 16'h8080
) (
    output            rgmii_clk   ,
    input             arp_rstn    ,
    input             trig          /*synthesis syn_keep=1*/,
    input      [15:0] index       ,
    // TX
    output reg        tx_read_en  ,
    input      [15:0] tx_data     ,
    input      [15:0] tx_data_len ,
    // RX
    output            rx_valid    ,
    output            rx_error    ,
    output     [ 7:0] rx_data     ,
    output     [15:0] rx_data_len ,

    output reg        connected   ,

    // Hardware
    input             rgmii_rxc   ,
    input             rgmii_rx_ctl,
    input      [ 3:0] rgmii_rxd   ,
    output            rgmii_txc   ,
    output            rgmii_tx_ctl,
    output     [ 3:0] rgmii_txd
);

    localparam RGMII_1MS = 125_000;

    localparam RGMII_ARP_WAIT = RGMII_1MS * 200;

    localparam RGMII_CNT = RGMII_ARP_WAIT >= 16 ? RGMII_ARP_WAIT : 16; // 16: WIDTH(data_len)

    reg [$clog2(RGMII_CNT)-1:0] rgmii_cnt;

    localparam UNINITED     = 4'b0000;
    localparam ARP_REQ      = 4'b0001;
    localparam ARP_WAIT_MAC = 4'b0010;
    localparam ARP_WAIT     = 4'b0011;
    localparam CHECK_MAC    = 4'b0100;
    localparam IDLE         = 4'b0101;
    localparam GEN_REQ      = 4'b0110;
    localparam WRITE_IDX1   = 4'b0111;
    localparam WRITE_IDX2   = 4'b1000;
    localparam WRITE_DATA_1 = 4'b1001;
    localparam WRITE_DATA_2 = 4'b1010;

    reg [3:0] state /*synthesis PAP_MARK_DEBUG="true"*/;

    reg       app_data_in_valid;
    reg [7:0] app_data_in      ;
    reg       app_data_request ;

    reg  arp_req  ;
    wire arp_found;

    wire mac_send_end ;
    wire mac_not_exist;
    wire udp_send_ack ;

    wire [15:0] app_data_length;
    assign app_data_length = tx_data_len + 2; // Write Index
    always_ff @(posedge rgmii_clk or negedge arp_rstn) begin
        if(~arp_rstn) begin
            state             <= #1 UNINITED;
            rgmii_cnt         <= #1 'b0;
            arp_req           <= #1 'b0;
            app_data_request  <= #1 'b0;
            connected         <= #1 'b0;
            app_data_in_valid <= #1 'b0;
            app_data_in       <= #1 'b0;
            tx_read_en        <= #1 'b0;
        end else begin
            case (state)
                UNINITED : begin
                    connected <= #1 'b0;
                    if (rgmii_cnt!=RGMII_ARP_WAIT-1) begin
                        arp_req   <= #1 'b0;
                        rgmii_cnt <= #1 rgmii_cnt + 1'b1;
                    end else begin
                        rgmii_cnt <= #1 'b0;
                        state     <= #1 ARP_REQ;
                    end
                end
                ARP_REQ : begin
                    arp_req   <= #1 'b1;
                    rgmii_cnt <= #1 'b0;
                    state     <= #1 ARP_WAIT_MAC;
                end
                ARP_WAIT_MAC : begin
                    arp_req <= #1 'b0;
                    if (mac_send_end) begin
                        state <= #1 ARP_WAIT;
                    end
                end
                ARP_WAIT : begin
                    if (arp_found) begin
                        rgmii_cnt <= #1 'b0;
                        state     <= #1 CHECK_MAC;
                    end else begin
                        if (rgmii_cnt!=RGMII_ARP_WAIT-1) begin
                            rgmii_cnt <= #1 rgmii_cnt + 1'b1;
                        end else begin
                            rgmii_cnt <= #1 'b0;
                            state     <= #1 UNINITED;
                        end
                    end
                end
                CHECK_MAC : begin
                    if (rgmii_cnt!=RGMII_ARP_WAIT-1) begin
                        rgmii_cnt <= #1 rgmii_cnt + 1'b1;
                    end else begin
                        if (mac_not_exist) begin
                            // Do not reset counter
                            // So `UNINITED` will continue soon
                            state <= #1 UNINITED;
                        end else begin
                            rgmii_cnt <= #1 'b0;
                            state     <= #1 IDLE;
                        end
                    end
                end
                IDLE : begin
                    app_data_in_valid <= #1 'b0;
                    connected         <= #1 'b1;
                    app_data_request  <= #1 'b0;
                    tx_read_en        <= #1 'b0;
                    if (trig) begin
                        state <= #1 GEN_REQ;
                    end
                end
                GEN_REQ : begin
                    app_data_in_valid <= #1 'b0;
                    tx_read_en        <= #1 'b0;
                    if (udp_send_ack) begin
                        app_data_request <= #1 'b0;
                        state            <= #1 WRITE_IDX1;
                    end else begin
                        app_data_request <= #1 'b1;
                    end
                end
                WRITE_IDX1 : begin
                    app_data_in_valid <= #1 'b1;
                    app_data_in       <= #1 index[15:8];
                    state             <= #1 WRITE_IDX2;
                    tx_read_en        <= #1 'b0;
                end
                WRITE_IDX2 : begin
                    app_data_in_valid <= #1 'b1;
                    app_data_in       <= #1 index[7:0];
                    // Begin read input
                    if (tx_data_len!=0) begin
                        tx_read_en <= #1 'b1;
                        rgmii_cnt  <= #1 'b0;
                        state      <= #1 WRITE_DATA_1;
                    end else begin
                        state <= #1 IDLE;
                    end
                end
                WRITE_DATA_1 : begin
                    tx_read_en <= #1 'b0;
                    if (rgmii_cnt==tx_data_len) begin
                        app_data_in_valid <= #1 'b0;
                        state             <= #1 IDLE;
                    end else begin
                        app_data_in_valid <= #1 1'b1;
                        app_data_in       <= #1 tx_data[15:8];
                        rgmii_cnt         <= #1 rgmii_cnt + 1'b1;
                        state             <= #1 WRITE_DATA_2;
                    end
                end
                WRITE_DATA_2 : begin
                    if (rgmii_cnt==tx_data_len) begin
                        tx_read_en        <= #1 'b0;
                        app_data_in_valid <= #1 'b0;
                        state             <= #1 IDLE;
                    end else begin
                        tx_read_en        <= #1 'b1;
                        app_data_in_valid <= #1 1'b1;
                        app_data_in       <= #1 tx_data[7:0];
                        rgmii_cnt         <= #1 rgmii_cnt + 1'b1;
                        state             <= #1 WRITE_DATA_1;
                    end
                end
                default : begin
                    state <= #1 UNINITED;
                end
            endcase
        end
    end

    wire       rgmii_tx_valid;
    wire [7:0] rgmii_tx_data ;
    wire       rgmii_rx_valid;
    wire [7:0] rgmii_rx_data ;
    rgmii u_rgmii (
        .rgmii_clk   (rgmii_clk     ),
        .tx_valid    (rgmii_tx_valid),
        .tx_data     (rgmii_tx_data ),
        .rx_error    (rx_error      ),
        .rx_valid    (rgmii_rx_valid),
        .rx_data     (rgmii_rx_data ),
        // Hardware
        .rgmii_rxc   (rgmii_rxc     ),
        .rgmii_rx_ctl(rgmii_rx_ctl  ),
        .rgmii_rxd   (rgmii_rxd     ),
        .rgmii_txc   (rgmii_txc     ),
        .rgmii_tx_ctl(rgmii_tx_ctl  ),
        .rgmii_txd   (rgmii_txd     )
    );

    udp_ip_mac_top #(
        .LOCAL_MAC (LOCAL_MAC ),
        .LOCAL_IP  (LOCAL_IP  ),
        .LOCAL_PORT(LOCAL_PORT),
        .DEST_IP   (DEST_IP   ),
        .DEST_PORT (DEST_PORT )
    ) u_udp_ip_mac_top (
        .rgmii_clk          (rgmii_clk        ),
        .rstn               (arp_rstn         ),
        // TX
        .udp_send_ack       (udp_send_ack     ),
        .app_data_in_valid  (app_data_in_valid),
        .app_data_in        (app_data_in      ),
        .app_data_length    (app_data_length  ),
        .app_data_request   (app_data_request ),
        // RX
        .udp_rec_data_valid (rx_valid         ),
        .udp_rec_rdata      (rx_data          ),
        .udp_rec_data_length(rx_data_len      ),
        // ARP
        .arp_req            (arp_req          ),
        .arp_found          (arp_found        ),
        // MAC
        .mac_send_end       (mac_send_end     ),
        .mac_not_exist      (mac_not_exist    ),
        // RGMII
        .mac_data_valid     (rgmii_tx_valid   ),
        .mac_tx_data        (rgmii_tx_data    ),
        .rx_en              (rgmii_rx_valid   ),
        .mac_rx_datain      (rgmii_rx_data    )
    );

endmodule : udp_packet
