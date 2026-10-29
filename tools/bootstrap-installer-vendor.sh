#!/usr/bin/env bash
# Ensure vendor blobs under INSTALLER_CONTENTS exist (not built from this repo's Makefiles).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOOT="${ROOT}/installer/INSTALLER_CONTENTS/BOOT"
APPS="${ROOT}/installer/INSTALLER_CONTENTS/APPS"
SYSCONF="${ROOT}/installer/INSTALLER_CONTENTS/SYS-CONF"

ULE_URL="${ULE_URL:-https://github.com/israpps/wLaunchELF_ISR/releases/download/latest/BOOT-DS34.ELF}"
OPL_URL="${OPL_URL:-https://github.com/ps2homebrew/Open-PS2-Loader/releases/download/latest/OPNPS2LD.ELF}"
BDM_ASSAULT_7Z_URL="${BDM_ASSAULT_7Z_URL:-https://github.com/israpps/BDMAssault/releases/download/v1.0.0/BDMAssault-v1.0.0.7z}"

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
  local base="${name%.IRX}"
  local lower
  lower="$(printf '%s' "${base}" | tr '[:upper:]' '[:lower:]')"
  local candidates=(
    "${PS2SDK}/iop/irx/${name}"
    "${PS2SDK}/iop/irx/${lower}.irx"
    "${PS2SDK}/ports/usbmass/irx/${name}"
    "${PS2SDK}/ports/usb/irx/${name}"
  )
  if [[ "${name}" == "USBD.IRX" ]]; then
    candidates+=("${PS2SDK}/iop/irx/usbd_mini.irx")
  fi
  local src=""
  for c in "${candidates[@]}"; do
    if [[ -f "${c}" ]]; then
      src="${c}"
      break
    fi
  done
  if [[ -z "${src}" ]]; then
    src="$(find "${PS2SDK}" -iname "${lower}.irx" -type f 2>/dev/null | head -1 || true)"
  fi
  if [[ -z "${src}" || ! -f "${src}" ]]; then
    echo "Missing ${dest}; install PS2SDK IRX or place file manually." >&2
    return 1
  fi
  cp "${src}" "${dest}"
  echo "Copied ${name} from ${src}"
}

fetch_bdm_sysconf_irx() {
  local usbd="${SYSCONF}/USBD.IRX"
  local mass="${SYSCONF}/USBHDFSD.IRX"

  if [[ -f "${usbd}" && -f "${mass}" && "${VENDOR_REFRESH}" != "1" ]]; then
    return 0
  fi

  mkdir -p "${SYSCONF}"
  if ! command -v 7z >/dev/null 2>&1; then
    echo "Need 7z to extract BDM Assault (${usbd}). Install p7zip-full." >&2
    return 1
  fi

  local tmp archive inner_usbd inner_mass
  tmp="$(mktemp -d)"
  archive="${tmp}/BDMAssault.7z"
  inner_usbd="READY_TO_USE/FreeMcBoot/SYS-CONF/USBD.IRX"
  inner_mass="READY_TO_USE/FreeMcBoot/SYS-CONF/USBHDFSD.IRX"

  download_url "${BDM_ASSAULT_7Z_URL}" "${archive}" "BDM Assault release 7z"
  7z x -y -o"${tmp}/out" "${archive}" "${inner_usbd}" "${inner_mass}" >/dev/null

  cp "${tmp}/out/${inner_usbd}" "${usbd}"
  cp "${tmp}/out/${inner_mass}" "${mass}"
  rm -rf "${tmp}"
  echo "Extracted BDM Assault → ${SYSCONF}/ (exFAT USB for FMCB boot)"
}

require_file() {
  local path="$1"
  local hint="$2"
  if [[ ! -f "${path}" ]]; then
    echo "Missing ${path} — ${hint}" >&2
    return 1
  fi
}

mkdir -p "${BOOT}" "${APPS}" "${SYSCONF}"

copy_irx_from_ps2sdk USBD.IRX
copy_irx_from_ps2sdk USBHDFSD.IRX
fetch_bdm_sysconf_irx

download_url "${ULE_URL}" "${BOOT}/ULE.ELF" "ULE.ELF (wLaunchELF_ISR latest)"
download_url "${OPL_URL}" "${APPS}/OPNPS2LD.ELF" "OPNPS2LD.ELF (Open-PS2-Loader latest)"

require_file "${BOOT}/FUNTUNA.CNF" "FunTuna settings seed (tracked in git)"
require_file "${BOOT}/LAUNCHELF.CNF" "uLaunchELF config (tracked in git)"
require_file "${BOOT}/POWEROFF.ELF" "power-off helper (tracked vendor ELF)"
require_file "${APPS}/OPNPS2LD.ELF" "run bootstrap with network or set OPL_URL"
require_file "${SYSCONF}/USBD.IRX" "run bootstrap with 7z + network (BDM Assault)"
require_file "${SYSCONF}/USBHDFSD.IRX" "run bootstrap with 7z + network (BDM Assault)"

echo "Vendor/bootstrap OK: ${BOOT} ${APPS} ${SYSCONF}"
