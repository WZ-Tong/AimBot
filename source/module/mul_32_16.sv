module mul_32_16 (
    input         clk,
    input  [31:0] a  ,
    input  [15:0] b  ,
    output [47:0] p
);

    wire [65:0] full_p;
    wb_mul u_mul_intrinsic (
        .clk   (clk   ),
        .ce    (1'b1  ),
        .rst   (1'b0  ),
        .a     (a     ),
        .b     (b     ),
        .reload(1'b1  ),
        .p     (full_p)
    );

    assign p = full_p[47:0];

endmodule : mul_32_16
