# EE ELF loader (SifLoadElf + ExecPS2) at fixed load address for FMCB embed.

LOADADDR  = 0x90000
STACKADDR = 0xA8000
STACKSIZE = 0x04000
HEAPSIZE  = 0x04000

ifeq ($(DEBUG),1)
LOADADDR  = 0x1700000
STACKADDR = 0x1720000
STACKSIZE = 0x08000
HEAPSIZE  = 0x08000
endif

LDPARAMS := -Wl,--defsym -Wl,_stack_size=$(STACKSIZE) -Wl,--defsym -Wl,_heap_size=$(HEAPSIZE) -Wl,--defsym -Wl,_stack=$(STACKADDR)

EE_BIN = loader.elf
EE_OBJS = loader.o
EE_INCS := -I$(PS2SDK)/ee/include -I$(PS2SDK)/common/include -I.
EE_CFLAGS := -D_EE -G0 -Os -Wall -mno-abicalls -fno-pic -ffunction-sections -fdata-sections
EE_LIBS = -lc -lkernel

ifeq ($(DEBUG),1)
EE_LIBS += -ldebug
endif

all: $(EE_BIN)

clean:
	rm -f $(EE_OBJS) $(EE_BIN)

include $(PS2SDK)/samples/Makefile.pref

%.o: %.c
	$(EE_CC) $(EE_CFLAGS) $(EE_INCS) -c $< -o $@

$(EE_BIN): $(EE_OBJS) linkfile
	$(EE_CC) -nostartfiles -T linkfile $(LDPARAMS) -Wl,-zmax-page-size=4096 \
		-o $(EE_BIN) $(EE_OBJS) -L$(PS2SDK)/ee/lib -Wl,--gc-sections $(EE_LIBS)
