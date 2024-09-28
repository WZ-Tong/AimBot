`timescale 1ns / 1ps

module AimBot #(
    parameter BITS               = 8       ,

    parameter V_TOTAL            = 12'd750 ,
    parameter V_FP               = 12'd5   ,
    parameter V_BP               = 12'd20  ,
    parameter V_SYNC             = 12'd5   ,
    parameter V_ACT              = 12'd720 ,

    parameter H_TOTAL            = 12'd1650,
    parameter H_FP               = 12'd110 ,
    parameter H_BP               = 12'd220 ,
    parameter H_SYNC             = 12'd40  ,
    parameter H_ACT              = 12'd1280,

    parameter V_BOX_WIDTH        = 1'b1    ,
    parameter H_BOX_WIDTH        = 1'b1    ,

    parameter N_BOX              = 1'b1    ,

    parameter MEM_ROW_ADDR_WIDTH = 15      ,
    parameter MEM_COL_ADDR_WIDTH = 10      ,
    parameter MEM_BADDR_WIDTH    = 3       ,
    parameter MEM_DQ_WIDTH       = 32      ,
    parameter MEM_DQS_WIDTH      = 32 / 8
) (
    input                           clk           ,
    input                           rstn          ,

    output                          cmos_inited   ,
    inout                           cmos_scl      ,
    inout                           cmos_sda      ,
    input                           cmos_vsync    ,
    input                           cmos_href     ,
    input                           cmos_pclk     ,
    input  [              BITS-1:0] cmos_data     ,
    output                          cmos_reset    ,
    output                          cmos_heart    ,

    output                          ddr_rst_n     ,
    output                          ddr_ck        ,
    output                          ddr_ck_n      ,
    output                          ddr_cke       ,
    output                          ddr_cs_n      ,
    output                          ddr_ras_n     ,
    output                          ddr_cas_n     ,
    output                          ddr_we_n      ,
    output                          ddr_odt       ,
    output [MEM_ROW_ADDR_WIDTH-1:0] ddr_a         ,
    output [   MEM_BADDR_WIDTH-1:0] ddr_ba        ,
    inout  [    MEM_DQ_WIDTH/8-1:0] ddr_dqs       ,
    inout  [    MEM_DQ_WIDTH/8-1:0] ddr_dqs_n     ,
    inout  [      MEM_DQ_WIDTH-1:0] ddr_dq        ,
    output [    MEM_DQ_WIDTH/8-1:0] ddr_dm        ,
    output                          ddr_inited    ,

    output                          hdmi_hsync    ,
    output                          hdmi_vsync    ,
    output                          hdmi_de       ,
    output [              BITS-1:0] hdmi_r        ,
    output [              BITS-1:0] hdmi_g        ,
    output [              BITS-1:0] hdmi_b        ,

    output                          hdmi_iic_rstn ,
    output                          hdmi_iic_i_scl,
    inout                           hdmi_iic_i_sda,
    output                          hdmi_iic_o_scl,
    inout                           hdmi_iic_o_sda
);

    // Pll clk generator
    wire clk_10, clk10l;
    wire clk_20, clk20l;
    wire clk_25, clk25l;
    fake_pll #(.CLK(3)) pll (
        .i(clk                   ),
        .l({clk10l,clk20l,clk25l}),
        .o({clk10, clk20, clk25} )
    );

    // HDMI configure
    wire hdmi_inited;
    hdmi_ctrl hdmi_ctrl (
        .clk50       (clk           ),
        .rstn        (rstn          ),
        .clk10       (clk10         ),
        .clk10_locked(clk10_locked  ),
        .inited      (hdmi_inited   ),
        .iic_rstn    (hdmi_iic_rstn ),
        .iic_i_scl   (hdmi_iic_i_scl),
        .iic_i_sda   (hdmi_iic_i_sda),
        .iic_o_scl   (hdmi_iic_o_scl),
        .iic_o_sda   (hdmi_iic_o_sda)
    );

    // OV5640 to HDMI
    wire ddr_hsync ;
    wire ddr_vsync ;
    wire ddr_de    ;
    wire ddr_inited;

    wire [BITS-1:0] ddr_r;
    wire [BITS-1:0] ddr_g;
    wire [BITS-1:0] ddr_b;

    ov5640_to_hdmi #(
        .MEM_ROW_ADDR_WIDTH(MEM_ROW_ADDR_WIDTH),
        .MEM_COL_ADDR_WIDTH(MEM_COL_ADDR_WIDTH),
        .MEM_BADDR_WIDTH   (MEM_BADDR_WIDTH   ),
        .MEM_DQ_WIDTH      (MEM_DQ_WIDTH      ),
        .MEM_DQS_WIDTH     (MEM_DQS_WIDTH     )
    ) ov5640_to_hdmi (
        .clk25         (clk25      ),
        .clk50         (clk50      ),
        .cmos_init_done(cmos_inited),
        .cmos_scl      (cmos_scl   ),
        .cmos_sda      (cmos_sda   ),
        .cmos_vsync    (cmos_vsync ),
        .cmos_href     (cmos_href  ),
        .cmos_pclk     (cmos_pclk  ),
        .cmos_data     (cmos_data  ),
        .cmos_reset    (cmos_reset ),
        .mem_rst_n     (ddr_rst_n  ),
        .mem_ck        (ddr_ck     ),
        .mem_ck_n      (ddr_ck_n   ),
        .mem_cke       (ddr_cke    ),
        .mem_cs_n      (ddr_cs_n   ),
        .mem_ras_n     (ddr_ras_n  ),
        .mem_cas_n     (ddr_cas_n  ),
        .mem_we_n      (ddr_we_n   ),
        .mem_odt       (ddr_odt    ),
        .mem_a         (ddr_a      ),
        .mem_ba        (ddr_ba     ),
        .mem_dqs       (ddr_dqs    ),
        .mem_dqs_n     (ddr_dqs_n  ),
        .mem_dq        (ddr_dq     ),
        .mem_dm        (ddr_dm     ),
        .heart_beat_led(cmos_heart ),
        .ddr_init_done (ddr_inited ),
        .pix_clk       (pix_clk    ),
        .vs_out        (ddr_vsync  ),
        .hs_out        (ddr_hsync  ),
        .de_out        (ddr_de     ),
        .r_out         (ddr_r      ),
        .g_out         (ddr_g      ),
        .b_out         (ddr_b      )
    );

    wire [BITS-1:0] o_r;
    wire [BITS-1:0] o_g;
    wire [BITS-1:0] o_b;
    draw_window #(
        .BITS       (BITS       ),
        .V_TOTAL    (V_TOTAL    ),
        .V_FP       (V_FP       ),
        .V_BP       (V_BP       ),
        .V_SYNC     (V_SYNC     ),
        .V_ACT      (V_ACT      ),
        .H_TOTAL    (H_TOTAL    ),
        .H_FP       (H_FP       ),
        .H_BP       (H_BP       ),
        .H_SYNC     (H_SYNC     ),
        .H_ACT      (H_ACT      ),
        .V_BOX_WIDTH(V_BOX_WIDTH),
        .H_BOX_WIDTH(H_BOX_WIDTH),
        .N_BOX      (N_BOX      )
    ) draw_window (
        .pix_clk (pix_clk   ),
        .hsync   (ddr_hsync ),
        .vsync   (ddr_vsync ),
        .start_xs(/* TODO */),
        .start_ys(/* TODO */),
        .end_xs  (/* TODO */),
        .end_ys  (/* TODO */),
        .colors  (/* TODO */),
        .i_r     (ddr_r     ),
        .i_g     (ddr_g     ),
        .i_b     (ddr_b     ),
        .o_r     (o_r       ),
        .o_g     (o_g       ),
        .o_b     (o_b       )
    );

    assign hdmi_hsync = ddr_hsync ;
    assign hdmi_vsync = ddr_vsync ;
    assign hdmi_de    = ddr_de    ;

endmodule : AimBot
