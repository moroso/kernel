
ASM_SRC_FILES = \
	arch/x86/hacks.S \
	arch/x86/context.S \
	arch/x86/entry_stubs_x86.S \
	arch/x86/entry_x86.S \
	arch/x86/invalidate_tlb.S \
	arch/x86/validate_x86.S

# This really nasty config.mk slots into our temporary (?)
# super hacky build system for testing the kernel on x86.

KERN_GAME_OBJS := kernel.o fs_img.o $(ASM_SRC_FILES:%.S=%.o)

TABSTOP = 4

MBC=../compiler/mbc
MBC_TARGET ?= c
ARCH=x86

%.c: %.mb $(MBC)
	$(MBC) $< -d --target $(MBC_TARGET) -o $@ --lib arch:kern/arch/$(ARCH)/mod.mb

# Wee.
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

# This is suuuuuper dubious.
# The user directory sits next to the kern directory in the kernel/ repo,
# but our bsenv setup just has a symlink to kernel/kern.
# However, kern/.. won't point to our current directory but will instead
# point to the *actual* parent of the kern directory, which is the kernel/
# root directory. kern/../user, then, points to kernel/user.
# I didn't want the userspace build system to be built into the bsenv one,
# though, so we use recursive make and I do a big glob to see if there is
# anything worth trying to change down in there.
# Welp.
kern/fs_img.o: $(call rwildcard,kern/../user,*.mb *.c *.S *.h Makefile *.mk)
	make -C kern/../user
	cp kern/../user/build-x86/fs_img.o $@

user_clean:
	make -C kern/../user clean
clean: user_clean

.SECONDARY: kern/kernel.c
# Should generalize this better!
STUKCLEANS += kern/kernel.c
