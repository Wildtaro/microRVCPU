`timescale 1ns / 1ps
`include "defines.vh"

module control #(
    parameter OPCODE_R      = 7'b0110011,
    parameter OPCODE_I      = 7'b0010011,
    parameter OPCODE_I_LOAD = 7'b0000011,
    parameter OPCODE_I_JALR = 7'b1100111,
    parameter OPCODE_S      = 7'b0100011,
    parameter OPCODE_B      = 7'b1100011,
    parameter OPCODE_U      = 7'b0110111,
    parameter OPCODE_J      = 7'b1101111,
	
	parameter FUNCT3_ADD    = 3'b000    ,
	parameter FUNCT3_SUB    = 3'b000    ,
	
    parameter FUNCT3_SLL    = 3'b001    ,
	
	parameter FUNCT3_SRL    = 3'b101    ,
	parameter FUNCT3_SRA    = 3'b101    ,

	parameter FUNCT3_XOR    = 3'b100    ,

	parameter FUNCT3_OR     = 3'b110    ,
    parameter FUNCT3_AND    = 3'b111    ,
	
    parameter FUNCT7_NR      = 7'b0000000,//normal R
    parameter FUNCT7_SUB_SRA = 7'b0100000,

		
    parameter FUNCT3_BEQ    = 3'b000    ,
    parameter FUNCT3_BNE    = 3'b001    ,
    parameter FUNCT3_BLT    = 3'b100    ,
    parameter FUNCT3_BGE    = 3'b101
)(
    input		[6:0] opcode	,
    input		[2:0] funct3	,
    input		[6:0] funct7	,

    output reg  [1:0] npc_op	,
    output            npco_sel  ,
    output      	  rf_we		,
    output reg  [1:0] rf_wesl	,
    output reg  [2:0] sext_op	,
    output reg  [3:0] alu_op	,
    output            alub_sel	,
    output            dram_we    
);

always @(*) begin
    case (opcode)
        OPCODE_R     : npc_op = `NPC_PC4;
        OPCODE_I_JALR: npc_op = `NPC_JMPR;
        OPCODE_B     : npc_op = `NPC_BEQ;
        OPCODE_J     : npc_op = `NPC_JMP;
        default:       npc_op = `NPC_PC4;
    endcase
end			

assign npco_sel = (opcode==OPCODE_I_JALR) ? `NPCO_ALU :`NPCO_SEXT;	
//��add�� Ӧ�ã�Ҳ��Ϊ0 ��������ν

assign rf_we = (opcode==OPCODE_S)||(opcode==OPCODE_B) ? `RF_WN:`RF_WY;

always @(*) begin
    case (opcode)
        OPCODE_I_LOAD: rf_wesl = `WB_DRAM;
        OPCODE_I_JALR  : rf_wesl = `WB_PC4;
        OPCODE_J     : rf_wesl = `WB_PC4;
        OPCODE_U     : rf_wesl = `WB_EXT;
        default:       rf_wesl = `WB_ALU;
    endcase
end		

always @(*) begin
    case (opcode)
        OPCODE_S : sext_op = `EXT_S;
        OPCODE_B : sext_op = `EXT_B;
        OPCODE_U : sext_op = `EXT_U;
        OPCODE_J : sext_op = `EXT_J;
        default:   sext_op = `EXT_I;
		//R��ָ��Ҳ����I����չ��  ��������ν
    endcase
end	

always @(*) begin
    if ((opcode == OPCODE_I || opcode == OPCODE_R)) begin
            case (funct3)
				FUNCT3_AND: alu_op = `ALU_AND;
				FUNCT3_OR : alu_op = `ALU_OR ;
				FUNCT3_XOR: alu_op = `ALU_XOR;
				FUNCT3_SLL: alu_op = `ALU_SLL;
				FUNCT3_ADD: alu_op= (opcode == OPCODE_R && funct7 == FUNCT7_SUB_SRA)?`ALU_SUB:`ALU_ADD;
				FUNCT3_SRL: alu_op= (funct7 == FUNCT7_SUB_SRA)?`ALU_SRA:`ALU_SRL;
			endcase
    end 
	else if (opcode == OPCODE_B) begin
        case (funct3)
				FUNCT3_BEQ: alu_op = `ALU_BEQ;
				FUNCT3_BNE: alu_op = `ALU_BNE;
				FUNCT3_BLT: alu_op = `ALU_BLT;
				FUNCT3_BGE: alu_op = `ALU_BGE;
		endcase
    end 
	else begin
        alu_op = `ALU_ADD;
    end
end

assign alub_sel = (opcode==OPCODE_I)||(opcode==OPCODE_I_JALR)||(opcode==OPCODE_I_LOAD)||(opcode==OPCODE_S) ? `ALUB_EXT:`ALUB_RS2;

assign dram_we = (opcode==OPCODE_S) ? `DRAM_WY:`DRAM_WN;

endmodule
