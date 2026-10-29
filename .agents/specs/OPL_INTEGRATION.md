# Integração Open PS2 Loader (addendum)

**Programa:** [PROGRAM.md](PROGRAM.md) — complementa **Fases B, C e E**  
**Status:** aprovado com plano Integração OPL (2026-10-29)

## Problema

O FunTuna entrega OPL em `mc?:/APPS/OPNPS2LD.ELF` e presets em `mc?:/OPL/`, mas faltavam: lista **Apps** no OPL (`conf_apps.cfg`), paridade **USB exFAT** no Configurator, pin/manifest do ELF bundled e orientação USB para jogos ISO/ZSO.

## Experiência desejada

- Instalação limpa ou upgrade **sem** `conf_opl.cfg` existente → seed inclui `conf_opl.cfg`, ícones, `conf_game.cfg` e **`conf_apps.cfg`** (FunTuna, CFG, ULE, OPL).
- Utilizador com OPL já configurado → installer **não** sobrescreve `mc?:/OPL/conf_opl.cfg` nem injeta `conf_apps.cfg`.
- **CFG.ELF** ao usar `mass:/` carrega IRX na mesma ordem que **BOOT.ELF** (SYS-CONF BDM antes de BOOT PS2SDK).
- Maintainer pode disparar workflow para registar pin SHA-256 do `OPNPS2LD.ELF` upstream; rebuild local via `bootstrap-installer-vendor.sh`.

## Invariantes

- Não reimplementar SMB, NBD, cheats, VMC ou PADEMU (permanecem no OPL upstream).
- `OPNPS2LD.ELF` continua **gitignored**; só configs e `opl-pin.txt` versionados.
- Launch keys Opentuna (default `launcher-keys-Funtuna`): Circle → `mc?:/APPS/OPNPS2LD.ELF`, Cross → `mc?:/BOOT/ULE.ELF`.

## Fora de escopo

- Fork do [Open-PS2-Loader](https://github.com/ps2homebrew/Open-PS2-Loader).
- Template USB copiado para MC pelo installer (só `__Release/MANUAL_INSTALL/USB-OPL/`).

## Critérios de sucesso

- [x] Seed OPL grava `conf_apps.cfg` quando ausente `conf_opl.cfg`.
- [x] `loadUsbModules` no Configurator tenta quatro pares mc0/mc1 SYS-CONF → BOOT.
- [x] `tools/sync-installer-manifest.sh` inclui APPS/OPL cfg hashes.
- [x] `.github/workflows/Update-OPL.yml` atualiza `.agents/specs/manifests/opl-pin.txt`.
- [x] Docs: USB_IRX_MATRIX, TROUBLESHOOTING (START / vídeo / fragmentação), RELEASE_RUNBOOK checklist pós-bump OPL.

## Validação

- Revisão estática de `installer/main.c`, `installer/Makefile`, `FreeMcBoot-Configurator/main.c`.
- `make -C installer` / `make -C FreeMcBoot-Configurator` com PS2SDK + vendor blobs.
- Manual: boot FMCB → OPL Apps list; CFG em `mass:` com pen exFAT ligada no boot.

## Referências

- [USB_IRX_MATRIX.md](USB_IRX_MATRIX.md), [INSTALLER_STATE_MATRIX.md](INSTALLER_STATE_MATRIX.md), [CI_WORKFLOWS.md](CI_WORKFLOWS.md)
