# No idea how the C code works btw, some Xorshift64 algorithm
# Pseudo C code for the random number generator:
# uint64_t seed = 88172645463325252ULL;
# seed ^= seed << 13;
# seed ^= seed >> 7;
# seed ^= seed << 17;
# uint64_t constrained_result = (seed % 7) + 1
# return constrained_result;

.section .game.data
seed: .quad 88172645463325252

.section .game.text
randomizeSeed:
    push %rbp
    movq %rsp, %rbp

    # ask the CPU how many ticks it did since it woke up.
    # it puts half the number in eax and the other half in edx.
    rdtsc               

    # make room for the upper half of the ticks in %rdx
    shlq $32, %rdx
    # Combine %rdx and %rax into %rax
    orq %rdx, %rax      
    
    cmp $0, %rax
    je .randomizeSeedExit         

    movq %rax, seed(%rip)
.randomizeSeedExit:
    movq %rbp, %rsp
    pop %rbp
    ret

# Returns a random number between 1 and 7 (inclusive)
getRandomNumberBetween1And7:
    push %rbp
    movq %rsp, %rbp

    movq seed(%rip), %rax

    movq %rax, %rcx
    shlq $13, %rcx
    xorq %rcx, %rax

    movq %rax, %rcx
    shrq $7, %rcx
    xorq %rcx, %rax

    movq %rax, %rcx
    shlq $17, %rcx
    xorq %rcx, %rax

    movq %rax, seed(%rip)
    xorq %rdx, %rdx       

    # Set divisor to 7
    # %rax = quotient (not used), %rdx = remainder (0 to 6)
    movq $7, %rcx         
    divq %rcx         

    incq %rdx             
    # %rdx now contains a value from 1 to 7
    movq %rdx, %rax       

    movq %rbp, %rsp
    pop %rbp
    ret