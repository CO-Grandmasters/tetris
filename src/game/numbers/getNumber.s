.section .game.data
numberBitmapTable:
    .quad NUMBER0, NUMBER1, NUMBER2, NUMBER3, NUMBER4
    .quad NUMBER5, NUMBER6, NUMBER7, NUMBER8, NUMBER9

.section .game.text

# %rdi - ASCII number
# %rax - bitmap address, or 0 when the character is not a number
getNumberBitmap:
    movzbq %dil, %rax
    cmp $48, %rax
    jl .getNumberBitmapInvalid
    cmp $57, %rax
    jg .getNumberBitmapInvalid

    sub $48, %rax
    mov $numberBitmapTable, %rdx
    mov (%rdx,%rax,8), %rax
    ret

.getNumberBitmapInvalid:
    mov $0, %rax
    ret
