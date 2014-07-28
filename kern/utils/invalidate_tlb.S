.globl invalidate_tlb

invalidate_tlb:
movl 0x4(%esp), %eax
invlpg (%eax)
ret
