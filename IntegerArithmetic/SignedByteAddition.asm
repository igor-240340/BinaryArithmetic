.include "m328Pdef.inc"

.def tmp = r16
.def a = r17
.def b = r18

.org 0x00
        
            jmp Reset

Reset:      ldi XL, low(RAMEND)
            ldi XH, high(RAMEND)
            out SPL, XL
            out SPH, XH

Main:       call Case1
            call Case2
            call Case3
            call Case4
            call Case5

Loop:       jmp Loop

Case1:      ldi a, 127                  ; a>0, b<0, sum<0
            ldi b, -128

            add a, b
            neg a                       ; abs(sum)
            ret

Case2:      ldi a, 127                  ; a>0, b<0, sum>0
            ldi b, -68

            add a, b
            ret

Case3:      ldi a, -15                  ; a<0, b<0, sum<0
            ldi b, -96

            add a, b
            neg a
            ret

Case4:      ldi a, -128                  ; a<0, b<0, sum<0, |sum| > 2^(n-1)
            ldi b, -128

            add a, b
            ret

Case5:      ldi a, 127                  ; a>0, b>0, sum>0, |sum| > 2^(n-1)-1
            ldi b, 1

            add a, b
            ret

