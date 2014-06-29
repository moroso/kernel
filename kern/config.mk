TABSTOP = 4

%.c: %.mb
# Need to delete the file if it doesn't work
	$(CPP) -MD -MP -MF $(@:.c=.$(DEP_SUFFIX)) -MT $@ $< | ../compiler/mc --target c > $@ || (rm $@; false)

.SECONDARY: kern/kernel.c
KERN_GAME_OBJS = kernel.o context/context.o entry/entry_stubs_x86.o entry/entry_x86.o
# Should generalize this better!
STUKCLEANS += kern/kernel.c
