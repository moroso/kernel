// TODO include consts file

.globl repl_with_stack
repl_with_stack:
    push %ebp # set up stack frame
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi
    movl 0x8(%ebp), %edx #move new stack to %edx
    movl 0xc(%ebp), %ebx # add func to ebx
    movl 0x10(%ebp), %edi # add args to %ecx
    movl $5, %eax #thr_repl int: need constant from somewhere  
    int $0x80
    cmp $0, %eax # determine whether we were returned 0
    jne parent_leave # let the parent exit (returned a non-0 value)
    # otherwise, we are the child   
    movl %edx, %esp #set new stack pointer
    movl %esp, %ebp # fix base pointer 
    movl %edi, (%esp) # place arguments
    call %ebx #call func 
    movl %eax, (%esp) # place return from func as argument to thr_exit
  #  call thr_exit # call ext function

/* reasonable exit call back to thr_create */
parent_leave:
    popl %edi
    popl %esi
    popl %ebx 
    leave        
    ret
