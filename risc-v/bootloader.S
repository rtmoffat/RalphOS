# Simple RISC-V Bootloader for QEMU
# This bootloader loads a kernel from the first sector of a disk

.section .text
.global _start

_start:
    # Disable interrupts
    li x1, 0
    csrw mie, x1        # Clear machine interrupt enable register
    csrw mstatus, x1    # Clear machine status register

    # Set up stack pointer (8KB stack at 0x80000000)
    li x2, 0x80002000
    mv sp, x2

    # Load kernel from disk (first sector)
    li x10, 0x80000000  # Kernel load address
    li x11, 0x10000000  # Disk address (first sector)
    li x12, 512         # Number of bytes to load

load_loop:
    beq x12, x0, load_done
    lw x13, 0(x11)      # Load word from disk
    sw x13, 0(x10)      # Store word to kernel address
    addi x10, x10, 4    # Increment kernel address
    addi x11, x11, 4    # Increment disk address
    addi x12, x12, -4   # Decrement byte counter
    j load_loop

load_done:
    # Jump to kernel
    li x10, 0x80000000  # Kernel entry point
    jr x10              # Jump to kernel

# Simple kernel to test the bootloader
.section .text.kernel
.global kernel_start

kernel_start:
    # Simple kernel that just loops
    li x10, 0x80000000  # Kernel entry point
    li x11, 0x80000000  # Another copy for comparison
    
    # Simple loop to show execution
    li x12, 100000000   # Counter
    
loop:
    addi x12, x12, -1
    bnez x12, loop
    
    # Infinite loop
    j kernel_start

# Bootloader data section
.section .data
    .align 4
    .word 0x00000000    # Padding to align to 4-byte boundary

# Bootloader BSS section
.section .bss
    .space 8192         # 8KB of uninitialized data (for stack)
