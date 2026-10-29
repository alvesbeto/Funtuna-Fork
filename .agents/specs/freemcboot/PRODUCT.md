# FreeMcBoot — PRODUCT

**Programa:** [../PROGRAM.md](../PROGRAM.md) — **Fase B** (USB); **Fase D** (OSD runtime)

## Escopo deste módulo

`BOOT.ELF`: boot chain, OSD customizável, carregamento USB IRX (`BOOT` then `SYS-CONF`), CNF FunTuna na USB separado do FMCB vanilla.

## Critérios de sucesso (resumo)

Seções **2** e **4** em PROGRAM.md (matriz USB; OSD não hardcoded).

## Detalhe local

- `FreeMcBoot/launcher2.c` — fallback SYS-CONF
- `FreeMcBoot/Makefile`

Runtime lê apenas `FUNTUNA.CNF` (USB primeiro, depois MC0/MC1). Delimitadores e demais OSD vêm do CNF; defaults pré-CNF alinhados ao Configurator (`Set_Default_Settings` ↔ `initFmcbCNF`).

Ver [../OSD_CONFIGURATOR.md](../OSD_CONFIGURATOR.md).

**Status:** Fase D — defaults alinhados; round-trip no hardware pendente.
