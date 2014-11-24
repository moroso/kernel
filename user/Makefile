include progs.mk

# XXX: I feel really dirty doing a recursive make thing for this,
# but I didn't want it to be built into the hacky bsenv build system.
# Some of this adapted from 410 makefiles

# Platform shit
ifeq (Darwin,$(shell uname))
PREFIX=i386-elf-
endif
# In case that didn't catch it and the stuff needs overridden
-include platform.mk

PROJROOT = $(PWD)
UDIR = .
BUILDDIR=build

BSLD = ./bs-ld
CC = $(PREFIX)gcc
LD = $(PREFIX)ld
OBJCOPY = $(PREFIX)objcopy
# UGGGGGGGGH
MBC=../../compiler/mbc
MBC_TARGET ?= c

# XXX: entry point probably won't be main?
LDFLAGS = -static -Ttext 40000000 --fatal-warnings -melf_i386 --entry=main
CFLAGS = -nostdinc \
	-fno-strict-aliasing -fno-builtin -fno-stack-protector -fno-omit-frame-pointer \
	-Wall -g -O1 -m32 \
	-DMB_FREESTANDING
INCLUDES = -Iinc

LIB_OBJS=build/syscall_x86.o build/thr_repl.o

PROG_BINS := $(PROGS:%=$(BUILDDIR)/%)
PROG_DEPS := $(PROGS:%=$(BUILDDIR)/%.dep)

all: $(BUILDDIR)/fs_img.o

$(BUILDDIR)/%.c: %.mb $(MBC)
	$(MBC) $< -d --target $(MBC_TARGET) -o $@ --lib=printf:../../compiler/lib/printf.mb --lib=prelude:prelude.mb

$(BUILDDIR)/%.o: %.S
	$(CC) $(CFLAGS) -DASSEMBLER $(INCLUDES) -c -o $@ $<
	$(OBJCOPY) -R .comment -R .note $@ $@
%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c  -o $@ $<
	$(OBJCOPY) -R .comment -R .note $@ $@

%.bin: %.o $(LIB_OBJS)
	$(LD) $(LDFLAGS) -o $@ $< $(LIB_OBJS)

%: %.bin
	$(BSLD) $< > $@

# Include all the dependency files for our programs that mbc generates.
-include $(PROG_DEPS)

GENERATED_FILES=$(PROGS:%=$(BUILDDIR)/%.bin) $(PROGS:%=$(BUILDDIR)/%.o) $(PROGS:%=$(BUILDDIR)/%.c) $(PROG_DEPS)
.SECONDARY: $(GENERATED_FILES) $(LIB_OBJS)

# We don't want the path in the names in the script, so cd
$(BUILDDIR)/fs.img: $(PROG_BINS)
	cd $(BUILDDIR) && ../build-disk -o fs.img $(PROGS)

$(BUILDDIR)/fs_img.o: $(BUILDDIR)/fs.img
	$(OBJCOPY) -I binary -O elf32-i386 -B i386 --rename-section .data=.rodata --redefine-sym _binary_build_fs_img_start=fs_img_start --redefine-sym _binary_build_fs_img_end=fs_img_end $< $@


clean:
	rm -f $(GENERATED_FILES)
    # Eh just kill it all
	rm -f build/*
