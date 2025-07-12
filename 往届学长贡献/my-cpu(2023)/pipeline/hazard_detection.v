
module hazard_detection(
    input             clk         ,
    input             rst_n       ,

    input             is_jump  ,
    input      [4 :0] id_rs1     ,//rs1 寄存器编号 
    input      [4 :0] id_rs2     ,
    input      [31:0] id_rd1     ,
    input      [31:0] id_aluB    ,//rd1和alub都是选择之后的了
    input      [4 :0] mem_wr      ,
    input      [4 :0] wb_wr       ,//写回的寄存器编号
    input             mem_we  ,//寄存器写使能
    input             wb_we   ,//寄存器写使能

    input      		  mem_dram_we     ,//写回数据来源选择
    input      [31:0] mem_wd      ,//写回的数据
    input      [31:0] wb_wd       ,//写回的数据

    output reg [31:0] final_rd1  ,
    output reg [31:0] final_rd2  ,

    output reg        if_id_flush ,//if/id寄存器的清空信号 因为分支检测
    output reg        id_ex_flush,//id/ex寄存器的清空信号 因为分支检测
    output reg        pipeline_stop	//流水线暂停信号
);

//RAW:A ID/EX
wire rs1_id_ex_hazard = (ex_rd == id_rs1) && ex_we && ex_wr != 0;
wire rs2_id_ex_hazard = (ex_rd == id_rs2) && ex_we && alub_sel==`ALUB_RS2 && ex_wr != 0;
//RAW:B EX/MEM
wire rs1_id_mem_hazard = (mem_rd == id_rs1) && mem_we && mem_wr != 0;
wire rs2_id_mem_hazard = (mem_rd == id_rs2) && mem_we && mem_wr != 0 && alub_sel==`ALUB_RS2 ;
//RAW:C MEM/WB reg rd==ID.rs1/2
wire rs1_id_wb_hazard = (wb_rd == id_rs1) && wb_we && wb_wr != 0;//编号对得上，寄存器写使能为1，且写回的寄存器不是x0
wire rs2_id_wb_hazard = (wb_rd == id_rs2) && wb_we && wb_wr != 0 && alub_sel==`ALUB_RS2;

/*id_rf1:表示ID阶段的RS1寄存器的读标志信号，该信号用于标识ID阶段的RS1是否被读取
增加id_rf1和id_rf2信号是为了避免I型、U型和J型指令执行时出现RAW冒险的误判。
即若有ext替代rs2作为ALU.B的情况时，防止被误判
这个信号可由controller生成 其实也就是alub_sel id_rf1必为1 id—rf2==1即alub_sel==0`ALUB_RS2*/


//停止stop 不得不停 如 load-使用型冒险
wire load_hazard;
assign load_hazard = (rs1_id_ex_hazard || rs2_id_ex_hazard) &&  mem_dram_we == `DRAM_WY;

assign pipeline_stop = load_hazard ? 1:0;
assign if_id_flush = is_jump ? 1:0;
assign id_ex_flush = is_jump ? 1:0;
//分支检测产生信号只给IF/ID 和ID/EX

// 前递数据
/*将ex、MEM、WB阶段的结果前推到ID阶段，参与ID阶段运算 源操作数的选择*/
always @(*) begin
    if (rs1_id_ex_hazard)     	final_rd1 = ex_wd ;
    else if (rs1_id_mem_hazard) final_rd1 = mem_wd ;
    else if (rs1_id_wb_hazard) 	final_rd1 = wb_wd  ;
    else                        final_rd1 = id_rd1;//不前递的话 还是保持原来的rd1
end

always @(*) begin
    if (rs2_id_ex_hazard)     	final_rd2 = ex_wd ;
    else if (rs2_id_mem_hazard) final_rd2 = mem_wd ;
    else if (rs2_id_wb_hazard) 	final_rd2 = wb_wd  ;
    else                        final_rd2 = id_aluB;//不前递的话 还是保持原来的aluB
end

endmodule
