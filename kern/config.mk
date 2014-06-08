TABSTOP = 4

%.c: %.mb
	cpp -MD -MP -MF $(@:.c=.$(DEP_SUFFIX)) -MT $@ -P $< | ../compiler/mc --target c > $@

KERN_GAME_OBJS = kernel.o
