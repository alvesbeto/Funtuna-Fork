# Opentuna / launcher — checklist de estabilidade (Fase A)

Preencher no PR que alterar `opentuna/` ou `installer/INSTALLER_CONTENTS/ENTRYPOINT/`.

## Payload

- [ ] `PAYLOAD=launcher-keys-Funtuna` em `opentuna/exploit/Makefile` (trocar para `launcher-no-keys-Funtuna` se release sem atalhos); ambas variantes compilam com PS2SDK + `linkfile`/`stubs.c`
- [ ] `tools/build-opentuna-launcher.sh` executado com PS2SDK; `payload.bin` regenerado se launcher mudou
- [ ] `REGENERATE_ENTRYPOINT=1` → `tools/regenerate-entrypoint-icons.sh` (Java + OpenTuna RLE); afinação por modelo em `tools/opentuna-tuned-icons/` se o encode base falhar no hardware
- [ ] `slims.bin`, `fats.bin`, `170.bin` distintos e corretos por ROM (não reutilizar um bin para outro)
- [ ] Manifesto `.agents/specs/manifests/installer-content.sha256` atualizado

## Launch keys (`launcher-keys-Funtuna`)

- [ ] Circle tenta `mc0`/`mc1` `APPS/OPNPS2LD.ELF`
- [ ] Cross tenta `mc0`/`mc1` `BOOT/ULE.ELF` (porta 1 usa `mc1:/BOOT/`, não `mc1:/ULE/`)
- [ ] Default carrega `BOOT/BOOT.ELF`
- [ ] Atalho ausente → syscall reset browser (código após ramos de tecla)

## Hardware (marcar console testado)

| Modelo / ROM | SLIMS / FATS / FAT170 | Boot exploit | ULE | OPL | Notas |
|--------------|----------------------|--------------|-----|-----|-------|
| | | | | | |
| | | | | | |

## Installer embed

- [ ] `make -C installer clean all` após mudança de ENTRYPOINT ou `INSTALLER_CONTENTS/`
- [ ] Variante escolhida no IconQuery corresponde ao bin embedado

## PSU manual (opcional release)

- [ ] `__Release/MANUAL_INSTALL/*.psu` coerentes com bins em ENTRYPOINT
- [ ] `FUNTUNA-LAUNCHER.psu`: gerar via fluxo wiki/OpenTuna RLE quando variante for promovida a release

**Aprovado por:** _______________ **Data:** _______________
