// MS7210模块初始化

`timescale 1ns / 1ps

module hdmi_ctrl (
    input  clk10    ,
    input  rstn     ,
    output inited   ,

    output iic_rstn ,
    output iic_i_scl,
    inout  iic_i_sda,
    output iic_o_scl,
    inout  iic_o_sda
);

    localparam RSTN_HOLD_CNT = 10_000_000;

    rstn_gen #(.TICK(RSTN_HOLD_CNT)) ms72xx_rstn_gen (
        .clk   (clk10   ),
        .i_rstn(rstn    ),
        .o_rstn(iic_rstn)
    );

    ms72xx_ctl ms72xx_ctl (
        .clk       (clk10    ),
        .rst_n     (iic_rstn ),
        .init_over (inited   ),
        .iic_tx_scl(iic_o_scl),
        .iic_tx_sda(iic_o_sda),
        .iic_scl   (iic_i_scl),
        .iic_sda   (iic_i_sda)
    );

endmodule : hdmi_ctrl
