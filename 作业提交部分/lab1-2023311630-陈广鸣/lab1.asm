.text
MAIN:
    # ��ʼ����������������ɴ�������ʼ��ջָ����������ַ
    ori t0, zero, 10      
    lui sp, 0x10000
    lui s1, 0xFFFFF    
    sw t0, 0x24(s1)   # �洢���ɴ���������Ĵ���

CLOCK:
    # ʱ��ͬ���׶Σ��ȴ�״̬1������ǰʱ��ֵ
    lw t0, 0x20(s1)       # ��ȡӲ��ʱ��
    lw t1, 0x70(s1)       # ��ȡ����״̬
    addi t2, t0, 0        # ���浱ǰʱ��ֵ
    sw t2, 0x0(s1)        # �����ʾ
    ori a1, zero, 1
    bne t1, a1, CLOCK     # ѭ���ȴ�״̬1

SEED:
    # ���ӳ�ʼ���׶Σ��ȴ�״̬2
    sw t2, 0x0(s1)        # ��ʾ��ǰֵ
    lw t1, 0x70(s1) 
    ori a1, zero, 2
    bne t1, a1, SEED      # �ȴ�״̬2

LSFR:
    # ��������ɽ׶Σ�32λLSFR�㷨�����Է�����λ�Ĵ�����
    # ʹ��bit0, bit1, bit21, bit31���㷴��ֵ
    xor s2, a3, a7        # ���㷴��λ
    slli t2, t2, 1        # ������λ
    add t2, t2, s2        # ���뷴��λ
    
    sw t2, 0x0(s1)        # �����ǰ�����
    lw t1, 0x70(s1)     
    ori a1, zero, 3
    bne t1, a1, LSFR      # ѭ��ֱ��״̬3

SORT:
    # ����׼������32λ���ֽ�Ϊ8��4λ�ֶδ���ջ
    addi sp, sp, -32      # ջ�ռ����
    # ...���ֽ����ʡ�ԣ�...
    
    # ð������ʵ�֣�8Ԫ�ذ棩
    addi t3, zero, 7      # ��ѭ��������
OUTER_LOOP:
    addi t4, zero, 0      # ��ѭ��������
INNER_LOOP:
    # ...��Ԫ�رȽϺͽ�����...
    j INNER_LOOP
INNER_END:
    addi t3, t3, -1  
    bge t3, zero, OUTER_LOOP 

    # ���飺��������8�����ֽ���ϻ�32λ��
    slli t2, a7, 28       # ��λ����
    # ...����Ϲ���ʡ�ԣ�...
    addi sp, sp, 32       # �ͷ�ջ�ռ�
    sw s11,0x60(s1)       # ����������ɱ�־

SORT_END:
    # ����׶Σ��ȴ�״̬0����ʾ���ս��
    ori a1, zero, 0
    lw t1, 0x70(s1)    
    bne t1, a1, SORT_END  # �ȴ�״̬0
    sw t2, 0x0(s1)        # ���������32λ��

TERMINATE:
    j TERMINATE           # ������ֹ������ѭ����