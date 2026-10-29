# Release runbook (Fase E)

**CI:** [CI_WORKFLOWS.md](CI_WORKFLOWS.md)  
**Manifest:** [manifests/installer-content.sha256](manifests/installer-content.sha256)

## Pré-requisitos

- PS2SDK + PS2DEV no PATH (`~/ps2dev`, ver `~/.zshrc`)
- `PS2SDKSRC` apontando para `ps2sdk-src` (IOP `init` / `elf_loader`)
- Opcional: `wine` para `ps2_packer` nos Makefiles
- Host: `tools/install-ps2dev-host-tools.sh` (`bin2s`, symlink `lzma-packer.so`)

## Git vs artefatos

Binários de build (`BOOT.ELF`, `CFG.ELF`, installer packed, `__Release/!Funtuna-*/BOOT/`, `__Binaries/*` excepto README) **não** vão para o git — ver `.gitignore`. Clone limpo:

1. `tools/bootstrap-installer-vendor.sh` — IRX PS2SDK → `BOOT/`; **BDM Assault** → `SYS-CONF/` (requer `7z`, rede); **ULE**; **OPNPS2LD.ELF**; valida `POWEROFF.ELF` versionado
2. `tools/build-release-local.sh` — rebuild completo + manifest local (não commitado)

## Atalho (maintainer)

```bash
source ~/.zshrc
chmod +x tools/*.sh
tools/build-release-local.sh          # FMCB + CFG + installer + variantes + manifest
BUILD_OPENTUNA=1 tools/build-release-local.sh   # inclui Opentuna/exploit
SKIP_INSTALLER=1 tools/build-release-local.sh   # só ELF BOOT/CFG + variantes
```

## Build local (ordem detalhada)

| # | Passo | Saída |
|---|--------|--------|
| 1 | `make -C FreeMcBoot clean all` | `FreeMcBoot/BOOT.ELF` |
| 2 | `make -C FreeMcBoot-Configurator clean all` | `FreeMcBoot-Configurator/CFG.ELF` |
| 3 | Copiar `BOOT.ELF`, `CFG.ELF` → `installer/INSTALLER_CONTENTS/BOOT/` e `__Binaries/` | embeds alinhados |
| 4 | Opentuna: `BUILD_OPENTUNA=1` → `build-opentuna-launcher.sh` + `REGENERATE_ENTRYPOINT=1` → `regenerate-entrypoint-icons.sh` (Java) | `ENTRYPOINT/exploit.sys`, `*.bin` |
| 5 | `make -C installer clean all` | `installer/FunTuna-Fork_Installer.ELF` |
| 6 | `tools/sync-installer-manifest.sh` | manifest SHA-256 |
| 7 | `tools/prepare-release-variants.sh` | `__Release/!Funtuna-*/BOOT/*` |

IRX / ULE / CNF / ícones em `INSTALLER_CONTENTS/BOOT/` — copiar para `__Binaries/` quando forem atualizados manualmente ou via workflow ULE.

### Tamanhos Opentuna (referência)

| Artefato | Git | Rebuild Linux (GCC 15) |
|----------|-----|------------------------|
| `loader-old/loader-stripped.elf` | ~18 KiB | ~14 KiB |
| `launcher-keys/payload-packed.elf` | ~16 KiB | **~44 KiB** (nostartfiles + pad-lite) |
| `exploit/payload.bin` | ~28 KiB | **~52 KiB** |

Validar no hardware antes de promover embeds no installer.

## GitHub Actions

Ver tabela completa em [CI_WORKFLOWS.md](CI_WORKFLOWS.md).

| Workflow | Disparo | Efeito |
|----------|---------|--------|
| `_check-format.yml` | push FMCB / Configurator | clang-format 11 |
| `stable.yml` | `workflow_dispatch` | `__Binaries` → variantes, zip, release |
| `repack-and-release.yml` | dispatch / push installer / `Component_update` | rebuild installer, 7z, release em `main` |
| `Update-uLaunchELF.yml` | dispatch / `Component_update` | commit `__Binaries/ULE.ELF` |

**Gap ULE (obrigatório após `Update-uLaunchELF.yml`):**

1. Copiar ULE (+ `LAUNCHELF.CNF` se necessário) para `installer/INSTALLER_CONTENTS/BOOT/`
2. `make -C installer clean all`
3. `tools/sync-installer-manifest.sh`
4. Copiar ELF/IRX atualizados para `__Binaries/` + `tools/prepare-release-variants.sh`

## Checklist `stable.yml` (`check-binaries`)

Ficheiros exigidos antes do repack:

| Path |
|------|
| `__Binaries/BOOT.ELF` |
| `__Binaries/CFG.ELF` |
| `__Binaries/USBD.IRX` |
| `__Binaries/USBHDFSD.IRX` |
| `__Binaries/ULE.ELF` |
| `__Binaries/LAUNCHELF.CNF` |
| `__Binaries/POWEROFF.ELF` |
| `__Binaries/icon.sys` |
| `__Binaries/SYSTEM.icn` |
| `installer/INSTALLER_CONTENTS/BOOT/FUNTUNA.CNF` |

Variantes `__Release/!Funtuna-*/BOOT/` são geradas no job (ou localmente via `prepare-release-variants.sh`).

## Variantes release

- `!Funtuna-Basic`, `!Funtuna-Clean`, `!Funtuna-Basic - Light` — camada `BOOT/` sincronizada pelo workflow; APPS/OPL no pacote completo vêm do installer (`repack-and-release.yml` → `MANUAL_INSTALL/`).
- PSU manual: `__Release/MANUAL_INSTALL/OPENTUNA-*.psu`

## OPL bundled

Ficheiros em `installer/INSTALLER_CONTENTS/OPL/`; sem workflow automático dedicado — atualizar ficheiros, rebuild installer, commit.
