@echo off
REM Run the bootloader in QEMU

if not exist bootloader.bin (
    echo bootloader.bin not found!
    echo Please run build_bootloader.bat first
    exit /b 1
)

echo Starting QEMU with bootloader...
qemu-system-x86_64 -drive format=raw,file=bootloader.bin
