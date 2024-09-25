module HdmiOutput (
   input        clk   ,
   input        rstn  ,

   output       pclk  , // HDMI显示图像: 像素时钟
   output       p_en  , // HDMI显示图像: 有效像素点使能信号
   output       h_sync, // HDMI显示图像: 行同步信号
   output       v_sync, // HDMI显示图像: 帧同步信号
   output [7:0] p_r   , // HDMI显示图像: 像素点位(R)
   output [7:0] p_g   , // HDMI显示图像: 像素点位(G)
   output [7:0] p_b   , // HDMI显示图像: 像素点位(B)

   output       m_rstn, // MS7210: 复位
   output       m_int , // MS7210: 输出中断
   output       m_scl , // MS7210: 控制通道IIC时钟
   output       m_sda , // MS7210: 控制通道IIC数据

   output       a_ws  , // 音频通道时钟
   output       a_0   , // 音频通道0
   output       a_1     // 音频通道1
);

endmodule
