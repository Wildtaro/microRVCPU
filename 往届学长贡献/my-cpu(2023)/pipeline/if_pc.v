`timescale 1ns / 1ps

module if_pc(
    input             clk  ,
    input             rst_n,
    input      [31:0] din  , // next pc

    output reg [31:0] pc
);

//时钟的上升沿更新pc吗  还是说要避免延迟  在使之能够在下降沿更新PC 在上升沿读rf  
//7/5/9/23 都不 采用6-3 讲rf的读操作改为组合逻辑 时序为6-1所示
always @(posedge clk, negedge rst_n) begin
    if(~rst_n)	pc <= -4;//7/6/15.00 原本是0 后为了trace能检测到 才改为-4
    else		pc <= din;
end

endmodule
