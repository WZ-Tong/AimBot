module pack_switch #(
    parameter TICK  = 1   ,
    parameter H_ACT = 1280,
    parameter V_ACT = 720
) (
    input                                          clk     ,
    input                                          rstn    ,
    input                                          key     ,
    input  [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] i_pack_1,
    input  [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] i_pack_2,
    output [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] o_pack
);

    wire switch;
    key_to_switch #(
        .TICK(TICK),
        .INIT(1'b1)
    ) u_key_to_switch (
        .clk   (clk   ),
        .rstn  (rstn  ),
        .key   (key   ),
        .switch(switch)
    );

    assign o_pack = switch ? i_pack_1 : i_pack_2;

endmodule : pack_switch
