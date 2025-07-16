// Annotate this macro before synthesis
// `define RUN_TRACE

// TODO: 在此处定义你的宏
`define PERI_ADDR_TIMER 32'hFFFF_F020   // 读取或修改32位计时器值
`define PERI_ADDR_FREQ  32'hFFFF_F024   // 设置计时器时钟的分频系数

// 外设I/O接口电路的端口地址
`define PERI_ADDR_DIG   32'hFFFF_F000
`define PERI_ADDR_LED   32'hFFFF_F060
`define PERI_ADDR_SW    32'hFFFF_F070
`define PERI_ADDR_BTN   32'hFFFF_F078
