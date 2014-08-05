/* Here is where we put various build system/runtime hacks. */

/* This is a big hack. */
.global kernel_main
kernel_main:
    jmp main

.global abort
.global malloc
malloc:
abort:
	cli
spin:
	hlt
	jmp spin
