`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 时钟模块仿真
// 
// Create Date: 2023/06/30 11:08:01
// Module Name: cpuclk_sim
// 注意事项：
// 将cpuclk_sim文件设置为顶层文件，右键点击cpuclk_sim.v，在弹出的菜单中选择Set as Top以将其设置为顶层文件
// 由于PLL锁相环需要一定的初始化时间，因此仿真时，需要按下快捷键Shift+F2以多运行5us，才能看到cpu_clk的波形输出。
//////////////////////////////////////////////////////////////////////////////////


module cpuclk_sim();
    // input
    reg fpga_clk = 0;
    // output
    wire clk_lock;
    wire pll_clk;
    wire cpu_clk;

    always #5 fpga_clk = ~fpga_clk;

    cpuclk UCLK (
        .clk_in1    (fpga_clk),
        .locked     (clk_lock),
        .clk_out1   (pll_clk)
    );

    assign cpu_clk = pll_clk & clk_lock;

endmodule