# Troubleshooting — comunidade (PS2 / OpenTuna / FunTuna)

Referências: [FunTuna FAQ](https://israpps.github.io/Funtuna-Fork/ASK-ENG.html), [instalação](https://israpps.github.io/Funtuna-Fork/INSTA_ENG.html), [ConsoleMods OpenTuna](https://consolemods.org/wiki/PS2:Fortuna/Opentuna), [PSX-Place OpenTuna](https://www.psx-place.com/threads/opentuna-an-open-source-version-of-fortuna-based-on-reverse-engineering.33010/).

**Como usar este doc:** sintomas na consola abaixo; detalhe técnico em [BIOS_ROM_MATRIX.md](BIOS_ROM_MATRIX.md) (ROM/ícone), [USB_IRX_MATRIX.md](USB_IRX_MATRIX.md) (IRX), [OPL_INTEGRATION.md](OPL_INTEGRATION.md) (OPL), [RELEASE_RUNBOOK.md](RELEASE_RUNBOOK.md) (rebuild).

## OpenTuna / ícone

| Sintoma | Causa provável | Ação |
|---------|----------------|------|
| Browser branco / freeze ao abrir MC | Ícone para **outra** ROM (ex.: slim bin em FAT 1.10) | Reinstalar com **IconQuery** (L2) ou R2 auto; ver [BIOS_ROM_MATRIX.md](BIOS_ROM_MATRIX.md); não reutilizar `slims.bin`/`fats.bin`/`170.bin` entre modelos |
| MC “funciona” numa consola e trava noutra idêntica | BIOS/ROM diferente ou cartão preparado para outro modelo | Usar cartão só na consola alvo; ver [avisos OpenTuna](https://www.psx-place.com/threads/opentuna-an-open-source-version-of-fortuna-based-on-reverse-engineering.33010/) |
| ROM `0x180`–`0x18F` com R2 auto e exploit falha | Instalador classifica como **FATS** (`>= 0x110`, `< 0x190`) | Testar **L2** ou ícone manual; registar no [STABILITY_CHECKLIST.md](STABILITY_CHECKLIST.md) |
| ProtoKernel SCPH-10000/15000 | OpenTuna **não suportado** | Installer omite `BXEXEC-OPENTUNA` (`UNSUPPORTED`); não forçar ícones |

**Pasta do exploit:** o instalador grava o ícone em **`mc?:/BXEXEC-OPENTUNA/`** (timestamp **2099** para ficar primeiro no browser). **Não editar** essa pasta à mão. Restaurar data: wLaunchELF bundled → R1 → “Fortuna Date” ([FAQ](https://israpps.github.io/Funtuna-Fork/ASK-ENG.html)). No upgrade, o installer remove a pasta legada **`BXEXEC-FUNTUNA`** se ainda existir.

Afinação RLE por modelo: [notas RLE](https://gist.github.com/ABelliqueux/342ccb4e114fd9369d30b58e53c8b245) + `tools/opentuna-tuned-icons/README.md`. Regenerar ícones / rebuild Opentuna: [RELEASE_RUNBOOK.md](RELEASE_RUNBOOK.md).

## Arranque FunTuna

FunTuna arranca **FMCB (`mc?:/BOOT/BOOT.ELF`)** após o exploit; OpenTuna “puro” tende a ir directo para OPL.

| Contexto | Comportamento |
|----------|----------------|
| OpenTuna **sem** launch keys | `mc?:/BOOT/BOOT.ELF` |
| OpenTuna **com** launch keys (variante default do build) | **Circle** → `mc?:/APPS/OPNPS2LD.ELF`; **Cross** → `mc?:/BOOT/ULE.ELF`; nenhuma tecla → `mc?:/BOOT/BOOT.ELF` |
| Atalhos no menu OSD (FMCB) | `mc?:/BOOT/FUNTUNA.CNF` — paths podem incluir `mass:/FUNTUNA/` |

Recuperação se OPL na MC estiver corrompido: **Cross** no exploit (keys) ou OSD → uLE / CFG → ULE ([OPL #1381](https://github.com/ps2homebrew/Open-PS2-Loader/issues/1381)).

## USB no arranque (FMCB e CFG)

O instalador grava IRX **PS2SDK (FAT32)** em `mc?:/BOOT/` e **BDM Assault (exFAT)** em `mc?:/SYS-CONF/`. **`BOOT.ELF`** e **`CFG.ELF`** tentam carregar o par completo em **SYS-CONF antes de BOOT** (mc0, depois mc1). Ver [USB_IRX_MATRIX.md](USB_IRX_MATRIX.md). Não substituir os IRX de `BOOT/` por BDM sem validar o Configurator em `mass:/`.

| Sintoma | Causa | Ação |
|---------|--------|------|
| Logo PS2 / FMCB **trava** com pen USB ligada (install antigo) | Stick **exFAT** + só drivers FAT em `BOOT/` | Reinstalar com installer recente (BDM em `SYS-CONF`) + `BOOT.ELF` / `CFG.ELF` recentes |
| Boot OK sem USB, trava com USB | Idem ou lixo na raiz da pen | Reinstalar FunTuna ou copiar BDM manualmente para `SYS-CONF` ([BDM Assault releases](https://github.com/israpps/BDMAssault/releases)) |
| Funciona se desligar USB antes do boot | IRX errados ou ausentes em SYS-CONF | Confirmar **dois** ficheiros em `SYS-CONF`; rebuild FMCB/CFG |

**Workaround imediato:** desligar a pen até o menu OSD, ligar depois (instalações antigas sem BDM em SYS-CONF).

**Partição USB:** alguns relatos de freeze com **GPT**; **MBR** + exFAT resolveu em casos isolados — ver [USB_IRX_MATRIX.md](USB_IRX_MATRIX.md) e [issue #26](https://github.com/israpps/Funtuna-Fork/issues/26).

## Open PS2 Loader (OPL)

| Sintoma | Causa provável | Ação |
|---------|----------------|------|
| OPL trava ao carregar (logo/cinza) | `conf_*.cfg` de OPL **antigo** incompatível | Segurar **START** enquanto o OPL inicia (ignora configs); guardar settings novos no OPL |
| OPL sem imagem no boot | Modo vídeo não suportado pela TV | Segurar **Triangle + Cross** no arranque do OPL (reset para Auto) |
| Tela preta / layout OPL pré-1.1.0 após upgrade | Pasta `mc?:/OPL/` com configs antigas | Reinstalar FunTuna (installer limpa OPL se detectar `conf_elm*` / ausência de `conf_game.cfg`) ou apagar `mc?:/OPL/` manualmente |
| Jogo trava em ecrã branco | ISO fragmentada ou corrompida | Copiar ISO de novo; ficheiros **contíguos** (copiar tudo para PC, formatar pen, voltar a copiar) |
| ISO >4 GiB em FAT32 | Limite FAT32 | Pen **exFAT** (MBR, allocation unit default) + BDM em `SYS-CONF`; ou formato USBExtreme |
| Lista Apps vazia no OPL | Falta `conf_apps.cfg` | Reinstalar FunTuna (seed grava `mc?:/OPL/conf_apps.cfg` se não houver `conf_opl.cfg`) ou copiar de `MANUAL_INSTALL/OPL/` |

**ZSO (ISO comprimida):** OPL ≥1.2; ferramenta `ziso.py` no repo [Open-PS2-Loader](https://github.com/ps2homebrew/Open-PS2-Loader) (`pc/ziso.py`), não incluída neste fork.

**Pen para jogos:** copiar a árvore de `__Release/MANUAL_INSTALL/USB-OPL/` — ver [OPL_INTEGRATION.md](OPL_INTEGRATION.md).

**MX4SIO (SD na porta MC):** o seed OPL traz `enable_mx4sio=1`; no menu OPL usar **BDM** / dispositivos de bloco. Cartão SD: MBR + exFAT ou FAT32, pastas `CD/`/`DVD/` como no USB ([OPL README](https://github.com/ps2homebrew/Open-PS2-Loader)). MC com `conf_opl.cfg` antigo → editar `enable_mx4sio=1` ou reinstalar sem config OPL.

## Memory card — espaço e formatação

O instalador FunTuna **não formata** a memory card. Apaga pastas do pacote (BOOT, APPS, exploit, etc.) e só depois mede clusters livres (mínimo **2000**). Ver [INSTALLER_STATE_MATRIX.md](INSTALLER_STATE_MATRIX.md).

| Sintoma | Causa provável | Ação |
|---------|----------------|------|
| Ecrã **NOT_ENOUGH_SPACE** após instalar | Saves/outros ficheiros ocupam a MC; cleanup do FunTuna não chegou | Apagar saves ou outros jogos; tentar reinstall (upgrade apaga só árvores FunTuna/Fortuna/Opentuna/OPL condicional) |
| Ainda sem espaço | MC quase cheia ou não formatada | Format no **browser** Sony (Memory Card) **ou** [Memory Card Annihilator](https://github.com/ffgriever-pl/Memory-Card-Annihilator) (`mca_new` = exFAT USB + dump/restore antes de format) |
| Queres backup antes de format | — | MCA: dump da imagem da MC para USB/PC; depois format ou restore |

Durante a instalação, o texto no ecrã mostra `Free clusters after cleanup` — útil para confirmar se o cleanup libertou espaço.

## HDD-OSD / Browser 2.0

OpenTuna/Fortuna **incompatível** com HDD-OSD ativo — pode bloquear reconhecimento da MC até power cycle ([ConsoleMods](https://consolemods.org/wiki/PS2:Fortuna/Opentuna)).

## Para quem faz build

```bash
source ~/.zshrc
tools/bootstrap-installer-vendor.sh
BUILD_OPENTUNA=1 tools/build-release-local.sh
```

Ordem completa, CI e manifests: [RELEASE_RUNBOOK.md](RELEASE_RUNBOOK.md).
