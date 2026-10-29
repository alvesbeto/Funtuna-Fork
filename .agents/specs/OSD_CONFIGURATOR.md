# OSD ↔ Configurator ↔ FUNTUNA.CNF

**Programa:** [PROGRAM.md](PROGRAM.md) — **Fase D**  
**Status:** inventário + alinhamento de defaults (2026-10-28)

## Filename e ordem de busca

| Artefato | Caminho | Notas |
|----------|---------|--------|
| CNF FunTuna (MC) | `mc0:/BOOT/FUNTUNA.CNF`, `mc1:/BOOT/FUNTUNA.CNF` | Configurator grava em `mc0`/`mc1`/`mass` conforme origem |
| CNF FunTuna (USB) | `mass:/FUNTUNA.CNF` | Prioridade na leitura do FMCB |
| CNF vanilla | `FMCB.CNF` / `FREEMCB.CNF` | **Não usado** neste fork |
| Seed pós-installer | `installer/INSTALLER_CONTENTS/BOOT/FUNTUNA.CNF` | Embutido como `FUNTUNA.CNF` na MC |

**FMCB (`launcher2.c`):** tenta USB → MC de boot → outra MC (ajusta `path[2]`).  
**Configurator (`config.c`):** `cnf_path_fmcb[]`, `cnf_path_fmcb2[]`, `cnf_path_fmcb3[]`.

## Chaves CNF (FMCB runtime)

Todas parseadas em `loadConfig()` / `get_CNF_string` loop em `FreeMcBoot/launcher2.c`.

| Chave CNF | Uso OSD / loader |
|-----------|------------------|
| `CNF_version` | Deve ser `1` |
| `hacked_OSDSYS` | OSD custom |
| `OSDSYS_video_mode` | AUTO / NTSC / PAL |
| `OSDSYS_scroll_menu` | Menu scroll |
| `OSDSYS_menu_x`, `OSDSYS_menu_y` | Posição menu |
| `OSDSYS_enter_x`, `OSDSYS_enter_y` | Botão Enter |
| `OSDSYS_version_x`, `OSDSYS_version_y` | Texto versão |
| `OSDSYS_cursor_max_velocity`, `OSDSYS_cursor_acceleration` | Scroll |
| `OSDSYS_left_cursor`, `OSDSYS_right_cursor` | Setas scroll (códigos `\a`) |
| `OSDSYS_menu_top_delimiter`, `OSDSYS_menu_bottom_delimiter` | Faixas superior/inferior |
| `OSDSYS_num_displayed_items` | Itens visíveis |
| `OSDSYS_Skip_Disc`, `OSDSYS_Skip_Logo`, `OSDSYS_Inner_Browser` | Boot OSD |
| `OSDSYS_Skip_MC`, `OSDSYS_Skip_HDD` | Updates |
| `OSDSYS_selected_color`, `OSDSYS_unselected_color` | RGBA por componente |
| `name_OSDSYS_ITEM_n`, `path1/2/3_OSDSYS_ITEM_n` | Itens de menu (n = 1…100) |
| `LK_*_E1/E2/E3`, `pad_delay`, `FastBoot`, `Debug_Screen` | Loader (Configurator) |

`%VER%` em `OSDSYS_menu_top_delimiter` é expandido no FMCB (`loadConfig`).

## UI do Configurator (CFG.ELF)

Menu **Free McBoot Settings** → `Config_fmcb()` em `config.c`.

| Tela | Função | Chaves tocadas |
|------|--------|----------------|
| Launch keys | `Config_fmcb_key()` | `LK_<botão>_E1/E2/E3` |
| OSD principal | `Config_fmcb_OSDSYS()` | `hacked_OSDSYS`, cores, coords, skip flags, TV mode, itens |
| Item OSD n | `Config_fmcb_OSDSYS_item()` | `name_OSDSYS_ITEM_*`, `path1/2/3_*` |
| Scroll / delimitadores | `Config_fmcb_OSDSYS_scroll()` | scroll, `menu_y`, cursor, **top/bottom delimiter** |
| ESR | `Config_ESR_path()` | paths ESR (não OSD) |

Persistência: `storeFmcbCNF` / `saveFmcbCNF` — mesmas chaves que o FMCB lê.

## Defaults quando não há CNF

Antes de `loadConfig()`, `Set_Default_Settings()` em `launcher2.c` deve coincidir com `initFmcbCNF()` em `config.c` (incl. delimitadores FunTuna, não faixas ASCII `------=/\\=------`).

## Validação round-trip (manual)

1. Instalar ou copiar `FUNTUNA.CNF` seed para `mc0:/BOOT/`.
2. Boot FMCB → anotar delimitadores / item 1 no OSD.
3. Abrir **FMCB Configurator** → alterar **Scroll Settings** (top/bottom delimiter) e um item OSD → salvar.
4. Reboot → confirmar OSD reflete alterações.
5. Reabrir Configurator → **Load** do mesmo path → valores iguais aos salvos.
6. Confirmar que `FMCB.CNF` na MC **não** é lido (opcional: colocar CNF vanilla e verificar que só `FUNTUNA.CNF` vale).

Registrar resultado no PR (pass/fail por linha da tabela acima).

## Gaps conhecidos

| Item | Severidade | Notas |
|------|------------|--------|
| Seed installer vs defaults Configurator | Baixa | Texto do topo no `.CNF` embarcado usa `%VER%`; defaults de fábrica do Configurator usam `v1.0.0` fixo — ambos válidos após save |
| Paridade USB debug FMCB vs CFG | Fora D | Fase B — mensagens quando IRX falha |
