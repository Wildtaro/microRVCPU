`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/03 22:45:39
// Design Name: 
// Module Name: ALU
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


module ALU(
    input  wire[31:0] A,
    input  wire[31:0] B,
    input  wire[3:0] op,
    output wire f,
    output wire[31:0] C
    );

    reg[31:0] result_C;
    reg result_f;

    assign C = result_C;
    assign f = result_f;

    parameter ALU_ADD = 4'h0;
    parameter ALU_SUB = 4'h1;
    parameter ALU_AND = 4'h2;
    parameter ALU_OR  = 4'h3;
    parameter ALU_XOR = 4'h4;
    parameter ALU_SLL = 4'h5;
    parameter ALU_SRL = 4'h6;
    parameter ALU_SRA = 4'h7;
    parameter ALU_EQ  = 4'h8;
    parameter ALU_NE  = 4'h9;
    parameter ALU_LT  = 4'ha;
    parameter ALU_GE  = 4'hb;
    parameter ALU_LTU = 4'hc;
    parameter ALU_GEU = 4'hd;
    
    always @(*) begin 
        case (op)
            ALU_ADD: begin
                result_C = A + B;
                result_f = 1'b0;
            end
            ALU_SUB: begin
                result_C = A - B;
                result_f = 1'b0;
            end
            ALU_AND: begin
                result_C = A & B;
                result_f = 1'b0;
            end
            ALU_OR : begin
                result_C = A | B;
                result_f = 1'b0;
            end
            ALU_XOR: begin
                result_C = A ^ B;
                result_f = 1'b0;
            end
            ALU_SLL: begin
                result_C = A << B[4:0];
                result_f = 1'b0;
            end
            ALU_SRL: begin
                result_C = A >> B[4:0];
                result_f = 1'b0;
            end
            ALU_SRA: begin
                result_C = $signed(A) >>> B[4:0];
                result_f = 1'b0;
            end
            ALU_EQ : begin
                result_C = 32'b0;
                result_f = (A == B);
            end
            ALU_NE : begin
                result_C = 32'b0;
                result_f = (A != B);
            end
            ALU_LT : begin
                result_C = ($signed(A) < $signed(B));
                result_f = ($signed(A) < $signed(B));
            end
            ALU_GE : begin
                result_C = ($signed(A) >= $signed(B));
                result_f = ($signed(A) >= $signed(B));
            end
            ALU_LTU: begin
                result_C = (A < B);
                result_f = (A < B);
            end
            ALU_GEU: begin
                result_C = (A >= B);
                result_f = (A >= B);
            end
            default: begin
                result_C = 32'h0;
                result_f = 1'b0;
            end
        endcase
    end


endmodule
