`timescale 1ns / 1ps

module reg_id_ex(
    input             clk       ,
    input             rst_n     ,

    input             flush     ,
    input             stop     ,
	
    input      [31:0] id_pc     ,
	
    input             id_npco_sel,
    input      [1 :0] id_rf_wesl,
    input      [3 :0] id_alu_op ,
    input             id_dram_we,
    input      [1 :0] id_npc_op ,
	
    input      [31:0] id_ext    ,
    input      [31:0] id_aluA   ,
    input      [31:0] id_aluB   ,
    input      [31:0] id_rd2    ,
	
    input      [4 :0] id_wr     ,	//写回寄存器的编号
    input             id_we 	,	//寄存器写使能
	
	output reg [31:0] ex_pc     ,
    output reg        ex_npco_sel,
    output reg [1 :0] ex_rf_wesl,
    output reg [3 :0] ex_alu_op ,
    output reg        ex_dram_we,
    output reg [1 :0] ex_npc_op ,
	
    output reg [31:0] ex_ext    ,
    output reg [31:0] ex_aluA   ,
    output reg [31:0] ex_aluB   ,
    output reg [31:0] ex_rd2    ,
	
    output reg [4 :0] ex_wr     ,	//写回寄存器的编号
    output reg        ex_we		,//寄存器写使能

    input [31:0] id_final_rd1	,
    input [31:0] id_final_rd2	,
    output reg [31:0] ex_final_rd1,
    output reg [31:0] ex_final_rd2,//那ALUB和A是否就不用保存了


    input             id_have_inst ,	//trace
    output reg        ex_have_inst	//trace
);
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)    ex_dram_we <= 'b0        ;
    else if (flush)ex_dram_we <= 'b0        ;
	else if (stop) ex_dram_we <= ex_dram_we;//可能有问题
    else           ex_dram_we <= id_dram_we;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)    ex_have_inst <= 'b0        ;
    else if (flush)ex_have_inst <= 'b0        ;
	else if (stop) ex_have_inst <= ex_have_inst;//可能有问题
    else           ex_have_inst <= id_have_inst;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)    ex_final_rd1 <= 'b0        ;
    else if (flush)ex_final_rd1 <= 'b0        ;
	else if (stop) ex_final_rd1 <= ex_final_rd1;//可能有问题
    else           ex_final_rd1 <= id_final_rd1;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)    ex_final_rd2 <= 'b0        ;
    else if (flush)ex_final_rd2 <= 'b0        ;
	else if (stop) ex_final_rd2 <= ex_final_rd2;//可能有问题
    else           ex_final_rd2 <= id_final_rd2;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_pc <= 'b0    	;
    else if (flush) ex_pc <= 'b0    	;
	else if (stop) 	ex_pc <= ex_pc	;
    else            ex_pc <= id_pc		;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_npco_sel <= 'b0    	;
    else if (flush) ex_npco_sel <= 'b0    	;
	else if (stop) 	ex_npco_sel <= ex_npco_sel	;
    else            ex_npco_sel <= id_npco_sel	;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_rf_wesl <= 'b0    		;
    else if (flush) ex_rf_wesl <= 'b0    		;
	else if (stop) 	ex_rf_wesl <= ex_rf_wesl	;
    else            ex_rf_wesl <= id_rf_wesl	;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_alu_op <= 'b0    	;
    else if (flush) ex_alu_op <= 'b0    	;
	else if (stop) 	ex_alu_op <= ex_alu_op	;
    else            ex_alu_op <= id_alu_op	;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_npc_op <= 'b0    	;
    else if (flush) ex_npc_op <= 'b0    	;
	else if (stop) 	ex_npc_op <= ex_npc_op;
    else            ex_npc_op <= id_npc_op	;
end


always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_ext <= 'b0    	;
    else if (flush) ex_ext <= 'b0    	;
	else if (stop) 	ex_ext <= ex_ext;
    else            ex_ext <= id_ext	;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_aluA <= 'b0    ;
    else if (flush) ex_aluA <= 'b0    ;
	else if (stop) 	ex_aluA <= ex_aluA;
    else            ex_aluA <= id_aluA;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_aluB <= 'b0		;
    else if (flush) ex_aluB <= 'b0		;
	else if (stop) 	ex_aluB <= ex_aluB;
    else            ex_aluB <= id_aluB	;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_rd2 <= 'b0		;
    else if (flush) ex_rd2 <= 'b0		;
	else if (stop)  ex_rd2 <= ex_rd2;
    else            ex_rd2 <= id_rd2	;
end

//为了冒险检测
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_wr <= 'b0    ;
    else if (flush) ex_wr <= 'b0    ;
	else if (stop)  ex_wr <= ex_wr;
    else            ex_wr <= id_wr;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_we <= 'b0        ;
    else if (flush) ex_we <= 'b0        ;
	else if (stop)  ex_we <= ex_we;
    else            ex_we <= id_we;
end

//为什么这个停顿的时候也要变成0 呢 是不是要改
/*always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_pc <= 'b0    	;
    else if (flush) ex_pc <= 'b0    	;
    else            ex_pc <= id_pc		;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_npco_sel <= 'b0    	;
    else if (flush) ex_npco_sel <= 'b0    	;
    else            ex_npco_sel <= id_npco_sel	;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_rf_wesl <= 'b0    		;
    else if (flush) ex_rf_wesl <= 'b0    		;
    else            ex_rf_wesl <= id_rf_wesl	;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_alu_op <= 'b0    	;
    else if (flush) ex_alu_op <= 'b0    	;
    else            ex_alu_op <= id_alu_op	;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_npc_op <= 'b0    	;
    else if (flush) ex_npc_op <= 'b0    	;
    else            ex_npc_op <= id_npc_op	;
end


always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_ext <= 'b0    	;
    else if (flush) ex_ext <= 'b0    	;
    else            ex_ext <= id_ext	;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_aluA <= 'b0    ;
    else if (flush) ex_aluA <= 'b0    ;
    else            ex_aluA <= id_aluA;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)     ex_aluB <= 'b0		;
    else if (flush) ex_aluB <= 'b0		;
    else            ex_aluB <= id_aluB	;
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)    ex_rd2 <= 'b0		;
    else if (flush)ex_rd2 <= 'b0		;
    else           ex_rd2 <= id_rd2	;
end

//为了冒险检测
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)    ex_wr <= 'b0    ;
    else if (flush)ex_wr <= 'b0    ;
    else           ex_wr <= id_wr;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)    ex_we <= 'b0        ;
    else if (flush)ex_we <= 'b0        ;
    else           ex_we <= id_we;
end
*/

endmodule
