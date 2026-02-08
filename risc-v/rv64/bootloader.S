# Minimal RV64 entry for QEMU -kernel.
.section .text.init
.global _start

.extern __bss_start
.extern __bss_end
.extern __stack_top
.extern kernel_main

_start:
    # Disable interrupts.
    li t0, 0
    csrw mie, t0
    csrw mstatus, t0

    # Set up stack.
    la sp, __stack_top

    # Clear .bss.
    la t0, __bss_start
    la t1, __bss_end
1:
    bgeu t0, t1, 2f
    sd zero, 0(t0)
    addi t0, t0, 8
    j 1b
2:
    # Jump to kernel.
    la t0, kernel_main
    jr t0
