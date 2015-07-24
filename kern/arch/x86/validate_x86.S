
// Could do this with cool section stuff
#define HANDLER(name, try, catch) \
  .global name; \
  name: ; \
    .long try; \
    .long catch;

HANDLER(user_copy_handler, 1f, 3f)

.global userspace_copy
userspace_copy:
    pushl %ebp
    movl %esp, %ebp
    pushl %edi
    pushl %esi

    movl 8(%ebp),  %edi
    movl 12(%ebp), %esi
    movl 16(%ebp), %ecx

    cld
1:
    rep movsb

    xor %eax, %eax
2:
    popl %esi
    popl %edi
    leave
    ret
3:
    movl $-1, %eax
    jmp 2b
