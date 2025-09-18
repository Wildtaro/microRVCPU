`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/11 08:45:33
// Design Name: 
// Module Name: timer
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

`include "defines.vh"
module timer(
    input  wire       clk,      // ϵͳʱ��
    input  wire       rst,      // ϵͳ��λ
    input  wire       we,       // дʹ�ܣ��ߵ�ƽд
    input  wire[31:0] addr,     // ��ַ����
    input  wire[31:0] wdata,    // д����
    output reg [31:0] rdata     // ������
    );


    reg [31:0] cnt;
    reg [31:0] timer_cnt;
    reg [31:0] freq_div;
    wire[31:0] cnt_max;


    always @(posedge clk or posedge rst) begin 
        if(rst) begin
            freq_div  <= 32'd0;
            cnt       <= 32'd0;
            timer_cnt <= 32'd0;
        end else if(we) begin
            case (addr)
                `PERI_ADDR_TIMER: timer_cnt <= wdata;
                `PERI_ADDR_FREQ:  freq_div  <= wdata;
                default: ;
            endcase
        end else begin
            if(cnt == cnt_max) begin
                cnt <= 32'd0;
                timer_cnt <= timer_cnt + 32'd1;
            end else begin
                cnt <= cnt + 32'd1;
                timer_cnt <= timer_cnt;
            end
        end
    end
    assign cnt_max = (freq_div == 0) ? 32'd1 : (32'd1000000000 / freq_div);

    // ������
    always @(*) begin
        if(!we) begin
            case(addr)
                `PERI_ADDR_TIMER: rdata = timer_cnt;
                default:          rdata = 32'd0;
            endcase
        end else begin
            rdata = 32'd0;
        end
    end

endmodule
