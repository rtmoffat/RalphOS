# RalphOS

Making my own OS

## risc-v
Run make -C risc-v
Run make -C risc-v qemu

## Simple BIOS Bootloader (for QEMU Testing)

A minimal bootloader that displays "hello" on screen.

### Prerequisites
- NASM assembler (download from https://www.nasm.us/)
- QEMU (download from https://www.qemu.org/download/)

### Build and Run
```batch
build_bootloader.bat
run_qemu.bat
```

Or manually:
```batch
nasm -f bin bootloader.asm -o bootloader.bin
qemu-system-x86_64 -drive format=raw,file=bootloader.bin
```

## UEFI Bootloader (for Physical Hardware)

Use x64 Native Tools Command Prompt for VS 2022 to build this

ml64 /c ralphos.asm
link /subsystem:efi_application /entry:EFI_MAIN /out:BOOTX64.EFI ralphos.obj
```

Note: The output **must** be named `BOOTX64.EFI` for x64 systems (or `BOOTIA32.EFI` for 32-bit).

## Step 2: Format the USB Drive

1. **Format as FAT32** (UEFI requires FAT32)
   - Right-click the USB drive in File Explorer
   - Select Format
   - File system: **FAT32**
   - Click Start

## Step 3: Create the EFI Directory Structure

On the USB drive, create this exact folder structure:
```
USB Drive:\
└── EFI\
    └── BOOT\
        └── BOOTX64.EFI  (your compiled file goes here)