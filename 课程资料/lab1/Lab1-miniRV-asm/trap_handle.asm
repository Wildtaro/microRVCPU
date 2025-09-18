MAIN:
    csrrwi zero, 0x300, 0       # Disable interrupt

    addi    sp, sp, -24
    sw      s0, 20(sp)
    sw      t0, 16(sp)
    sw      t1, 12(sp)
    sw      t2, 8(sp)
    sw      t3, 4(sp)
    sw      t4, 0(sp)

    li      t0, 0x0000000b      # Machine externel interrupt
    li      t1, 0x8000000b      # ECALL from M-mode

    csrrwi  t2, 0x342, 0        # Read MCAUSE
    beq     t2, t0, ECALL_HANDLER
    beq     t2, t1, EXTERNEL_INTR_HANDLER
    jal     zero, OTHER_TRAPS_HANDLER

TRAP_RET:
    lw      s0, 20(sp)
    lw      t0, 16(sp)
    lw      t1, 12(sp)
    lw      t2, 8(sp)
    lw      t3, 4(sp)
    lw      t4, 0(sp)
    addi    sp, sp, 24

    csrrwi  zero, 0x300, 0x8    # Enable interrupt
    uret                        # Should be mret, however RARS only supports uret.
     
###########################################################
# Ecall Handler
###########################################################
ECALL_HANDLER:
    lui     s0, 0xFFFFF

    sw      a0, 0x60(s0)        # Write LEDs
    sw      a0, 0x00(s0)        # Write 7-seg LEDs
    
    jal     zero, TRAP_RET

###########################################################
# Externel Interrupts Handler
###########################################################
EXTERNEL_INTR_HANDLER:
    lui     s0, 0xFFFFF

    li      t0, 0x11111111
    li      t1, 0x11111111
    li      t2, 0x99999999
    li      t4, 0xF

LOOP:
    sw      t0, 0x60(s0)        # Write LEDs
    sw      t0, 0x00(s0)        # Write 7-seg LEDs

    li      t3, 0
DELAY:
    addi    t3, t3, 1
    blt     t3, t4, DELAY

    add     t0, t0, t1
    bne     t2, t0, LOOP

    jal     zero, TRAP_RET

###########################################################
# Other Traps Handler
###########################################################
OTHER_TRAPS_HANDLER:
    lui     s0, 0xFFFFF

    ori     t0, zero, -1
    sw      t0, 0x60(s0)        # Write LEDs
    sw      t0, 0x00(s0)        # Write 7-seg LEDs

    jal     zero, TRAP_RET
