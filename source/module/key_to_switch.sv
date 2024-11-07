module key_to_switch #(
    parameter TICK = 1   ,
    parameter INIT = 1'b0
) (
    input  clk   ,
    input  rstn  ,
    input  key   ,
    output switch
);
    reg  state  ;
    wire press  ;
    reg  press_d;
    rstn_gen #(.TICK(TICK)) u_rstn_gen (
        .clk   (clk  ),
        .i_rstn(key  ),
        .o_rstn(press)
    );

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            state   <= #1 ~INIT;
            press_d <= #1 1'b1;
        end else begin
            press_d <= #1 press;
            if (press_d==0 && press==1) begin
                state <= #1 ~state;
            end
        end
    end

    assign switch = state;

endmodule : key_to_switch
