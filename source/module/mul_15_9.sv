module mul_15_9 (
    input         clk,
    input  [14:0] a  ,
    input  [ 8:0] b  ,
    output [23:0] p
);

    multiplier_15_9 u_mul_15_9_intrinsic (
        .ce (1'b1),
        .rst(1'b0),
        .clk(clk ),
        .a  (a   ),
        .b  (b   ),
        .p  (p   )
    );

endmodule : mul_15_9
