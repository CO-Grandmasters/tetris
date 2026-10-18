# %rdi - array
# %rsi - array length
# %rdx - byte to fill array with
# fills array
fillArr:
    push %rbp
    mov %rsp, %rbp
    mov $0, %rcx

.fillArrLoop:
    cmp %rsi, %rcx				# while %rcx < %rsi
    jge .fillArrExit

    #mov %rcx, %rax
    #xor %rdx, %rdx
    #mov $10, %r8
    #divq %r8						# %rax = row (quotient), %rdx = col (remainder)

    #movb %dl, (%rdi)

    movb %dl, (%rdi)

    inc %rdi
    inc %rcx
    jmp .fillArrLoop

.fillArrExit:
    mov %rbp, %rsp
    pop %rbp
    ret

# %rdi - source array
# %rsi - destination array
# %rdx - number of bytes to copy
copyArr:
    push %rbp
    mov %rsp, %rbp
    mov $0, %rcx

.copyArrLoop:
    cmp %rdx, %rcx
    jge .copyArrExit

    movb (%rdi), %al
    movb %al, (%rsi)
    inc %rdi
    inc %rsi
    inc %rcx
    jmp .copyArrLoop

.copyArrExit:
    mov %rbp, %rsp
    pop %rbp
    ret
