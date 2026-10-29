# Troubleshooting — comunidade (PS2 / OpenTuna / FunTuna)

Referências: [FunTuna FAQ](https://israpps.github.io/Funtuna-Fork/ASK-ENG.html), [instalação](https://israpps.github.io/Funtuna-Fork/INSTA_ENG.html), [ConsoleMods OpenTuna](https://consolemods.org/wiki/PS2:Fortuna/Opentuna), [PSX-Place OpenTuna](https://www.psx-place.com/threads/opentuna-an-open-source-version-of-fortuna-based-on-reverse-engineering.33010/).

## OpenTuna / variante errada

| Sintoma | Causa provável | Ação |
|---------|----------------|------|
| Browser branco / freeze ao abrir MC | Ícone para **outra** ROM (ex.: slim bin em FAT 1.10) | Reinstalar com **IconQuery** ou R2 auto; não reutilizar `slims.bin`/`fats.bin`/`170.bin` entre modelos |
| MC “funciona” numa consola e trava noutra idêntica | BIOS/ROM diferente ou cartão preparado para outro modelo | Usar cartão só na consola alvo; ver [avisos OpenTuna](https://www.psx-place.com/threads/opentuna-an-open-source-version-of-fortuna-based-on-reverse-engineering.33010/) |
| ProtoKernel SCPH-10000/15000 | OpenTuna **não suportado** | Installer omite `BXEXEC-OPENTUNA` (`UNSUPPORTED`); não forçar ícones |

Regenerar ícones após mudar launcher:

```bash
tools/build-opentuna-launcher.sh
REGENERATE_ENTRYPOINT=1 tools/regenerate-entrypoint-icons.sh
# ou BUILD_OPENTUNA=1 tools/build-release-local.sh  (REGENERATE_ENTRYPOINT=1 por defeito)
```

Afinação por modelo: [notas RLE](https://gist.github.com/ABelliqueux/342ccb4e114fd9369d30b58e53c8b245) + `tools/opentuna-tuned-icons/README.md`. Payload maior que o embed antigo → os três `.bin` ficam encode base até teste em hardware.

## FunTuna vs OpenTuna puro

FunTuna arranca **FMCB (BOOT.ELF)** com atalhos opcionais (Circle/Cross); OpenTuna vanilla tende a OPL. Recuperação de OPL corrompido: uLE via Cross ou CFG → ULE ([discussão OPL #1381](https://github.com/ps2homebrew/Open-PS2-Loader/issues/1381)).

## CFG.ELF / USB

- Freeze ao navegar `mass:/` no Configurator: drivers USB incompatíveis — pacote usa IRX oficiais (commit [b9e3d8f](https://github.com/israpps/Funtuna-Fork/commit/b9e3d8f4ff48df03c371a23702f78e8c52444e97)); não trocar por BDM em `BOOT/` sem validar.
- OPL freeze pós-install: apagar configs antigos em `mc?:/OPL/` (installer já limpa se detectar layout pré-1.1.0).

## Ícone BXEXEC-FUNTUNA

Data deve ser **2099** para o exploit ficar primeiro. Restaurar: wLaunchELF bundled → R1 → “Fortuna Date” no folder ([FAQ](https://israpps.github.io/Funtuna-Fork/ASK-ENG.html)). **Não editar** `BXEXEC-FUNTUNA` manualmente.

## HDD-OSD / Browser 2.0

OpenTuna/Fortuna **incompatível** com HDD-OSD ativo — pode bloquear reconhecimento da MC até power cycle ([ConsoleMods](https://consolemods.org/wiki/PS2:Fortuna/Opentuna)).

## exFAT

Opcional via [BDM Assault](https://github.com/israpps/BDMAssault) em `SYS-CONF` (ver [USB_IRX_MATRIX.md](USB_IRX_MATRIX.md)). Não faz parte do build padrão deste fork.

## Build local

```bash
source ~/.zshrc
tools/bootstrap-installer-vendor.sh   # ULE + OPL latest + IRX PS2SDK
BUILD_OPENTUNA=1 tools/build-release-local.sh
```

`ENTRYPOINT/*.bin` vivem fora do git (`.gitignore`); `tools/regenerate-entrypoint-icons.sh` + `tools/opentuna-static/exploit.sys`. Fallback git em `build-opentuna-launcher.sh` só com `REGENERATE_ENTRYPOINT=0` e blobs em falta.
