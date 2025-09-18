`timescale 1ns / 1ps

module ifetch(
    input             clk  ,
    input             rst_n,
    input      [31:0] ex_npc  , 
	input 		      is_jump,
    input             stop,

    output reg [31:0] pc
);
//wire pc4 = pc+4;
wire [31:0] din = is_jump ? ex_npc:pc+4; 

/*if_pc PC (
	.clk	(clk),
	.rst_n	(rst_n	),
	.din	(din	),
	
	.pc		(pc	)
);*/

always @(posedge clk, negedge rst_n) begin
    if(~rst_n)	pc <=-4;//7/13 11:23 -4 ->0
    else if(stop) pc <= pc;
    else		pc <= din;
end


endmodule
