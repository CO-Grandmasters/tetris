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

.macro line x0, y0, x1, y1, col 
		movq	\x0, %rdi
		movq 	\y0, %rsi
		movq	\x1, %rdx
		movq 	\y1, %rcx
		movq 	\col, %r8
		call putLine
.endm

.file "src/game/game.s"

.global gameInit
.global gameLoop

.section .game.data

.section .game.text

gameInit:
	# Basic demo

	mov		$0, %rdi
	call	clrScreen

	mov 	$0, %rdi
	mov 	$0xFFFFFF, %rsi
	call  	setPallette

	mov 	$1, %rdi
	mov 	$0x00A6D6, %rsi
	call  	setPallette

	line $17, $129, $176, $112, $1
	line $17, $129, $20, $159, $1
	line $20, $159, $188, $198, $1
	line $188, $198, $316, $191, $1
	line $316, $191, $176, $112, $1
	line $34, $126, $188, $198, $1
	line $119, $128, $140, $65, $1
	line $140, $65, $163, $132, $1
	line $202, $196, $143, $156, $1
	line $142, $156, $162, $154, $1
	line $162, $154, $302, $192, $1

	movq	$FLAME, %rdi
	movq	$128, %rsi
	movq	$22, %rdx
	call 	putBitmap

	ret

gameLoop:
	ret
