.text
MAIN:
    # 初始化：设置随机数生成次数，初始化栈指针和外设基地址
    ori t0, zero, 10      
    lui sp, 0x10000
    lui s1, 0xFFFFF    
    sw t0, 0x24(s1)   # 存储生成次数到外设寄存器

CLOCK:
    # 时钟同步阶段：等待状态1并捕获当前时钟值
    lw t0, 0x20(s1)       # 读取硬件时钟
    lw t1, 0x70(s1)       # 读取控制状态
    addi t2, t0, 0        # 保存当前时钟值
    sw t2, 0x0(s1)        # 输出显示
    ori a1, zero, 1
    bne t1, a1, CLOCK     # 循环等待状态1

SEED:
    # 种子初始化阶段：等待状态2
    sw t2, 0x0(s1)        # 显示当前值
    lw t1, 0x70(s1) 
    ori a1, zero, 2
    bne t1, a1, SEED      # 等待状态2

LSFR:
    # 随机数生成阶段：32位LSFR算法（线性反馈移位寄存器）
    # 使用bit0, bit1, bit21, bit31计算反馈值
    xor s2, a3, a7        # 计算反馈位
    slli t2, t2, 1        # 左移移位
    add t2, t2, s2        # 插入反馈位
    
    sw t2, 0x0(s1)        # 输出当前随机数
    lw t1, 0x70(s1)     
    ori a1, zero, 3
    bne t1, a1, LSFR      # 循环直到状态3

SORT:
    # 排序准备：将32位数分解为8个4位字段存入栈
    addi sp, sp, -32      # 栈空间分配
    # ...（分解过程省略）...
    
    # 冒泡排序实现（8元素版）
    addi t3, zero, 7      # 外循环计数器
OUTER_LOOP:
    addi t4, zero, 0      # 内循环计数器
INNER_LOOP:
    # ...（元素比较和交换）...
    j INNER_LOOP
INNER_END:
    addi t3, t3, -1  
    bge t3, zero, OUTER_LOOP 

    # 重组：将排序后的8个半字节组合回32位数
    slli t2, a7, 28       # 高位重组
    # ...（组合过程省略）...
    addi sp, sp, 32       # 释放栈空间
    sw s11,0x60(s1)       # 设置排序完成标志

SORT_END:
    # 输出阶段：等待状态0后显示最终结果
    ori a1, zero, 0
    lw t1, 0x70(s1)    
    bne t1, a1, SORT_END  # 等待状态0
    sw t2, 0x0(s1)        # 输出排序后的32位数

TERMINATE:
    j TERMINATE           # 程序终止（无限循环）