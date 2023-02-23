.include "m328Pdef.inc"

.def tmp = r16
.def a = r17
.def b = r18

; 16-bit result
.def sumL = r19
.def sumH = r20

.org 0x00
        
            jmp Reset

Reset:      ldi tmp, low(RAMEND)        ; Stack Pointer
            out SPL, tmp
            ldi tmp, high(RAMEND)
            out SPH, tmp

Main:       call Clear
            call Add8bit

            call Clear
            call Add8bitOvf

Loop:       jmp Loop

Clear:      clc                         ; Clear carry
            clr sumH     
            ret       

Add8bit:    ldi a, 37
            ldi b, 15
            add a, b
            mov sumL, a
            adc sumH, sumH              ; Handle overflow
            ret

Add8bitOvf: ldi a, 255
            ldi b, 1
            add a, b
            mov sumL, a
            adc sumH, sumH
            ret

