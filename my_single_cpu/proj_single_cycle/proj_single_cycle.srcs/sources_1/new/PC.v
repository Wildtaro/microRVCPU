`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/03 22:47:51
// Design Name: 
// Module Name: PC
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


module PC(
    input  wire       rst,
    input  wire       clk,
    input  wire[31:0] npc,
    output reg [31:0] pc
    );
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            pc <= 32'hfffffffc;
        end
        else begin
            pc <= npc;
        end
    end
endmodule
