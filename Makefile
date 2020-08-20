rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

# Once we actually have division and multiplication we can remove this part.
ADDITIONAL_MBC_OPTS = --div_func=__prelude__sw_div --mul_func=__prelude__sw_mul --mod_func=__prelude__sw_mod
#ADDITIONAL_MBC_OPTS += --disable_inliner

all: kernel.bin

kernel.bin: kernel_exe.bin user/build-osorom/fs.img
	cat $^ > $@

kernel_exe.bin: $(call rwildcard,kern,*.mb) prelude.ma Makefile
	../compiler/mbc kern/kernel.mb --lib arch:kern/arch/osorom/mod.mb --target asm -o kernel_exe.bin --list kernel.lst --global_start=100000 --stack_start=1f0000 --prelude_file prelude.ma $(ADDITIONAL_MBC_OPTS) #--debug kernel.sym

user/build-osorom/fs.img: $(call rwildcard,user,*.mb Makefile.osorom *.mk)
	make -f Makefile.osorom -C user
