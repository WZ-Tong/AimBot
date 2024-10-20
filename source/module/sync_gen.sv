module sync_gen #(
    parameter  THREASH   = 1                           ,
    parameter  DELAY     = 1                           ,
    parameter  V_BLANK   = 1                           ,
    parameter  H_BLANK   = 1                           ,

    localparam V_BP      = 5                           ,
    localparam V_SYNC    = 5                           ,
    localparam H_BP      = 200                         ,
    localparam H_SYNC    = 50                          ,

    localparam HV_OFFSET = 0                           ,
    localparam V_ACT     = 720                         ,
    localparam H_ACT     = 1280                        ,

    localparam V_FP      = V_BLANK - V_BP - V_SYNC     ,
    localparam H_FP      = H_BLANK - H_BP - H_SYNC     ,

    localparam H_TOTAL   = H_ACT + H_FP + H_SYNC + H_BP,
    localparam V_TOTAL   = V_ACT + V_FP + V_SYNC + V_BP,

    localparam X_BITS    = $clog2(H_TOTAL)             ,
    localparam Y_BITS    = $clog2(V_TOTAL)
) (
    input               clk     ,
    input               rstn    ,
    input               cam_href,

    output              vsync   ,
    output              hsync   ,
    output              data_en ,
    output              read_en ,

    output [X_BITS-1:0] x       ,
    output [Y_BITS-1:0] y
);

    localparam H_BLANK_TOTAL = (V_TOTAL-V_ACT) * H_TOTAL;

    localparam UNINIT   = 2'b00;
    localparam WAITING  = 2'b01;
    localparam DELAYING = 2'b10;
    localparam INITED   = 2'b11;

    reg [1:0] state /*synthesis PAP_MARK_DEBUG="true"*/;

    reg svg_rstn, href_d /*synthesis PAP_MARK_DEBUG="true"*/;

    reg [$clog2(H_BLANK_TOTAL)-1:0] cnt /*synthesis PAP_MARK_DEBUG="true"*/;

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            cnt      <= #1 'b0;
            href_d   <= #1 'b1;
            state    <= #1 UNINIT;
            svg_rstn <= #1 'b0;
        end else begin
            href_d <= #1 cam_href;
            case (state)
                UNINIT : begin
                    svg_rstn <= #1 'b0;
                    if (cam_href==0 && href_d==1) begin
                        state <= #1 WAITING;
                        cnt   <= #1 'b0;
                    end
                end
                WAITING : begin
                    svg_rstn <= #1 'b0;
                    if (cam_href==1) begin
                        state <= #1 UNINIT;
                    end else begin
                        cnt <= #1 cnt + 1'b1;
                        if (cnt==THREASH-1) begin
                            cnt   <= #1 'b0;
                            state <= #1 DELAYING;
                        end
                    end
                end
                DELAYING : begin
                    svg_rstn <= #1 'b0;
                    cnt      <= #1 cnt + 1'b1;
                    if (cnt==DELAY-1) begin
                        state <= #1 INITED;
                    end
                end
                INITED : begin
                    svg_rstn <= #1 'b1;
                end
            endcase
        end
    end

    sync_vg #(
        .X_BITS   (X_BITS   ),
        .Y_BITS   (Y_BITS   ),
        .V_TOTAL  (V_TOTAL  ),
        .V_FP     (V_FP     ),
        .V_BP     (V_BP     ),
        .V_SYNC   (V_SYNC   ),
        .V_ACT    (V_ACT    ),
        .H_TOTAL  (H_TOTAL  ),
        .H_FP     (H_FP     ),
        .H_BP     (H_BP     ),
        .H_SYNC   (H_SYNC   ),
        .H_ACT    (H_ACT    ),
        .HV_OFFSET(HV_OFFSET)
    ) u_sync_vg (
        .clk   (clk     ),
        .rstn  (svg_rstn),
        .vs_out(vsync   ),
        .hs_out(hsync   ),
        .de_out(data_en ),
        .de_re (read_en ),
        .x_act (x       ),
        .y_act (y       )
    );

endmodule : sync_gen
