.globl xchg
xchg:
    movl 0x4(%esp), %ecx
    movl 0x8(%esp), %eax
    xchg (%ecx), %eax 
    ret
