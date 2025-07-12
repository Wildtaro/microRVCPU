`timescale 1ns / 1ps

`include "defines.vh"

module miniRV_SoC (
    input  wire         fpga_rst,   // High active
    input  wire         fpga_clk,

    input  wire [23:0]  sw,
    input  wire [ 4:0]  button,
    output wire [ 7:0]  dig_en,
    output wire         DN_A,
    output wire         DN_B,
    output wire         DN_C,
    output wire         DN_D,
    output wire         DN_E,
    output wire         DN_F,
    output wire         DN_G,
    output wire         DN_DP,
    output wire [23:0]  led

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst, // 当前时钟周期是否有指令写回 (对单周期CPU，可在复位后恒置1)
    output wire [31:0]  debug_wb_pc,        // 当前写回的指令的PC (若wb_have_inst=0，此项可为任意值)
    output              debug_wb_ena,       // 指令写回时，寄存器堆的写使能 (若wb_have_inst=0，此项可为任意值)
    output wire [ 4:0]  debug_wb_reg,       // 指令写回时，写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
    output wire [31:0]  debug_wb_value      // 指令写回时，写入寄存器的值 (若wb_ena或wb_have_inst=0，此项可为任意值)
`endif
);

    wire        pll_lock;
    wire        pll_clk;
    wire        cpu_clk;

    // Interface between CPU and IROM
`ifdef RUN_TRACE
    wire [15:0] inst_addr;
`else
    wire [13:0] inst_addr;
`endif
    wire [31:0] inst;

    // Interface between CPU and Bridge
    wire [31:0] Bus_rdata;
    wire [31:0] Bus_addr;
    wire        Bus_wen;
    wire [31:0] Bus_wdata;
    
    // Interface between bridge and DRAM
    // wire         rst_bridge2dram;
    wire         clk_bridge2dram;
    wire [31:0]  addr_bridge2dram;
    wire [31:0]  rdata_dram2bridge;
    wire         wen_bridge2dram;
    wire [31:0]  wdata_bridge2dram;
    
    // Interface between bridge and peripherals
    // TODO done: 在此定义总线桥与外设I/O接口电路模块的连接信号
    //输出：数码显示管dig
	wire         rst_bridge2dig;
	wire         clk_bridge2dig;
    wire [11:0]  addr_bridge2dig;
    wire         wen_bridge2dig;
    wire [31:0]  wdata_bridge2dig;
	//输出：LED显示
	wire         rst_bridge2led;
	wire         clk_bridge2led;
    wire [11:0]  addr_bridge2led;
    wire         wen_bridge2led;
    wire [31:0]  wdata_bridge2led;
	//输入：拨码开关
	wire         rst_bridge2sw;
    wire         clk_bridge2sw;
    wire [11:0]  addr_bridge2sw;
    wire [31:0]  rdata_sw2bridge;
	//输入：按键开关
	wire         rst_bridge2btn;
    wire         clk_bridge2btn;
    wire [11:0]  addr_bridge2btn;
    wire [31:0]  rdata_btn2bridge;
    

    
`ifdef RUN_TRACE
    // Trace调试时，直接使用外部输入时钟
    assign cpu_clk = fpga_clk;
`else
    // 下板时，使用PLL分频后的时钟
    assign cpu_clk = pll_clk & pll_lock;
    cpuclk Clkgen (
        // .resetn     (!fpga_rst),
        .clk_in1    (fpga_clk),
        .clk_out1   (pll_clk),
        .locked     (pll_lock)
    );
`endif
    
    myCPU Core_cpu (
        .cpu_rst            (fpga_rst),
        .cpu_clk            (cpu_clk),

        // Interface to IROM
        .inst_addr          (inst_addr),
        .inst               (inst),

        // Interface to Bridge
        .Bus_addr           (Bus_addr),
        .Bus_rdata          (Bus_rdata),
        .Bus_wen            (Bus_wen),
        .Bus_wdata          (Bus_wdata)

`ifdef RUN_TRACE
        ,// Debug Interface
        .debug_wb_have_inst (debug_wb_have_inst),
        .debug_wb_pc        (debug_wb_pc),
        .debug_wb_ena       (debug_wb_ena),
        .debug_wb_reg       (debug_wb_reg),
        .debug_wb_value     (debug_wb_value)
`endif
    );
    
    IROM Mem_IROM (
        .a          (inst_addr),
        .spo        (inst)
    );
    
    Bridge Bridge (       
        // Interface to CPU
        .rst_from_cpu       (fpga_rst),
        .clk_from_cpu       (cpu_clk),
        .addr_from_cpu      (Bus_addr),
        .wen_from_cpu       (Bus_wen),
        .wdata_from_cpu     (Bus_wdata),
        .rdata_to_cpu       (Bus_rdata),
        
        // Interface to DRAM
        // .rst_to_dram    (rst_bridge2dram),
        .clk_to_dram        (clk_bridge2dram),
        .addr_to_dram       (addr_bridge2dram),
        .rdata_from_dram    (rdata_dram2bridge),
        .wen_to_dram        (wen_bridge2dram),
        .wdata_to_dram      (wdata_bridge2dram),
        
        // Interface to 7-seg digital LEDs
        .rst_to_dig         (rst_bridge2dig	),
        .clk_to_dig         (clk_bridge2dig	),
        .addr_to_dig        (addr_bridge2dig),
        .wen_to_dig         (wen_bridge2dig	),
        .wdata_to_dig       (wdata_bridge2dig),

        // Interface to LEDs
        .rst_to_led         (rst_bridge2led	),
        .clk_to_led         (clk_bridge2led	),
        .addr_to_led        (addr_bridge2led),
        .wen_to_led         (wen_bridge2led	),
        .wdata_to_led       (wdata_bridge2led),

        // Interface to switches
        .rst_to_sw          (rst_bridge2sw),
        .clk_to_sw          (clk_bridge2sw),
        .addr_to_sw         (addr_bridge2sw),
        .rdata_from_sw      (rdata_sw2bridge),

        // Interface to buttons
        .rst_to_btn         (rst_bridge2btn),
        .clk_to_btn         (clk_bridge2btn),
        .addr_to_btn        (addr_bridge2btn),
        .rdata_from_btn     (rdata_btn2bridge)
    );

//下板需要减去0x0000 4000 trace验证等不用
wire [31:0] waddr_temp = addr_bridge2dram-32'h4000;

    DRAM Mem_DRAM (
        .clk        (clk_bridge2dram),
        .a          (waddr_temp[15:2]),
        .spo        (rdata_dram2bridge),
        .we         (wen_bridge2dram),
        .d          (wdata_bridge2dram)
    );
    
    // TODO: 在此实例化你的外设I/O接口电路模块
	// pe_digital(tube)  pe_led  pe_switch  pe_button


	wire [6:0] led_cx;	
	assign DN_A = led_cx[0];
	assign DN_B = led_cx[1];
	assign DN_C = led_cx[2];
	assign DN_D = led_cx[3];
	assign DN_E = led_cx[4];
	assign DN_F = led_cx[5];
	assign DN_G = led_cx[6];
	assign DN_DP = 1;//低电平有效 小数点始终不亮
	
	pe_digital DIGa (
        .rst        (rst_bridge2dig),
        .clk        (clk_bridge2dig),
        .addr       (addr_bridge2dig),//写数码管的地址[11:0]  判断如果这个地址确实是数码管的地址000 则有反应
        .wen        (wen_bridge2dig),//数码管的写使能
		.data       (wdata_bridge2dig),//要数码管显示的数据[31:0]
		
        .led_en     (dig_en),
        .led_cx     (led_cx)	
    );
	pe_led LEDs (//0xFFFF_F060
        .rst        (rst_bridge2led),
        .clk        (clk_bridge2led),
        .addr       (addr_bridge2led),//写数码管的地址[11:0]  判断如果这个地址确实是数码管的地址060 则有反应  
        .wen        (wen_bridge2led),//数码管的写使能
		.data       (wdata_bridge2led),//高电平有效[31:0]
		
        .led     (led)//[23:0] 输出 控制24个小led 高电平有效
    );
	
	pe_switch SWITCHes (//0xFFFF_F070
        .rst        (rst_bridge2sw),
        .clk        (clk_bridge2sw),
        .addr       (addr_bridge2sw),//写拨码开关的地址[11:0]  070
        .sw     (sw),//[23:0] 24个拨码开关的输入 高电平有效
		
		.data       (rdata_sw2bridge)//输出：从拨码开关中读到的数据
    );
	
	pe_button BUTTONs (//0xFFFF_F078
        .rst        (rst_bridge2btn),
        .clk        (clk_bridge2btn),
        .addr       (addr_bridge2btn),//写拨码开关的地址[11:0]  078
        .button     (button),//5 位 按键开关的输入[ 4:0]
		
		.data       (rdata_btn2bridge)//输出：从拨码开关中读到的数据
    );

endmodule
