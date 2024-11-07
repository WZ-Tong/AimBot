module three_line_buffer #(
    parameter  H_ACT     = 12'd1280                         ,
    parameter  V_ACT     = 12'd720                          ,
    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                        rstn  ,
    input        [PACK_SIZE-1:0] i_pack,
    output logic [         23:0] line1   /*synthesis PAP_MARK_DEBUG="true"*/,
    output logic [         23:0] line2   /*synthesis PAP_MARK_DEBUG="true"*/
);

    wire                     clk   /*synthesis PAP_MARK_DEBUG="true"*/;
    wire                     hsync /*synthesis PAP_MARK_DEBUG="true"*/;
    wire                     vsync /*synthesis PAP_MARK_DEBUG="true"*/;
    wire                     de    /*synthesis PAP_MARK_DEBUG="true"*/;
    wire [              7:0] r;
    wire [              7:0] g;
    wire [              7:0] b;
    wire [$clog2(H_ACT)-1:0] x;
    wire [$clog2(V_ACT)-1:0] y;
    hdmi_unpack #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_hdmi_unpack (
        .pack (i_pack),
        .clk  (clk   ),
        .hsync(hsync ),
        .vsync(vsync ),
        .de   (de    ),
        .r    (r     ),
        .g    (g     ),
        .b    (b     ),
        .x    (x     ),
        .y    (y     )
    );
    wire [23:0] wdata /*synthesis PAP_MARK_DEBUG="true"*/;
    assign wdata = {r, g, b};

    logic        wen_a  ;
    wire  [23:0] rdata_a;
    line_ram u_line_a (
        .clk    (clk     ),
        .rst    (1'b0    ),
        .addr   (x       ),
        .wr_en  (wen_a&de),
        .wr_data(wdata   ),
        .rd_data(rdata_a )
    );

    logic        wen_b  ;
    wire  [23:0] rdata_b;
    line_ram u_line_b (
        .clk    (clk     ),
        .rst    (1'b0    ),
        .addr   (x       ),
        .wr_en  (wen_b&de),
        .wr_data(wdata   ),
        .rd_data(rdata_b )
    );

    logic        wen_c  ;
    wire  [23:0] rdata_c;
    line_ram u_line_c (
        .clk    (clk     ),
        .rst    (1'b0    ),
        .addr   (x       ),
        .wr_en  (wen_c&de),
        .wr_data(wdata   ),
        .rd_data(rdata_c )
    );

    reg [1:0] wid /*synthesis PAP_MARK_DEBUG="true"*/; // Which ram is currently write
    always_comb begin
        unique case (wid)
            2'b00 : begin
                wen_b = 'b0;
                wen_c = 'b0;
                wen_a = 'b1;
                line1 = rdata_b;
                line2 = rdata_c;
            end
            2'b01 : begin
                wen_c = 'b0;
                wen_a = 'b0;
                wen_b = 'b1;
                line1 = rdata_c;
                line2 = rdata_a;
            end
            2'b10 : begin
                wen_a = 'b0;
                wen_b = 'b0;
                wen_c = 'b1;
                line1 = rdata_a;
                line2 = rdata_b;
            end
            2'b11 : begin
                // Error
                wen_a = 'b0;
                wen_b = 'b0;
                wen_c = 'b0;
                line1 = 'b0;
                line2 = 'b0;
            end
        endcase
    end

    reg hsync_d;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            hsync_d <= #1 'b0;
        end else begin
            hsync_d <= #1 hsync;
        end
    end

    wire pos_hsync;
    assign pos_hsync = hsync_d==0 && hsync==1;

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            wid <= #1 'b0;
        end else if (vsync) begin
            wid <= #1 'b0;
        end else if (pos_hsync) begin
            unique case (wid)
                2'b00 : begin
                    wid <= #1 2'b01;
                end
                2'b01 : begin
                    wid <= #1 2'b10;
                end
                2'b10 : begin
                    wid <= #1 2'b00;
                end
                2'b11 : begin
                    wid <= #1 wid;
                end
            endcase
        end
    end

endmodule : three_line_buffer
