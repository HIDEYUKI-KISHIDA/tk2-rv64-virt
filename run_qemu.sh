#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")"
exec qemu-system-riscv64 \
  -machine virt,acpi=off \
  -cpu rv64 \
  -m 128M \
  -display none \
  -serial mon:stdio \
  -bios none \
  -kernel tk2-rv64.elf
