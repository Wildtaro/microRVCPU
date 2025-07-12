`timescale 1ns / 1ps

module if_pc(
    input             clk  ,
    input             rst_n,
    input      [31:0] din  , // next pc

    output reg [31:0] pc
);

//ʱ�ӵ������ظ���pc��  ����˵Ҫ�����ӳ�  ��ʹ֮�ܹ����½��ظ���PC �������ض�rf  
//7/5/9/23 ���� ����6-3 ��rf�Ķ�������Ϊ����߼� ʱ��Ϊ6-1��ʾ
always @(posedge clk, negedge rst_n) begin
    if(~rst_n)	pc <= -4;//7/6/15.00 ԭ����0 ��Ϊ��trace�ܼ�⵽ �Ÿ�Ϊ-4
    else		pc <= din;
end

endmodule
