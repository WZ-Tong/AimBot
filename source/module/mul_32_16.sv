module mul_32_16 (
    input         clk,
    input  [31:0] a  ,
    input  [15:0] b  ,
    output [47:0] p
);

    multiplier_32_16 u_mul_32_16_intrinsic (
        .ce (1'b1),
        .rst(1'b0),
        .clk(clk ),
        .a  (a   ),
        .b  (b   ),
        .p  (p   )
    );

endmodule : mul_32_16
