module hdmi_display (
    input         clk    ,
    input         rstn   ,
    input         i_vsync,
    input         i_href ,
    input  [15:0] i_data ,

    output [48:0] o_pack
);

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

    localparam H_FP   = 300 ;
    localparam H_BP   = 300 ;
    localparam H_SYNC = 12  ;
    localparam H_ACT  = 1280;

    localparam H_TOTAL = H_FP + H_BP + H_SYNC + H_ACT; // 1892

    localparam V_FP   = 9  ;
    localparam V_BP   = 9  ;
    localparam V_SYNC = 2  ; // 3784
    localparam V_ACT  = 720;

    localparam V_TOTAL = V_FP + V_BP + V_SYNC + V_ACT; // 38560

    wire [10:0] o_x;
    wire [ 9:0] o_y;
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
        .clk   (clk       ),
        .rstn  (svg_rstn  ),
        .vs_out(o_vsync   ),
        .hs_out(o_hsync   ),
        .de_out(o_de      ),
        .de_re (/*unused*/),
        .x_act (o_x       ),
        .y_act (o_y       )
    );

    localparam DATA_DELAY = 25;
    reg [15:0] data_ds [DATA_DELAY-1:0];

    integer i;
    always_ff @(posedge clk) begin
        for (i = 0; i < DATA_DELAY-1; i=i+1) begin
            data_ds[i+1] <= #1 data_ds[i];
        end
        data_ds[0] <= #1 i_data;
    end
    wire [15:0] o_data;
    assign o_data = data_ds[DATA_DELAY-1];

    hdmi_pack u_disp_pack (
        .clk  (clk                  ),
        .hsync(o_hsync              ),
        .vsync(o_vsync              ),
        .de   (o_de                 ),
        .r    ({o_data[04:00], 3'b0}),
        .g    ({o_data[10:05], 2'b0}),
        .b    ({o_data[15:11], 3'b0}),
        .x    (o_x                  ),
        .y    (o_y                  ),
        .pack (o_pack               )
    );

endmodule : hdmi_display
