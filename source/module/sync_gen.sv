module sync_gen (
    input  clk  ,
    input  rstn ,
    input  start,
    output hsync,
    output vsync
);

    sync_vg u_sync_vg (
        .clk   (clk37_125 ),
        .rstn  (rstn      ),
        .vs_out(vsync     ),
        .hs_out(hsync     ),
        .de_out(/*unused*/),
        .de_re (/*unused*/),
        .x_act (/*unused*/),
        .y_act (/*unused*/)
    );

endmodule : sync_gen
