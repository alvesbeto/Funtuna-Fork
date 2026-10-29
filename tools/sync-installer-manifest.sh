#!/usr/bin/env bash
# Record SHA-256 of installer ENTRYPOINT blobs and INSTALLER_CONTENTS/BOOT for drift checks.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="${ROOT}/.agents/specs/manifests/installer-content.sha256"
ENTRY="${ROOT}/installer/INSTALLER_CONTENTS/ENTRYPOINT"
BOOT="${ROOT}/installer/INSTALLER_CONTENTS/BOOT"
SYSCONF="${ROOT}/installer/INSTALLER_CONTENTS/SYS-CONF"

mkdir -p "$(dirname "$MANIFEST")"
{
  echo "# Generated $(date -u +%Y-%m-%dT%H:%M:%SZ) — verify after rebuilding embeds"
  if [[ -d "$ENTRY" ]]; then
    (cd "$ENTRY" && sha256sum exploit.sys slims.bin fats.bin 170.bin 2>/dev/null || true)
  fi
  if [[ -d "$BOOT" ]]; then
    (cd "$BOOT" && sha256sum BOOT.ELF CFG.ELF FUNTUNA.CNF ULE.ELF 2>/dev/null || true)
  fi
  if [[ -d "$SYSCONF" ]]; then
    (cd "$SYSCONF" && sha256sum USBD.IRX USBHDFSD.IRX 2>/dev/null || true)
  fi
} > "$MANIFEST"

echo "Wrote $MANIFEST"
cat "$MANIFEST"
