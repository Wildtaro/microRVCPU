`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/03 22:47:33
// Design Name: 
// Module Name: memory
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


module memory(
    input  wire[2:0]  ram_rb_op,     // ��ȡ��������
    input  wire[1:0]  ram_wdin_op,   // д���������
    input  wire[31:0] ALUC,          // ALU ������ĵ�ַ
    input  wire[31:0] Bus_rdata,     // ���ⲿ���߶��ص� 32 λ����
    input  wire[31:0] din,           // Ҫд������ݣ���λ��Ч��
    input  wire       ram_we,        // дʹ�ܣ�����Ч
    input  wire       clk,           // ʱ��
    output wire       Bus_we,        // �ⲿ����дʹ��
    output wire[31:0] Bus_addr,      // �ⲿ���ߵ�ַ
    output reg [31:0] rdo,           // �����ͻؼĴ���������
    output reg [31:0] Bus_wdata      // Ҫ�����ⲿ���ߵ�д����
    );

    assign Bus_addr = ALUC;
    assign Bus_we = ram_we;

    parameter WRAM_SB = 2'h0;
    parameter WRAM_SH = 2'h1;
    parameter WRAM_SW = 2'h2;
    parameter RDO_LB  = 3'h0;  // �������ֽ�
    parameter RDO_LBU = 3'h1;  // �޷����ֽ�
    parameter RDO_LH  = 3'h2;  // �����Ű���
    parameter RDO_LHU = 3'h3;  // �޷��Ű���
    parameter RDO_LW  = 3'h4;  // ��

    always @(*) begin 
        case(ram_wdin_op)
            WRAM_SW: Bus_wdata = din;   // ��д��ֱ�Ӱ� 32 λ din ȫ��д��
            WRAM_SB: begin              // �ֽ�д�����ݵ�ַ����λֻ�滻��Ӧ�ֽ�
                case(ALUC[1:0])
                    2'h0:    Bus_wdata = {Bus_rdata[31:8],  din[7:0]};                 // byte0
                    2'h1:    Bus_wdata = {Bus_rdata[31:16], din[7:0], Bus_rdata[7:0]}; // byte1
                    2'h2:    Bus_wdata = {Bus_rdata[31:24], din[7:0], Bus_rdata[15:0]};// byte2
                    default: Bus_wdata = {din[7:0], Bus_rdata[23:0]};                  // byte3
                endcase
            end
            WRAM_SH: begin
                case(ALUC[1])           // ����д�����ݵ�ַλ [1] ֻ�滻�ͻ�� 16 λ
                    1'h0:    Bus_wdata = {Bus_rdata[31:16], din[15:0]};
                    default: Bus_wdata = {din[15:0], Bus_rdata[15:0]};
                endcase
            end
            default: Bus_wdata = din;
        endcase
    end

    always @(*) begin 
        case(ram_rb_op)
            RDO_LW: rdo = Bus_rdata;    // ֱ�ӷ������� 32 λ
            RDO_LB: begin
                case(ALUC[1:0])
                    2'h0:    rdo = {{24{Bus_rdata[7]}},  Bus_rdata[7:0]};
                    2'h1:    rdo = {{24{Bus_rdata[15]}}, Bus_rdata[15:8]};
                    2'h2:    rdo = {{24{Bus_rdata[23]}}, Bus_rdata[23:16]};
                    default: rdo = {{24{Bus_rdata[31]}}, Bus_rdata[31:24]};
                endcase
            end
            RDO_LBU: begin              // �޷����ֽڣ�����չ
                case(ALUC[1:0])
                    2'h0:    rdo = {24'd0, Bus_rdata[7:0]};
                    2'h1:    rdo = {24'd0, Bus_rdata[15:8]};
                    2'h2:    rdo = {24'd0, Bus_rdata[23:16]};
                    default: rdo = {24'd0, Bus_rdata[31:24]};
                endcase
            end
            RDO_LH: begin               // �����Ű��֣��� ALUC[1] ѡ��ͣ��� 16 λ��������չ
                case(ALUC[1])
                    1'b0:    rdo = {{16{Bus_rdata[15]}}, Bus_rdata[15:0]};
                    default: rdo = {{16{Bus_rdata[31]}}, Bus_rdata[31:16]};
                endcase
            end
            RDO_LHU: begin               // �޷��Ű��֣�����չ
                case(ALUC[1])
                    1'b0:    rdo = {16'd0, Bus_rdata[15:0]};
                    default: rdo = {16'd0, Bus_rdata[31:16]};
                endcase
            end
            default: rdo = Bus_rdata;
        endcase
    end
endmodule
