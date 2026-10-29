# Matriz installer — estados e ações (Fase C)

Fluxo UI: Welcome → L1/R1 (MC0/MC1) → `Choose_Install_Mode` (R2 = ROM auto, L2 = IconQuery) → install.

## Pré-condições (bloqueiam antes de cleanup)

| Código | Condição | Ação |
|--------|----------|------|
| `NO_MEMORY_CARD` | `mcGetInfo` falha | Mensagem NO_MEMORY_CARD |
| `NO_PS2_MEMORY_CARD` | Tipo ≠ PS2 MC | NO_PS2_MC |
| `NOT_ENOUGH_SPACE` | `mc_Free < 2000` clusters | NOT_ENOUGH_SPACE (**antes** do cleanup) |

## Upgrade (destructive reinstall)

Após confirmação do usuário, o installer **remove** pastas legacy e reinstala:

- `BOOT`, `APPS`, `BXEXEC-FUNTUNA`, `FORTUNA`, `OPENTUNA`, `BXEXEC-OPENTUNA`
- OPL folder condicional (`conf_elm*`, `conf_game.cfg`)

Estados Fortuna / Opentuna / FunTuna fork **não** abortam com telas `FOUND_*` — o cleanup prepara upgrade. Telas `FOUND_*` permanecem no código para códigos reservados / erros futuros.

## Variante Opentuna (IconQuery)

| Entrada | Variante | Embed |
|---------|----------|-------|
| Triangle | SLIMS | `slims.bin` |
| Cross | FATS | `fats.bin` |
| Square | FAT170 | `170.bin` |

Auto (`GetIconType` + R2): ROM mapeada em `main.c` → variante default.

## Pós-install writes (resumo)

| Path | Conteúdo |
|------|----------|
| `BXEXEC-OPENTUNA/` | icon.icn (variante), icon.sys, icon.cnf timestamp trick |
| `BOOT/` | BOOT.ELF, CFG.ELF, FUNTUNA.CNF, ULE, IRX, icons |
| `APPS/` | OPL ELF + icons |
| `OPL/` | conf presets se ausente (`conf_opl.cfg`, ícones, `conf_game.cfg`, **`conf_apps.cfg`**) |

## Cenários de teste manual

| Estado inicial MC | Esperado |
|-------------------|----------|
| Vazia | Install ok |
| FunTuna fork (`BXEXEC-OPENTUNA`) | Cleanup + reinstall ok |
| Fortuna (`FORTUNA/`) | Cleanup + reinstall ok |
| Opentuna vanilla (`OPENTUNA/`) | Cleanup + reinstall ok |
| `< 2000` clusters livres | NOT_ENOUGH_SPACE, **sem** cleanup |

## Embeds vs `__Binaries/`

Após rebuild de FMCB/CFG/ULE, copiar para `installer/INSTALLER_CONTENTS/BOOT/` e `make -C installer`. Atualizar `.agents/specs/manifests/installer-content.sha256`.
