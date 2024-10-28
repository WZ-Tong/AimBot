module udp_unpack_720p (
    input  [47:0] i_data ,

    output [10:0] start_x,
    output [ 9:0] start_y,
    output [10:0] end_x  ,
    output [ 9:0] end_y  ,
    output [ 7:0] r      ,
    output [ 7:0] g      ,
    output [ 7:0] b
);

    // XXXX_XXXX XXXY_YYYY YYYY_YXXX XXXX_XXXX YYYY_YYYY YYCC_CCCC

    wire [5:0] color;
    assign {start_x, start_y, end_x, end_y, color} = i_data;

    assign r = {color[5:4], color[5:4], color[5:4], color[5:4]};
    assign g = {color[3:2], color[3:2], color[3:2], color[3:2]};
    assign b = {color[1:0], color[1:0], color[1:0], color[1:0]};

endmodule : udp_unpack_720p
