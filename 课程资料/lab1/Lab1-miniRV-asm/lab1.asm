.data    
    # ���ݱ���
    seed:           .word 0           # ���������
    random_array:   .space 8          # �������
    sorted_array:   .space 8          # ���������

.text
.globl _start
_start:
    # ���û���ַ�Ĵ��� (0xFFFFF000)
    lui s0, 0xFFFFF                  # s0 = 0xFFFFF000 (����ַ)

    # ��ʼ����ʱ��(���÷�Ƶϵ��Ϊ5)
    addi t0, zero, 5                 # ��Ƶϵ��=5
    sw t0, 0x24(s0)                  # ���÷�Ƶϵ�� (0xFFFFF024)

    # �׶�0����ʾ��ʱ��ֵ
stage0:
    # ��ȡ����ʾ��ʱ��ֵ
    lw t0, 0x20(s0)                  # ��ȡ��ʱ��ֵ (0xFFFFF020)
    sw t0, 0x0(s0)                   # ��ʾ��ʱ��ֵ (0xFFFFF000)

    # ��鲦�뿪��״̬
    lw t4, 0x70(s0)                  # ��ȡ���뿪��ֵ (0xFFFFF070)
    andi t4, t4, 0x3                 # ȡ���2λ(SW[1:0])
    
    # �Ƚ��Ƿ�Ϊ01
    addi t5, zero, 1
    bne t4, t5, stage0               # ����1������׶�0

    # �׶�1���������������
stage1:
    # t0�Ѱ�����ǰ��ʱ��ֵ
    lui t1, %hi(seed)                # ����seed��ַ
    addi t1, t1, %lo(seed)
    sw t0, 0(t1)                     # �洢��ʱ��ֵ��Ϊ����

    # ��ʾ����ֵ
    sw t0, 0x0(s0)                   # ʹ�û���ַ��ʾ

    # ����Ƿ��л����׶�2(SW[1:0]==10)
wait_for_stage2:
    lw t4, 0x70(s0)                  # ���¶�ȡ���뿪��
    andi t4, t4, 0x3
    addi t5, zero, 2
    bne t4, t5, wait_for_stage2      # ����2������׶�1

    # �׶�2���������������
stage2:
    lui t0, %hi(random_array)        # ����random_array��ַ
    addi t0, t0, %lo(random_array)
    lw t1, 0(t1)                     # ��������ֵ
    addi t2, zero, 8                 # ѭ��������=8

generate_loop:
    # LFSR�㷨ʵ��
    srli t3, t1, 1                   # ����1λ
    andi t4, t1, 1                   # ȡ���λ
    beq t4, zero, no_xor             # ���Ϊ0����ִ��XOR

    lui t5, 0xB4                     
    srli t5, t5, 8                  
    xor t3, t3, t5                   # ʹ��xorָ��

no_xor:
    add t1, t3, zero                 # ��������ֵ
    andi t3, t3, 0xF                 # ȡ��4λ��Ϊ�����
    sb t3, 0(t0)                     # �洢�����
    
    addi t0, t0, 1
    addi t2, t2, -1
    bne t2, zero, generate_loop      # ����ѭ��ֱ������8����

    # ��ʾ���������(�����ʾ)
    lui t0, %hi(random_array)        # ���¼���random_array��ַ
    addi t0, t0, %lo(random_array)
    add t1, zero, zero               # ��ʾλ�ü�����=0
    add t2, zero, zero               # ���ֵ�Ĵ���=0

display_random:
    lbu t3, 0(t0)                    # ��ȡ4bit�����
    slli t2, t2, 4                   # ����4λ
    or t2, t2, t3                    # ��ϵ���ʾֵ
    
    addi t0, t0, 1
    addi t1, t1, 1
    addi t4, zero, 8                 # ���ñȽ�ֵ8
    blt t1, t4, display_random       # �������ֱ��8����
    
    sw t2, 0x0(s0)                   # ��ʾ��Ϻ��ֵ (ʹ�û���ַ)

    # ����Ƿ��л����׶�3(SW[1:0]==11)
wait_for_stage3:
    lw t4, 0x70(s0)                  # ���¶�ȡ���뿪��
    andi t4, t4, 0x3
    addi t5, zero, 3
    bne t4, t5, wait_for_stage3

    # �׶�3����������
stage3:
    # �������鵽sorted_array
    lui t0, %hi(random_array)
    addi t0, t0, %lo(random_array)
    lui t1, %hi(sorted_array)
    addi t1, t1, %lo(sorted_array)
    addi t2, zero, 8                 # ������=8

copy_loop:
    lbu t3, 0(t0)                   # ʹ���޷��ż���
    sb t3, 0(t1)
    addi t0, t0, 1
    addi t1, t1, 1
    addi t2, t2, -1
    bne t2, zero, copy_loop

    # ð������
    addi t0, zero, 7                 # i=7
outer_loop:
    lui t1, %hi(sorted_array)        # �����ַ
    addi t1, t1, %lo(sorted_array)
    add t3, zero, zero               # ������־=0
    add t2, zero, zero               # j=0

inner_loop:
    lbu t4, 0(t1)                   # arr[j]
    lbu t5, 1(t1)                   # arr[j+1]
    ble t4, t5, no_swap
    
    # ִ�н���
    sb t5, 0(t1)
    sb t4, 1(t1)
    addi t3, zero, 1                # ���ý�����־

no_swap:
    addi t1, t1, 1                  # ָ��++
    addi t2, t2, 1                  # j++
    addi t6, zero, 7                # �Ƚ�ֵ
    blt t2, t6, inner_loop          # j<7����

    # ��ѭ������
    beq t3, zero, sort_done         # �޽��������
    addi t0, t0, -1                 # i--
    bne t0, zero, outer_loop        # i>0����

sort_done:
    # ����LED[0]
    addi t1, zero, 1                 # LEDֵ=1
    sw t1, 0x60(s0)                  # ʹ�û���ַ����LED

    # ����ʽ��Ⲧ�뿪�أ�ֱ�� SW[1:0] == 00
wait_for_stage4:
    lw t4, 0x70(s0)                  # ��ȡ���뿪�� (��ַ: 0xFFFFF070)
    andi t4, t4, 0x3                 # ȡ��� 2 λ (SW[1:0])
    bne t4, zero, wait_for_stage4    # ��� SW[1:0] != 00������ѭ��

    # �׶�4����ʾ������
stage4:
    # ��ʾ����������(�����ʾ)
    lui t0, %hi(sorted_array)        # ����sorted_array��ַ
    addi t0, t0, %lo(sorted_array)
    add t1, zero, zero               # ��ʾλ�ü�����=0
    add t2, zero, zero               # ���ֵ�Ĵ���=0

display_sorted:
    lbu t3, 0(t0)                    # ��ȡ4bit�����
    slli t2, t2, 4                   # ����4λ
    or t2, t2, t3                    # ��ϵ���ʾֵ
    
    addi t0, t0, 1
    addi t1, t1, 1
    addi t4, zero, 8                 # ���ñȽ�ֵ8
    blt t1, t4, display_sorted       # �������ֱ��8����
    
    sw t2, 0x0(s0)                   # ��ʾ��Ϻ��ֵ (ʹ�û���ַ)

    # �������
end:
    jal zero, end                   
