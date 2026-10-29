FUNTUNA-FORK — USB layout for Open PS2 Loader (OPL)
Layout USB para Open PS2 Loader (OPL)

Copy this folder tree to the root of your USB stick (e.g. mass:/ or E:\).
Copie esta árvore para a raiz da pen USB (ex.: mass:/ ou E:\).

Format (recommended / recomendado):
- Partition table: MBR (not GPT)
  Tabela de partições: MBR (não GPT)
- Filesystem: exFAT (OPL 1.2+) or FAT32
  Sistema de ficheiros: exFAT (OPL 1.2+) ou FAT32
- Allocation unit size: Default (Windows) when formatting exFAT
  Tamanho de unidade de alocação: Predefinido ao formatar exFAT

FunTuna console: use exFAT + BDM drivers in mc?:/SYS-CONF/ (installer) so FMCB/OPL boot with the stick plugged in.
Consola FunTuna: exFAT + drivers BDM em mc?:/SYS-CONF/ (instalador) para arrancar FMCB/OPL com a pen ligada.

Game files should be contiguous (copy all to PC, format USB, copy back if games fail to load).
Jogos devem estar contíguos no disco (copiar tudo para o PC, formatar, copiar de volta se falhar).

Folders (OPL standard):
- CD/     — CD-ROM game ISO/ZSO
- DVD/    — DVD game ISO/ZSO
- VMC/    — virtual memory cards
- CFG/    — per-game OPL config
- ART/    — cover art
- THM/    — themes
- LNG/    — translations
- CHT/    — PS2RD cheats
- APPS/   — homebrew ELFs

MC install already provides mc?:/APPS/OPNPS2LD.ELF and mc?:/OPL/ settings after FunTuna installer.
A instalação na MC já inclui mc?:/APPS/OPNPS2LD.ELF e mc?:/OPL/ após o instalador FunTuna.
Seed OPL: enable_mx4sio=1 (SD via MX4SIO adapter on memory card port) — same CD/DVD tree on the SD card (MBR, exFAT or FAT32).
Seed OPL: enable_mx4sio=1 (SD no adaptador MX4SIO na porta MC) — mesma árvore CD/DVD no cartão (MBR, exFAT ou FAT32).

See: https://github.com/ps2homebrew/Open-PS2-Loader
Ver: https://github.com/ps2homebrew/Open-PS2-Loader
