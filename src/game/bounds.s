# %rdi - x
# %rsi - y
# Returns 1 if the piece is in bounds, 0 if not
checkBounds:
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
    ret

.checkBoundsInvalid:
    mov $0, %rax
    ret

# %rdi - x
# %rsi - y
# returns:
# %rax = 1 if the piece is in a valid position, 0 if not
checkOverlap:
    push %rbp
    mov %rsp, %rbp

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