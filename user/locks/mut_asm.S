.globl xchg
xchg:
    mov 0x04(%esp), %ecx
    mov 0x08(%esp), %eax
    xchg (%ecx), %eax 
    ret
