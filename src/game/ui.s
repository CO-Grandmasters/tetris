.section .game.data
linesString: .asciz "LINES"
timeString: .asciz "TIME"
secondsString: .asciz "S"

.section .game.text

drawUI:
    push %rbp
    mov %rsp, %rbp

    mov $linesString, %rdi
    mov $40, %rsi
    mov $70, %rdx
    call drawString

    mov completedLines(%rip), %rdi
    mov $40, %rsi
    mov $85, %rdx
    call drawDecimal

    mov $47, %rdi
    push %rax
    mov %rax, %rsi
    mov $85, %rdx
    call drawChar

    pop %rsi
    mov maxLines(%rip), %rdi
    add $5, %rsi
    mov $85, %rdx
    call drawDecimal

    mov $timeString, %rdi
    mov $40, %rsi
    mov $105, %rdx
    call drawString

    mov timeInSeconds(%rip), %rdi
    mov $40, %rsi
    mov $120, %rdx
    call drawDecimal

    mov $secondsString, %rdi
    mov %rax, %rsi
    mov $120, %rdx
    call drawString

    mov %rbp, %rsp
    pop %rbp
    ret

# %rdi - ASCII character
# %rsi - x
# %rdx - y
drawChar:
    push %rbp
    mov %rsp, %rbp
    mov %rsi, -8(%rbp)
    mov %rdx, -16(%rbp)
    sub $16, %rsp

    movzbq %dil, %rax

    cmp $48, %rax
    jl .drawCharCheckLetter
    cmp $57, %rax
    jg .drawCharCheckLetter

    call getNumberBitmap
    jmp .drawCharPutBitmap

.drawCharCheckLetter:
    cmp $65, %rax
    jl .drawCharCheckSeparator
    cmp $90, %rax
    jg .drawCharCheckSeparator

    call getUppercaseBitmap
    jmp .drawCharPutBitmap

.drawCharCheckSeparator:
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

    mov %rdi, %r12
    mov %rsi, %r13
    mov %rdx, %r14

.drawStringLoop:
    movzbq (%r12), %rax
    test %rax, %rax
    jz .drawStringExit

    mov %rax, %rdi
    mov %r13, %rsi
    mov %r14, %rdx
    call drawChar

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
    mov %r12, %rax
    xor %rdx, %rdx
    divq %r8
    add $48, %rdx
    push %rdx
    inc %r15
    mov %rax, %r12
    cmp $0, %rax
    je .drawDecimalDraw
    jmp .drawDecimalConvertLoop

# Draw the digits in correct order
.drawDecimalDraw:
    cmp $0, %r15
    je .drawDecimalExit

    pop %rdi
    mov %r13, %rsi
    mov %r14, %rdx
    call drawChar

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
