`timescale 1ns / 1ps
`include "defines.vh"
//ALU NPC NPCO—MUX
module execute(
    input      [3 :0] alu_op,
	input      [1 :0] npc_op,
    input      [31:0] aluA	,
    input      [31:0] aluB	,
    input      [31:0] pc	,
    input      [31:0] ext	,
	
    output 			  is_jump,
    output reg [31:0] aluC	,
    output reg [31:0] npc   ,
    output     [31:0] pc4
);



reg aluf;
//NPCO—MUX
wire offset = (npco_sel==`NPCO_ALU) ? aluC : ext;//若npco_sel=1，则来自ALU.C

assign is_jump = (npc_op==`NPC_JMP || npc_op==`NPC_JMPR || (npc_op==`NPC_BEQ && aluf==1));//为了给分支冒险用

ex_alu ALU (
	.op	(alu_op	),
	.A	(aluA	),
	.B	(aluB	),
	.f	(aluf	),
	.C	(aluC	)
);
if_npc NPC (
	.op     (npc_op	),
	.pc   	(pc		),
	.br 	(aluf	),
	.offset	(offset	),
	
	.npc    (npc   	),
	.pc4    (pc4   	)
	
);


endmodule