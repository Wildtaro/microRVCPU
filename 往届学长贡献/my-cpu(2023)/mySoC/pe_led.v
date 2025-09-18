`timescale 1ns / 1ps
//简单实现一下 应该是没用上
module pe_led(
    input wire clk,
	input wire rst,
	input wire [11:0] addr,//判断如果这个地址确实是led的地址060 

	input wire wen,//写使能
	input wire [31:0] data,//要显示的数据[31:0]
	output reg [23:0] led

	);
	
	wire enable_signal;//真正的写使能
	assign enable_signal = ((addr==12'h060) && (wen==1));
	

	always @ (posedge clk or posedge rst) begin
		if (rst)       
			led <=0;
		else if (enable_signal) begin
			led <= data[23:0];//直接取低24位的值赋值
		end
		else led<=led;//enable_signal=0 不写的时候 保持原状态
		
	end
	endmodule