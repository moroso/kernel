# This is way more elaborate of a makefile than is necessary for this
# stuff.

ASM_SRC_FILES =
C_SRC_FILES = math64.c
PROGS = test mandelbrot

##################################################################


# Platform shit
ifeq (Darwin,$(shell uname))
PREFIX=i386-elf-
endif
# In case that didn't catch it and the stuff needs overridden
-include platform.mk

PROJROOT = $(PWD)
UDIR = .
BUILDDIR=build-x86

CC = $(PREFIX)gcc
LD = $(PREFIX)gcc
# UGGGGGGGGH
MBC=../../../compiler/mbc
MBC_TARGET ?= c
ARCH ?= x86

CFLAGS = -Wall -g -O2 -m32
LDFLAGS = -m32
INCLUDES = -Iinc

ASM_OBJS=$(ASM_SRC_FILES:%.S=$(BUILDDIR)/%.o)
C_OBJS=$(C_SRC_FILES:%.c=$(BUILDDIR)/%.o)
LIB_OBJS=$(ASM_OBJS) $(C_OBJS)

PROG_C_FILES=$(PROGS:%=$(BUILDDIR)/%.c)
PROG_OBJS=$(PROGS:%=$(BUILDDIR)/%.o)

ALL_OBJS=$(LIB_OBJS) $(PROG_OBJS)
ALL_DEPS=$(ALL_OBJS:%.o=%.dep)

all: $(PROGS)

$(BUILDDIR):
	mkdir -p $@

$(BUILDDIR)/%.c: %.mb $(MBC) |$(BUILDDIR)
	$(MBC) $< -d --target $(MBC_TARGET) \
		--lib arch:arch/x86/mod.mb \
		--lib out:arch/x86/out.mb -o $@

$(BUILDDIR)/%.o: %.S |$(BUILDDIR)
	$(CC) $(CFLAGS) -DASSEMBLER $(INCLUDES) -c -o $@ $<
$(BUILDDIR)/%.o: %.c |$(BUILDDIR)
	$(CC) $(CFLAGS) $(INCLUDES) -c  -o $@ $<
%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c  -o $@ $<

%: %.o $(LIB_OBJS)
	$(LD) $(LDFLAGS) -o $@ $< $(LIB_OBJS)

%: $(BUILDDIR)/%
	cp $< $@

%.bin: %.mb $(MBC) |$(BUILDDIR)
	$(MBC) $< -d --target asm -o $@ \
		--lib arch:arch/osorom/mod.mb \
		--lib out:arch/osorom/out.mb \
		--list $@.list --stack_start 400000

# Include all the dependency files
-include $(ALL_DEPS)

GENERATED_FILES=$(ALL_DEPS) $(PROG_C_FILES) $(ALL_OBJS) $(PROGS:%=$(BUILDDIR)/%)
.SECONDARY: $(GENERATED_FILES)

clean:
	rm -f $(GENERATED_FILES) $(PROGS) *.png
	rmdir --ignore-fail-on-non-empty $(BUILDDIR)
