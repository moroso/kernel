

.global syscall
.global syscall_0
.global syscall_1
.global syscall_2
.global syscall_3
.global syscall_4
.global syscall_5

// This could be a lot more optimized if I gave a shit.
// We always copy in everything. I could have different ones
// for different numbers of args.
// Syscall no in %eax
// Args in %ecx, %edx, %ebx, %esi, %edi

syscall:
syscall_0:
syscall_1:
syscall_2:
syscall_3:
syscall_4:
syscall_5:
  pushl %ebp
  movl %esp, %ebp

  pushl %edi
  pushl %esi
  pushl %ebx

  movl  8(%ebp), %eax
  movl 12(%ebp), %ecx
  movl 16(%ebp), %edx
  movl 20(%ebp), %ebx
  movl 24(%ebp), %esi
  movl 28(%ebp), %edi

  int $0x80

  popl %ebx
  popl %esi
  popl %edi

  leave
  ret
