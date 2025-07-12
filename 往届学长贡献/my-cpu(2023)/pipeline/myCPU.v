`timescale 1ns / 1ps

`include "defines.vh"

module myCPU (
    input  wire         cpu_rst,
    input  wire         cpu_clk,

    // Interface to IROM
    output wire [13:0]  inst_addr,	//指令的地址，cpu输出给IROM
    input  wire [31:0]  inst,		//指令的内容，IROM给cpu的输入
    
    // Interface to Bridge       //就是与DRAM及外设如数码管打交道的
    output wire [31:0]  Bus_addr,	//外设的地址
    input  wire [31:0]  Bus_rdata,	//外设读出的内容
    output wire         Bus_wen,	//外设的写使能
    output wire [31:0]  Bus_wdata	//要外设写的内容

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output              debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
`endif
);

    // TODO: 完成你自己的单周期CPU设计
	
//IF所需信号 
wire        br;
wire [31:0] pc4  ;
wire [31:0] pc   ;
wire [31:0] npc  ;
wire [31:0] offset ;

//IF/ID reg
wire [31:0] if_inst = inst;
wire [31:0] id_inst;

//  ID & WB
wire [31:0] rd1;
wire [31:0] rd2;
wire [31:0] wd ;
wire [31:0] ext;

//  EX
//wire [31:0] aluA;
wire [31:0] aluB;
wire  		aluf;
wire [31:0] aluC;

//  MEM 
wire [31:0] dram_rdo;

// control  8
wire npco_sel,rf_we, alub_sel, dram_we;
wire [1:0] npc_op ;//4
wire [1:0] rf_wesl ;//4
wire [2:0] sext_op;//5
wire [3:0] alu_op;//11

wire rst_n;
assign rst_n = ~cpu_rst;

// hazard 
wire pipeline_stop;
wire pipeline_flush;
wire is_jump;
// forward signals
//wire [31:0] mem_wd;
wire [31:0] final_rd1;
wire [31:0] final_rd2;

//因为流水线寄存器而多出来的信号
wire 		id_we, ex_we, mem_we, wb_we;//寄存器写使能
wire [4: 0] id_wr, ex_wr, mem_wr, wb_wr;//寄存器写编号
wire [31:0] mem_wd, wb_wd;//寄存器写数据


wire [31:0] ex_aluC, mem_aluC;
wire [31:0] ex_pc4, mem_pc4;
wire [31:0] id_dram_we, ex_dram_we, mem_dram_we;//数据存储器写使能
wire [31:0] id_ext, ex_ext, mem_ext;

wire [31:0] id_rd2, ex_rd2, mem_rd2;//rd2 值
wire [31:0] id_rf_wesl, ex_rf_wesl, mem_rf_wesl;//寄存器写选择

wire [31:0] if_pc, id_pc, ex_pc;
wire [31:0] id_alu_op, ex_alu_op;
wire [31:0] id_npco_sel, ex_npco_sel;

wire [31:0] id_npc_op, ex_npc_op;//特殊 再看看
wire [31:0] ex_npc;//特殊 再看看
wire [31:0] id_rd1, ex_rd1;
wire [31:0] id_aluB, ex_aluB;

wire [31:0] if_inst, id_inst;
//for hazard
wire [4: 0] id_rs1,id_rs2;



hazard_detection HD (
	.clk      		(clk      		),
	.rst_n          (rst_n         	),
	.is_jump      	(is_jump		),//改为 静态分支预测 预测不发生跳转
	.id_rs1         (id_rs1        	),
	.id_rs2         (id_rs2        	),
	.id_rd1         (id_rd1        	),
	.id_aluB        (id_aluB        ),
    .mem_wr         (mem_wr        	),
	.mem_we  	    (mem_we  	   	),
	.wb_we   	    (wb_we   	   	),
	.dram_we        (mem_dram_we	),
	.mem_wd         (mem_wd        	),
	.wb_wd          (wb_wd         	),
	.final_rd1      (final_rd1     	),
	.final_rd2      (final_rd2     	),
	.pipeline_flush (pipeline_flush	),
	.pipeline_stop  (pipeline_stop 	)
); 


//取指IF
ifetch IF (
	.clk	(cpu_clk),
	.rst_n	(rst_n	),
	.ex_npc	(ex_npc	),//特殊
	.npc_op	(id_npc_op),//特殊
	.pc		(if_pc	)
);
	
assign inst_addr = pc[15:2];  //32bits-》14

//IF/ID pipeline reg
reg_if_id IF_ID_REG(
	clk    			(clk    		),
	rst_n           (rst_n         	),
	pipeline_flush  (pipeline_flush	),
	pipeline_stop   (pipeline_stop 	),
	if_pc           (if_pc         	),
	if_inst         (if_inst       	),
	id_pc           (id_pc         	),
	id_inst         (id_inst       	)
);


//译码ID

//ID
idecode ID (
	.clk      	(clk     	),
	.rst_n    	(rst_n   	),
	.inst     	(inst    	),
	.wb_wd    	(wb_wd   	),
	.wb_wr    	(wb_wr   	),
	.wb_we		(wb_we	 	),
							 
 	.rs1        (id_rs1     ),
	.rs2        (id_rs2     ),
	.rd1        (id_rd1     ),
	.rd2        (id_rd2     ),
	.aluB       (id_aluB    ),
	.ext        (ext     	),
	.id_wr_o    (id_wr	 	),
	.npc_op	    (id_npc_op	),
	.npco_sel   (id_npco_sel),
	.id_rf_we   (id_we		),
	.rf_wesl	(id_rf_wesl ),
	.alu_op	    (id_alu_op	),
	.dram_we    (id_dram_we )
);

//ID/EX pipeline reg
reg_id_ex ID_EX_REG(
	.clk		(clk    		),
	.rst_n		(rst_n         	),
	.flush		(pipeline_flush	),
	.stop		(pipeline_stop 	),
	
	.id_pc		(id_pc		),
	.id_npco_sel(id_npco_sel),
    .id_rf_wesl (id_rf_wesl ),
    .id_alu_op  (id_alu_op  ),
    .id_dram_we (id_dram_we ),
    .id_npc_op  (id_npc_op  ),
    .id_ext     (id_ext     ),
    .id_aluA    (id_rd1    	),
    .id_aluB    (id_aluB    ),
    .id_rd2     (id_rd2     ),
    .id_wr     	(id_wr     	),
    .id_we 	  	(id_we 	  	),
	
	.ex_pc		(ex_pc		),
    .ex_npco_sel(ex_npco_sel),
    .ex_rf_wesl (ex_rf_wesl ),
    .ex_alu_op  (ex_alu_op  ),
    .ex_dram_we (ex_dram_we ),
    .ex_npc_op  (ex_npc_op  ),
    .ex_ext     (ex_ext     ),
    .ex_aluA    (ex_rd1	  	),
    .ex_aluB    (ex_aluB    ),
    .ex_rd2     (ex_rd2     ),
    .ex_wr      (ex_wr      ),
    .ex_we		(ex_we	  	),
	
	.id_have_inst (id_have_inst),
	.ex_have_inst (ex_have_inst	)//只是为了debug wb trace用
);


//执行EX
execute EX (
	.alu_op	(ex_alu_op		),
	.npc_op (ex_npc_op 	),
	.aluA	(final_rd1	),
	.aluB	(final_rd2	),
	.pc	    (ex_pc	  	),
	.ext	(ex_ext		),
             
	.is_jump(is_jump	),
	.aluC	(ex_aluC	),
	.npc    (ex_npc    	),
	.pc4    (ex_pc4    	)
);

//EX/MEM pipeline reg
reg_ex_mem EX_MEM_REG(
	.clk		(clk		),
	.rst_n      (rst_n      ),
	.stop       (pipeline_stop),
							 
	.ex_rd2     (ex_rd2     ),
	.ex_rf_wesl (ex_rf_wesl ),
	.ex_pc4     (ex_pc4     ),
	.ex_aluC    (ex_aluC    ),
	.ex_dram_we (ex_dram_we ),
	.ex_ext		(ex_ext		),
	.ex_wr      (ex_wr      ),
	.ex_we 	    (ex_we 	    ),//rf_we
							 
	.mem_rd2    (mem_rd2    ),
	.mem_rf_wesl(mem_rf_wesl),
	.mem_pc4    (mem_pc4    ),
	.mem_aluC   (mem_aluC   ),
	.mem_dram_we(mem_dram_we),
	.mem_ext	(mem_ext	),
	.mem_wr     (mem_wr     ),
	.mem_we	    (mem_we	    ),
	
	.ex_have_inst (ex_have_inst	),//只是为了debug wb trace用
	.mem_have_inst(mem_have_inst),
	.ex_pc      (ex_pc      ),//pc 只是为了debug wb trace用
	.mem_pc     (mem_pc     )

);
//MEM 阶段的选择器
wb_mux MEM_MUX (
	.rf_wesl(mem_rf_wesl),
	.aluC	(mem_aluC),
	.dram_rdo(dram_rdo),
	.ext	(mem_ext),
	.pc4	(mem_pc4),
	
	.wd		(mem_wd)
);

//MEM/WB pipeline reg
reg_mem_wb MEM_WB_REG(
.clk	(clk	),
.rst_n	(rst_n	),
.stop   (pipeline_stop),
         
.mem_we (mem_we ),
.mem_wd (mem_wd ),
.mem_wr (mem_wr ),
         
.wb_we	(wb_we	),
.wb_wd	(wb_wd	),
.wb_wr	(wb_wr	),

.mem_have_inst (mem_have_inst	),//只是为了debug wb trace用
.wb_have_inst  (wb_have_inst	),
.mem_pc (mem_pc	),//pc 只是为了debug wb trace用
.wb_pc  (wb_pc	)
);

//写回WB
/*wb_mux WB_MUX (
	.rf_wesl(rf_wesl),
	.aluC	(aluC),
	.dram_rdo(dram_rdo),
	.ext	(ext),
	.pc4	(pc4),
	.wd		(mem_wd	)
);*/




//访存MEM
    // Interface to Bridge       //就是与DRAM及外设如数码管打交道的
    // wire [31:0]  Bus_addr,	//外设的地址
    // wire [31:0]  Bus_rdata,	//外设读出的内容
    // wire         Bus_wen,	//外设的写使能
    // wire [31:0]  Bus_wdata	//要外设写的内容

assign Bus_addr=aluC;//lw sw
assign Bus_wen=dram_we;
assign Bus_wdata=rd2;
assign dram_rdo = Bus_rdata;

//pipeline reg



//wire just for trace
wire id_have_inst,ex_have_inst,mem_have_inst,wb_have_inst;
wire mem_pc,wb_pc;


`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = wb_have_inst;/* WB阶段是否有指令 对于单周期CPU恒为1 */
	//当nop 或者第一条的时候 可能为0 其余皆为1
    assign debug_wb_pc        = wb_pc;//通过流水线寄存器传过来的
    assign debug_wb_ena       = wb_we;
    assign debug_wb_reg       = wb_wr;
    assign debug_wb_value     = wb_wd;
`endif

endmodule
