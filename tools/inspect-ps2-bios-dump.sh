#!/usr/bin/env bash
# Offline sanity-check for PS2 BIOS dumps (4 MiB EE images). Does NOT replace rom0:ROMVER on real hardware.
# See .agents/specs/BIOS_ROM_MATRIX.md
set -euo pipefail

ROMVER_TABLE_FILE_OFFSET=0x2760

inspect_one() {
  local path="$1"
  if [[ ! -f "${path}" ]]; then
    echo "skip (not a file): ${path}" >&2
    return 1
  fi
  local sz sha
  sz="$(wc -c < "${path}" | tr -d ' ')"
  sha="$(sha256sum "${path}" | awk '{print $1}')"

  echo "=== ${path} ==="
  echo "  size=${sz}  sha256=${sha}"

  if (( sz != 4194304 )); then
    echo "  note: main EE BIOS dumps are usually 4194304 bytes; other sizes may be ROM1/EROM/NVM"
  fi

  python3 - "${path}" "${ROMVER_TABLE_FILE_OFFSET}" << 'PY'
import re, sys
path, off = sys.argv[1], int(sys.argv[2], 0)
data = open(path, "rb").read()
if len(data) > off + 64:
    chunk = data[off : off + 64]
    asc = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
    print(f"  @0x{off:04x}: {asc!r}")
tokens = set()
for m in re.finditer(rb"([0-9A-Fa-f]{5})([EUJCHAK])", data):
    n = int(m.group(1).decode(), 16)
    if 0x100 <= n <= 0x3ff:
        tokens.add(f"0x{n:03X}{m.group(2).decode()}")
for pat in [b"0160", b"0170", b"0180", b"0190", b"0200", b"0220", b"0230"]:
    if pat in data:
        tokens.add(pat.decode() + " (substring)")
if b"SCPH-10000" in data or b"protokernel" in data.lower():
    print("  hint: proto / early kernel strings present")
if tokens:
    print("  rom-like tokens:", ", ".join(sorted(tokens)[:12]))
else:
    print("  rom-like tokens: (none in scan — use hardware ROMVER)")
# Map first plausible 0x1xx/0x2xx token to GetIconType
best = None
for t in sorted(tokens):
    m = re.match(r"0x([0-9A-Fa-f]{3})", t)
    if m:
        best = int(m.group(1), 16)
        break
    m = re.match(r"([0-9A-Fa-f]{4})", t)
    if m:
        n = int(m.group(1), 16)
        if 0x100 <= n <= 0x3ff:
            best = n
            break
if best is not None:
    if best >= 0x190: label = "SLIMS"
    elif best == 0x170: label = "FAT170"
    elif best >= 0x110: label = "FATS"
    else: label = "UNSUPPORTED"
    print(f"  if ROMVER=0x{best:03X} → GetIconType → {label} (offline guess)")
PY

  echo ""
}

usage() {
  echo "Usage: $0 <file.bin|directory>" >&2
  exit 2
}

[[ $# -ge 1 ]] || usage

if [[ -d "$1" ]]; then
  shopt -s nullglob
  for f in "$1"/*.bin "$1"/*.BIN; do
    [[ -f "$f" ]] || continue
    inspect_one "$f" || true
  done
else
  inspect_one "$1"
fi
