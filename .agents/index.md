# Funtuna-Fork — roteador para agents

Leia este arquivo antes de alterar código neste repositório.

## O que é este repo

Launcher homebrew PS2 para modelos incompatíveis com FMCB clássico: payload **Opentuna**, **FreeMcBoot** customizado, **Configurator**, **installer** na MC, pacotes em `__Release/` e binários em `__Binaries/`.

## Spec-driven (obrigatório para mudanças substanciais)

1. Confirmar escopo no [mapa de capacidades](specs/CAPABILITY_MAP.md).
2. Escrever ou atualizar `specs/<modulo>/PRODUCT.md` (e `TECH.md` se a implementação for ambígua ou cross-cutting).
3. **Não implementar** até o humano aprovar a spec.
4. Implementar com a skill `execute` em `/home/beto/.agents/skills/execute/SKILL.md` (embedded C / release layout — não é stack Laravel).

## Programa atual

- [specs/PROGRAM.md](specs/PROGRAM.md) — cinco frentes (Opentuna, USB, installer, OSD, release)
- [specs/TECH.md](specs/TECH.md) — build, embeds, CI, testes

## Índice de specs

| Módulo | Spec de produto | Notas |
|--------|-----------------|-------|
| `opentuna` | [specs/opentuna/PRODUCT.md](specs/opentuna/PRODUCT.md) | Payload / ícone / variantes launcher |
| `freemcboot` | [specs/freemcboot/PRODUCT.md](specs/freemcboot/PRODUCT.md) | BOOT.ELF, OSD, USB drivers |
| `freemcboot-configurator` | [specs/freemcboot-configurator/PRODUCT.md](specs/freemcboot-configurator/PRODUCT.md) | CFG.ELF, settings USB |
| `installer` | [specs/installer/PRODUCT.md](specs/installer/PRODUCT.md) | Instalação na MC, mensagens, layout |
| `release-packaging` | [specs/release-packaging/PRODUCT.md](specs/release-packaging/PRODUCT.md) | CI, zip, runbook |

Mapa e ordem de build: [specs/CAPABILITY_MAP.md](specs/CAPABILITY_MAP.md).

Documentação operacional: [STABILITY_CHECKLIST.md](specs/STABILITY_CHECKLIST.md), [BIOS_ROM_MATRIX.md](specs/BIOS_ROM_MATRIX.md), [TROUBLESHOOTING.md](specs/TROUBLESHOOTING.md), [USB_IRX_MATRIX.md](specs/USB_IRX_MATRIX.md), [INSTALLER_STATE_MATRIX.md](specs/INSTALLER_STATE_MATRIX.md), [OSD_CONFIGURATOR.md](specs/OSD_CONFIGURATOR.md), [RELEASE_RUNBOOK.md](specs/RELEASE_RUNBOOK.md), [CI_WORKFLOWS.md](specs/CI_WORKFLOWS.md).

ADR: [adrs/ADR-0001-programa-spec-driven.mdc](adrs/ADR-0001-programa-spec-driven.mdc).

## Artefatos de release

- `.github/workflows/` — repack, OPL/uLaunchELF updates, clang-format
- `__Release/` — variantes Basic / Clean / Light
- `__Binaries/` — ELF/IRX empacotados no installer
