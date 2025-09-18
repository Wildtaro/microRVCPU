.data    
    # 数据变量
    seed:           .word 0           # 随机数种子
    random_array:   .space 8          # 随机数组
    sorted_array:   .space 8          # 排序后数组

.text
.globl _start
_start:
    # 设置基地址寄存器 (0xFFFFF000)
    lui s0, 0xFFFFF                  # s0 = 0xFFFFF000 (基地址)

    # 初始化计时器(设置分频系数为5)
    addi t0, zero, 5                 # 分频系数=5
    sw t0, 0x24(s0)                  # 设置分频系数 (0xFFFFF024)

    # 阶段0：显示计时器值
stage0:
    # 读取并显示计时器值
    lw t0, 0x20(s0)                  # 读取计时器值 (0xFFFFF020)
    sw t0, 0x0(s0)                   # 显示计时器值 (0xFFFFF000)

    # 检查拨码开关状态
    lw t4, 0x70(s0)                  # 读取拨码开关值 (0xFFFFF070)
    andi t4, t4, 0x3                 # 取最低2位(SW[1:0])
    
    # 比较是否为01
    addi t5, zero, 1
    bne t4, t5, stage0               # 不是1则继续阶段0

    # 阶段1：设置随机数种子
stage1:
    # t0已包含当前计时器值
    lui t1, %hi(seed)                # 加载seed地址
    addi t1, t1, %lo(seed)
    sw t0, 0(t1)                     # 存储计时器值作为种子

    # 显示种子值
    sw t0, 0x0(s0)                   # 使用基地址显示

    # 检查是否切换到阶段2(SW[1:0]==10)
wait_for_stage2:
    lw t4, 0x70(s0)                  # 重新读取拨码开关
    andi t4, t4, 0x3
    addi t5, zero, 2
    bne t4, t5, wait_for_stage2      # 不是2则继续阶段1

    # 阶段2：生成随机数数组
stage2:
    lui t0, %hi(random_array)        # 加载random_array地址
    addi t0, t0, %lo(random_array)
    lw t1, 0(t1)                     # 加载种子值
    addi t2, zero, 8                 # 循环计数器=8

generate_loop:
    # LFSR算法实现
    srli t3, t1, 1                   # 右移1位
    andi t4, t1, 1                   # 取最低位
    beq t4, zero, no_xor             # 如果为0，不执行XOR

    lui t5, 0xB4                     
    srli t5, t5, 8                  
    xor t3, t3, t5                   # 使用xor指令

no_xor:
    add t1, t3, zero                 # 更新种子值
    andi t3, t3, 0xF                 # 取低4位作为随机数
    sb t3, 0(t0)                     # 存储随机数
    
    addi t0, t0, 1
    addi t2, t2, -1
    bne t2, zero, generate_loop      # 继续循环直到生成8个数

    # 显示随机数数组(组合显示)
    lui t0, %hi(random_array)        # 重新加载random_array地址
    addi t0, t0, %lo(random_array)
    add t1, zero, zero               # 显示位置计数器=0
    add t2, zero, zero               # 组合值寄存器=0

display_random:
    lbu t3, 0(t0)                    # 读取4bit随机数
    slli t2, t2, 4                   # 左移4位
    or t2, t2, t3                    # 组合到显示值
    
    addi t0, t0, 1
    addi t1, t1, 1
    addi t4, zero, 8                 # 设置比较值8
    blt t1, t4, display_random       # 继续组合直到8个数
    
    sw t2, 0x0(s0)                   # 显示组合后的值 (使用基地址)

    # 检查是否切换到阶段3(SW[1:0]==11)
wait_for_stage3:
    lw t4, 0x70(s0)                  # 重新读取拨码开关
    andi t4, t4, 0x3
    addi t5, zero, 3
    bne t4, t5, wait_for_stage3

    # 阶段3：排序数组
stage3:
    # 复制数组到sorted_array
    lui t0, %hi(random_array)
    addi t0, t0, %lo(random_array)
    lui t1, %hi(sorted_array)
    addi t1, t1, %lo(sorted_array)
    addi t2, zero, 8                 # 计数器=8

copy_loop:
    lbu t3, 0(t0)                   # 使用无符号加载
    sb t3, 0(t1)
    addi t0, t0, 1
    addi t1, t1, 1
    addi t2, t2, -1
    bne t2, zero, copy_loop

    # 冒泡排序
    addi t0, zero, 7                 # i=7
outer_loop:
    lui t1, %hi(sorted_array)        # 数组地址
    addi t1, t1, %lo(sorted_array)
    add t3, zero, zero               # 交换标志=0
    add t2, zero, zero               # j=0

inner_loop:
    lbu t4, 0(t1)                   # arr[j]
    lbu t5, 1(t1)                   # arr[j+1]
    ble t4, t5, no_swap
    
    # 执行交换
    sb t5, 0(t1)
    sb t4, 1(t1)
    addi t3, zero, 1                # 设置交换标志

no_swap:
    addi t1, t1, 1                  # 指针++
    addi t2, t2, 1                  # j++
    addi t6, zero, 7                # 比较值
    blt t2, t6, inner_loop          # j<7继续

    # 外循环控制
    beq t3, zero, sort_done         # 无交换则完成
    addi t0, t0, -1                 # i--
    bne t0, zero, outer_loop        # i>0继续

sort_done:
    # 点亮LED[0]
    addi t1, zero, 1                 # LED值=1
    sw t1, 0x60(s0)                  # 使用基地址设置LED

    # 阻塞式检测拨码开关，直到 SW[1:0] == 00
wait_for_stage4:
    lw t4, 0x70(s0)                  # 读取拨码开关 (地址: 0xFFFFF070)
    andi t4, t4, 0x3                 # 取最低 2 位 (SW[1:0])
    bne t4, zero, wait_for_stage4    # 如果 SW[1:0] != 00，继续循环

    # 阶段4：显示排序结果
stage4:
    # 显示排序后的数组(组合显示)
    lui t0, %hi(sorted_array)        # 加载sorted_array地址
    addi t0, t0, %lo(sorted_array)
    add t1, zero, zero               # 显示位置计数器=0
    add t2, zero, zero               # 组合值寄存器=0

display_sorted:
    lbu t3, 0(t0)                    # 读取4bit随机数
    slli t2, t2, 4                   # 左移4位
    or t2, t2, t3                    # 组合到显示值
    
    addi t0, t0, 1
    addi t1, t1, 1
    addi t4, zero, 8                 # 设置比较值8
    blt t1, t4, display_sorted       # 继续组合直到8个数
    
    sw t2, 0x0(s0)                   # 显示组合后的值 (使用基地址)

    # 程序结束
end:
    jal zero, end                   
