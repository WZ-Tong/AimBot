`timescale 1ns / 1ps

module ov5640_to_hdmi #(
    parameter MEM_ROW_ADDR_WIDTH = 15    ,
    parameter MEM_COL_ADDR_WIDTH = 10    ,
    parameter MEM_BADDR_WIDTH    = 3     ,
    parameter MEM_DQ_WIDTH       = 32    ,
    parameter MEM_DQS_WIDTH      = 32 / 8
) (
    input                               clk25         ,
    input                               clk50         ,

    output                              cmos_init_done, //OV5640寄存器初始化完成
    inout                               cmos_scl      , //cmos i2c
    inout                               cmos_sda      , //cmos i2c
    input                               cmos_vsync    , //cmos vsync
    input                               cmos_href     , //cmos hsync refrence,data valid
    input                               cmos_pclk     , //cmos pxiel clock
    input      [                   7:0] cmos_data     , //cmos data
    output                              cmos_reset    , //cmos reset

    output                              mem_rst_n     ,
    output                              mem_ck        ,
    output                              mem_ck_n      ,
    output                              mem_cke       ,
    output                              mem_cs_n      ,
    output                              mem_ras_n     ,
    output                              mem_cas_n     ,
    output                              mem_we_n      ,
    output                              mem_odt       ,
    output     [MEM_ROW_ADDR_WIDTH-1:0] mem_a         ,
    output     [   MEM_BADDR_WIDTH-1:0] mem_ba        ,
    inout      [    MEM_DQ_WIDTH/8-1:0] mem_dqs       ,
    inout      [    MEM_DQ_WIDTH/8-1:0] mem_dqs_n     ,
    inout      [      MEM_DQ_WIDTH-1:0] mem_dq        ,
    output     [    MEM_DQ_WIDTH/8-1:0] mem_dm        ,
    output reg                          heart_beat_led,
    output                              ddr_init_done ,

    output                              pix_clk       ,
    output reg                          vs_out        ,
    output reg                          hs_out        ,
    output reg                          de_out        ,
    output reg [                   7:0] r_out         ,
    output reg [                   7:0] g_out         ,
    output reg [                   7:0] b_out
);

    parameter CTRL_ADDR_WIDTH = MEM_ROW_ADDR_WIDTH + MEM_BADDR_WIDTH + MEM_COL_ADDR_WIDTH;
    parameter TH_1S           = 27'd33000000                                             ;

    reg  [15:0] rstn_1ms  ;
    wire        cmos_scl  ;
    wire        cmos_sda  ;
    wire        cmos_vsync;
    wire        cmos_href ;
    wire        cmos_pclk ;
    wire [ 7:0] cmos_data ;
    wire        cmos_reset;
    wire        initial_en;

    wire        cmos_href_16bit;
    wire [15:0] cmos_d_16bit   ;
    reg  [ 7:0] cmos_d_d0      ;
    reg         cmos_href_d0   ;
    reg         cmos_vsync_d0  ;
    wire        cmos_pclk_16bit;

    wire[15:0] cmos2_d_16bit ;
    wire       cmos2_href_16bit;
    reg  [7:0] cmos2_d_d0      ;
    reg        cmos2_href_d0   ;
    reg        cmos2_vsync_d0  ;
    wire       cmos2_pclk_16bit;
    wire[15:0] o_rgb565 ;

    wire        pclk_in_test;
    wire        vs_in_test  ;
    wire        de_in_test  ;
    wire [15:0] i_rgb565    ;
    wire        de_re       ;

    wire [ CTRL_ADDR_WIDTH-1:0] axi_awaddr     ;
    wire                        axi_awuser_ap  ;
    wire [                 3:0] axi_awuser_id  ;
    wire [                 3:0] axi_awlen      ;
    wire                        axi_awready    ;
    wire                        axi_awvalid    ;
    wire [  MEM_DQ_WIDTH*8-1:0] axi_wdata      ;
    wire [MEM_DQ_WIDTH*8/8-1:0] axi_wstrb      ;
    wire                        axi_wready     ;
    wire [                 3:0] axi_wusero_id  ;
    wire                        axi_wusero_last;
    wire [ CTRL_ADDR_WIDTH-1:0] axi_araddr     ;
    wire                        axi_aruser_ap  ;
    wire [                 3:0] axi_aruser_id  ;
    wire [                 3:0] axi_arlen      ;
    wire                        axi_arready    ;
    wire                        axi_arvalid    ;
    wire [  MEM_DQ_WIDTH*8-1:0] axi_rdata      ;
    wire                        axi_rvalid     ;
    wire [                 3:0] axi_rid        ;
    wire                        axi_rlast      ;

    reg [26:0] cnt  ;
    reg [15:0] cnt_1;

    power_on_delay power_on_delay_inst (
        .clk_50M     (clk50      ),
        .reset_n     (1'b1       ),
        .camera1_rstn(cmos_reset ),
        .camera2_rstn(cmos2_reset),
        .camera_pwnd (           ),
        .initial_en  (initial_en )
    );

    reg_config coms1_reg_config (
        .clk_25M      (clk25         ),
        .camera_rstn  (cmos_reset    ),
        .initial_en   (initial_en    ),
        .i2c_sclk     (cmos_scl      ),
        .i2c_sdat     (cmos_sda      ),
        .reg_conf_done(cmos_init_done),
        .reg_index    (              ),
        .clock_20k    (              )
    );

    always@(posedge cmos_pclk)
        begin
            cmos_d_d0     <= cmos_data    ;
            cmos_href_d0  <= cmos_href    ;
            cmos_vsync_d0 <= cmos_vsync   ;
        end

    cmos_8_16bit cmos_8_16bit (
        .pclk     (cmos_pclk      ),   //input
        .rst_n    (cmos_init_done ),   //input
        .pdata_i  (cmos_d_d0      ),   //input[7:0]
        .de_i     (cmos_href_d0   ),   //input
        .vs_i     (cmos_vsync_d0  ),   //input
        .pixel_clk(cmos_pclk_16bit),   //output
        .pdata_o  (cmos_d_16bit   ),   //output[15:0]
        .de_o     (cmos_href_16bit)    //output
    );

    assign pclk_in_test = cmos_pclk_16bit    ;
    assign vs_in_test   = cmos_vsync_d0      ;
    assign de_in_test   = cmos_href_16bit    ;
    assign i_rgb565     = {cmos_d_16bit[4:0],cmos_d_16bit[10:5],cmos_d_16bit[15:11]};//{r,g,b}

    fram_buf fram_buf (
        .ddr_clk    (core_clk       ),   //input                         ddr_clk,
        .ddr_rstn   (ddr_init_done  ),   //input                         ddr_rstn,
        //data_in
        .vin_clk    (pclk_in_test   ),   //input                         vin_clk,
        .wr_fsync   (vs_in_test     ),   //input                         wr_fsync,
        .wr_en      (de_in_test     ),   //input                         wr_en,
        .wr_data    (i_rgb565       ),   //input  [15 : 0]  wr_data,
        //data_out
        .vout_clk   (pix_clk        ),   //input                         vout_clk,
        .rd_fsync   (vs_o           ),   //input                         rd_fsync,
        .rd_en      (de_re          ),   //input                         rd_en,
        .vout_de    (de_o           ),   //output                        vout_de,
        .vout_data  (o_rgb565       ),   //output [PIX_WIDTH- 1'b1 : 0]  vout_data,
        .init_done  (init_done      ),   //output reg                    init_done,
        //axi bus
        .axi_awaddr (axi_awaddr     ),   // output[27:0]
        .axi_awid   (axi_awuser_id  ),   // output[3:0]
        .axi_awlen  (axi_awlen      ),   // output[3:0]
        .axi_awsize (               ),   // output[2:0]
        .axi_awburst(               ),   // output[1:0]
        .axi_awready(axi_awready    ),   // input
        .axi_awvalid(axi_awvalid    ),   // output
        .axi_wdata  (axi_wdata      ),   // output[255:0]
        .axi_wstrb  (axi_wstrb      ),   // output[31:0]
        .axi_wlast  (axi_wusero_last),   // input
        .axi_wvalid (               ),   // output
        .axi_wready (axi_wready     ),   // input
        .axi_bid    (4'd0           ),   // input[3:0]
        .axi_araddr (axi_araddr     ),   // output[27:0]
        .axi_arid   (axi_aruser_id  ),   // output[3:0]
        .axi_arlen  (axi_arlen      ),   // output[3:0]
        .axi_arsize (               ),   // output[2:0]
        .axi_arburst(               ),   // output[1:0]
        .axi_arvalid(axi_arvalid    ),   // output
        .axi_arready(axi_arready    ),   // input
        .axi_rready (               ),   // output
        .axi_rdata  (axi_rdata      ),   // input[255:0]
        .axi_rvalid (axi_rvalid     ),   // input
        .axi_rlast  (axi_rlast      ),   // input
        .axi_rid    (axi_rid        )    // input[3:0]
    );

    always@(posedge pix_clk) begin
        r_out  <= {o_rgb565[15:11],3'b0   };
        g_out  <= {o_rgb565[10:5],2'b0    };
        b_out  <= {o_rgb565[4:0],3'b0     };
        vs_out <= vs_o;
        hs_out <= hs_o;
        de_out <= de_o;
    end

    sync_vg sync_vg (
        .clk   (pix_clk  ),
        .rstn  (init_done),
        .vs_out(vs_o     ),
        .hs_out(hs_o     ),
        .de_out(         ),
        .de_re (de_re    )
    );

    DDR3_50H u_DDR3_50H (
        .ref_clk                (clk50          ),
        .resetn                 (rstn_out       ),
        .ddr_init_done          (ddr_init_done  ),
        .ddrphy_clkin           (core_clk       ),
        .pll_lock               (pll_lock       ),
        .axi_awaddr             (axi_awaddr     ),
        .axi_awuser_ap          (1'b0           ),
        .axi_awuser_id          (axi_awuser_id  ),
        .axi_awlen              (axi_awlen      ),
        .axi_awready            (axi_awready    ),
        .axi_awvalid            (axi_awvalid    ),
        .axi_wdata              (axi_wdata      ),
        .axi_wstrb              (axi_wstrb      ),
        .axi_wready             (axi_wready     ),
        .axi_wusero_id          (               ),
        .axi_wusero_last        (axi_wusero_last),
        .axi_araddr             (axi_araddr     ),
        .axi_aruser_ap          (1'b0           ),
        .axi_aruser_id          (axi_aruser_id  ),
        .axi_arlen              (axi_arlen      ),
        .axi_arready            (axi_arready    ),
        .axi_arvalid            (axi_arvalid    ),
        .axi_rdata              (axi_rdata      ),
        .axi_rid                (axi_rid        ),
        .axi_rlast              (axi_rlast      ),
        .axi_rvalid             (axi_rvalid     ),
        .apb_clk                (1'b0           ),
        .apb_rst_n              (1'b1           ),
        .apb_sel                (1'b0           ),
        .apb_enable             (1'b0           ),
        .apb_addr               (8'b0           ),
        .apb_write              (1'b0           ),
        .apb_ready              (               ),
        .apb_wdata              (16'b0          ),
        .apb_rdata              (               ),
        .apb_int                (               ),
        .mem_rst_n              (mem_rst_n      ),
        .mem_ck                 (mem_ck         ),
        .mem_ck_n               (mem_ck_n       ),
        .mem_cke                (mem_cke        ),
        .mem_cs_n               (mem_cs_n       ),
        .mem_ras_n              (mem_ras_n      ),
        .mem_cas_n              (mem_cas_n      ),
        .mem_we_n               (mem_we_n       ),
        .mem_odt                (mem_odt        ),
        .mem_a                  (mem_a          ),
        .mem_ba                 (mem_ba         ),
        .mem_dqs                (mem_dqs        ),
        .mem_dqs_n              (mem_dqs_n      ),
        .mem_dq                 (mem_dq         ),
        .mem_dm                 (mem_dm         ),
        //debug
        .debug_data             (               ),
        .debug_slice_state      (               ),
        .debug_calib_ctrl       (               ),
        .ck_dly_set_bin         (               ),
        .force_ck_dly_en        (1'b0           ),
        .force_ck_dly_set_bin   (8'h05          ),
        .dll_step               (               ),
        .dll_lock               (               ),
        .init_read_clk_ctrl     (2'b0           ),
        .init_slip_step         (4'b0           ),
        .force_read_clk_ctrl    (1'b0           ),
        .ddrphy_gate_update_en  (1'b0           ),
        .update_com_val_err_flag(               ),
        .rd_fake_stop           (1'b0           )
    );

    always@(posedge core_clk) begin
        if (!ddr_init_done)
            cnt <= 27'd0;
        else if ( cnt >= TH_1S )
            cnt <= 27'd0;
        else
            cnt <= cnt + 27'd1;
    end

    always @(posedge core_clk)
        begin
            if (!ddr_init_done)
                heart_beat_led <= 1'd1;
            else if ( cnt >= TH_1S )
                heart_beat_led <= ~heart_beat_led;
        end

endmodule : ov5640_to_hdmi
