.include "m328Pdef.inc"

.def tmp = r16
.def a = r17
.def b = r18
.def byteCounter = r19
.def carry = r20
.def status = r21
.def lastZL = r22
.def lastZH = r23

.equ OPERAND_SIZE = 4
.equ A_ADDRESS = SRAM_START
.equ B_ADDRESS = SRAM_START + OPERAND_SIZE
.equ RES_ADDRESS = SRAM_START + OPERAND_SIZE * 2

.macro	Alloc4ByteOperand                           ; Stores 4-byte operand in SRAM
            ldi XL, low(@0)
            ldi XH, high(@0)

            ldi tmp, low(@1)
            st  X+, tmp
            ldi tmp, byte2(@1)
            st  X+, tmp
            ldi tmp, byte3(@1)
            st  X+, tmp
            ldi tmp, byte4(@1)
            st  X+, tmp
.endmacro

.org 0x00
        
            jmp Reset

Reset:      ldi XL, low(RAMEND)
            ldi XH, high(RAMEND)
            out SPL, XL
            out SPH, XH
            
            ; a>0, b<0, sum<0
            Alloc4ByteOperand A_ADDRESS, 156736975
            Alloc4ByteOperand B_ADDRESS, -512654123

            ; a<0, b<0, sum<0, |sum| < 2^(n-1)
            ;Alloc4ByteOperand A_ADDRESS, -512654123
            ;Alloc4ByteOperand B_ADDRESS, -512654123

            ; a>0, b<0, sum>0
            ;Alloc4ByteOperand A_ADDRESS, 156736975
            ;Alloc4ByteOperand B_ADDRESS, -12654123

            ; a<0, b<0, sum<0, |sum| < 2^(n-1)
            ;Alloc4ByteOperand A_ADDRESS, -156736975
            ;Alloc4ByteOperand B_ADDRESS, -12654123

            ;Alloc4ByteOperand A_ADDRESS, 156736975
            ;Alloc4ByteOperand B_ADDRESS, 12654123

            ; a>0, b>0, |sum| > 2^(n-1)-1
            ;Alloc4ByteOperand A_ADDRESS, 2147483647
            ;Alloc4ByteOperand B_ADDRESS, 156736975

            ldi XL, low(A_ADDRESS)                  ; Pointer to a
            ldi XH, high(A_ADDRESS)
            
            ldi YL, low(B_ADDRESS)                  ; Pointer to b
            ldi YH, high(B_ADDRESS)

            ldi ZL, low(RES_ADDRESS)                ; Pointer to result
            ldi ZH, high(RES_ADDRESS)

            ldi byteCounter, OPERAND_SIZE
            clc

AddBytes:   ld  a, X+
            ld  b, Y+

            adc a, b
            in status, SREG

            st  Z+, a

            dec byteCounter
            brne AddBytes

            sbrc status, SREG_N                     ; Store negative result in sign-magnitude representation
            rcall SignMag

End:        jmp End

SignMag:    ldi ZL, low(RES_ADDRESS)
            ldi ZH, high(RES_ADDRESS)

            ldi byteCounter, OPERAND_SIZE
            ldi carry, 1

NextByte:   ld  tmp, Z
            com tmp
            add tmp, carry
            
            in status, SREG
            sbrs status, SREG_C
            clr carry
            
            mov lastZL, ZL
            mov lastZH, ZH
            st  Z+, tmp

            dec byteCounter
            brne NextByte

            mov ZL, lastZL                          ; Add sign
            mov ZH, lastZH
            ld  a, Z
            ldi tmp, 0b10000000
            add a, tmp
            st  Z, a

            ret

