`timescale 1ns / 1ps

module Ctrl(
    input  wire [6:0] opcode,
    input  wire [6:0] funct7,
    input  wire [2:0] funct3,

    output wire       rf_we,

    output reg  [0:0] alu_op,
    output wire       alub_sel,
    
    output wire       ram_we
);

    // inner logic of CTRL

    wire r_typ = (opcode == 7'b0110011) ? 1'b1 : 1'b0;
    wire s_typ = (opcode == 7'b0100011) ? 1'b1 : 1'b0;

    wire inst_or = r_typ & (funct7 == 7'h0) & (funct3 == 3'b110);
    wire inst_sw = s_typ & (funct3 == 3'b010);

    assign rf_we    = inst_or ? 1'b1 : 1'b0;
    assign alub_sel = inst_sw ? 1'b1 : 1'b0;
    assign ram_we   = inst_sw ? 1'b1 : 1'b0;

    always @(*) begin
        if (inst_or)
            alu_op = `OP_OR;
        else if (inst_sw)
            alu_op = `OP_ADD;
    end

endmodule
