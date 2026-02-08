# Makefile for RISC-V bootloader and kernel

CC = riscv64-unknown-elf-gcc
AS = riscv64-unknown-elf-as
LD = riscv64-unknown-elf-ld
OBJCOPY = riscv64-unknown-elf-objcopy

# Target names
KERNEL = kernel

# Source files
BOOTLOADER_SRC = bootloader.S
KERNEL_SRC = kernel.c
KERNEL_OBJS = bootloader.o kernel.o

# Compiler flags
CFLAGS = -Wall -Wextra -O2 -march=rv32im_zicsr -mabi=ilp32
ASFLAGS = -march=rv32im_zicsr
LDFLAGS = -T linker.ld -nostdlib -nostartfiles -m elf32lriscv

# Default target
all: $(KERNEL).elf

bootloader.o: $(BOOTLOADER_SRC)
	$(AS) $(ASFLAGS) -o $@ $(BOOTLOADER_SRC)

kernel.o: $(KERNEL_SRC)
	$(CC) $(CFLAGS) -c -o $@ $(KERNEL_SRC)

$(KERNEL).elf: $(KERNEL_OBJS)
	$(LD) $(LDFLAGS) -o $@ $(KERNEL_OBJS)
	$(OBJCOPY) -O binary $@ $(KERNEL)

# Test with QEMU
qemu: $(KERNEL).elf
	qemu-system-riscv64 \
		-machine virt \
		-nographic \
		-kernel $(KERNEL).elf \
		-smp 1 \
		-m 128M

# Clean
clean:
	rm -f $(KERNEL) *.o *.elf

.PHONY: all qemu clean
