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
.include "src/game/macros.inc"

.global gameInit
.global gameLoop

.section .game.data
# (screen width - 8*squareSize) / 2

timeInSeconds: .quad 0
completedLines: .quad 0
maxLines: .quad 40
printingOffset: .quad 112
tickCounter: .quad 0
ticksUntilMoveDown: .quad 60
squareSize: .quad 12
arraySize: .quad 180
currentPieceID: .byte 1
currentX: .byte 3
currentY: .byte 0
currentRotation: .byte 0
.section .game.bss
gameArray:
	.skip 180
pieceArray:
    .skip 16

.section .game.text

gameInit:
	# 0=Empty, 1=I, 2=J, 3=L, 4=O, 5=S, 6=Z, 7=t
	setPallette $0, $0xFFFFFF # Screen background white

	setPallette $1, $0xb4b4b4 # Cube 0 (background cube)
	setPallette $2, $0x464646

	setPallette $3, $0x00f0f0 # Cube 1 (I-piece)
	setPallette $4, $0x009e9e

	setPallette $5, $0x0000f0 # Cube 2 (J-piece)
	setPallette $6, $0x00009e

	setPallette $7, $0xf0a000 # Cube 3 (L-piece)
	setPallette $8, $0x9e6500

	setPallette $9, $0xf0f000 # Cube 4 (O-piece)
	setPallette $10, $0x9e9e00

	setPallette $11, $0x00f000 # Cube 5 (S-piece)
	setPallette $12, $0x009e00

	setPallette $13, $0xf00000 # Cube 6 (Z-piece)
	setPallette $14, $0x9e0000

	setPallette $15, $0xa000f0 # Cube 7 (T-piece)
	setPallette $16, $0x630096

    setPallette $17, $0x000000 # Black for text

	mov $gameArray, %rdi        # fill gameArray with 0s
	mov arraySize, %rsi
    mov $0, %rdx
	call fillArr

    mov $pieceArray, %rdi       # fill pieceArray with -1s
    mov $16, %rsi
    mov $-1, %rdx
    call fillArr

    call randomizeSeed
    call getRandomNumberBetween1And7
    movb %al, currentPieceID(%rip)   # prep new piece
    call loadPiece

    call printGameArray
    call printPieceArray
    call drawUI

	ret

gameLoop:
    cmpb $60, tickCounter
    jge .incrementSeconds
.postIncrementSeconds:
    call drawUI
	cmpb $0, ticksUntilMoveDown
	jg .postDraw
.handleMoveDown:
    movb $60, ticksUntilMoveDown
    call tryMoveDown
    cmp $0, %rax
    je .putPieceInGameArray
    call printGameplay
.postDraw:
    xor %rax, %rax
    readKeyCode
    mov %rax, %rdi
    call handleMovement

    inc tickCounter
	dec ticksUntilMoveDown
	ret

.incrementSeconds:
    inc timeInSeconds
    movb $0, tickCounter
    jmp .postIncrementSeconds

.putPieceInGameArray:
    call placePieceInGameArray      # put piece in gameArray
    test %rax, %rax
    jz .postDraw

    call getRandomNumberBetween1And7
    movb %al, currentPieceID(%rip)   # prep new piece
    movb $0, currentRotation(%rip)
    movb $3, currentX(%rip)
    movb $0, currentY(%rip)
    call loadPiece
    call printGameplay
    call drawUI

    jmp .postDraw                   # go back to gameLoop

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
    mul %r9
    add %rax, %rdi
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