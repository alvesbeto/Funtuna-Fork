#!/usr/bin/env bash
# Create __Release variant BOOT/ trees from __Binaries + installer FUNTUNA.CNF seed.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="${ROOT}/__Binaries"
INSTALLER_BOOT="${ROOT}/installer/INSTALLER_CONTENTS/BOOT"

VARIANTS=(
  "!Funtuna-Basic"
  "!Funtuna-Clean"
  "!Funtuna-Basic - Light"
)

# Copied by stable.yml Repack job (BOOT layer only).
BOOT_FILES=(
  BOOT.ELF
  CFG.ELF
  LAUNCHELF.CNF
  POWEROFF.ELF
  USBD.IRX
  USBHDFSD.IRX
  ULE.ELF
  SYSTEM.icn
  icon.sys
  FUNTUNA.CNF
)

resolve_src() {
  local name="$1"
  if [[ -f "${BIN}/${name}" ]]; then
    echo "${BIN}/${name}"
    return 0
  fi
  if [[ -f "${INSTALLER_BOOT}/${name}" ]]; then
    echo "${INSTALLER_BOOT}/${name}"
    return 0
  fi
  echo "Missing ${name} (expected in __Binaries/ or installer/INSTALLER_CONTENTS/BOOT/)" >&2
  return 1
}

for variant in "${VARIANTS[@]}"; do
  dest="${ROOT}/__Release/${variant}/BOOT"
  mkdir -p "${dest}"
  for f in "${BOOT_FILES[@]}"; do
    src="$(resolve_src "${f}")"
    cp "${src}" "${dest}/${f}"
  done
  echo "Prepared ${dest}"
done
