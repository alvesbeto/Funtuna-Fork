EE_TARGET = payload
EE_BIN = $(EE_TARGET).elf
EE_BIN_STRIPPED = $(EE_TARGET)-stripped.elf
EE_BIN_PACKED = $(EE_TARGET)-packed.elf
EE_OBJS = main.o stubs.o loader_elf.o

EE_INCS := -I$(PS2SDK)/ee/include -I$(PS2SDK)/common/include -I.
EE_CFLAGS := -D_EE -G0 -Os -Wall -mno-abicalls -fno-pic -ffunction-sections -fdata-sections
EE_LIBS = -Wl,--start-group -lpatches -lc_nano -lkernel -lcglue -lgcc -Wl,--end-group

all:
	$(MAKE) $(EE_BIN_PACKED)

loader_elf.s:
	$(MAKE) -C ../loader-old/
	bin2s ../loader-old/loader-stripped.elf loader_elf.s loader_elf

clean:
	rm -f *.elf *.o *.s *.bin
	-$(MAKE) -C ../loader-old clean

include $(PS2SDK)/samples/Makefile.pref

%.o: %.c
	$(EE_CC) $(EE_CFLAGS) $(EE_INCS) -c $< -o $@

%.o: %.s
	$(EE_AS) $(EE_ASFLAGS) $< -o $@

$(EE_BIN): $(EE_OBJS) linkfile
	$(EE_CC) -nostartfiles -T linkfile -Wl,-zmax-page-size=4096 \
		-Wl,--defsym -Wl,_stack_size=0x04000 \
		-Wl,--defsym -Wl,_heap_size=0x04000 \
		-o $(EE_BIN) $(EE_OBJS) -L$(PS2SDK)/ee/lib -Wl,--gc-sections $(EE_LIBS)

$(EE_BIN_STRIPPED): $(EE_BIN)
	$(EE_STRIP) -s -R .comment -R .gnu.version -R .mdebug.eabi64 -R .reginfo --strip-unneeded -o $@ $<

$(EE_BIN_PACKED): $(EE_BIN_STRIPPED)
ifdef OS
	../ps2_packer/ps2_packer.exe -v $< $@
else
	if command -v ps2-packer >/dev/null 2>&1; then \
		cd "$(PS2DEV)/share/ps2-packer" && ps2-packer "$(CURDIR)/$<" "$(CURDIR)/$@"; \
	else \
		wine ../ps2_packer/ps2_packer.exe -v $< $@; \
	fi
endif
