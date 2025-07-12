// Annotate this macro before synthesis
// `define RUN_TRACE  //traceʱҪ�ſ����ۺ�/ʵ��/������ǰ��Ҫע��

// TODO: �ڴ˴�������ĺ�?
// 
	//<npc_op> ����NPC����һ��ָ��ĵ�ַ�Ĳ���? ��+4 ����������ת��PC+offset�����Ǹ���beq��B��ָ������
    `define NPC_PC4  'b00
    `define NPC_JMP  'b01
    `define NPC_JMPR 'b10
    `define NPC_BEQ  'b11
	
	//<NPCO_sel>  ����offset����ALU.C��jalr������SEXT.ext��jal��
	`define NPCO_ALU  'b1
    `define NPCO_SEXT 'b0

	//rf_we���Ĵ�����дʹ���ź� rd���Ƿ�д�ؼĴ���
	`define RF_WN  'b0
    `define RF_WY  'b1
	
	//rf_wsel���Ĵ�����дѡ���ź� д�ؼĴ���������������
    `define WB_ALU	'b00
    `define WB_DRAM 'b01
    `define WB_EXT  'b10
    `define WB_PC4  'b11

    // sext_op: ��������չ��ʽ
    `define EXT_I   'b000
    `define EXT_S   'b001
    `define EXT_B  	'b010
    `define EXT_U   'b011
    `define EXT_J  	'b100
	//����Ҫ������������չ����Ҫд�� ��Ҫָ����ʽ�� ����ָ������չ


    // alu_op: ALU��Ϊ
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

	//LUI��Ҫ�𣿣������������������������� ����jal��Ҫ��

	// alub_sel: alu�ĵڶ�����������?
    `define ALUB_RS2	'b0
    `define ALUB_EXT	'b1
	//��һ��������Ҫѡ����
	
	//��ָ֧����Ҫϸ����ϸ�����־�����ĳһ��ָ����BrSel

	//BrEQ A==B�Ľ����BrLT A<B�Ľ��?

    // Mem: memory access
    `define MEM_NON    'b0
    `define MEM_EN     'b1

    // ram_we: �Ƿ�д�����ݴ洢��DRAM  
    `define DRAM_WN   'b0
    `define DRAM_WY    'b1
	//���޶�DRAM�Ĳ���Mem�Ƿ���Ҫ  
	//PCSel��Ҫ��
	/////////////////////////
// ����I/O�ӿڵ�·�Ķ˿ڵ�ַ
`define PERI_ADDR_DIG   32'hFFFF_F000
`define PERI_ADDR_LED   32'hFFFF_F060
`define PERI_ADDR_SW    32'hFFFF_F070
`define PERI_ADDR_BTN   32'hFFFF_F078
