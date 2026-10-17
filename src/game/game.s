/*
This file is part of gamelib-x64.

Copyright (C) 2014 Tim Hegeman

gamelib-x64 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

gamelib-x64 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with gamelib-x64. If not, see <http://www.gnu.org/licenses/>.
*/


.file "src/game/game.s"
.file "src/game/ui.s"
.include "src/game/macros.inc"

.global gameInit
.global gameLoop

.section .game.data
# (screen width - 8*squareSize) / 2
printingOffset: .quad 112
tickCounter: .quad 60
squareSize: .quad 12
arraySize: .quad 180
.section .game.bss
gameArray:
	.skip 180

.section .game.text

gameInit:
	# 0=Empty, 1=I, 2=J, 3=L, 4=O, 5=S, 6=Z, 7=t
	setPallette $0, $0xFFFFFF # Screen background white

	setPallette $1, $0xb4b4b4 # Cube 0 (background cube)
	setPallette $2, $0x464646

	setPallette $3, $0x99d9ea # Cube 1 (I-piece)
	setPallette $4, $0x00b7ef

	setPallette $5, $0x4d6df3 # Cube 2 (J-piece)
	setPallette $6, $0x2f3699

	setPallette $7, $0xe5aa7a # Cube 3 (L-piece)
	setPallette $8, $0xff7e00

	setPallette $9, $0xfff200 # Cube 4 (O-piece)
	setPallette $10, $0xffc20e

	setPallette $11, $0xd3f9bc # Cube 5 (S-piece)
	setPallette $12, $0x22b14c

	setPallette $13, $0xffa3b1 # Cube 6 (Z-piece)
	setPallette $14, $0xed1c24

	setPallette $15, $0xb5a5d5 # Cube 7 (T-piece)
	setPallette $16, $0x6f3198

	mov gameArray, %rdi
	mov arraySize, %rsi
	call fillArr

	ret

gameLoop:
	cmpb $60, tickCounter
	jl .postDraw
	clrScreen $0 # Clear screen
	mov gameArray, %rdi
	mov arraySize, %rsi
	call printArr
  
.postDraw:
	inc tickCounter

	ret

# %rdi - array
# %rsi - array length
# draws array to screen
printArr:
    push %rbp
    mov %rsp, %rbp
    mov $0, %rcx

    movq squareSize(%rip), %r9		# (squareSize - 1)
    decq %r9

.printArrLoop:
    cmp %rsi, %rcx					# while %rcx < %rsi
    jge .printArrExit

    # row = %rcx / 10
	# col = %rcx % 10
    mov $0, %rdx
    movq %rcx, %rax
    movq $10, %r8
    divq %r8						# %rax = row (quotient), %rdx = col (remainder)

    # scale both by (squareSize - 1)
    imulq %r9, %rax					# %rax = row * (squareSize - 1)
    movq  %rax, %r8

    movq  %rdx, %rax
    imulq %r9, %rax					# %rax = col * (squareSize - 1)

    push %rsi						# save caller-saved registers
    push %rdi
    push %rcx
    push %r9

    add printingOffset(%rip), %rax			# add printing offset to row

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
    pop %r9							# restore caller-saved registers
    pop %rcx
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

# %rdi - array
# %rsi - array length
# fills array with 0s
fillArr:
    push %rbp
    mov %rsp, %rbp
    mov $0, %rcx

.fillArrLoop:
    cmp %rsi, %rcx				# while %rcx < %rsi
    jge .fillArrExit

    mov %rcx, %rax
    xor %rdx, %rdx
    mov $10, %r8
    divq %r8						# %rax = row (quotient), %rdx = col (remainder)

    movb %dl, (%rdi)

    inc %rdi
    inc %rcx
    jmp .fillArrLoop

.fillArrExit:
    mov %rbp, %rsp
    pop %rbp
    ret