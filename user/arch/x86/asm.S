.globl atomic_add
atomic_add:
    movl 0x8(%esp), %eax
    movl 0x4(%esp), %ecx
    LOCK xadd %eax, (%ecx)
    ret
    
