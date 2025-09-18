`timescale 1ns / 1ps

module DRAM(
    input  wire        clk,
    input  wire [31:0] adr,     // 实际有效的位宽与DRAM的容量有关
    output wire [31:0] rdout,
    input  wire        we,
    input  wire [31:0] wdin
);

    // inner logic of DRAM

endmodule
