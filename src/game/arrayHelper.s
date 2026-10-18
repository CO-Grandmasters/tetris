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

placePieceInGameArray:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14

    movsbq currentX(%rip), %rdi
    movsbq currentY(%rip), %rsi
    call checkBounds
    test %rax, %rax
    jz .placePieceInGameArrayInvalid

    movsbq currentX(%rip), %r14
    movsbq currentY(%rip), %rbx
    mov $0, %r12
    mov $pieceArray, %r13

.placePieceInGameArrayLoop:
    cmp $16, %r12
    jge .placePieceInGameArrayEnd

    cmpb $-1, (%r13,%r12,1)
    je .placePieceInGameArrayNext

    mov %r12, %rdi
    mov %r14, %rsi
    mov %rbx, %rdx
    call mapPieceArrayIndexToGameArrayIndex

    mov $gameArray, %rdi
    add %rax, %rdi
    movb (%r13,%r12,1), %al
    movb %al, (%rdi)

.placePieceInGameArrayNext:
    inc %r12
    jmp .placePieceInGameArrayLoop

.placePieceInGameArrayEnd:
    mov $1, %rax
    jmp .placePieceInGameArrayExit

.placePieceInGameArrayInvalid:
    xor %eax, %eax

.placePieceInGameArrayExit:
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    mov %rbp, %rsp
    pop %rbp
    ret