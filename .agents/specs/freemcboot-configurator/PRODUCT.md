# FreeMcBoot Configurator — PRODUCT

**Programa:** [../PROGRAM.md](../PROGRAM.md) — **Fases B e D**

## Escopo deste módulo

`CFG.ELF`: UI de settings, paths `SYS-CONF`, filename de config FunTuna distinto do FMCB vanilla, paridade USB com FMCB (`loadUsbModules`: pares SYS-CONF antes de BOOT, ver [../USB_IRX_MATRIX.md](../USB_IRX_MATRIX.md)).

## Critérios de sucesso (resumo)

Seções **2** e **4** em PROGRAM.md.

## Detalhe local

- `FreeMcBoot-Configurator/config.c`, `main.c`

## FUNTUNA.CNF (Fase D)

| Local | Path |
|-------|------|
| MC slot 0 | `mc0:/BOOT/FUNTUNA.CNF` |
| MC slot 1 | `mc1:/BOOT/FUNTUNA.CNF` |
| USB FunTuna | `mass:/FUNTUNA.CNF` |

Não ler nem gravar `FMCB.CNF` / `FREEMCB.CNF` vanilla.

Inventário UI ↔ chaves ↔ FMCB: [../OSD_CONFIGURATOR.md](../OSD_CONFIGURATOR.md).

**Status:** Fase D — UI e persistência já no tree; validar round-trip no hardware (checklist no doc acima).
