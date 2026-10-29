#!/usr/bin/env bash
# Ensure vendor blobs under INSTALLER_CONTENTS exist (not built from this repo's Makefiles).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOOT="${ROOT}/installer/INSTALLER_CONTENTS/BOOT"
APPS="${ROOT}/installer/INSTALLER_CONTENTS/APPS"

ULE_URL="${ULE_URL:-https://github.com/israpps/wLaunchELF_ISR/releases/download/latest/BOOT-DS34.ELF}"
OPL_URL="${OPL_URL:-https://github.com/ps2homebrew/Open-PS2-Loader/releases/download/latest/OPNPS2LD.ELF}"

# Set VENDOR_REFRESH=1 to re-download release ELFs (build-release-local.sh does this).
VENDOR_REFRESH="${VENDOR_REFRESH:-0}"

download_url() {
  local url="$1"
  local dest="$2"
  local label="$3"

  if [[ -f "${dest}" && "${VENDOR_REFRESH}" != "1" ]]; then
    return 0
  fi

  mkdir -p "$(dirname "${dest}")"
  if command -v wget >/dev/null 2>&1; then
    wget -q -O "${dest}" "${url}"
  elif command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "${dest}" "${url}"
  else
    echo "Need wget or curl to fetch ${label} (${dest})." >&2
    return 1
  fi
  echo "Downloaded ${label} from ${url}"
}

copy_irx_from_ps2sdk() {
  local name="$1"
  local dest="${BOOT}/${name}"
  [[ -f "${dest}" ]] && return 0
  [[ -n "${PS2SDK:-}" ]] || {
    echo "Missing ${dest} and PS2SDK unset (cannot copy ${name} from SDK)." >&2
    return 1
  }
  local candidates=(
    "${PS2SDK}/iop/irx/${name}"
    "${PS2SDK}/ports/usbmass/irx/${name}"
    "${PS2SDK}/ports/usb/irx/${name}"
  )
  local src=""
  for c in "${candidates[@]}"; do
    if [[ -f "${c}" ]]; then
      src="${c}"
      break
    fi
  done
  if [[ -z "${src}" ]]; then
    src="$(find "${PS2SDK}" -name "${name}" -type f 2>/dev/null | head -1 || true)"
  fi
  if [[ -z "${src}" || ! -f "${src}" ]]; then
    echo "Missing ${dest}; install PS2SDK IRX or place file manually." >&2
    return 1
  fi
  cp "${src}" "${dest}"
  echo "Copied ${name} from ${src}"
}

require_file() {
  local path="$1"
  local hint="$2"
  if [[ ! -f "${path}" ]]; then
    echo "Missing ${path} — ${hint}" >&2
    return 1
  fi
}

mkdir -p "${BOOT}" "${APPS}"

copy_irx_from_ps2sdk USBD.IRX
copy_irx_from_ps2sdk USBHDFSD.IRX

download_url "${ULE_URL}" "${BOOT}/ULE.ELF" "ULE.ELF (wLaunchELF_ISR latest)"
download_url "${OPL_URL}" "${APPS}/OPNPS2LD.ELF" "OPNPS2LD.ELF (Open-PS2-Loader latest)"

require_file "${BOOT}/FUNTUNA.CNF" "FunTuna settings seed (tracked in git)"
require_file "${BOOT}/LAUNCHELF.CNF" "uLaunchELF config (tracked in git)"
require_file "${BOOT}/POWEROFF.ELF" "power-off helper (tracked vendor ELF)"
require_file "${APPS}/OPNPS2LD.ELF" "run bootstrap with network or set OPL_URL"

echo "Vendor/bootstrap OK: ${BOOT} ${APPS}"
