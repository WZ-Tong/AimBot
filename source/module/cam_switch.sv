module cam_switch #(
    parameter H_ACT = 1280,
    parameter V_ACT = 720 ,
    parameter DELAY = 5   ,
    parameter TICK  = 5
) (
    input                                          clk       ,
    input                                          rstn      ,
    input  [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] main_pack ,
    input  [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] minor_pack,
    input                                          key       ,
    output [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] pack
);

    wire switch_switch;
    key_to_switch #(
        .TICK(TICK),
        .INIT(1'b1)
    ) u_cam_id_switch_gen (
        .clk   (clk          ),
        .rstn  (rstn         ),
        .key   (key          ),
        .switch(switch_switch)
    );

    reg cam_id      ;
    reg main_vsync_d;
    always_ff @(posedge main_clk or negedge rstn) begin
        if(~rstn) begin
            main_vsync_d <= #1 'b0;
            cam_id       <= #1 'b0;
        end else begin
            main_vsync_d <= #1 main_vsync;
            if (main_vsync_d==1 && main_vsync==1) begin
                cam_id <= #1 switch_switch;
            end
        end
    end

    wire                     main_clk  ;
    wire                     main_hsync;
    wire                     main_vsync;
    wire                     main_de   ;
    wire [              7:0] main_r    ;
    wire [              7:0] main_g    ;
    wire [              7:0] main_b    ;
    wire [$clog2(H_ACT)-1:0] main_x    ;
    wire [$clog2(V_ACT)-1:0] main_y    ;
    hdmi_unpack #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_main_unpack (
        .pack (main_pack ),
        .clk  (main_clk  ),
        .hsync(main_hsync),
        .vsync(main_vsync),
        .de   (main_de   ),
        .r    (main_r    ),
        .g    (main_g    ),
        .b    (main_b    ),
        .x    (main_x    ),
        .y    (main_y    )
    );
    wire [23:0] main_data;
    assign main_data = {main_r, main_g, main_b};

    wire [23:0] mo_data;
    delay #(
        .DELAY(DELAY),
        .WIDTH(3*8  )
    ) u_mo_rgb_delay (
        .clk   (main_clk ),
        .i_data(main_data),
        .o_data(mo_data  )
    );
    wire [7:0] mo_r, mo_g, mo_b;
    assign {mo_r, mo_g, mo_b} = mo_data;

    wire mo_hsync, mo_vsync;
    delay #(
        .DELAY(DELAY),
        .WIDTH(2    )
    ) u_mo_sync_delay (
        .clk   (main_clk                ),
        .i_data({main_hsync, main_vsync}),
        .o_data({mo_hsync, mo_vsync}    )
    );

    wire mo_re;
    delay #(
        .DELAY(DELAY-1),
        .WIDTH(1      )
    ) u_mo_re_gen (
        .clk   (main_clk),
        .i_data(main_de ),
        .o_data(mo_re   )
    );

    wire mo_de;
    delay #(
        .DELAY(1),
        .WIDTH(1)
    ) u_mo_de_gen (
        .clk   (main_clk),
        .i_data(mo_re   ),
        .o_data(mo_de   )
    );

    wire [$clog2(H_ACT)-1:0] mo_x;
    wire [$clog2(V_ACT)-1:0] mo_y;
    delay #(
        .DELAY(DELAY                      ),
        .WIDTH($clog2(H_ACT)+$clog2(V_ACT))
    ) u_mo_xy_delay (
        .clk   (main_clk        ),
        .i_data({main_x, main_y}),
        .o_data({mo_x, mo_y}    )
    );

    wire                     minor_clk  ;
    wire                     minor_hsync;
    wire                     minor_vsync;
    wire                     minor_de   ;
    wire [              7:0] minor_r    ;
    wire [              7:0] minor_g    ;
    wire [              7:0] minor_b    ;
    wire [$clog2(H_ACT)-1:0] minor_x    ;
    wire [$clog2(V_ACT)-1:0] minor_y    ;
    hdmi_unpack #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_minor_unpack (
        .pack (minor_pack ),
        .clk  (minor_clk  ),
        .hsync(minor_hsync),
        .vsync(minor_vsync),
        .de   (minor_de   ),
        .r    (minor_r    ),
        .g    (minor_g    ),
        .b    (minor_b    ),
        .x    (minor_x    ),
        .y    (minor_y    )
    );
    wire [23:0] minor_data;
    assign minor_data = {minor_r, minor_g, minor_b};

    wire wclk, wrst, wen, rrst, ren;
    assign wclk = minor_clk;
    assign wrst = cam_id ? 1'b1 : minor_vsync;
    assign wen  = cam_id ? 1'b0 : minor_de;
    assign rrst = cam_id ? 1'b1 : main_vsync;
    assign ren  = cam_id ? 1'b0 : mo_re;

    wire [23:0] wdata;
    assign wdata = cam_id ? (~24'b0) : minor_data;

    wire [23:0] rdata;
    async_fifo_lite u_pack_sync (
        // Write
        .wr_clk      (wclk      ),
        .wr_rst      (wrst      ),
        .wr_en       (wen       ),
        .wr_data     (wdata     ),
        .wr_full     (/*unused*/),
        .almost_full (/*unused*/),
        // Read
        .rd_clk      (main_clk  ),   // Avoid using comb logic: delay can be ignored
        .rd_rst      (main_vsync),   // Avoid using comb logic: delay can be ignored
        .rd_en       (ren       ),
        .rd_data     (rdata     ),
        .rd_empty    (/*unused*/),
        .almost_empty(/*unused*/)
    );
    wire [7:0] no_r, no_g, no_b;
    assign {no_r, no_g, no_b} = rdata;

    wire [7:0] o_r, o_g, o_b;
    assign o_r = cam_id ? mo_r : no_r;
    assign o_g = cam_id ? mo_g : no_g;
    assign o_b = cam_id ? mo_b : no_b;

    hdmi_pack #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_output_pack (
        .clk  (main_clk),
        .hsync(mo_hsync),
        .vsync(mo_vsync),
        .de   (mo_de   ),
        .x    (mo_x    ),
        .y    (mo_y    ),
        .r    (o_r     ),
        .g    (o_g     ),
        .b    (o_b     ),
        .pack (pack    )
    );

endmodule : cam_switch
