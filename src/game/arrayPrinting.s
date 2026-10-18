.file "src/game/arrayPrinting.s"

.include "src/game/macros.inc"

printGameArray:
    mov $gameArray, %rdi
    mov arraySize, %rsi
    mov $10, %rdx
    mov printingOffset, %rcx
    mov $0, %r8
    call printArr
    ret

# Prints the pieceArray to the screen at the currentX and currentY offsets
printPieceArray:
    mov $pieceArray, %rdi
    mov $16, %rsi
    mov $4, %rdx

    mov printingOffset, %rcx
    mov squareSize(%rip), %r9
    dec %r9                     # (squareSize - 1)
    movzbq currentX(%rip), %rax
    imulq %r9, %rax             # currentX * (squareSize - 1)
    add %rax, %rcx              # printingOffset + currentX * (squareSize - 1)

    movzbq currentY(%rip), %rax
    imulq %r9, %rax             # currentY * (squareSize - 1)
    mov %rax, %r8               

    call printArr
    ret

# %rdi - array
# %rsi - array length
# %rdx - array row size
# %rcx - x offset (pixels)
# %r8 - y offset (pixels)
# draws array to screen
printArr:
    push %rbp
    mov %rsp, %rbp

    movq squareSize(%rip), %r9		# (squareSize - 1)
    decq %r9
    mov %rdx, %r10
    mov %rcx, %r11
    mov %r8, %r12

    mov $0, %rcx

.printArrLoop:
    cmp %rsi, %rcx					# while %rcx < %rsi
    jge .printArrExit

    # row = %rcx / 10
	# col = %rcx % 10
    mov $0, %rdx
    movq %rcx, %rax
    divq %r10						# %rax = row (quotient), %rdx = col (remainder)

    # scale both by (squareSize - 1)
    imulq %r9, %rax					# %rax = row * (squareSize - 1)
    movq  %rax, %r8

    movq  %rdx, %rax
    imulq %r9, %rax					# %rax = col * (squareSize - 1)

    push %rsi						# save caller-saved registers
    push %rdi
    push %rdx
    push %rcx
    push %r9
    push %r10
    push %r11
    push %r12

    add %r11, %rax			# add printing offset to row
    add %r12, %r8			# add printing offset to col

    cmpb $0, (%rdi)					# draw different cube color depending on the value in that cell
    je .printCube0
    cmpb $1, (%rdi)
    je .printCube1
    cmpb $2, (%rdi)
    je .printCube2
    cmpb $3, (%rdi)
    je .printCube3
    cmpb $4, (%rdi)
    je .printCube4
    cmpb $5, (%rdi)
    je .printCube5
    cmpb $6, (%rdi)
    je .printCube6
    cmpb $7, (%rdi)
    je .printCube7

.afterPrint:
    pop %r12                    # restore caller-saved registers
    pop %r11
    pop %r10
    pop %r9
    pop %rcx
    pop %rdx
    pop %rdi
    pop %rsi

    inc %rcx
    inc %rdi
    jmp .printArrLoop

.printArrExit:
    mov %rbp, %rsp
    pop %rbp
    ret

.printCube0:
    putBitmap $CUBE0, %rax, %r8
    jmp .afterPrint
.printCube1:
    putBitmap $CUBE1, %rax, %r8
    jmp .afterPrint
.printCube2:
    putBitmap $CUBE2, %rax, %r8
    jmp .afterPrint
.printCube3:
    putBitmap $CUBE3, %rax, %r8
    jmp .afterPrint
.printCube4:
    putBitmap $CUBE4, %rax, %r8
    jmp .afterPrint
.printCube5:
    putBitmap $CUBE5, %rax, %r8
    jmp .afterPrint
.printCube6:
    putBitmap $CUBE6, %rax, %r8
    jmp .afterPrint
.printCube7:
    putBitmap $CUBE7, %rax, %r8
    jmp .afterPrint
