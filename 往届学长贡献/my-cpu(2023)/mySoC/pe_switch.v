`timescale 1ns / 1ps
module pe_switch(
    input wire clk,
	input wire rst,
	input wire [11:0] addr,//判断如果这个地址确实是switch的地址070 

	input wire [23:0] sw,//24个拨码开关的输入 高电平有效
	
	output reg [31:0] data//从拨码开关中读到的数据
	);
	
	wire enable_signal;//读使能
	assign enable_signal = (addr==12'h070);
	

	always @ (posedge clk or posedge rst) begin
		if (rst)       
			data <= 32'b0;
		else if (enable_signal) begin
		//以二进制原码的方式读入 赋值给低24位 高位清空
			data <= {8'b00000000,sw[23:0]};
		end
		else data<=data;//enable_signal=0 不读的时候 保持原状态
		
	end
	endmodule