MB_FILES=$(shell find kern/ -type f -name '*.mb')
USER_FILES=$(shell find user/ -type f -name '*.mb')

all: kernel.bin

kernel.bin: kernel_exe.bin user/build/fs.bin
	cat $^ > $@

kernel_exe.bin: $(MB_FILES)
	../compiler/mbc kern/kernel.mb --lib arch:kern/arch/osorom/mod.mb --target asm -o kernel_exe.bin --list kernel.lst

user/build/fs.bin: $(USER_FILES)
	make -f Makefile.osorom -C user

