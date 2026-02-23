# Makefile for RV64 bootloader and kernel

CC = riscv64-unknown-elf-gcc
AS = riscv64-unknown-elf-as
LD = riscv64-unknown-elf-ld
OBJCOPY = riscv64-unknown-elf-objcopy
ADA_CC = riscv64-unknown-elf-gnatgcc

# Target names
KERNEL = kernel
KERNEL_ADA = kernel_ada

# Source files
BOOTLOADER_SRC = bootloader.S
KERNEL_SRC = kernel.c
KERNEL_ADA_SRC = kernel.adb
KERNEL_OBJS = bootloader.o kernel.o
KERNEL_ADA_OBJS = bootloader.o kernel_ada.o

# Compiler flags
CFLAGS = -Wall -Wextra -O2 -march=rv64imac_zicsr -mabi=lp64 -mcmodel=medany
ASFLAGS = -march=rv64imac_zicsr
LDFLAGS = -T linker.ld -nostdlib -m elf64lriscv
ADAFLAGS = -Wall -O2 -gnatp -march=rv64imac_zicsr -mabi=lp64 -mcmodel=medany

# Default target
all: $(KERNEL).elf

ada: $(KERNEL_ADA).elf

bootloader.o: $(BOOTLOADER_SRC)
	$(AS) $(ASFLAGS) -o $@ $(BOOTLOADER_SRC)

kernel.o: $(KERNEL_SRC)
	$(CC) $(CFLAGS) -c -o $@ $(KERNEL_SRC)

kernel_ada.o: $(KERNEL_ADA_SRC)
	$(ADA_CC) $(ADAFLAGS) -c -o $@ $(KERNEL_ADA_SRC)

$(KERNEL).elf: $(KERNEL_OBJS)
	$(LD) $(LDFLAGS) -o $@ $(KERNEL_OBJS)
	$(OBJCOPY) -O binary $@ $(KERNEL)

$(KERNEL_ADA).elf: $(KERNEL_ADA_OBJS)
	$(LD) $(LDFLAGS) -o $@ $(KERNEL_ADA_OBJS)
	$(OBJCOPY) -O binary $@ $(KERNEL_ADA)

# Test with QEMU
qemu: $(KERNEL).elf
	qemu-system-riscv64 \
		-machine virt \
		-nographic \
		-bios none \
		-kernel $(KERNEL).elf \
		-smp 1 \
		-m 128M

qemu-ada: $(KERNEL_ADA).elf
	qemu-system-riscv64 \
		-machine virt \
		-nographic \
		-bios none \
		-kernel $(KERNEL_ADA).elf \
		-smp 1 \
		-m 128M

# Clean
clean:
	rm -f $(KERNEL) $(KERNEL_ADA) *.o *.elf

.PHONY: all ada qemu qemu-ada clean
