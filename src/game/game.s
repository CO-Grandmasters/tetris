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
tickCounter: .byte 60
squareSize: .byte 16
.section .game.bss
gameArray:
	.skip 200

.section .game.text

gameInit:
	# Basic demo

	setPallette $0, $0xFFFFFF # Screen background white

	setPallette $1, $0xb4b4b4 # Cube 0 (background cube)
	setPallette $2, $0x464646

	# setTimer $19886

	mov gameArray, %rdi
	call fillArr

	ret

gameLoop:
	cmpb $60, tickCounter
	jl .postDraw
	clrScreen $0 # Clear screen
	putBitmap $CUBE0, $0, $0
	mov $0, tickCounter
.postDraw:
	inc tickCounter

	ret



fillArr:
	push %rbp
	mov %rsp, %rbp
	mov $0, %rcx

.fillArrLoop:
	cmp $200, %rcx
	jge .fillArrExit

	mov $0, (%rdi)

	inc %rdi
	inc %rcx
	jmp .fillArrLoop

.fillArrExit:
	mov %rbp, %rsp
	pop %rbp
	ret