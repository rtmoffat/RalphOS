    .option norvc
    .section .text
    .globl _start

/* QEMU virt UART0 (NS16550A) base */
.equ UART0,       0x10000000
.equ UART_THR,    0x00        /* Transmit Holding Register (write) */
.equ UART_LSR,    0x05        /* Line Status Register */
.equ LSR_TX_IDLE, 0x20        /* THR empty */

_start:
    /* Set up a stack (must point to valid RAM) */
    la   sp, stack_top

    /* Print "hello\r\n" */
    la   a0, msg
1:  lbu  a1, 0(a0)
    beqz a1, 2f
    call uart_putc
    addi a0, a0, 1
    j    1b
2:
    /* Hang forever */
3:  wfi
    j    3b

/* uart_putc(a1 = byte) */
uart_putc:
    /* Poll until TX holding register is empty */
4:  li   t0, UART0
    lbu  t1, UART_LSR(t0)
    andi t1, t1, LSR_TX_IDLE
    beqz t1, 4b

    /* Write byte to THR */
    sb   a1, UART_THR(t0)
    ret

    .section .rodata
msg:
    .asciz "hello\r\n"

    .section .bss
    .align 12
stack:
    .space 4096
stack_top:
