`timescale 1ns / 1ps
`include "defines.vh"

module ex_alu(
    input      [3:0]  op,
    input      [31:0] A	,
    input      [31:0] B	,
    output reg		  f	,
    output reg [31:0] C
);


wire [4:0] shamt = B[4:0];

//把分支控制的特殊操作 拿出来 应该可以增加速度 可在此先不了 先在alu里全部完成看看

/*
beq x1 x2 label  x1与x2相等 则输出1  x1-x2
bne x1 x2 label  x1与x2不等 则输出1  
blt x1 x2 label  x1<x2 则输出1  
bge x1 x2 label  x1大于等于x2 则输出1  */

//alu 需要搞什么补码逻辑 移位器 之类的吗  
//复用sub，判断标志位又是何意

	
always @(*) begin
    case (op)
        `ALU_ADD: C = A + B ;
		`ALU_SUB: C = A - B ;
		`ALU_AND: C = A & B ;
		`ALU_OR : C = A | B ;
				        
		`ALU_XOR: C = A ^ B ;
		`ALU_SLL: C = A << shamt; 
		`ALU_SRL: C = A >> shamt ;
		`ALU_SRA: C = $signed(A) >>> shamt;

		`ALU_BEQ: if(A==B) f=1;else f=0;
		`ALU_BNE: if(A!=B) f=1;else f=0;
		`ALU_BLT: if($signed(A)<$signed(B))  f=1;else f=0;
		`ALU_BGE: if($signed(A)>=$signed(B)) f=1;else f=0;

        default:  begin C = C; f=f; end
    endcase
end

endmodule