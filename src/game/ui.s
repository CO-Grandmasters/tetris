.section .game.data
myTestString: .asciz "MAZNA"
totalTime: .quad 0
totalLines: .quad 0
maxLines: .quad 40

drawUI:
    push %rbp
    mov %rsp, %rbp

    mov $myTestString, %rdi
    mov $0, %rsi
    mov $0, %rdx
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
    push %rsi
    push %rdx
    push %rdi

    movzbq %dil, %rax

.drawCharCheckLetter:
    call getUppercaseBitmap
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
