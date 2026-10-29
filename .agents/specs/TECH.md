# Programa Funtuna-Fork — TECH

**Status:** rascunho alinhado a [PROGRAM.md](PROGRAM.md); revisar na implementação.

**Commit de referência:** _(preencher SHA no PR que implementar)_

---

## Arquitetura de build

```
opentuna/          → payloads + tools (RLE, ps2_packer)
FreeMcBoot/        → BOOT.ELF (+ chkesr, init, elf_loader)
FreeMcBoot-Configurator/ → CFG.ELF
installer/         → ELF monolítico com blobs (main.c externs)
__Binaries/        → staging local/CI (não commitado; ver README.MD)
__Release/         → layouts Basic | Clean | Light + PSU (BOOT gerado; docs/PSU podem ficar no git)
```

Ordem local típica: subprojetos Make → copiar para `__Binaries` → rebuild installer se embeds mudaram → repack `__Release`.

---

## Opentuna (fase A)

| Artefato | Local |
|----------|--------|
| Variant slim/fat/fat170 | `installer` embeds `opentuna_*` |
| Launcher keys / no-keys | `opentuna/launcher-keys-Funtuna`, `launcher-no-keys-Funtuna` |

Rebuild launcher + embed exploit:

```bash
PAYLOAD=launcher-keys-Funtuna tools/build-opentuna-launcher.sh   # default
PAYLOAD=launcher-no-keys-Funtuna tools/build-opentuna-launcher.sh
REGENERATE_ENTRYPOINT=1 tools/regenerate-entrypoint-icons.sh     # Java; ver tools/opentuna-tuned-icons/
```

Ou altere `PAYLOAD` em `opentuna/exploit/Makefile` e `make -C opentuna/exploit all`.

| PSU publicado | `__Release/FUNTUNA-LAUNCHER.psu` |

**Riscos:** divergência entre payload embedado no installer e PSU publicado; mitigar com script ou checklist único de hashes/tamanhos.

---

## USB fallback (fase B)

Implementação FMCB (`load_modules` em `launcher2.c`): tenta, por ordem, par completo **SYS-CONF** (mc0 → mc1) e depois **BOOT** (mc0 → mc1). Motivação: BDM Assault / exFAT em `SYS-CONF` sem sobrescrever IRX PS2SDK em `BOOT/` (Configurator). Detalhe: [USB_IRX_MATRIX.md](USB_IRX_MATRIX.md).

**Tarefa técnica:** auditar Configurator para equivalente onde IRX/USB são assumidos; extrair constantes compartilhadas só se reduzir drift sem aumentar footprint EE.

---

## Installer embeds (fases A, C)

`installer/main.c` declara blobs Opentuna, FMCB, CFG, OPL icons/cfg, USB IRX (PS2SDK → `BOOT/`, BDM Assault → `SYS-CONF/` via bootstrap) — qualquer bump de subprojeto exige regenerar headers/binários do installer (padrão existente do repo, não inventar novo packer sem ADR).

**Matriz de detecção:** headers em `installer/ERROR_MESSAGES/` — alterações de copy exigem rebuild apenas do installer, não do FMCB.

---

## OSD / Configurator (fase D)

- CNF único: `FUNTUNA.CNF` — ver [OSD_CONFIGURATOR.md](OSD_CONFIGURATOR.md).
- Parser FMCB: `FreeMcBoot/launcher2.c` (`loadConfig`, `Set_Default_Settings`).
- Editor: `FreeMcBoot-Configurator/config.c` (`initFmcbCNF`, `saveFmcbCNF`, `Config_fmcb_*`).
- Build PS2SDK moderno: `funtuna_io_compat.h`, `readMC` + `sceMcTblGetDir`, `-DNEWLIB_PORT_AWARE`, sem `-lmf`.
- Manter defaults pré-CNF sincronizados entre `Set_Default_Settings` e `initFmcbCNF` ao mudar branding ou skip flags.

---

## Release / CI (fase E)

| Workflow | Função |
|----------|--------|
| `.github/workflows/stable.yml` | `__Binaries` → variantes, zip, release |
| `.github/workflows/repack-and-release.yml` | Rebuild installer (ps2dev container), 7z, MANUAL_INSTALL |
| `.github/workflows/Update-uLaunchELF.yml` | Commit `ULE.ELF` em `__Binaries` |
| `.github/workflows/_check-format.yml` | clang-format FMCB + Configurator |

Runbook: [RELEASE_RUNBOOK.md](RELEASE_RUNBOOK.md). Workflows: [CI_WORKFLOWS.md](CI_WORKFLOWS.md). Script local: `tools/build-release-local.sh`.

**Gap conhecido:** `Update-uLaunchELF.yml` não rebuilda installer — passos pós-ULE no runbook.

---

## Testes

- **Automated:** clang-format CI; file-existence no stable workflow.
- **Manual obrigatório:** matriz hardware (slim/fat/fat170), [BIOS_ROM_MATRIX.md](BIOS_ROM_MATRIX.md), matriz USB IRX, matriz estados installer — registrar resultados no PR (tabela markdown).

---

## Decisões pendentes (resolver na implementação)

| Decisão | Opções | Notas |
|---------|--------|-------|
| Critério “Opentuna estável” | Checklist maintainer vs N boots sem reset | Bloqueia fase A |
| Job CI rebuild installer | Novo workflow vs doc only | Footprint secrets/pat |
| Shared headers USB paths | Duplicar vs header comum em `tools/` | Tradeoff memória/build PS2SDK |

Atualizar esta tabela ao fechar cada decisão; alternativas rejeitadas vão para ADR em `.agents/adrs/` se criarmos a pasta.
