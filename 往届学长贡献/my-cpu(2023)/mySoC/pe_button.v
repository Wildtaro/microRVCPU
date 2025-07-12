`timescale 1ns / 1ps
//简单写写 应该是没用上
module pe_button(
    input wire clk,
	input wire rst,
	input wire [11:0] addr,//078

	input wire [4:0] button,//5 位 按键开关的输入[4:0]
	
	output reg [31:0] data//从拨码开关中读到的数据
	);
	
	wire enable_signal;//读使能
	assign enable_signal = (addr==12'h078);
	
//传出的data到底是什么呢 是什么样的形式呢 传进来的5位长的的输入又是什么形式呢 ？？？？？？？
	always @ (posedge clk or posedge rst) begin
		if (rst)       
			data <= 32'b0;
		else if (enable_signal) begin
		//以二进制原码的方式读入 赋值给低5位 高位清空
			data <= {8'b00000000,button[4:0]};
			
		end
		else data<=data;
		//enable_signal=0 不读的时候 保持原状态
	end
	
endmodule