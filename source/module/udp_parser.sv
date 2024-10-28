module udp_parser #(
    parameter N_BOX = 1   ,
    parameter H_ACT = 1280,
    parameter V_ACT = 720 ,
    parameter C_DEP = 2     // Color depth
) (
    input  [N_BOX*(C_DEP*3+(2*($clog2(H_ACT)+$clog2(V_ACT))))-1:0] udp_data,

    output [                              N_BOX*$clog2(H_ACT)-1:0] start_xs,
    output [                              N_BOX*$clog2(V_ACT)-1:0] start_ys,

    output [                              N_BOX*$clog2(H_ACT)-1:0] end_xs  ,
    output [                              N_BOX*$clog2(V_ACT)-1:0] end_ys  ,

    output [                                         N_BOX*24-1:0] colors
);

    genvar i;
    for (i = 0; i < N_BOX; i=i+1) begin: gen_udp_unpack
        wire [47:0] packed_data;
        wire [10:0] start_x    ;
        wire [ 9:0] start_y    ;
        wire [10:0] end_x      ;
        wire [ 9:0] end_y      ;
        wire [ 7:0] r          ;
        wire [ 7:0] g          ;
        wire [ 7:0] b          ;
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
        assign packed_data = udp_data[(i+1)*48-1:i*48];

        assign start_xs[(i+1)*11-1:i*11] = start_x;
        assign start_ys[(i+1)*10-1:i*10] = start_y;

        assign end_xs[(i+1)*11-1:i*11] = end_x;
        assign end_ys[(i+1)*10-1:i*10] = end_y;

        assign colors[(i+1)*24-1:i*24] = {r, g, b};
    end

endmodule : udp_parser
