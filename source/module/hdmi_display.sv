module hdmi_display (
    input         clk    ,
    input         href   ,

    output        hsync  ,
    output        vsync  ,
    output        data_en,
    output [10:0] x      ,
    output [ 9:0] y
);

    sync_gen #(
        .THRESH (),
        .DELAY  (),
        .V_FP   (),
        .V_SYNC (),
        .V_BP   (),
        .H_FP   (),
        .H_SYNC (),
        .H_BP   (),
        .V_BLANK(),
        .H_BLANK()
    ) u_sync_gen (
        .clk    (clk       ),
        .rstn   (rstn      ),
        .href   (href      ),
        .vsync  (vsync     ),
        .hsync  (hsync     ),
        .data_en(data_en   ),
        .x      (x         ),
        .y      (y         ),
        .read_en(/*unused*/)
    );

endmodule : hdmi_display
