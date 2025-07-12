`timescale 1ns / 1ps
`include "defines.vh"

module id_sext(
    input      [2 :0] op,
    input      [31:7] din  ,

    output reg [31:0] ext
);

//SEXT是符号扩展部件
//输入：指令中的立即数 (12bit或20bit) din
//输出：符号扩展之后的立即数 (32bit)  ext
always @(*) begin
    case (op)
        `EXT_I:ext = {{20{din[31]}}, din[31:20]};//高20位为符号位的重复拼接  20要加括号吗
		`EXT_S:ext = {{20{din[31]}}, din[31:25], din[11:7]};
		`EXT_B:ext = {{19{din[31]}}, din[31], din[7], din[30:25], din[11:8], 1'b0};//补0，这样就可以直接pc+offset了
		`EXT_U:ext = {din[31:12], 12'b0};//lui 清空低12位，装入高20位
		`EXT_J:ext = {{11{din[31]}}, din[31], din[19:12], din[20], din[30:21], 1'b0};
        default:    ext = 32'b0;
    endcase
end

endmodule
