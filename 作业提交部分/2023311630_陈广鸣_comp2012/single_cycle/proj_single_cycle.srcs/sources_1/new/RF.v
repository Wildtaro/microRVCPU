`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/03 22:48:08
// Design Name: 
// Module Name: RF
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


module RF(
    input  wire clk,
    input  wire we,
    input  wire[4:0] rR1,
    input  wire[4:0] rR2,
    input  wire[4:0] wR,
    input  wire[31:0] wD,
    output reg[31:0] rD1,
    output reg[31:0] rD2
    );

    reg[31:0] regts[1:31];
    always @(*) begin
        rD1 = (rR1 == 5'h0) ? 32'd0 : regts[rR1];
    end

    always @(*) begin
        rD2 = (rR2 == 5'h0) ? 32'd0 : regts[rR2];
    end
    
    always @(posedge clk) begin
        if(we & (wR != 5'h0)) begin
            regts[wR] <= wD;
        end
    end


endmodule
