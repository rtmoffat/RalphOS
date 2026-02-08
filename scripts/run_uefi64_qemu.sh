#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EFI="$ROOT_DIR/x86/EFI/64/BOOTX64.EFI"
ESP_DIR="$ROOT_DIR/build/uefi/ESP"
OVMF_CODE="$ROOT_DIR/scripts/ovmf/OVMF_CODE.fd"
OVMF_VARS="$ROOT_DIR/scripts/ovmf/OVMF_VARS.fd"

if [[ ! -f "$EFI" ]]; then
  echo "BOOTX64.EFI not found. Building first..."
  "$ROOT_DIR/scripts/build_uefi64.sh"
fi

if [[ ! -f "$OVMF_CODE" && -n "${OVMF_CODE_PATH:-}" ]]; then
  OVMF_CODE="$OVMF_CODE_PATH"
fi

if [[ ! -f "$OVMF_VARS" && -n "${OVMF_VARS_PATH:-}" ]]; then
  OVMF_VARS="$OVMF_VARS_PATH"
fi

if [[ ! -f "$OVMF_CODE" ]]; then
  echo "OVMF_CODE.fd not found." >&2
  echo "Place it at $ROOT_DIR/scripts/ovmf/OVMF_CODE.fd" >&2
  echo "Or set OVMF_CODE_PATH to its full path." >&2
  exit 1
fi

if [[ ! -f "$OVMF_VARS" ]]; then
  echo "OVMF_VARS.fd not found." >&2
  echo "Place it at $ROOT_DIR/scripts/ovmf/OVMF_VARS.fd" >&2
  echo "Or set OVMF_VARS_PATH to its full path." >&2
  exit 1
fi

mkdir -p "$ESP_DIR/EFI/BOOT"
cp -f "$EFI" "$ESP_DIR/EFI/BOOT/BOOTX64.EFI"

echo "Starting QEMU (UEFI)..."
qemu-system-x86_64 \
  -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
  -drive if=pflash,format=raw,file="$OVMF_VARS" \
  -drive format=raw,file=fat:rw:"$ESP_DIR"
