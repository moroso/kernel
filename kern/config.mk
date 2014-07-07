TABSTOP = 4

# Wee.
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

kern/kernel.c: $(call rwildcard,kern,*.mb)
# Need to delete the file if it doesn't work
	$(CPP) kern/kernel.mb | ../compiler/mbc --target c -o $@

.SECONDARY: kern/kernel.c
KERN_GAME_OBJS = kernel.o context/context.o entry/entry_stubs_x86.o entry/entry_x86.o
# Should generalize this better!
STUKCLEANS += kern/kernel.c
