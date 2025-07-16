`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/03 22:48:34
// Design Name: 
// Module Name: sw
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


module sw(
    input  wire       clk,
    input  wire       rst,
    input  wire[31:0] addr,
    input  wire[23:0] sw,
    output wire[31:0] rdata
    );

    assign rdata = {8'd0, sw};
endmodule
