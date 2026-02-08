@echo off
setlocal

set ROOT=%~dp0..
set EFI=%ROOT%\x86\EFI\64\BOOTX64.EFI
set ESPDIR=%ROOT%\build\uefi\ESP
set OVMF_CODE=%ROOT%\scripts\ovmf\OVMF_CODE.fd
set OVMF_VARS=%ROOT%\scripts\ovmf\OVMF_VARS.fd

if not exist "%EFI%" (
    echo BOOTX64.EFI not found. Building first...
    call "%ROOT%\scripts\build_uefi64.bat"
    if %errorlevel% neq 0 exit /b 1
)

if not exist "%OVMF_CODE%" if defined OVMF_CODE_PATH set OVMF_CODE=%OVMF_CODE_PATH%
if not exist "%OVMF_VARS%" if defined OVMF_VARS_PATH set OVMF_VARS=%OVMF_VARS_PATH%

if not exist "%OVMF_CODE%" (
    echo OVMF_CODE.fd not found.
    echo Place it at %ROOT%\scripts\ovmf\OVMF_CODE.fd
    echo Or set OVMF_CODE_PATH to its full path.
    exit /b 1
)

if not exist "%OVMF_VARS%" (
    echo OVMF_VARS.fd not found.
    echo Place it at %ROOT%\scripts\ovmf\OVMF_VARS.fd
    echo Or set OVMF_VARS_PATH to its full path.
    exit /b 1
)

if not exist "%ESPDIR%\EFI\BOOT" mkdir "%ESPDIR%\EFI\BOOT"
copy /y "%EFI%" "%ESPDIR%\EFI\BOOT\BOOTX64.EFI" >nul

echo Starting QEMU (UEFI)...
qemu-system-x86_64 ^
  -drive if=pflash,format=raw,readonly=on,file="%OVMF_CODE%" ^
  -drive if=pflash,format=raw,file="%OVMF_VARS%" ^
  -drive format=raw,file=fat:rw:"%ESPDIR%"
