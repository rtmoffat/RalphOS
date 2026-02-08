#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT_DIR/x86/EFI/64/ralphos.asm"
OUTDIR="$ROOT_DIR/x86/EFI/64"
OBJ="$OUTDIR/ralphos.obj"
EFI="$OUTDIR/BOOTX64.EFI"

if [[ ! -f "$SRC" ]]; then
  echo "Source not found: $SRC" >&2
  exit 1
fi

echo "Building UEFI x64 loader..."
ml64 /c /Fo"$OBJ" "$SRC"

link /subsystem:efi_application /entry:EFI_MAIN /out:"$EFI" "$OBJ"

echo "Built: $EFI"
