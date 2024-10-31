module udp_parser #(
    parameter BOX_NUM = 1   ,
    parameter H_ACT   = 1280,
    parameter V_ACT   = 720 ,
    parameter C_DEP   = 2     // Color depth
) (
    input  [BOX_NUM*(C_DEP*3+(2*($clog2(H_ACT)+$clog2(V_ACT))))-1:0] udp_data,

    output [                              BOX_NUM*$clog2(H_ACT)-1:0] start_xs,
    output [                              BOX_NUM*$clog2(V_ACT)-1:0] start_ys,

    output [                              BOX_NUM*$clog2(H_ACT)-1:0] end_xs  ,
    output [                              BOX_NUM*$clog2(V_ACT)-1:0] end_ys  ,

    output [                                         BOX_NUM*24-1:0] colors
);

    localparam UDP_PACK_SEG_SIZE = ($clog2(H_ACT)+$clog2(V_ACT))*2+C_DEP*3;

    genvar i;
    for (i = 0; i < BOX_NUM; i=i+1) begin: g_udp_unpack
        wire [UDP_PACK_SEG_SIZE-1:0] packed_data;
        assign packed_data = udp_data[(i+1)*48-1:i*48];

        wire [$clog2(H_ACT)-1:0] start_x;
        wire [$clog2(V_ACT)-1:0] start_y;
        wire [$clog2(H_ACT)-1:0] end_x  ;
        wire [$clog2(V_ACT)-1:0] end_y  ;
        wire [              7:0] r      ;
        wire [              7:0] g      ;
        wire [              7:0] b      ;
        udp_unpack_720p u_udp_unpack (
            .i_data (packed_data),
            .start_x(start_x    ),
            .start_y(start_y    ),
            .end_x  (end_x      ),
            .end_y  (end_y      ),
            .r      (r          ),
            .g      (g          ),
            .b      (b          )
        );

        assign start_xs[(i+1)*$clog2(H_ACT)-1:i*$clog2(H_ACT)] = start_x;
        assign start_ys[(i+1)*$clog2(V_ACT)-1:i*$clog2(V_ACT)] = start_y;

        assign end_xs[(i+1)*$clog2(H_ACT)-1:i*$clog2(H_ACT)] = end_x;
        assign end_ys[(i+1)*$clog2(V_ACT)-1:i*$clog2(V_ACT)] = end_y;

        assign colors[(i+1)*24-1:i*24] = {r, g, b};
    end

endmodule : udp_parser
