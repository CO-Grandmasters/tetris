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

printingOffset: .quad 112
tickCounter: .quad 0
squareSize: .quad 12
arraySize: .quad 180
currentPieceID: .byte 0
currentX: .byte 0
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

    setPallette $17, $0x000000 # Black for text

	mov $gameArray, %rdi        # fill gameArray with 0s
	mov arraySize, %rsi
    mov $0, %rdx
	call fillArr

    mov $pieceArray, %rdi       # fill pieceArray with -1s
    mov $16, %rsi
    mov $-1, %rdx
    call fillArr

    movb $2, currentPieceID
    call loadPiece

    call printGameArray
    call printPieceArray
    call drawUI

	ret

gameLoop:
	cmpb $60, tickCounter
	jl .postDraw

    movb $0, tickCounter
    
    call tryMoveDown
    cmp $0, %rax
    je .putPieceInGameArray

    call printGameplay
    call drawUI

.postDraw:
    xor %rax, %rax
    readKeyCode
    mov %rax, %rdi
    call handleMovement

	inc tickCounter
	ret

.putPieceInGameArray:
    call placePieceInGameArray      # put piece in gameArray
    test %rax, %rax
    jz .postDraw

    movb $1, currentPieceID(%rip)   # prep new piece
    movb $0, currentRotation(%rip)
    movb $0, currentX(%rip)
    movb $0, currentY(%rip)
    call loadPiece
    call printGameplay

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
