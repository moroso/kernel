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
  movl 0x14(%ebp), %edi
  movl 0x18(%ebp), %ecx
  movl 0x1c(%ebp), %edx
  movl 0x20(%ebp), %ebx
  popf
  popl %ebp
  movl 0x10(%ebp), %esi
  movl %eax, (%esi)
  movl 0x14(%ebp), %esi
  movl %edi, (%esi)
  movl 0x18(%ebp), %esi
  movl %ecx, (%esi)
  movl 0x1c(%ebp), %esi
  movl %edx, (%esi)
  movl 0x20(%ebp), %esi
  movl %ebx, (%esi)
  popl %ebx
  popl %edi
  popl %esi
  leave
  ret


.global fastpath_recv_switch 
  fastpath_recv_switch:
  pushl %ebp
  movl %esp, %ebp
  pushl %esi
  pushl %edi
  pushl %ebx
  pushl %ebp
  pushf
  movl 0xc(%ebp), %eax
  movl %esp, (%eax)
  movl 0x8(%ebp), %esp
  popf
  popa
  leave
  ret

