.data
    offset: .space 0x70
    peri:   .word  0x12345678       # Assume it's a peripheral

.text
MAIN:
    # 在LoongSonAssembler运行本程序，需将-1改成0x00000
    # 在LA32R NEMU运行本程序，需将-1改成0x1c010
    lu12i.w $s0, -1     # 0xfffff   

TEST:
    ld.w   $t0, $s0, 0x70           # Read switches
    st.w   $t0, $s0, 0x60           # Write LEDs
    st.w   $t0, $s0, 0x00           # Write 7-seg LEDs

    ori    $t0, $zero, 5
    st.w   $t0, $s1, 0x24           # Set frequency of the Timer
    ld.w   $t0, $s1, 0x20           # Read value of the Timer
    
    b TEST
