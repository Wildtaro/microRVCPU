`timescale 1ns / 1ps

module reg_if_id(
    input             clk    ,
    input             rst_n  ,

    input             pipeline_flush  ,//分支检测 pc next 异常
    input             pipeline_stop   ,//停顿

    input      [31:0] if_pc  ,
    input      [31:0] if_inst,

    output reg [31:0] id_pc  ,
    output reg [31:0] id_inst
);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)    			id_pc <= 'b0    ;
    else if (pipeline_flush)id_pc <= 'b0    ;
    else if (pipeline_stop) id_pc <= id_pc	;
    else           			id_pc <= if_pc	;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)    			id_inst <= 'b0		;
    else if (pipeline_flush)id_inst <= 'b0      ;
    else if (pipeline_stop) id_inst <= id_inst	;
    else           			id_inst <= if_inst	;
end

endmodule
