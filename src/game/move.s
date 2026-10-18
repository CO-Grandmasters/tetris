# %rdi = PS2 scan keycode 
handleMovement:
  push %rbp
  mov %rsp, %rbp

  # %rax = 0 if no movement, 1 if movement
  cmp $0x4B, %rdi
  je .handleMovementLeft
  cmp $0x4D, %rdi
  je .handleMovementRight
  cmp $0x50, %rdi
  je .handleMovementDown
  xor %eax, %eax
  jmp .handleMovementAfterCheck
.handleMovementLeft:
  call tryMoveLeft
  jmp .handleMovementAfterCheck
.handleMovementRight:
  call tryMoveRight
  jmp .handleMovementAfterCheck
.handleMovementDown:
  call tryMoveDown
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

tryMoveDown:
  push %rbp
  mov %rsp, %rbp

  # call check bounds and collision for down movement
  # if valid, increment currentY
  movzbq currentY(%rip), %rsi
  add $1, %rsi
  movzbq currentX(%rip), %rdi
  call isValidPosition

  cmp $0, %rax
  je .tryMoveDownExit


  inc currentY
.tryMoveDownExit:
  mov %rbp, %rsp
  pop %rbp
  ret

tryMoveRight:
  push %rbp
  mov %rsp, %rbp

  # call check bounds and collision for right movement
  # if valid, increment currentX
    movzbq currentX(%rip), %rdi
  add $1, %rdi
  movzbq currentY(%rip), %rsi
  call isValidPosition
  cmp $0, %rax
  je .tryMoveRightExit

  inc currentX
.tryMoveRightExit:
  mov %rbp, %rsp
  pop %rbp
  ret

tryMoveLeft:
  push %rbp
  mov %rsp, %rbp

  # call check bounds and collision for left movement
  # if valid, decrement currentX
      movzbq currentX(%rip), %rdi
  sub $1, %rdi
  movzbq currentY(%rip), %rsi
  call isValidPosition
  cmp $0, %rax
  je .tryMoveLeftExit

  dec currentX
.tryMoveLeftExit:
  mov %rbp, %rsp
  pop %rbp
  ret