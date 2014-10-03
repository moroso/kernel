.global common_entry_asm
common_entry_asm:
    /* Save state */
    pushl $0
    pusha
    pushl %ds
    pushl %es
    movl %esp, %eax
    pushl 0x50(%esp) # push eip
    pushl %ebp # push ebp
    movl %esp, %ebp # move esp to ebp
    pushl %eax # push address of ureg
    call __entry__kernel_entry
    addl $12, %esp

common_exit_asm:
    popl %es
    popl %ds
    popa
    addl $12, %esp

    iret

.global leave_kernel
leave_kernel:
    movl 4(%esp), %esp
    jmp common_exit_asm
