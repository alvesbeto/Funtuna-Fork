# Installer — PRODUCT

**Programa:** [../PROGRAM.md](../PROGRAM.md) — **Fases A e C**

## Escopo deste módulo

ELF de instalação: detecção Fortuna/Opentuna/Funtuna/BOOT/apps, queries de ícone por modelo, embeds sincronizados com subprojetos e `__Binaries/`.

## Critérios de sucesso (resumo)

Seções **1** e **3** em PROGRAM.md.

## Detalhe local

- `installer/main.c` — tabela de blobs embedados; `GetIconType()` + `rom0:ROMVER` (ver [../BIOS_ROM_MATRIX.md](../BIOS_ROM_MATRIX.md))
- `installer/ERROR_MESSAGES/*`
- QA offline: `tools/inspect-ps2-bios-dump.sh`
- Seed OPL (sem `conf_opl.cfg` pré-existente): `conf_opl.cfg`, ícones, `conf_game.cfg`, **`conf_apps.cfg`** — ver [../OPL_INTEGRATION.md](../OPL_INTEGRATION.md)

**Status:** integração OPL (seed `conf_apps.cfg`) — ver OPL_INTEGRATION.md.
