module draw_window_pos_sel #(
    parameter V_ACT       = 12'd720 ,
    parameter H_ACT       = 12'd1280,
    parameter MAIN_CAM_ID = 1'b0
) (
    input                      cam_id      ,
    input  [$clog2(H_ACT)-1:0] cam1_start_x,
    input  [$clog2(V_ACT)-1:0] cam1_start_y,
    input  [$clog2(H_ACT)-1:0] cam1_end_x  ,
    input  [$clog2(V_ACT)-1:0] cam1_end_y  ,
    input  [$clog2(H_ACT)-1:0] cam2_start_x,
    input  [$clog2(V_ACT)-1:0] cam2_start_y,
    input  [$clog2(H_ACT)-1:0] cam2_end_x  ,
    input  [$clog2(V_ACT)-1:0] cam2_end_y  ,
    output [$clog2(H_ACT)-1:0] cam_start_x ,
    output [$clog2(V_ACT)-1:0] cam_start_y ,
    output [$clog2(H_ACT)-1:0] cam_end_x   ,
    output [$clog2(V_ACT)-1:0] cam_end_y
);

    wire cam_valid, cam1_valid, cam2_valid;
    assign cam1_valid = 1
        && cam1_start_x!=0 && cam1_end_x!=0
        && cam1_start_y!=0 && cam1_end_y!=0;
    assign cam2_valid = 1
        && cam2_start_x!=0 && cam2_end_x!=0
        && cam2_start_y!=0 && cam2_end_y!=0;
    assign cam_valid = cam1_valid && cam2_valid;

    assign cam_start_x = cam_valid ? (cam_id==MAIN_CAM_ID ? cam1_start_x : cam2_start_x) : 'b0;
    assign cam_start_y = cam_valid ? (cam_id==MAIN_CAM_ID ? cam1_start_y : cam2_start_y) : 'b0;
    assign cam_end_x   = cam_valid ? (cam_id==MAIN_CAM_ID ? cam1_end_x   : cam2_end_x  ) : 'b0;
    assign cam_end_y   = cam_valid ? (cam_id==MAIN_CAM_ID ? cam1_end_y   : cam2_end_y  ) : 'b0;

endmodule : draw_window_pos_sel
