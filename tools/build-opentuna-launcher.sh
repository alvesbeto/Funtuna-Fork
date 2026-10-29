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

if [[ "${REGENERATE_ENTRYPOINT:-0}" == "1" ]]; then
  echo "==> ENTRYPOINT icons (OpenTuna RLE)"
  "${ROOT}/tools/regenerate-entrypoint-icons.sh"
else
  cp "${ROOT}/opentuna/exploit/payload.bin" "${ENTRY}/exploit.bin"

  STATIC_SYS="${ROOT}/tools/opentuna-static/exploit.sys"
  if [[ -s "${STATIC_SYS}" && ! -s "${ENTRY}/exploit.sys" ]]; then
    cp "${STATIC_SYS}" "${ENTRY}/exploit.sys"
  fi

  # Optional git fallback for dev offline (legacy tuned icons; may not match current payload size).
  ENTRYPOINT_FALLBACK_REF="${ENTRYPOINT_FALLBACK_REF:-bf0b012}"
  for f in exploit.sys slims.bin fats.bin 170.bin; do
    if [[ ! -s "${ENTRY}/${f}" ]]; then
      if git show "${ENTRYPOINT_FALLBACK_REF}:installer/INSTALLER_CONTENTS/ENTRYPOINT/${f}" > "${ENTRY}/${f}" 2>/dev/null; then
        echo "Restored ${f} from git ${ENTRYPOINT_FALLBACK_REF} (run REGENERATE_ENTRYPOINT=1 after launcher changes)."
      else
        echo "Missing ${ENTRY}/${f} — set REGENERATE_ENTRYPOINT=1 or restore blob." >&2
        exit 1
      fi
    fi
  done

  echo "Built: opentuna/exploit/payload.bin → ${ENTRY}/exploit.bin"
fi
