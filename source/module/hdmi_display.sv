module hdmi_display (
    input         clk    ,
    input         rstn   ,
    input         i_vsync,
    input  [15:0] i_data ,

    output        o_error,
    output        o_hsync  /*synthesis PAP_MARK_DEBUG="true"*/,
    output        o_vsync  /*synthesis PAP_MARK_DEBUG="true"*/,
    output        o_de     /*synthesis PAP_MARK_DEBUG="true"*/,
    output [15:0] o_data ,
    output [10:0] o_x    ,
    output [ 9:0] o_y
);

    wire read_en  /*synthesis PAP_MARK_DEBUG="true"*/;
    reg  svg_rstn /*synthesis PAP_MARK_DEBUG="true"*/;
    reg  vsync_d ;

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            svg_rstn <= #1 'b0;
            vsync_d  <= #1 'b0;
        end else begin
            vsync_d <= #1 i_vsync;
            if (~svg_rstn) begin
                if (vsync_d==0 && i_vsync==1) begin
                    svg_rstn <= #1 'b1;
                end
            end
        end
    end

    localparam V_FP   = 14544  ;
    localparam V_BP   = 3530644;
    localparam V_SYNC = 5688   ;
    localparam V_ACT  = 720    ;

    localparam H_FP   = 750 ;
    localparam H_BP   = 750 ;
    localparam H_SYNC = 64  ;
    localparam H_ACT  = 1280;

    localparam V_TOTAL = V_FP + V_BP + V_SYNC + V_ACT;
    localparam H_TOTAL = H_FP + H_BP + H_SYNC + H_ACT;

    sync_vg #(
        .V_TOTAL  (V_TOTAL),
        .V_FP     (V_FP   ),
        .V_BP     (V_BP   ),
        .V_SYNC   (V_SYNC ),
        .V_ACT    (V_ACT  ),
        .H_TOTAL  (H_TOTAL),
        .H_FP     (H_FP   ),
        .H_BP     (H_BP   ),
        .H_SYNC   (H_SYNC ),
        .H_ACT    (H_ACT  ),
        .X_BITS   (11     ),
        .Y_BITS   (10     ),
        .HV_OFFSET(0      )
    ) u_sync_vg (
        .clk   (clk     ),
        .rstn  (svg_rstn),
        .vs_out(o_vsync ),
        .hs_out(o_hsync ),
        .de_out(o_de    ),
        .de_re (read_en ),
        .x_act (o_x     ),
        .y_act (o_y     )
    );

    wire full, err_fulln;
    rstn_gen #(.TICK(500_000)) u_err_full (
        .clk   (clk      ),
        .i_rstn(~full    ),
        .o_rstn(err_fulln)
    );
    assign err_full = ~err_fulln;

    wire empty, err_emptyn;
    rstn_gen #(.TICK(500_000)) u_err_empty (
        .clk   (clk       ),
        .i_rstn(~empty    ),
        .o_rstn(err_emptyn)
    );
    assign err_empty = ~err_emptyn;

    assign error = err_full || err_empty;

    sync_fifo u_sync_fifo (
        .clk         (clk       ),
        .rst         (svg_rstn  ),
        .wr_data     (i_data    ),
        .wr_en       (href      ),
        .wr_full     (full      ),
        .almost_full (/*unused*/),
        .rd_data     (o_data    ),
        .rd_en       (read_en   ),
        .rd_empty    (empty     ),
        .almost_empty(/*unused*/)
    );

endmodule : hdmi_display
