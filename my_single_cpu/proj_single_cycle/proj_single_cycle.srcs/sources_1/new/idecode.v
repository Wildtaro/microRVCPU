`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/03 22:47:03
// Design Name: 
// Module Name: idecode
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


module idecode(
    input  wire[31:7] inst,       // ȡָ�׶δ�����ָ��� 25 λ��[31:7]��
    input  wire [2:0] sext_op,    // ��������չ����ѡ���ź�
    input  wire       rf_we,      // �Ĵ�����дʹ��
    input  wire [1:0] rf_wsel,    // �Ĵ���д������Դѡ��
    input  wire       clk,        // ʱ�ӣ����� RF д����
    input  wire[31:0] ALUC,       // ALU �������ֵ��������д�أ�
    input  wire[31:0] rdo,        // Load ָ����ڴ���ص�ֵ
    input  wire[31:0] pc4,        // PC+4��ͨ��������תָ���д�أ�
    output wire[31:0] rD1,        // �ӼĴ����Ѷ����� rs1 ����
    output wire[31:0] rD2,        // �ӼĴ����Ѷ����� rs2 ����
    output wire[31:0] ext,        // ��������չ��Ľ��
    output reg [31:0] wD          // д�ؼĴ����ѵ�����
    );

    parameter WD_ALUC = 2'h0;
    parameter WD_RAM  = 2'h1;
    parameter WD_EXT  = 2'h2;
    parameter WD_PC4  = 2'h3;

    always@(*)begin
        case(rf_wsel)
             WD_ALUC: begin
                wD = ALUC;
             end
             WD_RAM: begin
                wD = rdo;
             end
             WD_EXT: begin
                wD = ext;
             end
             WD_PC4: begin
                wD = pc4;
             end
             default: begin
                wD = 32'h0;
             end
        endcase
    end

    RF rf_module(
        .rR1(inst[19:15]),
        .rR2(inst[24:20]),
        .wR(inst[11:7]),
        .we(rf_we),
        .clk(clk),
        .wD(wD),
        .rD1(rD1),
        .rD2(rD2)
    );

    SEXT sext_module(
        .op(sext_op),
        .din(inst[31:7]),
        .ext(ext)
    );
endmodule
