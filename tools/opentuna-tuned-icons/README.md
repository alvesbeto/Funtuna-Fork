# OpenTuna ENTRYPOINT — ícones afinados por modelo

O instalador grava estes blobs como `BXEXEC-OPENTUNA/icon.icn`:

| Ficheiro | Consolas (ROM) |
|----------|----------------|
| `slims.bin` | Slims (ex.: 2.20+) |
| `fats.bin` | FAT 1.10–1.60 (exceto casos abaixo) |
| `170.bin` | FAT ROM `0x170` |

## Regeneração automática

```bash
tools/build-opentuna-launcher.sh
tools/regenerate-entrypoint-icons.sh
```

Ou num build completo:

```bash
BUILD_OPENTUNA=1 REGENERATE_ENTRYPOINT=1 tools/build-release-local.sh
```

O script RLE gera um **encode base** a partir de `opentuna/exploit/payload.bin`. Se um `.bin` já existir e decodificar para o **mesmo tamanho** que o payload actual, mantém-se (preserva afinação manual). Caso contrário, copia-se o encode base para os três — **não substitui** afinação por modelo.

## Afinação manual (payload ou ROM novo)

1. [OpenTuna RLE](https://github.com/parrado/opentuna-RLE) + notas [gist ABelliqueux](https://gist.github.com/ABelliqueux/342ccb4e114fd9369d30b58e53c8b245).
2. Testar cada variante na consola alvo (browser branco = bin errado).
3. Colocar cópias finais nesta pasta e repetir:

```bash
TUNED_ICONS_DIR="$(pwd)/tools/opentuna-tuned-icons" tools/regenerate-entrypoint-icons.sh
```

(Nomes exactos: `slims.bin`, `fats.bin`, `170.bin`.)

`exploit.sys` (→ `icon.sys`) fica em `tools/opentuna-static/exploit.sys`; não regenerar via RLE salvo instrução explícita na wiki OpenTuna.
