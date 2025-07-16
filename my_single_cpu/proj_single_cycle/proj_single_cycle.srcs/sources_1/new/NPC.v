`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/03 22:47:44
// Design Name: 
// Module Name: NPC
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


module NPC(
    input  wire[31:0] PC,
    input  wire[31:0] offset,
    input  wire [1:0] op,
    input  wire       br,
    output reg [31:0] npc,
    output wire[31:0] pc4
    );

    parameter PC4 = 2'h0;
    parameter BEQ = 2'h1;
    parameter JMP = 2'h2;
    
    assign pc4 = PC + 3'd4;
    always @(*) begin
        case (op)
            PC4:     npc = pc4;
            BEQ:     npc = br ? PC + offset : pc4;
            JMP:     npc = PC + offset;
            default: npc = pc4;
        endcase
    end


endmodule
