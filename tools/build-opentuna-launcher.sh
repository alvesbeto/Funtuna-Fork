#!/usr/bin/env bash
# Rebuild Opentuna launcher payload and refresh exploit payload.bin.
# PAYLOAD=launcher-keys-Funtuna (default) or launcher-no-keys-Funtuna.
# Requires PS2SDK; ps2-packer native (PS2DEV) or wine for ps2_packer.exe.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# launcher-keys-Funtuna (Circle/Cross shortcuts) or launcher-no-keys-Funtuna (BOOT.ELF only)
PAYLOAD="${PAYLOAD:-launcher-keys-Funtuna}"

if [[ -z "${PS2SDK:-}" ]] || ! command -v mips64r5900el-ps2-elf-gcc >/dev/null 2>&1; then
  echo "PS2SDK not configured or mips64r5900el-ps2-elf-gcc missing. Set PS2DEV/PS2SDK/PATH (see ~/.zshrc)." >&2
  exit 1
fi

echo "==> Building payload: opentuna/${PAYLOAD}"
make -C "${ROOT}/opentuna/${PAYLOAD}" clean all

echo "==> Building exploit embed (payload.bin)"
make -C "${ROOT}/opentuna/exploit" all

echo "Built: opentuna/exploit/payload.bin"
echo ""
echo "ENTRYPOINT icons (slims.bin, fats.bin, 170.bin) use per-model OpenTuna builds."
echo "After producing each .bin, copy into:"
echo "  installer/INSTALLER_CONTENTS/ENTRYPOINT/"
echo "Then run: tools/sync-installer-manifest.sh"
echo "Then rebuild installer: make -C installer clean all"
