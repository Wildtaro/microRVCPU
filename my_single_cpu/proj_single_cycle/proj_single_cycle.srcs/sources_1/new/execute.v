`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/03 22:46:46
// Design Name: 
// Module Name: execute
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


module execute(
    input  wire[31:0] pc,
    input  wire[31:0] rD1,
    input  wire[31:0] rD2,
    input  wire[31:0] ext,
    input  wire[3:0]  alu_op,
    input  wire alua_sel,
    input  wire alub_sel,
    output wire[31:0] C,
    output wire f
    );

    wire[31:0] A;
    wire[31:0] B;
    
    assign A = alua_sel ? pc  : rD1;
    assign B = alub_sel ? ext : rD2;

    ALU alu_module(
        .A(A),
        .B(B),
        .op(alu_op),
        .C(C),
        .f(f)
    );
endmodule
