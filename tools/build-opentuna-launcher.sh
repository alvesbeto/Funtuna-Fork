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

ENTRY="${ROOT}/installer/INSTALLER_CONTENTS/ENTRYPOINT"
mkdir -p "${ENTRY}"
cp "${ROOT}/opentuna/exploit/payload.bin" "${ENTRY}/exploit.bin"

# Icon/exploit.sys per model: rebuild with OpenTuna RLE when changed; keep existing files if present.
for f in exploit.sys slims.bin fats.bin 170.bin; do
  if [[ ! -s "${ENTRY}/${f}" ]]; then
    if git show bf0b012:"installer/INSTALLER_CONTENTS/ENTRYPOINT/${f}" > "${ENTRY}/${f}" 2>/dev/null; then
      echo "Restored ${f} from git bf0b012 (replace after RLE rebuild)."
    else
      echo "Missing ${ENTRY}/${f} — build OpenTuna entrypoint or restore blob." >&2
      exit 1
    fi
  fi
done

echo "Built: opentuna/exploit/payload.bin → ${ENTRY}/exploit.bin"
