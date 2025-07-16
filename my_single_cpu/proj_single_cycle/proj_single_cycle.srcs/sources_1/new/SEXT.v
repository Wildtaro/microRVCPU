`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/03 22:48:17
// Design Name: 
// Module Name: SEXT
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


module SEXT(
    input  wire[2:0]  op,
    input  wire[31:7] din,
    output reg [31:0] ext
    );

    // wire sign = din[31];
    parameter SEXT_I = 3'h0;
    parameter SEXT_S = 3'h1;
    parameter SEXT_B = 3'h2;
    parameter SEXT_U = 3'h3;
    parameter SEXT_J = 3'h4;

    always @(*) begin
        case(op)
            SEXT_I:  ext = {{20{din[31]}}, din[31:20]};
            SEXT_S:  ext = {{20{din[31]}}, din[31:25], din[11:7]};
            SEXT_B:  ext = {{19{din[31]}}, din[31], din[7], din[30:25], din[11:8], 1'b0};
            SEXT_U:  ext = {din[31:12], 12'h000};
            SEXT_J:  ext = {{11{din[31]}}, din[31], din[19:12], din[20], din[30:21], 1'b0};
            default: ext = 32'h0;
        endcase
    end



endmodule
