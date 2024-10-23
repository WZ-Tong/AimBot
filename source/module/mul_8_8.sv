module mul_8_8 (
    input         clk,
    input  [ 7:0] a  ,
    input  [ 7:0] b  ,
    output [15:0] p
);

    multiplier_8_8 u_mul_8_8_intrinsic (
        .ce (1'b1),
        .rst(1'b0),
        .clk(clk ),
        .a  (a   ),
        .b  (b   ),
        .p  (p   )
    );

endmodule : mul_8_8
