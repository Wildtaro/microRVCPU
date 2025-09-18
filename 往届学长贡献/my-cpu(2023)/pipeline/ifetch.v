`timescale 1ns / 1ps

module ifetch(
    input             clk  ,
    input             rst_n,
    input      [31:0] ex_npc  , 
	input 		[1:0] npc_op,

    output reg [31:0] pc
);
wire pc4 = pc+4;
wire din = (npc_op==`NPC_PC4) ? pc4:ex_npc

if_pc PC (
	.clk	(cpu_clk),
	.rst_n	(rst_n	),
	.din	(din	),
	
	.pc		(pc	)
);
	

endmodule
