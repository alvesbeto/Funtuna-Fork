# Staging area for release workflows — not committed (see `tools/build-release-local.sh`).

Populate locally:

1. `tools/bootstrap-installer-vendor.sh` — IRX from PS2SDK, ULE via wget
2. `tools/build-release-local.sh` — BOOT.ELF, CFG.ELF, installer, copies here
3. `tools/prepare-release-variants.sh` — mirrors into `__Release/!Funtuna-*/BOOT/`

Configs and icons live under `installer/INSTALLER_CONTENTS/BOOT/` (e.g. `FUNTUNA.CNF`, `LAUNCHELF.CNF`, `icon.sys`, `SYSTEM.icn`).
