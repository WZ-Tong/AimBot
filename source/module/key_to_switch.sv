module key_to_switch #(parameter TICK=1) (
    input  clk   ,
    input  key   ,
    output switch
);
    reg  state   = 0;
    wire press      ;
    reg  press_d    ;
    rstn_gen #(.TICK(TICK)) u_rstn_gen (
        .clk   (clk  ),
        .i_rstn(key  ),
        .o_rstn(press)
    );

    always_ff @(posedge clk) begin
        press_d <= #1 press;
        if (press_d==0 && press==1) begin
            state <= #1 ~state;
        end
    end

    assign switch = state;

endmodule : key_to_switch
