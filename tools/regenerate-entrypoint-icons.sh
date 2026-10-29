#!/usr/bin/env bash
# Regenerate OpenTuna ENTRYPOINT icons (slims.bin / fats.bin / 170.bin) via OpenTuna RLE.
# Requires: Java, opentuna/exploit/payload.bin (run tools/build-opentuna-launcher.sh first).
#
# Per-model RLE tuning (return-address repetitions) is NOT automated — after a payload size
# change, all three bins start as the same fresh encode; validate on hardware and tune copies
# (see tools/opentuna-tuned-icons/README.md).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RLE_DIR="${ROOT}/tools/OpenTuna RLE"
ENTRY="${ROOT}/installer/INSTALLER_CONTENTS/ENTRYPOINT"
PAYLOAD="${ROOT}/opentuna/exploit/payload.bin"
STATIC_SYS="${ROOT}/tools/opentuna-static/exploit.sys"
JAR="${RLE_DIR}/OpenTunaRLE.jar"

TUNED_ICONS_DIR="${TUNED_ICONS_DIR:-}"
COPY_SAME="${COPY_SAME:-0}"

if ! command -v java >/dev/null 2>&1; then
  echo "java not found — install a JRE to run OpenTuna RLE." >&2
  exit 1
fi
if [[ ! -f "${JAR}" ]]; then
  echo "Missing ${JAR}" >&2
  exit 1
fi
if [[ ! -s "${PAYLOAD}" ]]; then
  echo "Missing ${PAYLOAD} — run: tools/build-opentuna-launcher.sh" >&2
  exit 1
fi
if [[ ! -s "${STATIC_SYS}" ]]; then
  echo "Missing ${STATIC_SYS} (vendor exploit.sys for icon.sys embed)." >&2
  exit 1
fi

mkdir -p "${ENTRY}"

rle_encode() {
  local payload="$1" out="$2"
  (cd "${RLE_DIR}" && java -jar OpenTunaRLE.jar -e "${payload}" "${out}")
}

rle_decode_to() {
  local icn="$1" out="$2"
  (cd "${RLE_DIR}" && java -jar OpenTunaRLE.jar -d "${icn}" "${out}")
}

payload_size="$(wc -c < "${PAYLOAD}" | tr -d ' ')"
echo "==> OpenTuna RLE encode (payload ${payload_size} bytes)"

work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT

base_icn="${work}/base.icn"
rle_encode "${PAYLOAD}" "${base_icn}"
base_size="$(wc -c < "${base_icn}" | tr -d ' ')"
echo "    base icon.icn → ${base_size} bytes"

icon_kept=0
icon_fresh=0

install_variant() {
  local name="$1"
  local dst="${ENTRY}/${name}"

  if [[ -n "${TUNED_ICONS_DIR}" && -s "${TUNED_ICONS_DIR}/${name}" ]]; then
    cp "${TUNED_ICONS_DIR}/${name}" "${dst}"
    echo "    ${name}: from TUNED_ICONS_DIR"
    return
  fi

  if [[ "${COPY_SAME}" != "1" && -s "${dst}" ]]; then
    local decoded="${work}/dec-${name}"
    if rle_decode_to "${dst}" "${decoded}" 2>/dev/null; then
      local dec_size="$(wc -c < "${decoded}" | tr -d ' ')"
      if [[ "${dec_size}" == "${payload_size}" ]]; then
        echo "    ${name}: kept (decode ${dec_size} B matches payload)"
        icon_kept=$((icon_kept + 1))
        return
      fi
    fi
  fi

  cp "${base_icn}" "${dst}"
  echo "    ${name}: fresh encode (needs hardware / per-model tuning if exploit fails)"
  icon_fresh=$((icon_fresh + 1))
}

install_variant "slims.bin"
install_variant "fats.bin"
install_variant "170.bin"

cp "${PAYLOAD}" "${ENTRY}/exploit.bin"
cp "${STATIC_SYS}" "${ENTRY}/exploit.sys"

echo "==> ENTRYPOINT updated (kept ${icon_kept}, fresh ${icon_fresh})"
if [[ "${icon_fresh}" -gt 0 && -z "${TUNED_ICONS_DIR}" ]]; then
  echo ""
  echo "WARNING: ${icon_fresh} icon(s) are identical base encodes — test SLIMS / FATS / FAT170 on real hardware."
  echo "         Drop tuned slims.bin, fats.bin, 170.bin into TUNED_ICONS_DIR=... and re-run, or hex-tune per PSX-Place RLE notes."
fi
