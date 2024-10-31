module three_line_buffer #(
    parameter  H_ACT     = 12'd1280                         ,
    parameter  V_ACT     = 12'd720                          ,
    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input        [PACK_SIZE-1:0] i_pack,
    output logic [         23:0] line1 ,
    output logic [         23:0] line2
);

    wire                     clk  ;
    wire                     hsync;
    wire                     vsync;
    wire                     de   ;
    wire [              7:0] r    ;
    wire [              7:0] g    ;
    wire [              7:0] b    ;
    wire [$clog2(H_ACT)-1:0] x    ;
    wire [$clog2(V_ACT)-1:0] y    ;
    hdmi_unpack #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_hdmi_unpack (
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

    logic        wen_a  ;
    wire  [23:0] wdata_a;
    wire  [23:0] rdata_a;
    line_ram u_line_a (
        .clk    (clk    ),
        .rst    (1'b0   ),
        .addr   (x      ),
        .wr_en  (wen_a  ),
        .wr_data(wdata_a),
        .rd_data(rdata_a)
    );

    logic        wen_b  ;
    wire  [23:0] wdata_b;
    wire  [23:0] rdata_b;
    line_ram u_line_b (
        .clk    (clk    ),
        .rst    (1'b0   ),
        .addr   (x      ),
        .wr_en  (wen_b  ),
        .wr_data(wdata_b),
        .rd_data(rdata_b)
    );

    logic        wen_c  ;
    wire  [23:0] wdata_c;
    wire  [23:0] rdata_c;
    line_ram u_line_c (
        .clk    (clk    ),
        .rst    (1'b0   ),
        .addr   (x      ),
        .wr_en  (wen_c  ),
        .wr_data(wdata_c),
        .rd_data(rdata_c)
    );

    reg [1:0] wid; // Which ram is currently write
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

endmodule : three_line_buffer
