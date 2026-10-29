# Release packaging — PRODUCT

**Programa:** [../PROGRAM.md](../PROGRAM.md) — **Fase E**

## Escopo

Publicação reproduzível: `__Binaries/`, árvore `__Release/` (variantes Basic / Clean / Light, `MANUAL_INSTALL/`, PSU), workflows GitHub, manifest de hashes do installer.

## Critérios de sucesso

Seção **5** em PROGRAM.md — runbook, workflows documentados, checklist alinhado a `stable.yml`.

## Detalhe local

- [RELEASE_RUNBOOK.md](../RELEASE_RUNBOOK.md) — ordem build local
- [CI_WORKFLOWS.md](../CI_WORKFLOWS.md) — workflows
- `tools/build-release-local.sh`, `tools/prepare-release-variants.sh`, `tools/sync-installer-manifest.sh`

**Status:** Fase E — scripts + docs; validar dispatch CI no GitHub após push.
