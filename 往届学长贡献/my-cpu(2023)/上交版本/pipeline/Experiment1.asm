
MAIN:
	lui  s1, 0xFFFFF#0xFFFF_F000  数码管基地址 sw 写数码管
	#0xFFFF_F060	LED 基地址	0x60(s1) sw 写led
	#0xFFFF_F070	拨码开关 基地址	0x70(s1) lw 读拨码开关
	addi  s0, s1, 0x70	#s0 拨码开关
	
	add s3,x0,x0  #s3清零  输出的结果s3

	lw t0, 0(s0)	#读拨码开关	运算符 和 保留
	srli t0,t0,21
	
	lw t2, 0(s0)#读拨码开关	操作数B
	andi t2,t2,0x000000ff
	lw t1, 0(s0)#读拨码开关	操作数A
	srli t1,t1,8
	andi t1,t1,0x000000ff
	
	
	add t3,x0,x0
	
	beq t0,t3,AND
	addi t3,t3,1
	beq t0,t3,OR
	addi t3,t3,1
	beq t0,t3,XOR
		addi t3,t3,1
	beq t0,t3,SLL
		addi t3,t3,1
	beq t0,t3,SRA
		addi t3,t3,1
	beq t0,t3,CPL
		addi t3,t3,1
	beq t0,t3,DIV
		addi t3,t3,1
	beq t0,t3,END		#输入为111 则为计算器结束退出 不再进行循环
	jal x0,EXIT2
AND:
	and s3,t1,t2	

	jal  EXIT1
OR:
	or s3,t1,t2

	jal  EXIT1	
XOR:
	xor s3,t1,t2	

	jal  EXIT1
SLL:
	add a1,x0,x0
	andi a1,t1,0x0080
	andi s3,t1,0x007f	
	sll s3,s3,t2
	andi s3,s3,0x007f	
	or s3,a1,s3
	add a1,x0,x0
	jal  EXIT2
SRA:
	add a1,x0,x0
	andi a1,t1,0x0080
	andi s3,t1,0x007f	
	sra s3,s3,t2
	andi s3,s3,0x007f	
	or s3,a1,s3
	add a1,x0,x0
	jal  EXIT2
CPL:
	#如t1=1.1001011  t2=1.1101000
	#li t1,0xCB
	#li t2,0xe8#11101000    10011000  98  10000000  80
	addi t6,x0,0x80
	beq t1,x0,Aling
	# B  t2的补码
	bge t2,t6,fsCPL
	add s3,t2,x0	#正数和0 不变  000？？？？？
	jal  x0,EXIT1
	fsCPL:
	xori s3,t2,0x7f	#按位取反 末尾+1？？？？  10010111  97
	addi s3,s3,1
	jal  x0,EXIT1
	Aling: add s3,t2,x0
	jal  x0,EXIT1
DIV:
	#加减交替法来实现？？
	#如t1=0 0001000  t2=0 0000010
	#求x*补 t3 000000 0 0001000  
	#y*补 t4=0 0000010 000000 
	#-y*补 t5=1 1111110 000000
	addi t6,x0,0x80
	# B  t2的补码
	bge t1,t6,fxing
	add t3,t1,x0#正数和0 不变  000？？？？？
	jal  x0,zong
	fxing:xori t3,t1,0x80#去掉符号位
	zong:
	bge t2,t6,fying
	add t4,t2,x0#正数和0 不变  000？？？？？
	jal  x0,yzong
	fying:xori t4,t2,0x80#去掉符号位
	yzong:
	# -y*补 对 y*补 连同符号位按位取反末尾+1
	xori t5,t4,0xff#t4=00000010 t5=11111101  
	addi t5,t5,1#t5=11111110
	
	#由于是整数除法  所以要将t5，t4左移6位
	slli t4,t4,6
	slli t5,t5,6
	
	add s8,t3,t5
	#移位7次
	addi s11,x0,6
	add s10,x0,x0
	for:beq s10,s11,divExit
	addi s10,s10,1
	
	#先上商 再左移 再加减
	srli s9,s8,13
	andi s9,s9,0x01#s9=1 则为负数  s9=0,则为正数 
	beq s9,x0,zheng
	#余数s8为负，上商s3 0，+y*t4  逻辑左移
	slli s8,s8,1#逻辑左移
	slli s3,s3,1#逻辑左移
	add s8,s8,t4
	
	jal x0,for
	zheng:#余数s8为正，上商1，+-y*t5  逻辑左移
	addi s3,s3,1#上商1
	slli s8,s8,1#逻辑左移
	slli s3,s3,1#逻辑左移
	add s8,s8,t5

	jal x0,for
	divExit:
	#上商
	srli s9,s8,13
	andi s9,s9,0x01#s9=1 则为负数  s9=0,则为正数 
	bne s9,x0,mfu
	addi s3,s3,1#上商1
	mfu:
	andi s3,s3,0x0000007f#清空高位
	#加上符号位
	andi a6,t1,0x00000080
	andi a7,t2,0x00000080
	xor a5,a6,a7
	beq a5,x0,z
	lui s4,0x00010000
	add s3,s3,s4
	z:
	sw s3,0x00(s1)	#写数码管  s1
	jal x0,EXIT

er_FUNC:
	addi a3,x0,7
	add a4,x0,x0
	add s4,x0,x0
	ffor:
	beq a4,a3,jieshu
	addi a4,a4,1
	
	andi t0,s3,0x0080
	slli s3,s3,1
	
	beq t0,x0,ling
	addi s4,s4,1
	ling:slli s4,s4,4
	j ffor
	jieshu:
	andi t0,s3,0x0080
	beq t0,x0,ling2
	addi s4,s4,1
	ling2:
	sw s4,0x00(s1)
	jalr zero,ra,0#return
	
	
	EXIT2:
	#有符号整数显示  如-32：10000020
		addi t6,x0,0x00000080  #负数 1
		blt s3,t6,zz
		lui s4,0x00010000
		andi s3,s3,0x7f #清除符号位
		add s3,s3,s4
		zz:
		sw s3,0x00(s1)	#写数码管  s1
		jal x0,EXIT
	EXIT1:
	#2进制显示
		jal ra,er_FUNC
		
	EXIT:
	add t1,x0,x0
	add t2,x0,x0
	add s3,x0,x0
	add s4,s4,x0	
	jal x0, MAIN
	
	END:sw x0,0x00(s1)  #清空数码管显示，使之全为0000


