# %rdi = PS2 scan keycode 
handleMovement:
  push %rbp
  mov %rsp, %rbp

  # %rax = 0 if no movement, 1 if movement
  cmp $0x4B, %rdi
  je tryMoveLeft
  cmp $0x4D, %rdi
  je tryMoveRight
  cmp $0x50, %rdi
  je tryMoveDown
.handleMovementAfterCheck:
  cmp $0, %rax
  je .handleMovementExit

  # if movement redraw the game and piece arrays
  call printGameplay
.handleMovementExit:
  mov %rbp, %rsp
  pop %rbp
  ret

tryMoveDown:
  # call check bounds and collision for down movement
  # if valid, increment currentY
  inc currentY
  mov $1, %rax
  jmp .handleMovementAfterCheck

tryMoveRight:
  # call check bounds and collision for right movement
  # if valid, increment currentX
  inc currentX
  mov $1, %rax
  jmp .handleMovementAfterCheck

tryMoveLeft:
  # call check bounds and collision for left movement
  # if valid, decrement currentX
  dec currentX
  mov $1, %rax
  jmp .handleMovementAfterCheck