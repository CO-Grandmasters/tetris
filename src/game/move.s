# %rdi = PS2 scan keycode 
handleMovement:
  push %rbp
  mov %rsp, %rbp

  # %rax = 0 if no movement, 1 if movement
  cmp $0x48, %rdi
  je .hanleRotateClockwise
  cmp $0x4B, %rdi
  je .handleMovementLeft
  cmp $0x4D, %rdi
  je .handleMovementRight
  cmp $0x50, %rdi
  je .handleMovementDown
  cmp $0x13, %rdi
  je .handleResetGame
  xor %eax, %eax
  jmp .handleMovementAfterCheck
.hanleRotateClockwise:
  call tryRotateClockwise
  jmp .handleMovementAfterCheck
.handleMovementLeft:
  call tryMoveLeft
  jmp .handleMovementAfterCheck
.handleMovementRight:
  call tryMoveRight
  jmp .handleMovementAfterCheck
.handleMovementDown:
  call tryMoveDown
  cmp $0, %rax
  je .handleMovementAfterCheck
  movb $60, ticksUntilMoveDown
  jmp .handleMovementAfterCheck
.handleResetGame:
  call .resetGame
  jmp .handleMovementAfterCheck
.handleMovementAfterCheck:
  cmp $0, %rax
  je .handleMovementExit

  # if movement redraw the game and piece arrays
  call printGameplay
  call drawUI
.handleMovementExit:
  mov %rbp, %rsp
  pop %rbp
  ret

tryRotateClockwise:
  push %rbp
  mov %rsp, %rbp

  call incrementRotation
  call loadPiece
  movsbq currentX(%rip), %rdi
  movsbq currentY(%rip), %rsi
  call isValidPosition
  cmp $0, %rax
  je .tryRotateClockwiseInvalid
  jmp .tryRotateClockwiseExit
.tryRotateClockwiseInvalid:
  call decrementRotation
  call loadPiece
  mov $0, %rax
.tryRotateClockwiseExit:
  mov %rbp, %rsp
  pop %rbp
  ret

tryMoveDown:
  push %rbp
  mov %rsp, %rbp

  # call check bounds and collision for down movement
  # if valid, increment currentY
  movsbq currentY(%rip), %rsi
  add $1, %rsi
  movsbq currentX(%rip), %rdi
  call isValidPosition

  cmp $0, %rax
  je .tryMoveDownExit


  incb currentY(%rip)
.tryMoveDownExit:
  mov %rbp, %rsp
  pop %rbp
  ret

tryMoveRight:
  push %rbp
  mov %rsp, %rbp

  # call check bounds and collision for right movement
  # if valid, increment currentX
    movsbq currentX(%rip), %rdi
  add $1, %rdi
  movsbq currentY(%rip), %rsi
  call isValidPosition
  cmp $0, %rax
  je .tryMoveRightExit

  incb currentX(%rip)
.tryMoveRightExit:
  mov %rbp, %rsp
  pop %rbp
  ret

tryMoveLeft:
  push %rbp
  mov %rsp, %rbp

  # call check bounds and collision for left movement
  # if valid, decrement currentX
      movsbq currentX(%rip), %rdi
  sub $1, %rdi
  movsbq currentY(%rip), %rsi
  call isValidPosition
  cmp $0, %rax
  je .tryMoveLeftExit

  decb currentX(%rip)
.tryMoveLeftExit:
  mov %rbp, %rsp
  pop %rbp
  ret

incrementRotation:
  push %rbp
  mov %rsp, %rbp

  movzbq currentRotation(%rip), %rax
  add $1, %rax
  cmp $3, %rax
  jg .incrementRotationReset

  movb %al, currentRotation(%rip)
  jmp .incrementRotationExit

.incrementRotationReset:
  movb $0, currentRotation(%rip)

.incrementRotationExit:
  mov %rbp, %rsp
  pop %rbp
  ret

decrementRotation:
  push %rbp
  mov %rsp, %rbp

  movzbq currentRotation(%rip), %rax
  sub $1, %rax
  cmp $0, %rax
  jl .decrementRotationReset

  movb %al, currentRotation(%rip)
  jmp .decrementRotationExit

.decrementRotationReset:
  movb $3, currentRotation(%rip)

.decrementRotationExit:
  mov %rbp, %rsp
  pop %rbp
  ret