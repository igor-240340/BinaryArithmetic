            ;
            ; Unsigned restoring division with fixed divisor.
            ; Divides an unsigned 16-bit number by an unsigned 8-bit number.
            ;
            .include "m328Pdef.inc"

            .def tmp = r16

            .def dividendL = r17
            .def dividendH = r18

            .def posDivisor = r19       ; The positive value of the divisor.
            .def negDivisor = r20       ; The negative value of the divisor.
            .def bitsLeft = r21         ; How many bits of quotient left to determine.
            .def status = r22

            ;
            ; Aliases.            
            ;
            .def remainder = r18        ; The remainder is generated in the MSB of the dividend.
            .def quotient = r17         ; The quotient is generated in the LSB of the dividend.
            .def smallRem = r17         ; Remainder from the division of partial remainder by 2^(n-i). Is generates in the LSB of the dividend.

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
            
            ldi posDivisor, 0x53        ; 83.

            ;
            ; Checks if division is possible.
            ;
            mov negDivisor, posDivisor  ; -Y.
            com negDivisor
            ldi tmp, 0x01
            add negDivisor, tmp
            clr tmp
            
            add dividendH, negDivisor  ; R'' = INT(X/2^n) - Y.
            brbc SREG_N, DivError      ; Quotient overflow or zero divisor?

            ;
            ; Determines the next quotient digit.
            ;
            ldi bitsLeft, 8
NextQDigit: sbrc dividendH, 7           ; Last remainder is negative?
            rcall RestoreRem            ; Yes, restore.

            clc                         ; 2R'' + INT(2r/[2^-(n-[i-1])]).
            rol smallRem                ; Now contains the new value of r shifted to the left so it's already prepared for the next step.
            rol dividendH

            add dividendH, negDivisor   ; Subtract Y.

            ldi tmp, 0b00000001         ; The remainder is negative?
            sbrs dividendH, 7           ; Yes, set 0 as the next quotient digit.
            or quotient, tmp            ; No, set 1.

            dec bitsLeft                ; All bits of the quotient are determined?
            brbc SREG_Z, NextQDigit     ; No, continue.
                                        ; Yes.
            sbrc dividendH, 7           ; The remainder is negative?
            rcall RestoreRem            ; Yes, restore.
            jmp End                     ; No, we have finished division procedure.

            ;
            ; Restores the remainder to the last positive value.
            ; R'' + Y.
            ;
RestoreRem: add dividendH, posDivisor
            ret

DivError:   nop
   
            ;
            ; End loop.
            ;
End:        jmp End
