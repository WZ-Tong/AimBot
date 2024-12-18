module bin_buffer #(
    parameter WIDTH = 1280/16, // 80
    parameter ROWS  = 720/10   // 72
) (
    input             clk   ,
    input             rstn  ,
    input             valid ,
    input             bin   ,
    input             cls   ,
    input             next  ,

    output [ROWS-1:0] window
);

    reg [$clog2(WIDTH)-1:0] addr;
    reg [ $clog2(ROWS)-1:0] ptr ;

    reg next_d;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            next_d <= #1 'b0;
        end else begin
            next_d <= #1 next;
        end
    end

    wire next_r;
    assign next_r = next_d==0 && next==1;

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            addr <= #1 'b0;
            ptr  <= #1 'b0;
        end else if (cls) begin
            addr <= #1 'b0;
            ptr  <= #1 'b0;
        end else if (next_r) begin
            addr <= #1 'b0;
            if (ptr!=ROWS-1) begin
                ptr <= #1 ptr + 1'b1;
            end else begin
                ptr <= #1 'b0;
            end
        end else if (addr!=WIDTH-1 && valid) begin
            addr <= #1 addr + 1'b1;
        end
    end
    genvar i;
    for (i = 0; i < ROWS; i=i+1) begin: g_rams
        reg  read;
        wire wen ;
        assign wen = ptr==i && valid;
        reg [WIDTH-1:0] ram;
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
        assign window[i] = read;
    end

endmodule : bin_buffer
