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

## Memory card — espaço (não formata)

O instalador **não** chama `mcFormat` (format completo fica para o browser Sony ou [Memory Card Annihilator](https://github.com/ffgriever-pl/Memory-Card-Annihilator)).

| Passo | Comportamento |
|-------|----------------|
| Pré-check | `mcGetInfo`: cartão presente, tipo PS2 MC |
| Cleanup | Apaga árvores FunTuna/Fortuna/Opentuna/OPL condicional ([INSTALLER_STATE_MATRIX.md](../INSTALLER_STATE_MATRIX.md)) |
| Pós-cleanup | `mcGetInfo` de novo; se `mc_Free < 2000` clusters → `NOT_ENOUGH_SPACE` (mensagem BMP + orientação em [TROUBLESHOOTING.md](../TROUBLESHOOTING.md)) |
| Escrita | `mcMkDir` + embeds |

Isto permite upgrade/reinstall quando o pacote antigo ocupava clusters mas o cleanup libertava espaço suficiente.

**Status:** integração OPL + política de espaço pós-cleanup.
