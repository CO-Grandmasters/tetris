#ifndef MACROS_H
#define MACROS_H

/*
 * void setTimer(int16 reloadValue)
 * Arg 1: %rdi (16-bit passed in 64-bit register)
 */
.macro setTimer reloadValue
    movq    \reloadValue, %rdi
    call    setTimer
.endm

/*
 * int8 readKeyCode()
 * Return: %al (8-bit value returned in %rax)
 */
.macro readKeyCode
    call    readKeyCode
.endm

/*
 * void setPallette(int8 colorNr, int32 color)
 * Arg 1: %rdi (int8 colorNr)
 * Arg 2: %rsi (int32 color)
 */
.macro setPallette colorNr, color
    movq    \colorNr, %rdi
    movq    \color, %rsi
    call    setPallette
.endm

/*
 * void clrScreen(int32 color)
 * Arg 1: %rdi (int32 color)
 */
.macro clrScreen color
    movq    \color, %rdi
    call    clrScreen
.endm

/*
 * void putDot(int8 x, int8 y, int32 color)
 * Arg 1: %rdi (int8 x)
 * Arg 2: %rsi (int8 y)
 * Arg 3: %rdx (int32 color)
 */
.macro putDot x, y, color
    movq    \x, %rdi
    movq    \y, %rsi
    movq    \color, %rdx
    call    putDot
.endm

/*
 * void putLine(int8 x0, int8 y0, int8 x1, int8 y1, int32 color)
 * Arg 1: %rdi (int8 x0)
 * Arg 2: %rsi (int8 y0)
 * Arg 3: %rdx (int8 x1)
 * Arg 4: %rcx (int8 y1)
 * Arg 5: %r8  (int32 color)
 */
.macro putLine x0, y0, x1, y1, col
    movq    \x0, %rdi
    movq    \y0, %rsi
    movq    \x1, %rdx
    movq    \y1, %rcx
    movq    \col, %r8
    call    putLine
.endm

/*
 * void putBitmap(int64* addr, int8 x, int8 y)
 * Arg 1: %rdi (int64* addr pointer)
 * Arg 2: %rsi (int8 x)
 * Arg 3: %rdx (int8 y)
 */
.macro putBitmap addr, x, y
    movq    \addr, %rdi
    movq    \x, %rsi
    movq    \y, %rdx
    call    putBitmap
.endm

#endif
