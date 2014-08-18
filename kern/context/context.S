.global actually_switch_contexts_with_asm
actually_switch_contexts_with_asm:
  pushl %ebp
  movl %esp, %ebp
  pusha
  pushf
  movl 0xc(%ebp), %eax
  movl %esp, (%eax)
  movl 0x8(%ebp), %esp
  popf
  popa
  leave
  ret
