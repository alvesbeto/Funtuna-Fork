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
