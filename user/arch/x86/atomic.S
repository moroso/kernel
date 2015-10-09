.globl atomic_add
atomic_add:
    movl 0x8(%esp), %eax
    movl 0x4(%esp), %ecx
    lock xadd %eax, (%ecx)
    ret

.globl xchg
xchg:
    mov 0x04(%esp), %ecx
    mov 0x08(%esp), %eax
    xchg (%ecx), %eax
    ret
