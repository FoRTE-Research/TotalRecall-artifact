outputs = quicksort.out factorial.out factorial_iterative.out fir.out matrix.out dhrystone.out

GCC_DIR =  ~/ti/msp430-gcc/bin
SUPPORT_FILE_DIRECTORY = ~/ti/msp430-gcc/include
CC      = $(GCC_DIR)/msp430-elf-gcc

OBJDIR  = $(DEVICE)/bin
SRCDIR  = $(DEVICE)/src
CKPTDIR = $(DEVICE)/checkpoint
LDDIR   = $(DEVICE)/ld
OBJECTS = $(addprefix $(OBJDIR)/, $(outputs))

CFLAGS = -I $(SUPPORT_FILE_DIRECTORY) -mmcu=$(DEVICE) -Os -S -fverbose-asm
ASMFLAGS = -I $(SUPPORT_FILE_DIRECTORY) -mmcu=$(DEVICE) -D_GNU_ASSEMBLER -Wall -g -fdata-sections -ffunction-sections -T $(LDDIR)/$(DEVICE).ld -ffreestanding $(CKPTDIR)/recover_sram_ckpt.S $(CKPTDIR)/take_sram_ckpt.S -e__recover_sram_ckpt
LFLAGS = -L $(SUPPORT_FILE_DIRECTORY)

# Don't delete .S files as intermediate
#.SECONDARY:

.PHONY: check-dev clean

all: check-dev $(OBJECTS)

check-dev:
ifndef DEVICE
	$(error DEVICE is not set - rerun make with either DEVICE=msp430g2553 or DEVICE=msp430fr6989)
endif

$(OBJDIR)/%.out: %.S
	$(CC) $(ASMFLAGS) $(LFLAGS) $< -o $@

%.S: $(SRCDIR)/%.c $(CKPTDIR)/take_sram_ckpt.S $(CKPTDIR)/recover_sram_ckpt.S
	$(CC) $(CFLAGS) $(LFLAGS) $< -o $@

clean:
	$(RM) msp430g2553/bin/*.out
	$(RM) msp430fr6989/bin/*.out
