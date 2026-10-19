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

# %rdi - new score to add
addScoreToLeaderboard:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %rbx

    # Load the current scores into registers
    lea scoreArray(%rip), %r12
    movl (%r12), %eax
    movl 4(%r12), %ebx
    movl 8(%r12), %ecx

    # A zero entry is an empty leaderboard slot.
    cmpl $0, %eax
    je .addScoreToLeaderboardAddBest
    cmpl %eax, %edi
    jge .addScoreToLeaderboardCheckSecond

.addScoreToLeaderboardAddBest:
    # New score is the best score
    movl %eax, 4(%r12)   # Move old best to second place
    movl %ebx, 8(%r12)   # Move old second to third place
    movl %edi, (%r12)     # Insert new best score
    jmp .addScoreToLeaderboardExit

.addScoreToLeaderboardCheckSecond:
    cmpl $0, %ebx
    je .addScoreToLeaderboardAddSecond
    cmpl %ebx, %edi
    jge .addScoreToLeaderboardCheckThird

.addScoreToLeaderboardAddSecond:
    # New score is the second best score
    movl %ebx, 8(%r12)   # Move old second to third place
    movl %edi, 4(%r12)     # Insert new second best score
    jmp .addScoreToLeaderboardExit

.addScoreToLeaderboardCheckThird:
    cmpl $0, %ecx
    je .addScoreToLeaderboardAddThird
    cmpl %ecx, %edi
    jge .addScoreToLeaderboardExit

.addScoreToLeaderboardAddThird:
    # New score is the third best score
    movl %edi, 8(%r12)     # Insert new third best score
.addScoreToLeaderboardExit:
    pop %rbx
    pop %r12
    mov %rbp, %rsp
    pop %rbp

    ret