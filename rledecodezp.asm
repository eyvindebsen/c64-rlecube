;Zero page code for fast RLE decode
;NOTE: This code needs to be compiled first, since its loaded into the
;main program "1byterleasm"
;This output of this file should be named "myzeropageasm3.prg"

;v2, with fincescroll offset, color change
;weird thing; raster check jumps, after some time
; only visible with raster measure on.
; turning raster measure off, yields 12 cycles
; should be able to look up colors in a table, nope. but time for a EOR

*=$0003
        ;here goes main loop
rlemainloop

        
datap   lax $1ac2               ;read a byte to A and X; 
                                ;lda is ok, but saves 2 cycles per decode byte on the later tax
                                ;now time enough for some more effects... maybe
        beq aframeisdone        ;a zero means frame done, for speed

        ;tax                    ;else there are data to decode
                                ;this tax is now obsolete, since i load both A and X with LAX

        ldy $ce00,x             ;look up the repeat length from table
                                ;instead of doing 4 lsr's --saves 4 cycles
        
        ;change color
;coladd  lda $cda3,x             ;try a table... spends 2 cycles too much
        ;clc
coladd  eor #0                  ;manipulate colors --- no time :( --- or?
                                ;just time for a 2 cycle trick...which is saved using lax :)

dorunleny                       ;now decode the length of Y, plot A                   
        sty tcal+1              ;store the amount to add, in code ahead
domore  dey                     ;drawing in reverse, not visible, fast
ramc    sta $d800,y             ;draw the repeat
        bne domore

        clc                     ;calc the next color ram address
        lda ramc+1
tcal    adc #$b0                ;here is what to add, ahead
        sta ramc+1              ;update low color byte pointer
        bcc rlebytedone         ;skip updating high color byte
        inc ramc+2              ;update high color byte pointer

rlebytedone
        
        inc datap+1             ;count up data pointer
        bne rlemainloop         ;this line made it fast enough...
        inc datap+2             ;update high byte data pointer
rleahead

        bne rlemainloop         ;keep decoding ; was jmp

aframeisdone
        inc datap+1             ;count up data pointer to skip the 0
                                ;seperating frames
        bne framedonskip
        inc datap+2

framedonskip
        ;wait a rotation before moving
        inc $02
        beq tcnt
        
        lda #$00
        sta ramc+1
        lda #$d8
        sta ramc+2
        bne countframe
        ;reset color ram pointer - now with finescroll offset
tcnt    ldx #$00
        lda $0c00,x             
        sta ramc+1              ;set colorram offset
        lda $0d00,x
        sta ramc+2
        lda $0e00,x             ;set finescroll
        sta $d016
        lda $0f00,x
        sta $d001               ;set sprite Y pos
        dec $02                 ;dirty hack to stay in 2nd loop - skip the wait
countframe
        inc tcnt+1
        
        ;inc $02                 ;update framecounter
        bne moreframes

        inc waitbyte            ;wait some time before ugly color changes
        bne skipcolchange
        ;change color adder
        dec coladd+1            ;changes the EOR value above

        dec $d020               ;change border color
        lda $d020
        eor coladd+1            ;EOR color so its not the background
        sta $d027               ;set sprite color
        lda #$fd
        sta waitbyte            ;reset wait byte
skipcolchange
        ;reset data pointer
        lda #$c2
        sta datap+1
        lda #$1a
        sta datap+2             ;reset data pointer

        ;more cycles are available at this point
        ;since wrap around the animation has less
        ;complex frames to decode

        ;sprites
        inc $07f8               ;inc sprite pointer
        lda $07f8
        cmp #48                 ;we reached 8 sprites?
        bne moreframes
        lda #39
        sta $07f8               ;reset sprite pointer

moreframes

        ;dec $d020               ;measure raster time end
        lda #32                 ;if checking at $fa, glitches will happen... ?
              
rastw  
        cmp $d012
        bne rastw               ;wait raster
        ;inc $d020               ;measure raster time start
        jsr $1003               ;play music
        
        jmp rlemainloop         ;was bvc: hope for no overflow
                                ;this routine is below 127 bytes, so can
                                ;use a speedier branch
waitbyte byte $f6