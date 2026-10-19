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

findCompletedRow:
    push %r12
    push %r13
    push %r14

    mov $0, %r12

.findCompletedRowLoop:
    cmp $18, %r12
    jge .findCompletedRowNotFound

    mov %r12, %rax
    imul $10, %rax, %rax
    mov $gameArray, %r14
    add %rax, %r14
    mov $0, %r13

.findCompletedRowColumnLoop:
    cmp $10, %r13
    jge .findCompletedRowFound

    cmpb $0, (%r14,%r13,1)
    je .findCompletedRowNext

    inc %r13
    jmp .findCompletedRowColumnLoop

.findCompletedRowNext:
    inc %r12
    jmp .findCompletedRowLoop

.findCompletedRowFound:
    mov %r12, %rax
    jmp .findCompletedRowExit

.findCompletedRowNotFound:
    mov $-1, %rax

.findCompletedRowExit:
    pop %r14
    pop %r13
    pop %r12
    ret

# %rdi - row to remove
removeGameArrayRow:
    push %r12
    push %r13
    push %r14

    mov %rdi, %r12
    cmp $0, %r12
    jl .removeGameArrayRowInvalid
    cmp $18, %r12
    jge .removeGameArrayRowInvalid

    mov $gameArray, %r14

.removeGameArrayRowLoop:
    cmp $0, %r12
    je .removeGameArrayClearTop

    mov $0, %r13

.removeGameArrayColumnLoop:
    cmp $10, %r13
    jge .removeGameArrayPreviousRow

    mov %r12, %rax
    imul $10, %rax, %rax
    add %r13, %rax
    movb -10(%r14,%rax,1), %dl
    movb %dl, (%r14,%rax,1)

    inc %r13
    jmp .removeGameArrayColumnLoop

.removeGameArrayPreviousRow:
    dec %r12
    jmp .removeGameArrayRowLoop

.removeGameArrayClearTop:
    mov $0, %r13

.removeGameArrayClearTopLoop:
    cmp $10, %r13
    jge .removeGameArraySuccess

    movb $0, (%r14,%r13,1)
    inc %r13
    jmp .removeGameArrayClearTopLoop

.removeGameArraySuccess:
    mov $1, %rax
    jmp .removeGameArrayExit

.removeGameArrayRowInvalid:
    xor %eax, %eax

.removeGameArrayExit:
    pop %r14
    pop %r13
    pop %r12
    ret
