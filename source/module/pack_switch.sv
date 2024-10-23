module pack_switch (
    input         clk     ,
    input         switch  ,
    input  [49:0] i_pack_1,
    input  [49:0] i_pack_2,
    output [49:0] o_pack
);

    reg state = 0;

    reg press_d;
    rstn_gen #(.TICK(5_000_000)) u_rstn_gen (
        .clk   (clk   ),
        .i_rstn(switch),
        .o_rstn(press)
    );

    always_ff @(posedge clk) begin
        press_d <= #1 press;
        if (press_d==0 && press==1) begin
            state <= #1 ~state;
        end
    end

    assign o_pack = state ? i_pack_1 : i_pack_2;

endmodule : pack_switch
