# rdi - pieceArray index
mapPieceArrayIndexToGameArrayIndex:
    push %rbp
    mov %rsp, %rbp

    push %r12
    push %r13
    push %r14

    movzbq currentX(%rip), %r12
    movzbq currentY(%rip), %r13

    mov %rdi, %rax
    mov $0, %rdx
    mov $4, %r14
    div %r14                    # rax = row, rdx = col

    add %r13, %rax               # add Y to row
    imul $10, %rax, %rax        # multiply by 10 to index in gameArray
    add %r12, %rdx               # index in gameArray = (row + Y)*10 + col + X
    add %rdx, %rax              # rax = index in gameArray

    pop %r14
    pop %r13
    pop %r12

    mov %rbp, %rsp
    pop %rbp
    ret
