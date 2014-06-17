TABSTOP = 4

%.c: %.mb
# Need to delete the file if it doesn't work
	$(CPP) -MD -MP -MF $(@:.c=.$(DEP_SUFFIX)) -MT $@ $< | ../compiler/mc --target c > $@ || (rm $@; false)


KERN_GAME_OBJS = kernel.o context/context.o
# Should generalize this better!
STUKCLEANS += kern/kernel.c
