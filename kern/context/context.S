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


.global fastpath_send_switch 
fastpath_send_switch:
  pushl %ebp
  movl %esp, %ebp
  pusha
  pushf
  movl 0xc(%ebp), %eax
  movl %esp, (%eax)
  movl 0x8(%ebp), %esp
  movl 0x10(%ebp), %eax
  popf
  popl %edi
  popl %esi
  popl %ebp
  popl %ebx
  popl %edx
  popl %ecx
  movl 0x10(%ebp), %esi
  movl %eax, (%esi)
  leave
  ret


.global fastpath_recv_switch 
  fastpath_recv_switch:
  pushl %ebp
  movl %esp, %ebp
  pushl %ecx
  pushl %edx
  pushl %ebx
  pushl %ebp
  pushl %esi
  pushl %edi
  pushf
  movl 0xc(%ebp), %eax
  movl %esp, (%eax)
  movl 0x8(%ebp), %esp
  popf
  popa
  leave
  ret

