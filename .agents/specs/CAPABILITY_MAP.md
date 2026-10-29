# Capability Map: Funtuna-Fork (baseline do repositório)

Este mapa descreve **módulos existentes** e dependências de build/release. Use-o na Fase 0 do fluxo spec-driven antes de escrever `PRODUCT.md` por módulo.

| Module id | Responsibility | Depends on | Paths principais |
|-----------|----------------|------------|------------------|
| `opentuna` | Exploit/payload Opentuna; variantes com/sem launch keys; ícone independente; PSU launcher | — | `opentuna/`, `tools/OpenTuna RLE`, `tools/ps2_packer` |
| `freemcboot` | Launcher OSD (BOOT.ELF); bugs corrigidos vs upstream; USB IRX de `BOOT` ou fallback `SYS-CONF`; CNF separado na USB | `opentuna` (cadeia de boot em MC) | `FreeMcBoot/` |
| `freemcboot-configurator` | CFG.ELF; personalização OSD; settings filename distinto do FMCB vanilla | `freemcboot` | `FreeMcBoot-Configurator/` |
| `installer` | ELF de instalação na memory card; detecção Fortuna/Opentuna/Funtuna; embed de payloads e binários | `opentuna`, `freemcboot`, `freemcboot-configurator`, `__Binaries` | `installer/` |
| `release-packaging` | Copiar binários para variantes, zip, GitHub release | todos os ELF/IRX acima | `__Release/`, `__Binaries/`, `.github/workflows/` |

## Build order (dependência lógica)

```
opentuna → freemcboot → freemcboot-configurator → installer → release-packaging
```

Mudanças em `opentuna` ou ícone/`icon.sys` quase sempre exigem revisar **installer** (embeds) e **release-packaging**. Mudanças só em mensagens/UI do installer podem isolar em `installer`.

## Fronteiras (invariantes conhecidas do fork)

- Ícone “hackeado” / Opentuna em pasta independente para não alterar timestamp ao atualizar software (ver README raiz).
- Settings FunTuna na USB separados dos settings FreeMcBoot vanilla (filename distinto).
- Bundled: wLaunchELF mod, OPL latest (atualização via workflow), variantes Basic / Clean / Light.

## Próximo passo spec-driven

Definir **uma iniciativa** (problema + critérios de sucesso) e marcar quais module ids ela toca. Escrever `PRODUCT.md` apenas nos módulos afetados; `TECH.md` quando houver tradeoff de memória, layout MC, ou formato de embed no installer.

**Status:** mapa baseline — programa aprovado; ver `PRODUCT.md` por módulo.
