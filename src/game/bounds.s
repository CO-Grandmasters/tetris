# %rdi - x
# %rsi - y
# Returns 1 if the piece is in bounds, 0 if not
checkBounds:
    push %rbp
    mov %rsp, %rbp

    mov %rdi, %r8
    mov %rsi, %r9
    mov $0, %rcx # piece index
    mov $pieceArray, %r11

.checkBoundsLoop:
    cmp $16, %rcx
    jge .checkBoundsValid

    cmpb $-1, (%r11)
    je .checkBoundsNext

    # index/4 = row (y), index%4 = column (x)
    mov $4, %r10
    mov %rcx, %rax
    mov $0, %rdx
    div %r10

    # Now %rax = updatedRow
    add %r9, %rax
    cmp $0, %rax
    jl .checkBoundsInvalid
    cmp $18, %rax
    jge .checkBoundsInvalid

    # Now %rdx = updatedColumn
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
    mov $0, %rcx # pieceArray index
    mov $gameArray, %r10
    mov $pieceArray, %r11

.checkOverlapLoop:
    cmp $16, %rcx
    jge .checkOverlapValid

    # if current piece doesn't matter (= -1), skip it
    cmpb $-1, (%r11)
    je .checkOverlapLoopNext

    mov %rcx, %rdi
    mov %r8, %rsi
    mov %r9, %rdx
    call mapPieceArrayIndexToGameArrayIndex
    # now %rax holds the gameArray index to check
    
    # if the gameArray[%rax] is not empty (0), then the piece overlaps with something
    movzbq (%r10,%rax,1), %rax
    cmp $0, %rax
    je .checkOverlapLoopNext
    jmp .checkOverlapInvalid

.checkOverlapLoopNext:
    # Go to the next piece in the pieceArray
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