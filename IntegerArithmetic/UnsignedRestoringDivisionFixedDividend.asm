            ;
            ; Unsigned restoring division with fixed dividend.
            ; Divides an unsigned 16-bit number by an unsigned 8-bit number.
            ;
            .include "m328Pdef.inc"

            .def tmp = r16
            .def dividendL = r17
            .def dividendH = r18
            .def divisorL = r19
            .def divisorH = r20
            .def quotient = r21
            .def remainder = r17        ; The remainder is generated in the low byte of the dividend.
            .def bitsCount = r22        ; Quotient bits count to determine.
            .def tmpL = r23
            .def tmpH = r24
            .def status = r25

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
Main:       ldi dividendL, 0xC3         ; 16323.
            ldi dividendH, 0x3F
            ldi divisorL, 0x00          ; 83 * 2^n.
            ldi divisorH, 0x53

            ; Division by zero.
            ;ldi dividendL, 0xC3         ; 16323.
            ;ldi dividendH, 0x3F
            ;ldi divisorL, 0x00
            ;ldi divisorH, 0x00

            ; Quotient overflow.
            ;ldi dividendL, 0xC3         ; 16323.
            ;ldi dividendH, 0x3F
            ;ldi divisorL, 0x00          ; 10 * 2^n.
            ;ldi divisorH, 0x0A

            ;
            ; Checks if division is possible.
            ;
            com divisorL                ; Two's complement of the shifted divisor.
            com divisorH
            ldi tmp, 0x01
            add divisorL, tmp
            clr tmp
            adc divisorH, tmp

            add dividendL, divisorL     ; X - Y*2^n.
            adc dividendH, divisorH

            brbc SREG_N, DivError       ; Quotient overflow or zero divisor?

            ;
            ; Determines next quotient digit.
            ;
            ldi bitsCount, 8
NextQDigit: sbrc dividendH, 7           ; Last remainder is negative?
            rcall RestoreRem            ; Yes, restore.

            asr divisorH                ; Y*2^(n-i). Multiply divisor by guessed partial quotient.
            ror divisorL

            add dividendL, divisorL     ; No, subtract shifted divisor.
            adc dividendH, divisorH

            sec                         ; Remainder is positive?
            brbc SREG_N, SetDigit       ; Yes, set 1.
            clc                         ; No, set 0.
SetDigit:   rol quotient

            dec bitsCount               ; All bits of quotient determined?
            brbc SREG_Z, NextQDigit     ; No, determine next bit.
                                        ; Yes.
            sbrc dividendH, 7           ; Last remainder is negative?
            rcall RestoreRem            ; Yes, restore.
            jmp End                     ; No, we have finished division procedure.

            ;
            ; Restores last positive remainder.
            ;
RestoreRem: mov tmpL, divisorL          ; Copy current divisor.
            mov tmpH, divisorH

            com tmpL                    ; Restore positive divisor from Two's complement.
            com tmpH
            ldi tmp, 0x01
            add tmpL, tmp
            clr tmp
            adc tmpH, tmp

            add dividendL, tmpL
            adc dividendH, tmpH

            ret

DivError:   nop
   
            ;
            ; End loop.
            ;
End:        jmp End
