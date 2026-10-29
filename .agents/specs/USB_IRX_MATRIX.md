# Matriz USB IRX — BOOT vs SYS-CONF (Fase B)

Comportamento de referência: `FreeMcBoot/launcher2.c` (`load_modules`).

## Ordem de tentativa (par USBD.IRX + USBHDFSD.IRX)

Para cada candidato, **ambos** os ficheiros têm de existir; carrega-se o par ou passa-se ao seguinte.

1. `mc0:/SYS-CONF/USBD.IRX` + `mc0:/SYS-CONF/USBHDFSD.IRX`
2. `mc1:/SYS-CONF/...`
3. `mc0:/BOOT/...`
4. `mc1:/BOOT/...`

**Porquê SYS-CONF primeiro:** o instalador grava IRX PS2SDK (FAT32) em `BOOT/`. Utilizadores com [BDM Assault](https://github.com/israpps/BDMAssault) para **exFAT** copiam os IRX renomeados para `SYS-CONF/` (documentação BDM). Se o boot carregasse `BOOT/` primeiro, o mass driver FAT-only podia **travar** com pen USB exFAT ligada ([PSX-Place](https://www.psx-place.com/threads/fmcb-1966-exfat-freeze-with-usb-memory.43121/), [Reddit](https://www.reddit.com/r/ps2homebrew/comments/1jds6aa/freemcboot_freezing_when_usb_connected/)).

Falha em todas as tentativas: USB mass storage indisponível no boot FMCB; console continua sem USB (degradação graceful).

## Matriz de teste manual

| IRX em BOOT | IRX em SYS-CONF | Resultado esperado |
|-------------|-----------------|-------------------|
| Sim (PS2SDK) | — | USB ok via BOOT (FAT32); exFAT no stick → boot pode travar **até** instalar BDM em SYS-CONF |
| — | Sim (BDM) | USB ok via SYS-CONF; exFAT no stick no boot |
| Sim | Sim (BDM) | USB ok via **SYS-CONF** (BDM); BOOT intacto para CFG |
| — | — | Sem USB; boot FMCB/OPL por MC/DVD conforme config |

## Instalação padrão FunTuna

O installer grava IRX **PS2SDK (FAT32)** em `mc?:/BOOT/` e **BDM Assault (exFAT)** em `mc?:/SYS-CONF/` (`installer/main.c`, blobs via `tools/bootstrap-installer-vendor.sh` + `p7zip-full`). O `BOOT.ELF` preferencia o par em SYS-CONF no arranque.

Alternativa documentada na comunidade FunTuna: BDM directamente em `BOOT/` ([PSX-Place BDMAssault](https://www.psx-place.com/resources/bdmassault.1393/)) — validar CFG.ELF em `mass:/`.

## FreeMcBoot Configurator

O Configurator **não** carrega módulos USB IRX no boot; usa paths em `OSDSYS`/`USBD_FILE` (default `mc0:/BOOT/...`). Paridade “prefer SYS-CONF” aplica-se ao **BOOT.ELF**, não ao CFG.ELF.

## Regressão pós-install

- [ ] IRX presentes em `BOOT` após install → USB FAT32 funciona sem SYS-CONF
- [ ] BDM em `SYS-CONF` + pen exFAT ligada → boot FMCB completa
- [ ] Remover IRX de `BOOT`, copiar PS2SDK para `SYS-CONF` → USB ainda funciona

## exFAT USB (opcional)

IRX em `BOOT/` vêm do PS2SDK (FAT32). Drivers Jolek antigos causavam freeze no Configurator em `mass:/` — corrigido com IRX oficiais ([FAQ](https://israpps.github.io/Funtuna-Fork/ASK-ENG.html), [b9e3d8f](https://github.com/israpps/Funtuna-Fork/commit/b9e3d8f4ff48df03c371a23702f78e8c52444e97)).

**Partição:** alguns relatos de freeze com tabela **GPT**; **MBR** + exFAT resolveu em casos isolados ([Reddit](https://www.reddit.com/r/ps2homebrew/comments/1k3fn54/freemcboot_freezes_at_startup_when_usb_is_plugged/)).

Ver [Funtuna-Fork #26](https://github.com/israpps/Funtuna-Fork/issues/26).
