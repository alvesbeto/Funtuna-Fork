# Opentuna — PRODUCT

**Programa:** [../PROGRAM.md](../PROGRAM.md) — **Fase A**

## Escopo deste módulo

Payload Opentuna (slim / fat / fat170), variantes com e sem launch keys, ícone independente, alinhamento com `FUNTUNA-LAUNCHER.psu` e embeds do installer.

## Critérios de sucesso (resumo)

Ver seção **1. Opentuna estável + launcher PSU** em PROGRAM.md.

## Detalhe local

- `opentuna/README.MD` — comportamento de launch keys
- Paths: `opentuna/exploit`, `launcher-keys-Funtuna`, `launcher-no-keys-Funtuna`

**Status:** builds locais PS2SDK para `launcher-keys-Funtuna` e `launcher-no-keys-Funtuna` (linkfile + newlib); embed via `PAYLOAD=` em `tools/build-opentuna-launcher.sh` / `opentuna/exploit/Makefile`. Validação hardware pendente ([STABILITY_CHECKLIST.md](../STABILITY_CHECKLIST.md)).
