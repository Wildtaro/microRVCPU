`timescale 1ns / 1ps

module reg_pc(
    input             clk  ,
    input             rst_n,
    input      [31:0] din  , // next pc
    input             stop ,

    output reg [31:0] pc
);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)    pc <= -4;//32'b0
    else if (stop) pc <= pc ;
    else           pc <= din;
end

endmodule
