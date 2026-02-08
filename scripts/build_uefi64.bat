@echo off
setlocal

set ROOT=%~dp0..
set SRC=%ROOT%\x86\EFI\64\ralphos.asm
set OUTDIR=%ROOT%\x86\EFI\64
set OBJ=%OUTDIR%\ralphos.obj
set EFI=%OUTDIR%\BOOTX64.EFI

if not exist "%SRC%" (
    echo Source not found: %SRC%
    exit /b 1
)

echo Building UEFI x64 loader...
ml64 /c /Fo"%OBJ%" "%SRC%"
if %errorlevel% neq 0 (
    echo Assemble failed!
    exit /b 1
)

link /subsystem:efi_application /entry:EFI_MAIN /out:"%EFI%" "%OBJ%"
if %errorlevel% neq 0 (
    echo Link failed!
    exit /b 1
)

echo Built: %EFI%
