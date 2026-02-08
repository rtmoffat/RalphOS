# Makefile for RISC-V bootloader and kernel

CC = riscv64-unknown-elf-gcc
AS = riscv64-unknown-elf-as
LD = riscv64-unknown-elf-ld
OBJCOPY = riscv64-unknown-elf-objcopy

# Target names
BOOTLOADER = bootloader
KERNEL = kernel
IMAGE = boot-image

# Source files
BOOTLOADER_SRC = bootloader.S
KERNEL_SRC = kernel.c

# Compiler flags
CFLAGS = -Wall -Wextra -O2 -march=rv32im -mabi=ilp32
ASFLAGS = -march=rv32im
LDFLAGS = -T linker.ld -nostdlib -nostartfiles

# Default target
all: $(IMAGE)

# Build bootloader
$(BOOTLOADER): $(BOOTLOADER_SRC)
	$(AS) $(ASFLAGS) -o $(BOOTLOADER).o $(BOOTLOADER_SRC)
	$(LD) $(LDFLAGS) -o $(BOOTLOADER).elf $(BOOTLOADER).o
	$(OBJCOPY) -O binary $(BOOTLOADER).elf $(BOOTLOADER)

# Build kernel (if you have one)
$(KERNEL): $(KERNEL_SRC)
	$(CC) $(CFLAGS) -c -o $(KERNEL).o $(KERNEL_SRC)
	$(LD) $(LDFLAGS) -o $(KERNEL).elf $(KERNEL).o
	$(OBJCOPY) -O binary $(KERNEL).elf $(KERNEL)

# Create combined image
$(IMAGE): $(BOOTLOADER) $(KERNEL)
	# Create a 512-byte disk image with bootloader and kernel
	dd if=/dev/zero of=$(IMAGE) bs=512 count=1
	# Copy bootloader to first 512 bytes
	dd if=$(BOOTLOADER) of=$(IMAGE) bs=1 conv=notrunc

# Test with QEMU
qemu: $(IMAGE)
	qemu-system-riscv64 \
		-machine virt \
		-nographic \
		-bios $(IMAGE) \
		-smp 1 \
		-m 128M

# Clean
clean:
	rm -f $(BOOTLOADER) $(KERNEL) $(IMAGE) *.o *.elf

.PHONY: all qemu clean
