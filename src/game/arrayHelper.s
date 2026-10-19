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

# Returns: %rax - 1 if success, 0 if fail
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
    mov $0, %r12 # Counter for pieceArray index
    mov $pieceArray, %r13 # Pointer to pieceArray

.placePieceInGameArrayLoop:
    cmp $16, %r12
    jge .placePieceInGameArrayEnd

    # -1 == pieceArray[%r12]
    cmpb $-1, (%r13,%r12,1)
    je .placePieceInGameArrayNext

    mov %r12, %rdi
    mov %r14, %rsi
    mov %rbx, %rdx
    call mapPieceArrayIndexToGameArrayIndex
    # %rax now holds the gameArray index to write to

    # point %rdi to gameArray[%rax]
    mov $gameArray, %rdi
    add %rax, %rdi

    # move pieceArray[%r12] to gameArray[%rax]
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

    mov $0, %r12 # gameArray row index

# Returns: %rax - index of first completed row, or -1 if none found
.findCompletedRowLoop:
    cmp $18, %r12 # column height
    jge .findCompletedRowNotFound

    mov %r12, %rax
    imul $10, %rax, %rax # %rax now holds the starting index of the current row in gameArray

    mov $gameArray, %r14
    add %rax, %r14 # %r14 now points to the start of the current row in gameArray
    mov $0, %r13 # gameArray column index

.findCompletedRowColumnLoop:
    cmp $10, %r13 # gameArray column width
    jge .findCompletedRowFound

    # 0 == gameArray[%r14 + %r13]
    # If some column in the row is empty, then this row is not completed
    cmpb $0, (%r14,%r13,1)
    je .findCompletedRowNext

    # Go to the next column
    inc %r13
    jmp .findCompletedRowColumnLoop

.findCompletedRowNext:
    # Go to next row
    inc %r12
    jmp .findCompletedRowLoop

.findCompletedRowFound:
    # Found a completed row
    mov %r12, %rax
    jmp .findCompletedRowExit

.findCompletedRowNotFound:
    mov $-1, %rax

.findCompletedRowExit:
    pop %r14
    pop %r13
    pop %r12
    ret

# %rdi - row to remove (0-17)
removeGameArrayRow:
    push %r12
    push %r13
    push %r14

    # If row is invalid (< 0 or >= 18), return 0
    mov %rdi, %r12
    cmp $0, %r12
    jl .removeGameArrayRowInvalid
    cmp $18, %r12
    jge .removeGameArrayRowInvalid

    mov $gameArray, %r14

.removeGameArrayRowLoop:
    cmp $0, %r12
    je .removeGameArrayClearTop

    mov $0, %r13 # Counter for gameArray column index (x)

.removeGameArrayColumnLoop:
    cmp $10, %r13
    jge .removeGameArrayPreviousRow

    mov %r12, %rax
    imul $10, %rax, %rax # %rax now holds the starting index of the current row in gameArray
    add %r13, %rax

    # gameArray[%rax] = gameArray[%rax - 10]
    # copy value from upper row to current row
    movb -10(%r14,%rax,1), %dl
    movb %dl, (%r14,%rax,1)

    inc %r13
    jmp .removeGameArrayColumnLoop

.removeGameArrayPreviousRow:
    # Go to higher row
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
