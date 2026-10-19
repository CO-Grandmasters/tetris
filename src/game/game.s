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
# -1 - lost, 0 - playing, 1 - won
gameState: .quad 0
timeInSeconds: .quad 0
completedLines: .quad 0
maxLines: .quad 40
# (screen width - 8*squareSize) / 2
printingOffset: .quad 112
holdPieceOffset: .quad 56
holdFlag: .byte 0
tickCounter: .quad 0			# 60 ticks/s
ticksUntilMoveDown: .quad 60
squareSize: .quad 12
arraySize: .quad 180
currentPieceID: .byte 1
holdPieceID: .byte 1
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
    call initScoreArray
postScoreLoadGameInit:
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

    mov $0, holdPieceID              # reset hold params
    mov $0, holdFlag

    clrScreen $0 
    call printGameplay              # print game arr,
                                    # piece arr, ui and
									# hold piece (it's 0 so just clears)

	ret

gameLoop:
    cmpq $0, gameState(%rip)
    jne .renderGameState			# if gameState != playing
    mov completedLines(%rip), %rax	
    cmp maxLines(%rip), %rax		# if cleared lines < goal
    jl .gameStatePlaying			
    movq $1, gameState(%rip)		# else gameState = won
    jmp .renderGameState

.gameStatePlaying:
    cmpb $60, tickCounter
    jge .incrementSeconds			# increment seconds every 60 ticks
.postIncrementSeconds:
    call drawUI
	cmpb $0, ticksUntilMoveDown		# automatically move down once every 60 ticks
	jg .postDraw
.handleMoveDown:
    movb $60, ticksUntilMoveDown	# reset counter
    call tryMoveDown
    cmp $0, %rax
    je .putPieceInGameArray			# if can't move down, confirm piece
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
    movb $0, holdFlag
    call placePieceInGameArray      # write piece to gameArray
    cmp $0, %rax					# if placed successful -> clear lines
    jne .clearLines
    movq $-1, gameState(%rip)		# else gameState = lose
    jmp .renderGameState
.clearLines:
    call findCompletedRow			
    cmp $-1, %rax					# if no completed rows, stop loop
    je .generateNewPiece
    mov %rax, %rdi
    call removeGameArrayRow			# remove first found completed row
    inc completedLines
    jmp .clearLines					# loop
.generateNewPiece:
    call getRandomNumberBetween1And7
    movb %al, currentPieceID(%rip)   # prep new piece
    movb $0, currentRotation(%rip)
    movb $3, currentX(%rip)
    movb $0, currentY(%rip)
    call loadPiece
    movsbq currentX(%rip), %rdi
    movsbq currentY(%rip), %rsi
    call isValidPosition
    test %rax, %rax
    jz .setGameStateLost			# if can't place new piece -> gameState lose
    call printGameplay
    call drawUI

    jmp .postDraw                   # go back to gameLoop

.setGameStateLost:
    movq $-1, gameState(%rip)

.renderGameState:
    xor %rax, %rax
    readKeyCode
    cmp $0x13, %rax
    je .resetGame
    call printGameplay
    call drawUI
    cmpq $1, gameState(%rip)
    je .renderGameStateWin
    call drawYouLose
    ret

.renderGameStateWin:
	mov timeInSeconds(%rip), %rdi
    call addScoreToLeaderboard
    call drawYouWin
    ret

.resetGame:
    movq $0, gameState(%rip)
    movq $0, timeInSeconds(%rip)
    movq $0, completedLines(%rip)
    movq $0, tickCounter(%rip)
    movb $60, ticksUntilMoveDown(%rip)
    movb $3, currentX(%rip)
    movb $0, currentY(%rip)
    movb $0, currentRotation(%rip)
	mov $0, hasAddedNewScoreThisSession(%rip)

    jmp postScoreLoadGameInit
