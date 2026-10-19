.section .game.data
# Top 3 times - each time is 4 bytes, so 12 bytes total
scoreArray: .skip 12

initScoreArray:
    push %rbp
    mov %rsp, %rbp

    push $0
    push %r12

    # Initialize the score array with zeros
    lea scoreArray(%rip), %r12 
    movl $0, (%r12)
    movl $0, 4(%r12)
    movl $0, 8(%r12)

    pop %r12
    pop %rdi

    mov %rbp, %rsp
    pop %rbp

    ret