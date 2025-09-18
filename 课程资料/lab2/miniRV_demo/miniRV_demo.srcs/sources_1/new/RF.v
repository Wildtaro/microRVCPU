`timescale 1ns / 1ps

module RF(
    input  wire        clk,

    input  wire [ 4:0] rR1,
    output reg  [31:0] rD1,
    
    input  wire [ 4:0] rR2,
    output reg  [31:0] rD2,
    
    input  wire        we,
    input  wire [ 4:0] wR,
    input  wire [31:0] wD
);

    // inner logic of RF

endmodule
