MAIN:
    ori t0, zero, 10       # 初始化随机数生成器种子值为10
    lui sp, 0x10000        # 设置栈指针初始地址为0x10000000
    lui s1, 0xFFFFF        # 设置外设基地址为0xFFFFF000
    sw t0, 0x24(s1)        # 将种子值写入随机数生成器的种子寄存器(偏移0x24)

# 阶段1：时钟同步 - 等待控制信号启动
CLOCK:
    lw t0, 0x20(s1)        # 读取时钟计数器的当前值
    lw t1, 0x70(s1)        # 读取控制信号状态
    addi t2, t0, 0         # 复制时钟值到t2（后续用作LFSR初始状态）
    sw t2, 0x0(s1)         # 输出当前值到显示外设
    ori a1, zero, 1        # 设置期望控制状态值=1（启动信号）
    bne t1, a1, CLOCK      # 若控制信号≠1，持续轮询等待

# 阶段2：种子获取 - 确认进入随机数生成阶段
SEED:
    sw t2, 0x0(s1)         # 保持输出当前值（时钟同步阶段获取的值）
    lw t1, 0x70(s1)        # 读取控制信号状态
    ori a1, zero, 2        # 设置期望控制状态值=2（随机数生成阶段）
    bne t1, a1, SEED       # 若控制信号≠2，持续轮询等待

# 阶段3：LFSR随机数生成 - 使用线性反馈移位寄存器
LSFR:
    # 计算反馈位（抽头位置：0,1,21,31）
    andi a2, t2, 0x1       # 提取bit0
    andi a4, t2, 0x2       # 提取bit1
    srli a4, a4, 1         # 将bit1移至最低位
    slli a5, t2, 10        # 准备提取bit21：左移10位使bit21到MSB
    srli a5, a5, 31        # 将bit21移至最低位
    srli a6, t2, 31        # 直接提取bit31
    
    # 三级异或计算新比特
    xor a3, a2, a4         # bit0 ^ bit1
    xor a7, a5, a6         # bit21 ^ bit31
    xor s2, a3, a7         # 最终反馈位 = (bit0^bit1)^(bit21^bit31)
    
    # 更新LFSR状态
    slli t2, t2, 1         # 寄存器整体左移1位
    add t2, t2, s2         # 在最低位插入新的反馈位
    
    sw t2, 0x0(s1)         # 输出新的LFSR状态到显示外设
    lw t1, 0x70(s1)        # 读取控制信号状态
    ori a1, zero, 3        # 设置期望控制状态值=3（排序阶段）
    bne t1, a1, LSFR       # 若控制信号≠3，继续生成随机数

# 阶段4：冒泡排序 - 对随机数的半字节(nibble)排序
SORT:
    addi sp, sp, -32       # 栈上分配32字节空间（存储8个4位半字节）
    
    # 将32位值拆分为8个4位半字节
    andi t3, t2, 0xF       # 提取最低4位(nibble0)
    sw t3, 0(sp)           # 存储到栈[0]
    srli t4, t2, 4         # 右移4位
    andi t3, t4, 0xF       # 提取nibble1
    sw t3, 4(sp)           # 存储到栈[4]
    srli t4, t2, 8         # 继续右移
    andi t3, t4, 0xF       # 提取nibble2
    sw t3, 8(sp)           # 存储到栈[8]
    srli t4, t2, 12        # 重复操作...
    andi t3, t4, 0xF       # 提取nibble3
    sw t3, 12(sp)          # 存储到栈[12]
    srli t4, t2, 16
    andi t3, t4, 0xF       # 提取nibble4
    sw t3, 16(sp)          # 存储到栈[16]
    srli t4, t2, 20
    andi t3, t4, 0xF       # 提取nibble5
    sw t3, 20(sp)          # 存储到栈[20]
    srli t4, t2, 24
    andi t3, t4, 0xF       # 提取nibble6
    sw t3, 24(sp)          # 存储到栈[24]
    srli t4, t2, 28
    andi t3, t4, 0xF       # 提取最高4位(nibble7)
    sw t3, 28(sp)          # 存储到栈[28]

    # 冒泡排序实现（升序）
    addi t3, zero, 7       # 外循环计数器（n-1次迭代，n=8）
OUTER_LOOP:
    addi t4, zero, 0       # 内循环计数器（当前比较位置）
INNER_LOOP:
    bge t4, t3, INNER_END  # 内循环结束条件：j ≥ n-i-1
    slli t5, t4, 2         # 计算元素偏移（乘以4：每个元素占4字节）
    add t5, t5, sp         # 计算当前元素地址
    lw t6, 0(t5)           # 加载当前元素arr[j]
    lw a4, 4(t5)           # 加载下一个元素arr[j+1]
    bge t6, a4, NO_SWAP    # 若arr[j] ≤ arr[j+1]，跳过交换
    sw a4, 0(t5)           # 交换元素：将arr[j+1]存入arr[j]位置
    sw t6, 4(t5)           # 将原arr[j]存入arr[j+1]位置
NO_SWAP:
    addi t4, t4, 1         # 内循环计数器+1（j++）
    j INNER_LOOP
INNER_END:
    addi t3, t3, -1        # 外循环计数器-1（i++）
    bge t3, zero, OUTER_LOOP # 继续外循环直到i=n-1

    # 从栈中加载排序后的半字节
    lw a0, 0(sp)           # 加载nibble0（最低位）
    lw a1, 4(sp)           # 加载nibble1
    lw a2, 8(sp)           # 加载nibble2
    lw a3, 12(sp)          # 加载nibble3
    lw a4, 16(sp)          # 加载nibble4
    lw a5, 20(sp)          # 加载nibble5
    lw a6, 24(sp)          # 加载nibble6
    lw a7, 28(sp)          # 加载nibble7（最高位）
    
    # 将8个半字节重组为32位字
    slli t2, a7, 28        # nibble7移到[31:28]
    slli t4, a6, 24        # nibble6移到[27:24]
    or t2, t2, t4
    slli t4, a5, 20        # nibble5移到[23:20]
    or t2, t2, t4
    slli t4, a4, 16        # nibble4移到[19:16]
    or t2, t2, t4
    slli t4, a3, 12        # nibble3移到[15:12]
    or t2, t2, t4
    slli t4, a2, 8         # nibble2移到[11:8]
    or t2, t2, t4
    slli t4, a1, 4         # nibble1移到[7:4]
    or t2, t2, t4
    or t2, t2, a0          # 组合nibble0到[3:0]
    
    addi sp, sp, 32        # 释放栈空间
    xori s11, zero, 1      # 生成完成标志(值=1)
    sw s11, 0x60(s1)       # 将完成信号写入状态寄存器(偏移0x60)

# 阶段5：结果输出 - 等待控制信号归零
SORT_END:
    ori a1, zero, 0        # 期望控制状态=0（完成状态）
    lw t1, 0x70(s1)        # 读取控制信号状态
    bne t1, a1, SORT_END   # 若控制信号≠0，持续等待
    
    sw t2, 0x0(s1)         # 输出最终排序结果到显示外设

# 程序终止
TERMINATE:
    j TERMINATE            # 无限循环终止程序（保持最终状态）