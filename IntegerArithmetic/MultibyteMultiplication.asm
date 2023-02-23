            ;
            ; Multibyte multiplication.
            ; This subroutine performs both signed and unsigned multiplication.
            ;
            .include "m328Pdef.inc"

            .def tmp = r16
            .def byteCnt = r17
            .def bitCnt = r18
            .def a = r19            ; Stores current byte of A.
            .def r = r20            ; Stores current byte of R.
            .def status = r21       ; Stores status register.

            .equ SIZE = 2           ; Operand size in bytes.

            ;
            ; SRAM.
            ;
            .dseg
A_ADDR:     .byte SIZE * 2          ; Reserve memory for A.
B_ADDR:     .byte SIZE * 2          ; Reserve memory for B.
R_ADDR:     .byte SIZE * 2          ; Reserve memory for the result.

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
Main:       ldi XL, low(A_ADDR)     ; Pointer to A value.
            ldi XH, high(A_ADDR)
            
            ldi tmp, 0x00           ; A = -32768. Little-endian. Two's complement.
            st X+, tmp
            ldi tmp, 0x80
            st X+, tmp
            ldi tmp, 0xff
            st X+, tmp
            ldi tmp, 0xff
            st X, tmp

            ldi XL, low(B_ADDR)     ; Pointer to B value.
            ldi XH, high(B_ADDR)

            ldi tmp, 0x00           ; B = -1. Big-endian. Two's complement.
            st X+, tmp
            ldi tmp, 0x00
            st X+, tmp
            ldi tmp, 0xff
            st X+, tmp
            ldi tmp, 0xff
            st X, tmp

            ldi XL, low(R_ADDR)     ; Pointer to R value.
            ldi XH, high(R_ADDR)

            clr tmp                 ; R = 0.
            st X+, tmp
            st X+, tmp
            st X+, tmp
            st X, tmp

            ldi bitCnt, SIZE * 2 * 8  ; Total bits of B.

            ;
            ; Extracts the next bit of B.
            ;
NextBit:    ldi byteCnt, SIZE * 2   ; Total bytes of B.

            ldi XL, low(B_ADDR)     ; Jump onto the highest byte of B (is stored in big-endian).
            ldi XH, high(B_ADDR)
            
            clc                     ; Clear carry for the first byte: does not really matter, just to avoid garbage values.
Shift1:     ld tmp, X               ; Read byte.
            ror tmp                 ; Shift byte.
            st X+, tmp              ; Write byte.
            
            dec byteCnt             ; The last byte?
            breq Sum                ; Yes.
            rjmp Shift1             ; No.

            ;
            ; Accumulates partial products of A.
            ;
Sum:        in tmp, SREG            ; Current bit of B is zero?
            sbrc tmp, SREG_C        ; Yes, skip adding.
            rcall AddAToR           ; No, add current partial product to the result.
            dec bitCnt              ; Finished with B?
            breq End                ; Yes, multiplication is done.

            ;
            ; Calculates the next partial product of A.
            ;
PartProd:   ldi byteCnt, SIZE * 2   ; Total bytes of A.

            ldi XL, low(A_ADDR)     ; Jump onto the lowest byte of A.
            ldi XH, high(A_ADDR)

            clc                     ; Clear carry for the first byte.
Shift2:     ld tmp, X               ; Read byte.
            rol tmp                 ; Shift byte.
            st X+, tmp              ; Write byte.

            dec byteCnt             ; Finished with A?
            breq NextBit            ; Yes, get the next bit of B.
            rjmp Shift2             ; No, shift the next byte of A.

            ;
            ; R = R + A, where A - partial product.
            ; Overflow is impossible (see math proof for multiplication).
            ;
AddAToR:    ldi byteCnt, SIZE * 2   ; Total bytes to be handled.

            ldi XL, low(A_ADDR)     ; Jump onto the lowest byte of A.
            ldi XH, high(A_ADDR)

            ldi YL, low(R_ADDR)     ; Jump onto the lowest byte of R.
            ldi YH, high(R_ADDR)

            clc                     ; Clear carry for the first bytes.
AddBytes:   ld a, X+                ; Read current byte of A and jump on the next byte.
            ld r, Y                 ; Read current byte of R.
            adc r, a                ; Add with carry.
            in status, SREG         ; Preserve status after handling the last byte.
            st Y+, r                ; Update current byte of R and jump on the next byte.

            dec byteCnt             ; All bytes has been added?
            brne AddBytes           ; No, add the next pair of bytes.
            ret                     ; Yes.

            ;
            ; End loop.
            ;
End:        jmp End

