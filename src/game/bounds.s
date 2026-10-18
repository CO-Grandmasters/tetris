# %rdi - x
# %rsi - y
# Returns 1 if the piece is in bounds, 0 if not
checkBounds:
    push %rbp
    mov %rsp, %rbp

    mov %rdi, %r8
    mov %rsi, %r9
    mov $0, %rcx
    mov $pieceArray, %r11

.checkBoundsLoop:
    cmp $16, %rcx
    jge .checkBoundsValid

    cmpb $-1, (%r11)
    je .checkBoundsNext

    mov $4, %r10
    mov %rcx, %rax
    mov $0, %rdx
    div %r10

    add %r9, %rax
    cmp $0, %rax
    jl .checkBoundsInvalid
    cmp $18, %rax
    jge .checkBoundsInvalid

    add %r8, %rdx
    cmp $0, %rdx
    jl .checkBoundsInvalid
    cmp $10, %rdx
    jge .checkBoundsInvalid
    
.checkBoundsNext:
    inc %rcx
    inc %r11
    jmp .checkBoundsLoop

.checkBoundsValid:
    mov $1, %rax

    mov %rbp, %rsp
    pop %rbp
    ret

.checkBoundsInvalid:
    mov $0, %rax

    mov %rbp, %rsp
    pop %rbp
    ret

# %rdi - x
# %rsi - y
# returns:
# %rax = 1 if the piece is in a valid position, 0 if not
checkOverlap:
    push %rbp
    mov %rsp, %rbp

    mov %rdi, %r8
    mov %rsi, %r9
    mov $0, %rcx
    mov $gameArray, %r10
    mov $pieceArray, %r11

.checkOverlapLoop:
    cmp $16, %rcx
    jge .checkOverlapValid

    cmpb $-1, (%r11)
    je .checkOverlapLoopNext

    mov %rcx, %rdi
    mov %r8, %rsi
    mov %r9, %rdx
    call mapPieceArrayIndexToGameArrayIndex
    
    # gameArray[%rax * 1] 
    movzbq (%r10,%rax,1), %rax
    cmp $0, %rax
    je .checkOverlapLoopNext
    jmp .checkOverlapInvalid

.checkOverlapLoopNext:
    inc %rcx
    inc %r11
    jmp .checkOverlapLoop

.checkOverlapInvalid:
    mov $0, %rax
    
    mov %rbp, %rsp
    pop %rbp
    ret
.checkOverlapValid:
    mov $1, %rax

    mov %rbp, %rsp
    pop %rbp
    ret

# %rdi - x
# %rsi - y
# returns:
# %rax = 1 if the piece is in a valid position, 0 if not
isValidPosition:
    push %rbp
    mov %rsp, %rbp
    mov $0, %rax

    push %rdi
    push %rsi
    call checkBounds
    cmp $0, %rax
    je .isValidPositionExit

    pop %rsi
    pop %rdi
    call checkOverlap
    cmp $0, %rax
    je .isValidPositionExit

    mov $1, %rax

.isValidPositionExit:
    mov %rbp, %rsp
    pop %rbp
    ret