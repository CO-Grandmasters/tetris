.section .game.data
linesString: .asciz "LINES"
timeString: .asciz "TIME"
secondsString: .asciz "S"
naString: .asciz "N/A"
bestTimesString: .asciz "BEST TIMES"
youWinString: .asciz "YOU WIN"
youLoseString: .asciz "YOU LOSE"
playAgainString: .asciz "PRESS R TO PLAY AGAIN"

.section .game.text

drawUI:
    push %rbp
    mov %rsp, %rbp

    call drawLinesBundle
    call drawTimeBundle
    call drawTop3Times

    mov %rbp, %rsp
    pop %rbp
    ret

drawLinesBundle:
    push %rbp
    mov %rsp, %rbp

    mov $linesString, %rdi
    mov $70, %rsi
    mov $130, %rdx
    call drawString

    mov completedLines(%rip), %rdi
    mov $70, %rsi
    mov $145, %rdx
    call drawDecimal

    mov $47, %rdi
    push %rax
    mov %rax, %rsi
    mov $145, %rdx
    call drawChar

    pop %rsi
    mov maxLines(%rip), %rdi
    add $5, %rsi
    mov $145, %rdx
    call drawDecimal

    mov %rbp, %rsp
    pop %rbp
    ret

drawTimeBundle:
    push %rbp
    mov %rsp, %rbp

    mov $timeString, %rdi
    mov $70, %rsi
    mov $165, %rdx
    call drawString

    mov timeInSeconds(%rip), %rdi
    mov $70, %rsi
    mov $180, %rdx
    call drawDecimal

    mov $secondsString, %rdi
    mov %rax, %rsi
    mov $180, %rdx
    call drawString

    mov %rbp, %rsp
    pop %rbp
    ret

# Draw the three recorded leaderboard times.
drawTop3Times:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    push %r14
    push %r15

    # draw Best Times at  x=10, y=130
    mov $scoreArray, %r12
    mov $bestTimesString, %rdi
    mov $10, %rsi
    mov $130, %rdx
    call drawString

    # Init x=10, y=145, and loop counter
    mov $10, %r13
    mov $145, %r15
    mov $0, %r14

.drawTop3TimesLoop:
    cmp $3, %r14
    jge .drawTop3TimesExit

    # is scoreArray[%r14 * 4]  a valid score
    movl (%r12,%r14,4), %edi
    cmpl $0, %edi
    je .drawTop3TimesNA

    # Draw the score at x=10, y=145 + 15 * %r14
    mov %r13, %rsi
    mov %r15, %rdx
    call drawDecimal

    # Draw the seconds string at x=10 + width of the score, y=145 + 15 * %r14
    mov $secondsString, %rdi
    mov %rax, %rsi
    mov %r15, %rdx
    call drawString
    jmp .drawTop3TimesNext

.drawTop3TimesNA:
    # Draw "N/A" at x=10, y=145 + 15 * %r14
    mov %r13, %rdi
    mov %r15, %rsi
    call drawNA

.drawTop3TimesNext:
    # Increment loop counter and y position for next score
    inc %r14
    add $15, %r15
    jmp .drawTop3TimesLoop

.drawTop3TimesExit:
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    mov %rbp, %rsp
    pop %rbp
    ret

# %rdi - x
# %rsi - y
drawNA:
    push %rbp
    mov %rsp, %rbp

    mov %rsi, %rdx
    mov %rdi, %rsi
    mov $naString, %rdi
    call drawString

    mov %rbp, %rsp
    pop %rbp
    ret

drawYouWin:
    push %rbp
    mov %rsp, %rbp

    call drawGameOverBackground

    mov $youWinString, %rdi
    mov $143, %rsi
    mov $90, %rdx
    call drawString

    mov $playAgainString, %rdi
    mov $108, %rsi
    mov $105, %rdx
    call drawString

    mov %rbp, %rsp
    pop %rbp
    ret

drawYouLose:
    push %rbp
    mov %rsp, %rbp

    call drawGameOverBackground

    mov $youLoseString, %rdi
    mov $140, %rsi
    mov $90, %rdx
    call drawString

    mov $playAgainString, %rdi
    mov $108, %rsi
    mov $105, %rdx
    call drawString

    mov %rbp, %rsp
    pop %rbp
    ret

drawGameOverBackground:
    push %rbp
    mov %rsp, %rbp
    # Start drawing the background at y=85
    movq $85, -8(%rbp)
    sub $16, %rsp

