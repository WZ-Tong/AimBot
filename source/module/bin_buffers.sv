// First `ROW` line blank, then normal
module bin_buffers #(
    parameter  H_ACT     = 12'd1280                         ,
    parameter  V_ACT     = 12'd720                          ,
    parameter  ROW       = 4                                ,
    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                  rstn  ,
    input  [PACK_SIZE-1:0] i_pack,
    output [PACK_SIZE-1:0] o_pack,

    output [      ROW-1:0] window
);

    wire                     clk  ;
    wire                     hsync;
    wire                     vsync;
    wire                     de   ;
    wire [              7:0] r    ;
    wire [              7:0] g    ;
    wire [              7:0] b    ;
    wire [$clog2(H_ACT)-1:0] x    ;
    wire [$clog2(V_ACT)-1:0] y    ;
    hdmi_unpack #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_hdmi_unpack (
        .pack (i_pack),
        .clk  (clk   ),
        .hsync(hsync ),
        .vsync(vsync ),
        .de   (de    ),
        .r    (r     ),
        .g    (g     ),
        .b    (b     ),
        .x    (x     ),
        .y    (y     )
    );
    wire bin;
    assign bin = (r==0&&g==0&&b==0) ? 1'b0 : 1'b1;

    reg [$clog2(H_ACT)-1:0] addr;
    reg [  $clog2(ROW)-1:0] ptr ;

    reg hsync_d;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            hsync_d <= #1 'b0;
        end else begin
            hsync_d <= #1 hsync;
        end
    end

    wire hsync_r;
    assign hsync_r = hsync_d==0 && hsync==1;

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            addr <= #1 'b0;
            ptr  <= #1 'b0;
        end else if (vsync) begin
            addr <= #1 'b0;
            ptr  <= #1 'b0;
        end else if (hsync_r) begin
            addr <= #1 'b0;
            if (ptr!=ROW-1) begin
                ptr <= #1 ptr + 1'b1;
            end else begin
                ptr <= #1 'b0;
            end
        end else if (addr!=H_ACT-1 && de) begin
            addr <= #1 addr + 1'b1;
        end
    end

    `ifdef __ICARUS__
        genvar i;
        for (i = 0; i < ROW; i=i+1) begin: g_rams
            reg  read;
            wire wen ;
            assign wen = ptr==i && de;

            reg [H_ACT-1:0] ram;
            always_ff @(posedge clk or negedge rstn) begin
                if(~rstn) begin
                    ram  <= #1 'b0;
                    read <= #1 'b0;
                end else begin
                    if (wen) begin
                        // Write mode
                        ram[addr] <= #1 bin;
                    end else begin
                        // Read mode
                        read <= #1 ram[addr];
                    end
                end
            end
        end
    `else
        genvar i;
        for (i = 0; i < ROW; i=i+1) begin: g_rams
            wire read;
            wire wen ;
            assign wen = ptr==i && de;
            bin_ram u_bin_ram (
                .clk    (clk  ),
                .rst    (~rstn),
                .wr_en  (wen  ),
                .addr   (addr ),
                .wr_data(bin  ),
                .rd_data(read )
            );
        end
    `endif


    reg current;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            current <= #1 'b0;
        end else begin
            current <= #1 bin;
        end
    end

    if (ROW==3) begin: g_temp_link_3
        reg [ROW-1:0] temp_window;
        always_comb begin
            unique case (ptr)
                'd0 : begin
                    temp_window[0] = g_rams[1].read;
                    temp_window[1] = g_rams[2].read;
                end
                'd1 : begin
                    temp_window[0] = g_rams[2].read;
                    temp_window[1] = g_rams[0].read;
                end
                'd2 : begin
                    temp_window[0] = g_rams[0].read;
                    temp_window[1] = g_rams[1].read;
                end
                default : begin
                    temp_window[0] = 'b0;
                    temp_window[1] = 'b0;
                end
            endcase
            temp_window[2] = current;
        end
        assign window = temp_window;
    end else if (ROW==4) begin: g_temp_link_4
        reg [ROW-1:0] temp_window;
        always_comb begin
            unique case (ptr)
                'd0 : begin
                    temp_window[0] = g_rams[1].read;
                    temp_window[1] = g_rams[2].read;
                    temp_window[2] = g_rams[3].read;
                end
                'd1 : begin
                    temp_window[0] = g_rams[2].read;
                    temp_window[1] = g_rams[3].read;
                    temp_window[2] = g_rams[0].read;
                end
                'd2 : begin
                    temp_window[0] = g_rams[3].read;
                    temp_window[1] = g_rams[0].read;
                    temp_window[2] = g_rams[1].read;
                end
                'd3 : begin
                    temp_window[0] = g_rams[0].read;
                    temp_window[1] = g_rams[1].read;
                    temp_window[2] = g_rams[2].read;
                end
                default : begin
                    temp_window[0] = 'b0;
                    temp_window[1] = 'b0;
                    temp_window[2] = 'b0;
                end
            endcase
            temp_window[3] = current;
        end
        assign window = temp_window;
    end else if (ROW==5) begin: g_temp_link_5
        reg [ROW-1:0] temp_window;
        always_comb begin
            unique case (ptr)
                'd0 : begin
                    temp_window[0] = g_rams[1].read;
                    temp_window[1] = g_rams[2].read;
                    temp_window[2] = g_rams[3].read;
                    temp_window[3] = g_rams[4].read;
                end
                'd1 : begin
                    temp_window[0] = g_rams[2].read;
                    temp_window[1] = g_rams[3].read;
                    temp_window[2] = g_rams[4].read;
                    temp_window[3] = g_rams[0].read;
                end
                'd2 : begin
                    temp_window[0] = g_rams[3].read;
                    temp_window[1] = g_rams[4].read;
                    temp_window[2] = g_rams[0].read;
                    temp_window[3] = g_rams[1].read;
                end
                'd3 : begin
                    temp_window[0] = g_rams[4].read;
                    temp_window[1] = g_rams[0].read;
                    temp_window[2] = g_rams[1].read;
                    temp_window[3] = g_rams[2].read;
                end
                'd4 : begin
                    temp_window[0] = g_rams[0].read;
                    temp_window[1] = g_rams[1].read;
                    temp_window[2] = g_rams[2].read;
                    temp_window[3] = g_rams[3].read;
                end
                default : begin
                    temp_window[0] = 'b0;
                    temp_window[1] = 'b0;
                    temp_window[2] = 'b0;
                    temp_window[3] = 'b0;
                end
            endcase
            temp_window[4] = current;
        end
        assign window = temp_window;
    end else begin: g_temp_link_unimpl
        err_mode not_yet_linked();
    end

    localparam DELAY = 1;

    wire blank;
    assign blank = y<(ROW-1);

    wire o_hsync, o_vsync, o_de;
    delay #(
        .DELAY(DELAY),
        .WIDTH(3    )
    ) u_sync_de_delay (
        .clk   (clk                     ),
        .i_data({hsync, vsync, de}      ),
        .o_data({o_hsync, o_vsync, o_de})
    );

    wire [$clog2(H_ACT)-1:0] o_x;
    wire [$clog2(V_ACT)-1:0] o_y;
    delay #(
        .DELAY(DELAY                      ),
        .WIDTH($clog2(H_ACT)+$clog2(V_ACT))
    ) u_xy_delay (
        .clk   (clk       ),
        .i_data({x, y}    ),
        .o_data({o_x, o_y})
    );

    wire [7:0] o_rgb;
    assign o_rgb = {8{current}};

    hdmi_pack #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_hdmi_pack (
        .clk  (clk             ),
        .hsync(o_hsync         ),
        .vsync(o_vsync         ),
        .de   (o_de            ),
        .r    (blank?8'b0:o_rgb),
        .g    (blank?8'b0:o_rgb),
        .b    (blank?8'b0:o_rgb),
        .x    (o_x             ),
        .y    (o_y             ),
        .pack (o_pack          )
    );

endmodule : bin_buffers
