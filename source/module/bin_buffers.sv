module bin_buffers #(
    parameter CAPACITY = 12'd1280,
    parameter PARALLEL = 5
) (
    input                 clk   ,
    input                 rstn  ,
    input                 bin   ,
    input                 de    ,
    input                 hsync ,
    input                 cls   ,
    output [PARALLEL-1:0] window
);

    reg [$clog2(CAPACITY)-1:0] addr;
    reg [$clog2(PARALLEL)-1:0] ptr ;

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            addr <= #1 'b0;
            ptr  <= #1 'b0;
        end else if (cls) begin
            addr <= #1 'b0;
            ptr  <= #1 'b0;
        end else if (hsync) begin
            addr <= #1 'b0;
            if (ptr!=PARALLEL-1) begin
                ptr <= #1 ptr + 1'b1;
            end else begin
                ptr <= #1 'b0;
            end
        end else if (addr!=CAPACITY-1 && de) begin
            addr <= #1 addr + 1'b1;
        end
    end

    genvar i;
    for (i = 0; i < PARALLEL; i=i+1) begin: g_rams
        reg  read;
        wire wen ;
        assign wen = ptr==i && de;

        reg [CAPACITY-1:0] ram;
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

    reg current;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            current <= #1 'b0;
        end else begin
            current <= #1 bin;
        end
    end

    if (PARALLEL==5) begin: g_temp_link_5
        reg [CAPACITY-1:0] temp_window;
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
            endcase
            temp_window[4] = current; // TODO: When hold, use g_rams.read
        end
        assign window = temp_window;
    end else begin: g_temp_link_unimpl
        err_mode not_yet_linked();
    end

endmodule : bin_buffers
