#!/usr/bin/env bash
# Host tools missing from prebuilt ps2dev tarball + ps2-packer layout fix.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PS2DEV="${PS2DEV:-$HOME/ps2dev}"

mkdir -p "$PS2DEV/bin"
gcc -O2 -o "$PS2DEV/bin/bin2s" "$ROOT/tools/host-bin2s.c"

if [[ -f /tmp/ps2sdk-src/tools/bin2c/src/bin2c.c ]]; then
  gcc -O2 -o "$PS2DEV/bin/bin2c" /tmp/ps2sdk-src/tools/bin2c/src/bin2c.c
else
  echo "Optional: clone ps2sdk to build bin2c (not required if bin2s works)."
fi

PACKER_DIR="$PS2DEV/share/ps2-packer"
if [[ -d "$PACKER_DIR/module" ]]; then
  ln -sf module/lzma-packer.so "$PACKER_DIR/lzma-packer.so"
  echo "Linked $PACKER_DIR/lzma-packer.so"
fi

for cmd in gcc g++ as ld ar objcopy strip ranlib; do
  target="$PS2DEV/ee/bin/mips64r5900el-ps2-elf-$cmd"
  link="$PS2DEV/bin/ee-$cmd"
  if [[ -x "$target" ]]; then
    ln -sf "$target" "$link"
  fi
done

if [[ ! -f "$PS2DEV/ps2sdk-src/iop/Rules.release" ]]; then
  echo "Cloning ps2sdk source for IOP builds (PS2SDKSRC)..."
  git clone --depth 1 https://github.com/ps2dev/ps2sdk "$PS2DEV/ps2sdk-src"
fi
echo "Set PS2SDKSRC=$PS2DEV/ps2sdk-src in ~/.zshrc for FreeMcBoot init/chkesr rebuilds."
