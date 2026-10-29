#!/usr/bin/env bash
# Full local path: PS2 subprojects → installer embeds → __Binaries → variant BOOT trees → manifest.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

echo "==> Vendor blobs (IRX / ULE / OPL / checks)"
export VENDOR_REFRESH="${VENDOR_REFRESH:-1}"
"${ROOT}/tools/bootstrap-installer-vendor.sh"

BUILD_OPENTUNA="${BUILD_OPENTUNA:-0}"
SKIP_INSTALLER="${SKIP_INSTALLER:-0}"

if [[ -z "${PS2SDK:-}" ]] || ! command -v mips64r5900el-ps2-elf-gcc >/dev/null 2>&1; then
  echo "PS2SDK not configured. Source ~/.zshrc or set PS2DEV/PS2SDK/PATH." >&2
  exit 1
fi

export PS2SDKSRC="${PS2SDKSRC:-${PS2DEV:-$HOME/ps2dev}/ps2sdk-src}"
if [[ ! -f "${PS2SDKSRC}/Defs.make" ]]; then
  echo "PS2SDKSRC missing or invalid (${PS2SDKSRC}). Clone ps2sdk-src or set PS2SDKSRC." >&2
  exit 1
fi

echo "==> FreeMcBoot (BOOT.ELF)"
make -C FreeMcBoot clean all

echo "==> FreeMcBoot-Configurator (CFG.ELF)"
make -C FreeMcBoot-Configurator clean all

INSTALLER_BOOT="${ROOT}/installer/INSTALLER_CONTENTS/BOOT"
mkdir -p "${ROOT}/__Binaries" "${INSTALLER_BOOT}"

cp "${ROOT}/FreeMcBoot/BOOT.ELF" "${INSTALLER_BOOT}/BOOT.ELF"
cp "${ROOT}/FreeMcBoot/BOOT.ELF" "${ROOT}/__Binaries/BOOT.ELF"
cp "${ROOT}/FreeMcBoot-Configurator/CFG.ELF" "${INSTALLER_BOOT}/CFG.ELF"
cp "${ROOT}/FreeMcBoot-Configurator/CFG.ELF" "${ROOT}/__Binaries/CFG.ELF"

if [[ "${BUILD_OPENTUNA}" == "1" ]]; then
  echo "==> Opentuna launcher + exploit"
  "${ROOT}/tools/build-opentuna-launcher.sh"
fi

if [[ "${SKIP_INSTALLER}" != "1" ]]; then
  echo "==> Installer"
  make -C installer clean all
fi

echo "==> Release variant BOOT/ (from __Binaries + FUNTUNA.CNF)"
"${ROOT}/tools/prepare-release-variants.sh"

echo "==> Manifest"
"${ROOT}/tools/sync-installer-manifest.sh"

echo ""
echo "Done. Next steps:"
echo "  - Commit updated embeds / __Binaries / manifest if intentional"
echo "  - GitHub: workflow_dispatch stable.yml OR repack-and-release.yml (see .agents/specs/CI_WORKFLOWS.md)"
