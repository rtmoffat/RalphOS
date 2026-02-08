@echo off
REM Build script for the bootloader
REM Requires NASM assembler

echo Building bootloader...
nasm -f bin bootloader.asm -o bootloader.bin

if %errorlevel% neq 0 (
    echo Build failed!
    exit /b 1
)

echo Build successful! bootloader.bin created.
echo.
echo To test with QEMU, run:
echo qemu-system-x86_64 -drive format=raw,file=bootloader.bin
echo.
echo Or simply run: run_qemu.bat
