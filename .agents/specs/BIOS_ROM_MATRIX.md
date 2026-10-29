# Matriz ROMVER / BIOS — QA e instalador

Referência cruzada entre dumps de BIOS (offline), `rom0:ROMVER` no hardware e `GetIconType()` em `installer/main.c`.

**Runtime (fonte de verdade):** o instalador lê 5 caracteres hex de `rom0:ROMVER` + região (`E`/`U`/…) e calcula `ROM_VERSION = strtoul(romver, NULL, 16)`.

## Política `GetIconType` (instalador)

| Condição (`ROM_VERSION`) | Variante OpenTuna | Embed |
|--------------------------|-------------------|--------|
| `>= 0x190` | SLIMS | `slims.bin` |
| `== 0x170` | FAT170 | `170.bin` |
| `>= 0x110` (resto) | FATS | `fats.bin` |
| `< 0x110` (ex.: `0x100`, `0x101`) | **UNSUPPORTED** | sem `BXEXEC-OPENTUNA` |

Ordem dos `if` importa: `0x170` antes do ramo `>= 0x110`.

### Faixa `0x180` – `0x18F` (incerteza)

Consolas nesta faixa caem em **FATS** (`fats.bin`), não SLIMS. Se o exploit OpenTuna falhar (browser branco) com R2 auto, testar **L2 → IconQuery** ou afinação RLE específica; registar no checklist hardware.

ProtoKernel **SCPH-10000 / 15000** (`0x100` / `0x101`): OpenTuna não suportado — comportamento esperado.

## Pack de referência (QA local, fora do git)

Dumps analisados em Oct 2025 — **não confundir ficheiros** (hashes distintos):

| Ficheiro (exemplo) | SHA-256 (prefixo) | Tokens no dump | `GetIconType` esperado |
|--------------------|-------------------|----------------|------------------------|
| `scph10000.bin` | `c4dad3b5…` | Proto, `SCPH-10000` | UNSUPPORTED |
| `scph39001.bin` | `f4c948e6…` | `0160` | FATS |
| `PS2 Bios 30004R V6 Pal.bin` | `ee7ae4cc…` | `0160`, `0160E`, `0200` | FATS (ROM retail ~1.60; **≠** 39001) |
| `SCPH-70004_BIOS_V12_PAL_200.BIN` | `d6653f4e…` | `0200`, `0200E` | SLIMS |
| `rom1.bin` | `41de2047…` | fragmento ROM1 | *(não define ROMVER)* |
| `*.EROM` / `ROM1` / `ROM2` | — | DVD/região slim | FMCB `EROMDRV`; não escolhe ícone OpenTuna |
| `*.NVM` / `*.MEC` | — | Mechacon | irrelevante ao instalador |

Lacunas deste pack para cobertura completa: ROM **`0x170`**, slim NTSC **`0x220+`**, **`0x230`**, outras regiões — validar em hardware quando disponível.

## Tabela EE / ficheiro (offline)

No mapa EE clássico, offset **`0x2760`** no ficheiro 4 MiB (`0xBFC00000` + 0x2760) costuma cair na região de nomes **`EXTINFO` / `ROMVER` / `SBIN` / `LOGO`** (util para sanity-check, não substitui `rom0:ROMVER`).

## Ferramenta host

```bash
tools/inspect-ps2-bios-dump.sh /caminho/para/dump.bin
tools/inspect-ps2-bios-dump.sh /pasta/com/variose/bins/
```

Saída: SHA-256, região `@0x2760`, tokens `01xx`/`02xx`, variante prevista. Ver [STABILITY_CHECKLIST.md](STABILITY_CHECKLIST.md).

## Instalação

- **R2:** usa `GetIconType(ROM_VERSION)` automático.
- **L2:** `IconQuery` manual — usar se auto falhar ou ROM ambígua.

Ver [TROUBLESHOOTING.md](TROUBLESHOOTING.md) (OpenTuna / variante errada).
