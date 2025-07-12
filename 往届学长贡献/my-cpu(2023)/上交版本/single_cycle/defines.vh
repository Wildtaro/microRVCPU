// Annotate this macro before synthesis
// `define RUN_TRACE  //trace时要放开，综合/实现/比特流前，要注释

// TODO: 在此处定义你的宏
// 
	//<npc_op> 决定NPC对下一条指令的地址的操作 是+4 还是立即跳转到PC+offset，还是根据beq等B型指令来跳
    `define NPC_PC4  'b00
    `define NPC_JMP  'b01
    `define NPC_JMPR 'b10
    `define NPC_BEQ  'b11
	
	//<NPCO_sel>  决定offset是来ALU.C（jalr）还是SEXT.ext（jal）
	`define NPCO_ALU  'b1
    `define NPCO_SEXT 'b0

	//rf_we：寄存器堆写使能信号 rd段是否写回寄存器
	`define RF_WN  'b0
    `define RF_WY  'b1
	
	//rf_wsel：寄存器堆写选择信号 写回寄存器的内容来哪里
    `define WB_ALU	'b00
    `define WB_DRAM 'b01
    `define WB_EXT  'b10
    `define WB_PC4  'b11

    // sext_op: 立即数扩展方式
    `define EXT_I   'b000
    `define EXT_S   'b001
    `define EXT_B  	'b010
    `define EXT_U   'b011
    `define EXT_J  	'b100
	//不需要进行立即数扩展的需要写吗 需要指定方式吗 比如指定不扩展


    // alu_op: ALU行为
    `define ALU_ADD 'b0000
    `define ALU_SUB 'b0001
    `define ALU_AND 'b0010
    `define ALU_OR  'b0011
	
    `define ALU_XOR 'b0100
    `define ALU_SLL 'b0101
    `define ALU_SRL 'b0110
    `define ALU_SRA 'b0111
	
	`define	ALU_BEQ 'b1000
	`define	ALU_BNE 'b1001
	`define	ALU_BLT 'b1010
	`define	ALU_BGE 'b1011

	//LUI需要吗？？？？？？？？？？？？？？ 而且jal需要吗

	// alub_sel: alu的第二个输入的来源
    `define ALUB_RS2	'b0
    `define ALUB_EXT	'b1
	//第一个输入需要选择吗
	
	//分支指令需要细化吗，细化区分究竟是某一个指令吗BrSel

	//BrEQ A==B的结果；BrLT A<B的结果

    // Mem: memory access
    `define MEM_NON    'b0
    `define MEM_EN     'b1

    // ram_we: 是否写入数据存储器DRAM  
    `define DRAM_WN   'b0
    `define DRAM_WY    'b1
	//有无对DRAM的操作Mem是否需要  
	//PCSel需要吗
	/////////////////////////
// 外设I/O接口电路的端口地址
`define PERI_ADDR_DIG   32'hFFFF_F000
`define PERI_ADDR_LED   32'hFFFF_F060
`define PERI_ADDR_SW    32'hFFFF_F070
`define PERI_ADDR_BTN   32'hFFFF_F078
