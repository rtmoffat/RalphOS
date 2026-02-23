#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

make clean
make

qemu-system-riscv64 \
  -machine virt \
  -nographic \
  -bios none \
  -kernel kernel.elf \
  -smp 1 \
  -m 128M
