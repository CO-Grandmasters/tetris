# rdi - pieceArray index
mapPieceArrayIndexToGameArrayIndex:
    push %rbp
    mov %rsp, %rbp

    movzbq currentX(%rip), %r8
    movzbq currentY(%rip), %r9

    mov %rdi, %rax
    mov $0, %rdx
    mov $4, %r10
    div %r10                    # rax = row, rdx = col

    add %r9, %rax               # add Y to row
    imul $10, %rax, %rax        # multiply by 10 to index in gameArray
    add %r8, %rdx               # index in gameArray = (row + Y)*10 + col + X
    add %rdx, %rax              # rax = index in gameArray

    mov %rbp, %rsp
    pop %rbp
    ret
