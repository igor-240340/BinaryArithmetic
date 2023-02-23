.include "m328Pdef.inc"

.def tmp = r16
.def a = r17
.def b = r18
.def bytesLeft = r19

.equ OPERAND_SIZE = 5
.equ A_ADDRESS = SRAM_START
.equ B_ADDRESS = SRAM_START + OPERAND_SIZE
.equ RES_ADDRESS = SRAM_START + OPERAND_SIZE * 2

.org 0x00
        
            jmp Reset

Reset:      ldi tmp, low(RAMEND)                    ; Init Stack Pointer
            out SPL, tmp
            ldi tmp, high(RAMEND)
            out SPH, tmp

Init:       ldi XL, low(SRAM_START)
            ldi XH, high(SRAM_START)

            ldi tmp, 0x52                           ; a = 127324145234
            st  X+, tmp
            ldi tmp, 0x46
            st  X+, tmp
            ldi tmp, 0x1C
            st  X+, tmp
            ldi tmp, 0xA5
            st  X+, tmp
            ldi tmp, 0x1D
            st  X+, tmp

            ldi tmp, 0xEF                           ; b = 317236978415
            st  X+, tmp
            ldi tmp, 0x22
            st  X+, tmp
            ldi tmp, 0xCC
            st  X+, tmp
            ldi tmp, 0xDC
            st  X+, tmp
            ldi tmp, 0x49
            st  X+, tmp

            ldi bytesLeft, OPERAND_SIZE

            clc

Select:     ldi XL, low(A_ADDRESS)                  ; Pointer to a
            ldi XH, high(A_ADDRESS)
            
            ldi YL, low(B_ADDRESS)                  ; Pointer to b
            ldi YH, high(B_ADDRESS)

            ldi ZL, low(RES_ADDRESS)                ; Pointer to result
            ldi ZH, high(RES_ADDRESS)

AddBytes:   ld  a, X+
            ld  b, Y+

            adc a, b

            st  Z+, a

            dec bytesLeft
            brne AddBytes
            
            ldi tmp, 0
            adc tmp, tmp
            st  Z+, tmp

Loop:       jmp Loop
