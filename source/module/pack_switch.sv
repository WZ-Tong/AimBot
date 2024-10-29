module pack_switch (
    input         clk     ,
    input         rstn    ,
    input         key     ,
    input  [48:0] i_pack_1,
    input  [48:0] i_pack_2,
    output [48:0] o_pack
);

    wire switch;
    key_to_switch #(
        .TICK(50_000_000),
        .INIT(1'b1      )
    ) u_key_to_switch (
        .clk   (clk   ),
        .key   (key   ),
        .switch(switch)
    );

    assign o_pack = switch ? i_pack_1 : i_pack_2;

endmodule : pack_switch
