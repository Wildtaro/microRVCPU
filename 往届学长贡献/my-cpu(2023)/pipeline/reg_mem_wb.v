`timescale 1ns / 1ps

module reg_mem_wb(
    input             clk	,
    input             rst_n	,
	input             stop  ,
	
	input      		  mem_we,
	input      [31:0] mem_wd,
	input      [4:0]  mem_wr,
	
	output     		  wb_we	,
	output reg [31:0] wb_wd	,
	output reg [4:0]  wb_wr	,
	//trace
	input      [31:0] mem_pc,
	output reg [31:0] wb_pc	,
    input             mem_have_inst ,
    output reg        wb_have_inst
);
///trace///
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) 	wb_have_inst <= 'b0         ;
    else if (stop)	wb_have_inst <= wb_have_inst  ;
    else        	wb_have_inst <= mem_have_inst;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) 	wb_pc <= 'b0    ;
    else if (stop)	wb_pc <= wb_pc  ;
    else        	wb_pc <= mem_pc	;
end
///trace///


always @(posedge clk or negedge rst_n) begin
    if (~rst_n) 	wb_we <= 'b0    ;
    else if (stop)	wb_we <= wb_we  ;
    else        	wb_we <= mem_we	;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) 	wb_wd <= 'b0    ;
	else if (stop)	wb_wd <= wb_wd  ;
    else        	wb_wd <= mem_wd	;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) 	wb_wr <= 'b0    ;
    else if (stop)	wb_wr <= wb_wr  ;
    else        	wb_wr <= mem_wr	;
end
endmodule
