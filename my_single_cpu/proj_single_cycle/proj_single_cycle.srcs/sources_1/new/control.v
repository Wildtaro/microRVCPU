`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/03 22:46:20
// Design Name: 
// Module Name: control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module control(
    input  wire[6:0] opcode,
    input  wire[2:0] funct3,
    input  wire[6:0] funct7,
    output reg[1:0] ram_wdin_op,
    output reg[2:0] ram_rb_op,
    output reg ram_we,
    output reg pc_sel,
    output reg alub_sel,
    output reg alua_sel,
    output reg[3:0] alu_op,
    output reg[2:0] sext_op,
    output reg[1:0] rf_wsel,
    output reg rf_we,
    output reg[1:0] npc_op
    );

    parameter PC4 = 2'h0;
    parameter BEQ = 2'h1;
    parameter JMP = 2'h2;

    always @(*) begin
        case(opcode)
            7'b1100011: npc_op = BEQ;
            7'b1101111: npc_op = JMP;
            default: npc_op = PC4;
        endcase
    end

    always @(*) begin
        case(opcode)
            7'b0110011: rf_we = 1'b1;
            7'b0010011: rf_we = 1'b1;
            7'b0000011: rf_we = 1'b1;
            7'b1100111: rf_we = 1'b1;
            7'b0110111: rf_we = 1'b1;
            7'b0010111: rf_we = 1'b1;
            7'b1101111: rf_we = 1'b1;
            default:    rf_we = 1'b0;
        endcase
    end

    parameter WD_ALUC = 2'h0; // ALU ���
    parameter WD_RAM  = 2'h1; // ���ݴ洢������
    parameter WD_EXT  = 2'h2; // ��������չ�����LUI��
    parameter WD_PC4  = 2'h3; // PC+4��JAL��JALR��

    always@(*)begin
        case(opcode)
            7'b0110011: rf_wsel = WD_ALUC;
            7'b0010011: rf_wsel = WD_ALUC;
            7'b0000011: rf_wsel = WD_RAM;
            7'b1100111: rf_wsel = WD_PC4;
            7'b0110111: rf_wsel = WD_EXT;
            7'b0010111: rf_wsel = WD_ALUC;
            default:    rf_wsel = WD_PC4;
        endcase
    end

    parameter SEXT_I = 3'h0;
    parameter SEXT_S = 3'h1;
    parameter SEXT_B = 3'h2;
    parameter SEXT_U = 3'h3;
    parameter SEXT_J = 3'h4;

    always @(*) begin
        case(opcode)
            7'b0100011: sext_op = SEXT_S;
            7'b1100011: sext_op = SEXT_B;
            7'b0110111: sext_op = SEXT_U;
            7'b0010111: sext_op = SEXT_U;
            7'b1101111: sext_op = SEXT_J;
            default:    sext_op = SEXT_I;
        endcase
    end

    parameter ALU_ADD = 4'h0;
    parameter ALU_SUB = 4'h1;
    parameter ALU_AND = 4'h2;
    parameter ALU_OR  = 4'h3;
    parameter ALU_XOR = 4'h4;
    parameter ALU_SLL = 4'h5;
    parameter ALU_SRL = 4'h6;
    parameter ALU_SRA = 4'h7;
    parameter ALU_EQ  = 4'h8;
    parameter ALU_NE  = 4'h9;
    parameter ALU_LT  = 4'ha;
    parameter ALU_GE  = 4'hb;
    parameter ALU_LTU = 4'hc;
    parameter ALU_GEU = 4'hd;

    always @(*) begin
        case(opcode)
            7'b0110011: begin // R
                case(funct3)
                    3'b000:  alu_op = funct7[5] ? ALU_SUB : ALU_ADD;
                    3'b111:  alu_op = ALU_AND;
                    3'b110:  alu_op = ALU_OR;
                    3'b100:  alu_op = ALU_XOR;
                    3'b001:  alu_op = ALU_SLL;
                    3'b101:  alu_op = funct7[5] ? ALU_SRA : ALU_SRL;
                    3'b010:  alu_op = ALU_LT;
                    3'b011:  alu_op = ALU_LTU;
                    default: alu_op = ALU_ADD;
                endcase
            end
            7'b0010011: begin // I
                case(funct3)
                    3'b000:  alu_op = ALU_ADD;
                    3'b111:  alu_op = ALU_AND;
                    3'b110:  alu_op = ALU_OR;
                    3'b100:  alu_op = ALU_XOR;
                    3'b001:  alu_op = ALU_SLL;
                    3'b101:  alu_op = funct7[5] ? ALU_SRA : ALU_SRL;
                    3'b010:  alu_op = ALU_LT;
                    3'b011:  alu_op = ALU_LTU;
                    default: alu_op = ALU_ADD;
                endcase
            end
            7'b1100011: begin // b
                case(funct3)
                    3'b000:  alu_op = ALU_EQ;
                    3'b001:  alu_op = ALU_NE;
                    3'b100:  alu_op = ALU_LT;
                    3'b110:  alu_op = ALU_LTU;
                    3'b101:  alu_op = ALU_GE;
                    default: alu_op = ALU_GEU;
                endcase
            end
            7'b0000011: begin // lw
                alu_op = ALU_ADD;
            end
            7'b0100011: begin // sw
                alu_op = ALU_ADD;
            end
            7'b1100111: begin // jalr
                alu_op = ALU_ADD;
            end
            7'b0010111: begin // auipc
                alu_op = ALU_ADD;
            end
            default: alu_op = ALU_ADD;
        endcase
    end

    always@(*)begin 
        alua_sel = (opcode == 7'b0010111) ? 1'b1 : 1'b0;
    end

    always @(*) begin
        case(opcode)
            7'b0010011: alub_sel = 1;
            7'b0000011: alub_sel = 1;
            7'b1100111: alub_sel = 1;
            7'b0100011: alub_sel = 1;
            7'b0010111: alub_sel = 1;
            default:    alub_sel = 0;
        endcase
    end

    always @(*) begin
        pc_sel = (opcode == 7'b1100111) ? 1'b1 : 1'b0;
    end

    always @(*) begin
        ram_we = (opcode == 7'b0100011 | opcode == 7'b0010111) ? 1'b1 : 1'b0;
    end

    parameter WRAM_SB = 2'h0;
    parameter WRAM_SH = 2'h1;
    parameter WRAM_SW = 2'h2;

    always@(*)begin
        if(opcode == 7'b0100011)begin
            case(funct3)
                3'b000:  ram_wdin_op = WRAM_SB;
                3'b001:  ram_wdin_op = WRAM_SH;
                default: ram_wdin_op = WRAM_SW;
            endcase
        end
        else ram_wdin_op = WRAM_SW;
    end

    parameter RDO_LB  = 3'h0;
    parameter RDO_LBU = 3'h1;
    parameter RDO_LH  = 3'h2;
    parameter RDO_LHU = 3'h3;
    parameter RDO_LW  = 3'h4;
    
    always@(*)begin
        if(opcode == 7'b0000011) begin
            case(funct3)
                3'b000:  ram_rb_op = RDO_LB;
                3'b001:  ram_rb_op = RDO_LH;
                3'b100:  ram_rb_op = RDO_LBU;
                3'b101:  ram_rb_op = RDO_LHU;
                default: ram_rb_op = RDO_LW;
            endcase
        end
        else ram_rb_op = RDO_LW;
    end

endmodule
