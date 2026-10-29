#!/usr/bin/env bash
# Record SHA-256 of installer ENTRYPOINT blobs and INSTALLER_CONTENTS/BOOT for drift checks.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="${ROOT}/.agents/specs/manifests/installer-content.sha256"
ENTRY="${ROOT}/installer/INSTALLER_CONTENTS/ENTRYPOINT"
BOOT="${ROOT}/installer/INSTALLER_CONTENTS/BOOT"
SYSCONF="${ROOT}/installer/INSTALLER_CONTENTS/SYS-CONF"
APPS="${ROOT}/installer/INSTALLER_CONTENTS/APPS"
OPL="${ROOT}/installer/INSTALLER_CONTENTS/OPL"

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
  if [[ -d "$APPS" ]]; then
    (cd "$APPS" && sha256sum OPNPS2LD.ELF 2>/dev/null || true)
  fi
  if [[ -d "$OPL" ]]; then
    (cd "$OPL" && sha256sum conf_opl.cfg conf_opl1.cfg conf_game.cfg conf_apps.cfg 2>/dev/null || true)
  fi
} > "$MANIFEST"

echo "Wrote $MANIFEST"
cat "$MANIFEST"
