`timescale 1ns / 1ps
`include "defines.vh"

module if_npc(
    input      [1:0] op		,
    input      [31:0] pc	,
    input      br	,
    input      [31:0] offset, 

    output reg [31:0] npc   ,
    output     [31:0] pc4
);

// pc4
assign pc4 = pc + 32'h4;
// npc
always @(*) begin
    case (op)
        `NPC_PC4: 	npc = pc + 32'h4;
        `NPC_JMP: 	npc = pc + offset;
        `NPC_JMPR: 	npc = offset;
        `NPC_BEQ: 	
				begin 
					if(br) npc = pc + offset;
					else npc = pc + 32'h4;
				end
		//判断条件成立，则br=ALU.f=1,则跳转 不然就+4
		
        default:     npc = npc;
    endcase
end



endmodule