.drawGameOverBackgroundLoop:
    # Draw one horizontal line from x=95 to x=225
    mov -8(%rbp), %rsi
    mov $95, %rdi
    mov $225, %rdx
    mov %rsi, %rcx
    mov $0, %r8
    call putLine

    # Move to the next line
    incq -8(%rbp)
    
    # Stop after drawing through y=115
    cmpq $116, -8(%rbp)
    jl .drawGameOverBackgroundLoop

    mov %rbp, %rsp
    pop %rbp
    ret

# %rdi - ASCII character
# %rsi - x
# %rdx - y
drawChar:
    push %rbp
    mov %rsp, %rbp
    mov %rsi, -8(%rbp) # x
    mov %rdx, -16(%rbp) # y
    sub $16, %rsp

    # Move char to %rax for comparison
    movzbq %dil, %rax

    # If char is a number (0-9), call getNumberBitmap
    cmp $48, %rax
    jl .drawCharCheckLetter
    cmp $57, %rax
    jg .drawCharCheckLetter

    call getNumberBitmap
    jmp .drawCharPutBitmap

.drawCharCheckLetter:
    # If char is an uppercase letter (A-Z), call getUppercaseBitmap
    cmp $65, %rax
    jl .drawCharCheckSeparator
    cmp $90, %rax
    jg .drawCharCheckSeparator

    call getUppercaseBitmap
    jmp .drawCharPutBitmap

.drawCharCheckSeparator:
    # If char is a slash or a colon, draw it
    cmp $47, %rax
    je .drawCharSlash
    cmp $58, %rax
    je .drawCharColon
    jmp .drawCharExit

.drawCharSlash:
    mov $CHARSLASH, %rax
    jmp .drawCharPutBitmap

.drawCharColon:
    mov $CHARCOLON, %rax

.drawCharPutBitmap:
    test %rax, %rax
    jz .drawCharExit

    # Draw the bitmap at x and y
    mov %rax, %rdi
    mov -8(%rbp), %rsi
    mov -16(%rbp), %rdx
    putBitmap %rdi, %rsi, %rdx

.drawCharExit:
    mov %rbp, %rsp
    pop %rbp
    ret

# %rdi - string
# %rsi - x
# %rdx - y
drawString:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    push %r14

    mov %rdi, %r12 # string
    mov %rsi, %r13 # x
    mov %rdx, %r14 # y

.drawStringLoop:
    # Save current character and check if it's null terminator
    movzbq (%r12), %rax
    test %rax, %rax
    jz .drawStringExit

    # Draw the character at x and y
    mov %rax, %rdi
    mov %r13, %rsi
    mov %r14, %rdx
    call drawChar

    # Go to the next character in the string and increment x position by 5
    inc %r12
    add $5, %r13
    jmp .drawStringLoop

.drawStringExit:
    pop %r14
    pop %r13
    pop %r12
    pop %rbp
    ret

# %rdi - unsigned value
# %rsi - x
# %rdx - y
# %rax - x position after the last digit
drawDecimal:
    push %rbp
    mov %rsp, %rbp

    push %r12
    push %r13
    push %r14
    push %r15

    mov %rdi, %r12 # %r12 - value to draw
    mov %rsi, %r13 # %r13 - x
    mov %rdx, %r14 # %r14 - y
    mov $0, %r15 # %r15 - number of digits
    mov $10, %r8 # %r8 - divisor for decimal conversion

# Store all digits in reverse order on the stack, then pop them off to draw in correct order
.drawDecimalConvertLoop:
    # Divide %r12 by 10
    mov %r12, %rax

    # Prepare %rdx for division
    xor %rdx, %rdx
    divq %r8

    # Get ASCII character for the digit and push it onto the stack
    add $48, %rdx
    push %rdx

    # Increment digit counter
    inc %r15

    # Update %r12 with the quotient for the next iteration
    mov %rax, %r12
    cmp $0, %rax
    je .drawDecimalDraw
    jmp .drawDecimalConvertLoop

# Draw the digits in correct order
.drawDecimalDraw:
    # Until digit counter = 0 loop
    cmp $0, %r15
    je .drawDecimalExit

    # Pop the top digit from the stack and draw it
    pop %rdi
    mov %r13, %rsi
    mov %r14, %rdx
    call drawChar
    
    # Increment x position by 5 for the next digit
    add $5, %r13
    dec %r15
    jmp .drawDecimalDraw

.drawDecimalExit:
    mov %r13, %rax
    pop %r15
    pop %r14
    pop %r13
    pop %r12

    mov %rbp, %rsp
    pop %rbp
    ret
