uppercaseBitmapTable:
    .quad CHARA, CHARB, CHARC, CHARD, CHARE, CHARF, CHARG
    .quad CHARH, CHARI, CHARJ, CHARK, CHARL, CHARM, CHARN
    .quad CHARO, CHARP, CHARQ, CHARR, CHARS, CHART, CHARU
    .quad CHARV, CHARW, CHARX, CHARY, CHARZ

.section .game.text

# %rdi - ASCII character
# %rax - bitmap address, or 0 when the character is not an uppercase letter
getUppercaseBitmap:
    movzbq %dil, %rax
    cmp $65, %rax
    jl .getUppercaseBitmapInvalid
    cmp $90, %rax
    jg .getUppercaseBitmapInvalid

    sub $65, %rax
    mov $uppercaseBitmapTable, %rdx
    mov (%rdx,%rax,8), %rax
    ret

.getUppercaseBitmapInvalid:
    mov $0, %rax
    ret
