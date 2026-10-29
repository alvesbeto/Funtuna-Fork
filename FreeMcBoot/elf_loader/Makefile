# _____     ___ ____     ___ ____
#  ____|   |    ____|   |        | |____|
# |     ___|   |____ ___|    ____| |    \    PS2DEV Open Source Project.
#-----------------------------------------------------------------------
# (c) 2020 Francisco Javier Trujillo Mata <fjtrujy@gmail.com>
# Licenced under Academic Free License version 2.0
# Review ps2sdk README & LICENSE files for further details.

EE_OBJS = elf.o loader.o
EE_WARNFLAGS = -Wall

all:: prepareLoader $(EE_LIB)

clean:: cleanLoader

prepareLoader:
	mkdir -p lib obj
	$(MAKE) -C src/loader
	bin2c src/loader/loader.elf obj/loader.c loader_elf

cleanLoader:
	$(MAKE) -C src/loader clean
	rm -f obj/loader.c

include $(PS2SDKSRC)/Defs.make
include $(PS2SDKSRC)/ee/Rules.lib.make
include $(PS2SDKSRC)/ee/Rules.make
include $(PS2SDKSRC)/ee/Rules.release

$(EE_OBJS_DIR)loader.o: $(EE_OBJS_DIR)loader.c
	$(DIR_GUARD)
	$(EE_C_COMPILE) $< -c -o $@

.NOTPARALLEL:: prepareLoader
