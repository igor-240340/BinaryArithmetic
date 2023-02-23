;
; Multiplies two positive 8-bit operands.
; Stores the result in 16-bit.
;
            .include "m328Pdef.inc"

            .def tmp = r16
            .def a = r17
            .def res = r18
            .def cnt = r19
            .def multiplier = r20

            .equ A_ADDR = SRAM_START
            .equ RES_ADDR = SRAM_START + 2

            .org 0x00

;
; Interrupts.
;
            jmp Reset

;
; Initialization.
;
Reset:      ldi XL, low(RAMEND)
            ldi XH, high(RAMEND)
            out SPL, XL
            out SPH, XH

;
; Main program
;
Main:       ldi cnt, 8              ; Eight bits of multiplier b.
            
            ldi XL, low(A_ADDR)     ; Store a in SRAM.
            ldi XH, high(A_ADDR)
            ldi tmp, 134
            st X+, tmp
            ldi tmp, 0
            st X, tmp

            ldi YL, low(RES_ADDR)   ; Clear res.
            ldi YH, high(RES_ADDR)
            st Y+, tmp
            st Y, tmp

            ldi multiplier, 13

NextBit:    and cnt, cnt            ; All bits of multiplier has been handled?
            breq End                ; Yes.

            ror multiplier          ; Bit is set?
            brcc PartProd           ; No.
            rcall Add2              ; Yes, calculate res = res + a, where a - partial product.

PartProd:   ldi XL, low(A_ADDR)     ; Point to a.
            ldi XH, high(A_ADDR)

            ld  a, X                ; a = a * 2.
            clc
            rol a
            st  X+, a

            ld  a, X
            rol a
            st  X, a

            dec cnt                 ; Bit has been handled.
            rjmp NextBit

;
; Adds two bytes.
;
Add2:       ldi XL, low(A_ADDR)     ; Point to a.
            ldi XH, high(A_ADDR)

            ldi YL, low(RES_ADDR)   ; Point to res.
            ldi YH, high(RES_ADDR)

            ldi tmp, 2              ; Two bytes.
            clc

NextByte:   ld  a, X+
            ld  res, Y

            adc res, a
            st  Y+, res

            dec tmp                 ; All bytes has been added?
            brne NextByte           ; No.

            ret

;
; End loop.
;
End:       jmp End
