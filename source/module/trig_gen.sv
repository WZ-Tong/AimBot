module trig_gen #(parameter TICK = 1) (
    input      clk   ,
    input      switch,
    output reg trig
);

    wire press  ;
    reg  press_d;

    rstn_gen #(.TICK(TICK)) u_rstn_gen (
        .clk   (clk   ),
        .i_rstn(switch),
        .o_rstn(press )
    );

    always_ff @(posedge clk) begin
        press_d <= #1 press;
        if (press_d==0 && press==1) begin
            trig <= #1 'b1;
        end else begin
            trig <= #1 'b0;
        end
    end

endmodule : trig_gen
