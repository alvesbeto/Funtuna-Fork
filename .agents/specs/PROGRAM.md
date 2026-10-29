# Programa: Funtuna-Fork — hardening multi-módulo

**Status:** aprovado (2026-10-28) — fases A–E documentadas; builds locais PS2SDK (FMCB, CFG, Opentuna keys/no-keys); validação hardware + CI dispatch pendente.

**Módulos:** `opentuna`, `freemcboot`, `freemcboot-configurator`, `installer`, `release-packaging` (ver [CAPABILITY_MAP.md](CAPABILITY_MAP.md)).

**Objetivo:** fechar lacunas entre o que o README promete e o que build/release/testes garantem, em cinco frentes interdependentes, sem regressão em modelos slim/fat e instalações já existentes.

---

## 1. Opentuna estável + launcher PSU

### Problema

Variantes com/sem launch keys existem no tree (`opentuna/`), mas a promoção para release (`FUNTUNA-LAUNCHER.psu`) depende de critério de “estabilidade” ainda informal.

### Experiência desejada

- **Sem keys:** boot direto em `mc?:/BOOT/BOOT.ELF`.
- **Com keys:** Circle → `mc?:/APPS/OPNPS2LD.ELF`, Cross → `mc?:/BOOT/ULE.ELF`, default → `mc?:/BOOT/BOOT.ELF`; se app ausente → reset browser.
- Ícone/payload em pasta independente para não invalidar timestamps ao atualizar outros ELFs.

### Critérios de sucesso

- [ ] Checklist de estabilidade assinado (hardware alvo: slim, fat, fat170 conforme payloads em `installer`). → [`STABILITY_CHECKLIST.md`](STABILITY_CHECKLIST.md)
- [ ] `__Release/FUNTUNA-LAUNCHER.psu` gerado a partir da variante aprovada (runbook / wiki; PSU manual em `MANUAL_INSTALL/`)
- [x] Manifesto de embeds + script de rebuild launcher → `tools/`, `manifests/installer-content.sha256`
- [ ] Installer embeda a mesma variante aprovada para cada classe de modelo (validar após rebuild PS2SDK)

### Validação

- Boot frio após instalação limpa e após upgrade desde Fortuna/Opentuna/Funtuna detectados pelo installer.

---

## 2. USB: BOOT vs SYS-CONF (FMCB + Configurator)

### Problema

Usuários podem ter IRX só em `BOOT` ou só em `SYS-CONF`; o fork documenta fallback, mas comportamento deve ser simétrico entre **BOOT.ELF** e **CFG.ELF** e previsível na USB FunTuna.

### Experiência desejada

- Tentar `mc?:/BOOT/USBD.IRX` e `USBHDFSD.IRX` primeiro; se falhar, tentar `mc?:/SYS-CONF/` (porta 0 e 1), como em `FreeMcBoot/launcher2.c`.
- Configurator não quebra paths `SYS-CONF` ao salvar settings (IPCONFIG, fontes, etc.).

### Critérios de sucesso

- [x] Matriz documentada → [`USB_IRX_MATRIX.md`](USB_IRX_MATRIX.md)
- [ ] Paridade de mensagens ou logs debug entre FMCB e Configurator quando USB falha (se aplicável ao escopo de debug build).

### Validação

- Testes manuais com MC preparada para cada célula da matriz; regressão no fluxo normal (IRX em `BOOT` pós-installer).

---

## 3. Installer: detecção, mensagens, modelos

### Problema

O installer centraliza detecção (`FOUND_*`, `ICONQUERY_*`, espaço, MC) e embeds (`installer/main.c`); mudanças em Opentuna/FMCB exigem alinhamento de mensagens e payloads por modelo.

### Experiência desejada

- Fluxo claro: welcome → queries de ícone/modelo → confirmação → escrita na MC → sucesso/falha com mensagens em `ERROR_MESSAGES/`.
- Upgrade a partir de estados já suportados (Fortuna, Opentuna, Funtuna, BOOT, apps) sem brick lógico (espaço insuficiente, MC ausente tratados antes de escrever).

### Critérios de sucesso

- [x] Matriz de estados documentada → [`INSTALLER_STATE_MATRIX.md`](INSTALLER_STATE_MATRIX.md)
- [ ] Embeds sincronizados com `__Binaries/` após rebuild dos subprojetos (manifest + PS2SDK)

### Validação

- Build installer; rodar cenários da matriz no hardware ou em ambiente aceito pelo maintainer.

---

## 4. OSD / Configurator — customização

### Problema

Diferencial do fork: elementos OSD customizáveis vs FunTuna original; evoluções não devem reintroduzir delimitadores hardcoded.

### Experiência desejada

- Usuário altera aparência/comportamento via Configurator; settings FunTuna na USB **não** colidem com filename FMCB vanilla.

### Critérios de sucesso

- [x] Lista de elementos OSD configuráveis refletida na UI do Configurator → [`OSD_CONFIGURATOR.md`](OSD_CONFIGURATOR.md)
- [x] Filename de settings FunTuna permanece distinto e documentado na spec do módulo `freemcboot-configurator`.

### Validação

- Round-trip save/load; boot FMCB lê settings esperados.

---

## 5. Release e CI

### Problema

Release depende de `__Binaries/` + cópia para variantes (`stable.yml`); uLaunchELF atualiza via workflow; OPL bundled deve permanecer rastreável e reproduzível.

### Experiência desejada

- Maintainer dispara workflow ou commit em `__Release/` e obtém zip consistente (Basic / Clean / Light).
- Atualizações de componentes (ULE, OPL) não deixam installer desatualizado sem rebuild explícito documentado.

### Critérios de sucesso

- [x] Runbook: ordem build local → [`RELEASE_RUNBOOK.md`](RELEASE_RUNBOOK.md)
- [x] Workflows existentes documentados → [`CI_WORKFLOWS.md`](CI_WORKFLOWS.md) (`stable.yml`, `Update-uLaunchELF.yml`, `repack-and-release.yml`, OPL manual)
- [x] Checklist de arquivos obrigatórios alinhado ao `check-binaries` do workflow.

### Validação

- CI verde em `clang-format`; job de release completa com artefatos esperados.

**Addendum OPL:** integração bundle/installer/Configurator (sem reescrever OPL upstream) — [`OPL_INTEGRATION.md`](OPL_INTEGRATION.md).

---

## Ordem de entrega recomendada

| Fase | Frente | Motivo |
|------|--------|--------|
| A | Opentuna + embeds installer | Base da cadeia de boot |
| B | FMCB USB fallback + Configurator paridade | Runtime pós-install |
| C | Installer matriz de estados | UX e segurança de upgrade |
| D | OSD / settings filename | Diferencial produto |
| E | Release runbook + CI | Ship reproduzível |

Fases B–D podem sobrepor **somente** com specs de módulo atualizadas no mesmo PR.

---

## Fora de escopo (salvo nova spec)

- Suporte a hardware não PS2.
- Reescrever OPL ou wLaunchELF upstream — apenas bundle/version pin documentado.
- Linear issue / Figma (não usados neste repo).

---

## Aprovação

- [ ] Product owner aprova este programa e a ordem de fases. **Aprovado 2026-10-28.**
- [x] ADR [`../adrs/ADR-0001-programa-spec-driven.mdc`](../adrs/ADR-0001-programa-spec-driven.mdc)
- [ ] Após rebuild PS2SDK: checklist hardware + rebuild installer.
