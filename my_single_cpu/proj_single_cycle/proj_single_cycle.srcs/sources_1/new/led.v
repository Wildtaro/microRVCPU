`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/03 22:47:23
// Design Name: 
// Module Name: led
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
module led(
    input  wire       clk,
    input  wire       rst,
    input  wire[31:0] addr,
    input  wire       we,
    input  wire[31:0] wdata,
    output reg [23:0] led
    );

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            led <= 32'd0;
        end else if(addr == `PERI_ADDR_LED) begin
            if(we) led <= wdata;
            else   led <= led;
        end
    end
endmodule
