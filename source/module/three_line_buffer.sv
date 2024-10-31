module three_line_buffer #(
    parameter  H_ACT     = 12'd1280                         ,
    parameter  V_ACT     = 12'd720                          ,
    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                  en    ,
    input  [PACK_SIZE-1:0] i_pack,
    output [         23:0] line1 ,
    output [         23:0] line2
);

    line_ram u_line_a (
        .clk    (),
        .rst    (),
        .addr   (),
        .wr_en  (),
        .wr_data(),
        .rd_data()
    );

endmodule : three_line_buffer
