module udp_sender #(
    parameter LOCAL_MAC  = 48'h11_11_11_11_11_11,
    parameter LOCAL_IP   = 32'hC0_A8_01_6E      , //192.168.1.110
    parameter LOCAL_PORT = 16'h8080             ,

    parameter DEST_IP    = 32'hC0_A8_01_69      , //192.168.1.105
    parameter DEST_PORT  = 16'h8080
) (
    output            rgmii_clk   ,
    input             arp_rstn    ,
    input             trig        ,
    input      [15:0] index       ,
    output reg        read_en     ,
    input             valid       ,
    input      [ 7:0] data        ,
    input      [15:0] data_len    ,
    output reg        connected   ,

    // Hardware
    input             rgmii_rxc   ,
    input             rgmii_rx_ctl,
    input      [ 3:0] rgmii_rxd   ,
    output            rgmii_txc   ,
    output            rgmii_tx_ctl,
    output     [ 3:0] rgmii_txd
);

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
        // Hardware
        .rgmii_rxc   (rgmii_rxc     ),
        .rgmii_rx_ctl(rgmii_rx_ctl  ),
        .rgmii_rxd   (rgmii_rxd     ),
        .rgmii_txc   (rgmii_txc     ),
        .rgmii_tx_ctl(rgmii_tx_ctl  ),
        .rgmii_txd   (rgmii_txd     )
    );

    wire        mac_send_end       ;
    wire [ 7:0] udp_rec_rdata      ;
    wire [15:0] udp_rec_data_length;
    wire        udp_rec_data_valid ;
    wire        mac_data_valid     ;
    wire [ 7:0] mac_tx_data        ;
    wire        rx_en              ;
    wire [ 7:0] mac_rx_datain      ;

    localparam RGMII_1MS = 125_000;

    localparam RGMII_ARP_WAIT = RGMII_1MS * 200;

    localparam RGMII_CNT = RGMII_ARP_WAIT >= 16 ? RGMII_ARP_WAIT : 16; // 16: WIDTH(data_len)

    reg [$clog2(RGMII_CNT)-1:0] rgmii_cnt;

    localparam UNINITED   = 4'b0000;
    localparam ARP_REQ    = 4'b0001;
    localparam ARP_WAIT   = 4'b0010;
    localparam CHECK_MAC  = 4'b0011;
    localparam IDLE       = 4'b0100;
    localparam GEN_REQ    = 4'b0101;
    localparam WRITE_IDX1 = 4'b0110;
    localparam WRITE_IDX2 = 4'b0111;
    localparam WRITE_DATA = 4'b1000;

    reg [3:0] state;

    reg         app_data_in_valid;
    reg  [ 7:0] app_data_in      ;
    wire [15:0] app_data_length  ;
    reg         app_data_request ;

    reg         arp_req          ;
    wire        arp_found        ;
    
    wire        mac_not_exist    ;
    wire        udp_send_ack     ;
    reg  [15:0] write_ram_len    ;

    assign app_data_length = data_len + 2; // Write Index
    always_ff @(posedge rgmii_clk or negedge arp_rstn) begin
        if(~arp_rstn) begin
            state             <= #1 UNINITED;
            rgmii_cnt         <= #1 'b0;
            arp_req           <= #1 'b0;
            app_data_request  <= #1 'b0;
            connected         <= #1 'b0;
            app_data_in_valid <= #1 'b0;
            app_data_in       <= #1 'b0;
            read_en           <= #1 'b0;
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
                    state     <= #1 ARP_WAIT;
                end
                ARP_WAIT : begin
                    arp_req <= #1 'b0;
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
                    read_en           <= #1 'b0;
                    if (trig) begin
                        state <= #1 GEN_REQ;
                    end
                end
                GEN_REQ : begin
                    app_data_in_valid <= #1 'b0;
                    read_en           <= #1 'b0;
                    if (udp_send_ack) begin
                        app_data_request <= #1 'b0;
                        write_ram_len    <= #1 'b0;
                        state            <= #1 WRITE_IDX1;
                    end else begin
                        app_data_request <= #1 'b1;
                    end
                end
                WRITE_IDX1 : begin
                    app_data_in_valid <= #1 'b1;
                    app_data_in       <= #1 index[15:8];
                    state             <= #1 WRITE_IDX2;
                    read_en           <= #1 'b0;
                end
                WRITE_IDX2 : begin
                    app_data_in_valid <= #1 'b1;
                    app_data_in       <= #1 index[7:0];
                    state             <= #1 WRITE_DATA;
                    // Begin read input
                    if (data_len!=0) begin
                        read_en   <= #1 'b1;
                        rgmii_cnt <= #1 'b0;
                    end else begin
                        state <= #1 IDLE;
                    end
                end
                WRITE_DATA : begin
                    if (rgmii_cnt==data_len) begin
                        read_en           <= #1 'b0;
                        app_data_in_valid <= #1 'b0;
                        state             <= #1 IDLE;
                    end else begin
                        app_data_in_valid <= #1 valid;
                        app_data_in       <= #1 data;
                        if (valid) begin
                            rgmii_cnt <= #1 rgmii_cnt + 1'b1;
                        end
                    end
                end
                default : begin
                    state <= #1 UNINITED;
                end
            endcase
        end
    end

    udp_ip_mac_top #(
        .LOCAL_MAC (LOCAL_MAC ),
        .LOCAL_IP  (LOCAL_IP  ),
        .LOCAL_PORT(LOCAL_PORT),
        .DEST_IP   (DEST_IP   ),
        .DEST_PORT (DEST_PORT )
    ) u_udp_ip_mac_top (
        .rgmii_clk          (rgmii_clk          ),
        .rstn               (arp_rstn           ),
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
