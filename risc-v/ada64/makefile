# Makefile for RV64 Ada bootloader + kernel

ADA_CC = riscv64-unknown-elf-gnatgcc
LD = riscv64-unknown-elf-ld
OBJCOPY = riscv64-unknown-elf-objcopy

KERNEL = kernel

BOOTLOADER_SRC = bootloader.adb
KERNEL_SRC = kernel.adb
OBJS = bootloader.o kernel.o

ADAFLAGS = -O2 -gnatp -ffreestanding -fno-builtin -march=rv64imac_zicsr -mabi=lp64 -mcmodel=medany
LDFLAGS = -T linker.ld -nostdlib -m elf64lriscv

all: $(KERNEL).elf

bootloader.o: $(BOOTLOADER_SRC)
	$(ADA_CC) $(ADAFLAGS) -c -o $@ $(BOOTLOADER_SRC)

kernel.o: $(KERNEL_SRC)
	$(ADA_CC) $(ADAFLAGS) -c -o $@ $(KERNEL_SRC)

$(KERNEL).elf: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)
	$(OBJCOPY) -O binary $@ $(KERNEL)

qemu: $(KERNEL).elf
	qemu-system-riscv64 \
		-machine virt \
		-nographic \
		-bios none \
		-kernel $(KERNEL).elf \
		-smp 1 \
		-m 128M

clean:
	rm -f $(KERNEL) *.o *.elf

.PHONY: all qemu clean
