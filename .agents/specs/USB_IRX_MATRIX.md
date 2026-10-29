# Matriz USB IRX — BOOT vs SYS-CONF (Fase B)

Comportamento de referência: `FreeMcBoot/launcher2.c` (`load_common_modules`).

## Ordem de tentativa (USBD.IRX e USBHDFSD.IRX)

1. `mc0:/BOOT/USBD.IRX` / `mc0:/BOOT/USBHDFSD.IRX`
2. `mc1:/BOOT/...` (incremento do dígito da porta no path)
3. `mc0:/SYS-CONF/USBD.IRX` / `mc0:/SYS-CONF/USBHDFSD.IRX`
4. `mc1:/SYS-CONF/...`

Falha em todas as tentativas: USB mass storage indisponível no boot FMCB; console continua sem USB (degradação graceful).

## Matriz de teste manual

| IRX em BOOT | IRX em SYS-CONF | Resultado esperado |
|-------------|-----------------|-------------------|
| Sim | — | USB ok via BOOT |
| — | Sim | USB ok via SYS-CONF |
| Sim | Sim | USB ok (BOOT primeiro) |
| — | — | Sem USB; boot FMCB/OPL por MC/DVD conforme config |

## Instalação padrão FunTuna

O installer grava IRX em `mc?:/BOOT/` (`installer/main.c`). Usuários que copiam drivers manualmente para `SYS-CONF` dependem do fallback acima.

## FreeMcBoot Configurator

O Configurator **não** carrega módulos USB IRX no boot; usa `SYS-CONF` para settings (IPCONFIG, etc.). Paridade “USB fallback” aplica-se ao **BOOT.ELF**, não ao CFG.ELF.

## Regressão pós-install

- [ ] IRX presentes em `BOOT` após install → USB funciona sem SYS-CONF
- [ ] Remover IRX de `BOOT`, copiar para `SYS-CONF` → USB ainda funciona

## exFAT USB (opcional, fora do pacote padrão)

IRX em `BOOT/` vêm do PS2SDK (FAT32). Drivers errados no Configurator causavam freeze em `mass:/` ([FAQ](https://israpps.github.io/Funtuna-Fork/ASK-ENG.html), commit [b9e3d8f](https://github.com/israpps/Funtuna-Fork/commit/b9e3d8f4ff48df03c371a23702f78e8c52444e97)).

**exFAT:** usar [BDM Assault](https://github.com/israpps/BDMAssault) manualmente em `mc?:/SYS-CONF/USBD.IRX` e `USBHDFSD.IRX` (ver [POPStarter BDM](https://nathanneurotic.github.io/POPSTARTERINFO/bdm-exfat.html)). Não substituir `BOOT/` sem testar CFG.ELF. Ver [Funtuna-Fork #26](https://github.com/israpps/Funtuna-Fork/issues/26).
