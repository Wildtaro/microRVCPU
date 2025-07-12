`timescale 1ns / 1ps
`include "defines.vh"

module wb_mux(
    input       [1:0]  rf_wesl  ,
    input       [31:0] aluC	    ,
    input       [31:0] dram_rdo ,
    input       [31:0] ext ,
    input       [31:0] pc4      ,
    output reg  [31:0] wd
);

always @(*) begin
    case (rf_wesl)
        `WB_ALU : wd = aluC;
        `WB_DRAM: wd = dram_rdo;
        `WB_EXT : wd = ext;
        `WB_PC4 : wd = pc4;
        default: wd = wd;
    endcase
end	
endmodule
//MUX-rf_wesl //选择写回内容来自于哪里 

