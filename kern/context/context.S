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
  movl 0x10(%ebp), %esi
  movl (%esi), %eax
  addl $4, %esi
  movl (%esi), %edi
  addl $4, %esi
  movl (%esi), %edx
  addl $4, %esi
  movl (%esi), %ecx
  addl $4, %esi
  movl (%esi), %ebx
  popf
  popl %ebp
  movl 0x10(%ebp), %esi
  movl %eax, (%esi)
  addl $4, %esi
  movl %edi, (%esi)
  addl $4, %esi
  movl %ecx, (%esi)
  addl $4, %esi
  movl %edx, (%esi)
  addl $4, %esi
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

