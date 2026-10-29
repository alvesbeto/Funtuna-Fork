# CI / GitHub Actions (Fase E)

**Runbook operacional:** [RELEASE_RUNBOOK.md](RELEASE_RUNBOOK.md)

## Visão geral

| Workflow | Arquivo | Quando usar |
|----------|---------|-------------|
| clang-format | `_check-format.yml` | Push/PR em `FreeMcBoot/**`, `FreeMcBoot-Configurator/**` (branch `master` no YAML — alinhar ao default do repo se for `main`) |
| Labeler | `label.yml` | PR automático (requer `.github/labeler.yml`) |
| Update uLaunchELF | `Update-uLaunchELF.yml` | Baixa ULE para `installer/.../ULE.ELF`; rebuild installer local/CI ( **`__Binaries/` não é commitado** ) |
| stable Release | `stable.yml` | Container `ps2dev`: `bootstrap` + `build-release-local.sh`, zip `__Release/*` |
| Release Funtuna (installer) | `repack-and-release.yml` | Rebuild **installer** no container `ps2dev/ps2dev`, 7z de `__Release/`, artefato `FunTuna-Fork_Installer.ELF` |

Não há workflow dedicado só para **OPL** — OPL fica em `installer/INSTALLER_CONTENTS/OPL/` e entra no pacote via `repack-and-release.yml` (`MANUAL_INSTALL/OPL/`).

## `stable.yml`

**Disparo:** `workflow_dispatch`.

**Job único `build-and-release`** (container `ps2dev/ps2dev:v1.2.0`):

1. `tools/bootstrap-installer-vendor.sh`
2. `BUILD_OPENTUNA=1 tools/build-release-local.sh`
3. Cópia extra `__Binaries/*` → variantes (redundante com prepare, mantida para paridade com release histórico)
4. Zip, artifact, release `latest`
5. Manifest local (`installer-content.sha256`, não commitado)

**Git:** binários de release estão no `.gitignore`; o workflow **compila** em vez de exigir ficheiros pré-commitados.

## `repack-and-release.yml`

**Disparo:** `workflow_dispatch`, PR, push em `__Release/**` ou `installer/**`, `repository_dispatch` tipo `Component_update`.

**Passos relevantes:**

- Baixa **wLaunchELF_ISR** `BOOT-DS34.ELF` → `installer/INSTALLER_CONTENTS/BOOT/ULE.ELF` (não altera `__Binaries/`).
- `make` em `installer/` (container PS2SDK).
- Copia `FunTuna-Fork_Installer.ELF` (saída packed), `MANUAL_INSTALL/BOOT|APPS|OPL` a partir de `INSTALLER_CONTENTS`.
- 7z de todo `__Release/`; release em `main` only.

**Divergência ULE:** `Update-uLaunchELF.yml` usa URL `BOOT.ELF`; `repack-and-release.yml` usa `BOOT-DS34.ELF`. Manter consciente ao escolher workflow.

## `Update-uLaunchELF.yml`

Atualiza binários ULE no repo e faz commit. **Não** rebuilda installer nem `__Binaries` FMCB/CFG. Após rodar:

1. Copiar ULE (+ CNF se mudou) para `installer/INSTALLER_CONTENTS/BOOT/`
2. `make -C installer clean all`
3. `tools/sync-installer-manifest.sh`
4. Opcional: copiar IRX/ELF rebuildados para `__Binaries/` + `prepare-release-variants.sh`

## OPL bundled

| Artefato | Path |
|----------|------|
| Config / ícones | `installer/INSTALLER_CONTENTS/OPL/` |
| No pacote manual | `__Release/MANUAL_INSTALL/OPL/` (após repack CI) |

Atualização: substituir ficheiros em `INSTALLER_CONTENTS/OPL/`, rebuild installer, commit; ou estender workflow (fora de escopo atual).

## Validação CI (maintainer)

- [ ] PR que toca FMCB/Configurator: `_check-format.yml` verde
- [ ] Após bump de embeds: `tools/build-release-local.sh` local OK
- [ ] `workflow_dispatch` → `stable.yml` produz zip com três variantes BOOT sincronizadas
- [ ] `repack-and-release.yml` produz `FunTuna-Fork_Installer.ELF` + 7z
- [ ] (Opcional) Dumps BIOS de referência: `tools/inspect-ps2-bios-dump.sh` alinhado a [BIOS_ROM_MATRIX.md](BIOS_ROM_MATRIX.md)
