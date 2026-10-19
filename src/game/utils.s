# rdi - pieceArray index
# rsi - x
# rdx - y
mapPieceArrayIndexToGameArrayIndex:
    push %rbp
    mov %rsp, %rbp

    push %r12
    push %r13
    push %r14

    mov %rsi, %r12 # %r12 = x
    mov %rdx, %r13 # %r13 = y

    mov %rdi, %rax # %rax = pieceArray index
    mov $0, %rdx # reset %rdx for division
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

loadPiece:
    push %rbp
    mov %rsp, %rbp

    movzbq currentPieceID(%rip), %r8
    movzbq currentRotation(%rip), %r9

    cmp $1, %r8
    je .loadPiece1
    cmp $2, %r8
    je .loadPiece2
    cmp $3, %r8
    je .loadPiece3
    cmp $4, %r8
    je .loadPiece4
    cmp $5, %r8
    je .loadPiece5
    cmp $6, %r8
    je .loadPiece6
    cmp $7, %r8
    je .loadPiece7

.loadPieceExit:
    mov %rbp, %rsp
    pop %rbp
    ret

.loadPiece1:
    mov $PIECE1, %rdi
    mov $16, %rax
    mul %r9 # multiply rotation by 16 to get the correct piece offset
    add %rax, %rdi

    # Copy the piece data to the current pieceArray
    mov $pieceArray, %rsi
    mov $16, %rdx
    call copyArr
    jmp .loadPieceExit

.loadPiece2:
    mov $PIECE2, %rdi
    mov $16, %rax
    mul %r9
    add %rax, %rdi
    mov $pieceArray, %rsi
    mov $16, %rdx
    call copyArr
    jmp .loadPieceExit

.loadPiece3:
    mov $PIECE3, %rdi
    mov $16, %rax
    mul %r9
    add %rax, %rdi
    mov $pieceArray, %rsi
    mov $16, %rdx
    call copyArr
    jmp .loadPieceExit

.loadPiece4:
    mov $PIECE4, %rdi
    mov $16, %rax
    mul %r9
    add %rax, %rdi
    mov $pieceArray, %rsi
    mov $16, %rdx
    call copyArr
    jmp .loadPieceExit

.loadPiece5:
    mov $PIECE5, %rdi
    mov $16, %rax
    mul %r9
    add %rax, %rdi
    mov $pieceArray, %rsi
    mov $16, %rdx
    call copyArr
    jmp .loadPieceExit

.loadPiece6:
    mov $PIECE6, %rdi
    mov $16, %rax
    mul %r9
    add %rax, %rdi
    mov $pieceArray, %rsi
    mov $16, %rdx
    call copyArr
    jmp .loadPieceExit

.loadPiece7:
    mov $PIECE7, %rdi
    mov $16, %rax
    mul %r9
    add %rax, %rdi
    mov $pieceArray, %rsi
    mov $16, %rdx
    call copyArr
    jmp .loadPieceExit