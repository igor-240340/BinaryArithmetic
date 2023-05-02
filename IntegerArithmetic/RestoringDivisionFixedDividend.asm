            ;
            ; Restoring division with fixed dividend.
            ; Divides an unsigned 16-bit number by an unsigned 8-bit number.
            ;
            .include "m328Pdef.inc"

            .def tmp = r16
            .def dividendL = r17
            .def dividendH = r18
            .def divisor = r19
            .def remainder = r17    ; The remainder is generated in the low byte of the dividend.
            .def quotient = r20

            ;
            ; SRAM.
            ;
            .dseg

            ;
            ; Code.
            ;
            .cseg
            .org 0x00

            ;
            ; Interrupts.
            ;
            jmp Reset

            ;
            ; Init.
            ;
Reset:      ldi XL, low(RAMEND)
            ldi XH, high(RAMEND)
            out SPL, XL
            out SPH, XH

            ;
            ; Main program.
            ;
Main:       ldi dividendL, 0xC3     ; 16323
            ldi dividendH, 0x3F

            ldi divisor, 0x53       ; 53

            ;
            ; End loop.
            ;
End:        jmp End

