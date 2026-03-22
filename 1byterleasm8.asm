;decode RLE v0.88
;Suggestion from FB
;https://www.facebook.com/groups/1622769802100240/permalink/1622835148760372/

;instead of 4 times lsr you can write lda table,x (after tax) and generate a table before with:
;lda#$00
;tax
;loop
;lsr
;lsr
;lsr
;lsr
;sta table,x
;inx
;bne loop
;need more ram, but you save 4 cycles

;works very fine, with just a few cycles to spare
;moved code to zeropage $3, and got yet a speedboost
;music is possible now; using a fast and small sid ("Lille_svin" by Jeff)
;now time to look up tables, and store some offsets
;so the cube moves in X axis
;will try to display a sprite...
;4 sprites in action now, floating in and out, like signs, using another table

;there are weird glitches when waiting for raster at $fa
;moved to #32 fixed it.

;one more trick is to have different color tables, stored somwhere
; -- no time, need to change color every byte to decode... using LAX in main loop
;now allows for a 2 cycle color change

;cleared room for 4 more sprites, need to move tables, if used
;tables moved

;Basic Stub: sys 2061
*=$0801                                 ;2026 sys2061
        byte $0b,$08,$ea,$07            ;line number (year)
        byte $9e, "2","0","6","1",0,0,0 ;sys 2061


*=$080D                         ;this is address 2061 (not rly needed)

              
        ;clear screen dramatic effect
        lda #25
        sta $02
        sta $03
        sta $04

clsloop
        jsr $e981               ;kernel routine to scroll screen down
        lda #32
waitinras
        cmp $d012
        bne waitinras
        dec $03
        bne waitinras
        dec $04
        lda $04
        sta $03
        dec $02
        bne clsloop
        


        ;hardware init

        lda #$7f
        sta $dc0d               ; disable CIA#1 IRQs
        lda $dc0d               ; acknowledge pending IRQ at CIA#1 just in case
     
        sei                     ; disable interrupts
        lda #$35 
        sta $01                 ; kill basic, use mem under rom

        
        ;create the table suggested
        lda #$00
        tax
tloop
        txa                     ;this is needed or you get zeroes
        lsr
        lsr
        lsr
        lsr
        sta $ce00,x             ;was reptable
        inx
        bne tloop
        ;need more ram, but you save 4 cycles
        ;
        ;table created. Its 16 zeroes, 16 ones, 16 twos ...
        ;this table kinda makes it all possible
        ;thanks to 
        ;https://www.facebook.com/groups/1622769802100240/permalink/1622835148760372/

        ;init other stuff


        ldx #0                  ;fill screen with #160
        
filoop
        lda #6                  ;also fill color mem, or there will be 1 frame of crap
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $db00,x

        lda #160
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x

        inx
        bne filoop

        ;init foreground and background
        lda #$06
        sta $d020
        lda #$07
        sta $d021

        lda #0
        sta $d016


        ;display sprite
        lda #01
        sta $d015               ;enable sprite 1
        sta $d010               ;set x 9th bit, x>255
        lda #54
        sta $d000
        lda #229
        sta $d001               ;set sprite Y
        lda #39
        sta $07f8               ;set sprite pointer
        lda #$0e
        sta $d027               ;set sprite color

        ;clear all registers
        lda #0
        tay
        tax
        sta $02                 ;framecounter
        
        jsr $1000               ;init music

        ;copy the mainloop zeropage code to zeropage
        ldx #0
zloop
        lda myzeropageasm,x
        sta $03,x
        inx
        cpx #myzeropageasm_end-myzeropageasm
        bne zloop

        jmp $03                 ;lets rock!


     
*=$0900  
myzeropageasm
        incbin "myzeropageasm3.prg",$02
        ;incbin "myzeropageasm2.seq",$02
        ;incbin "myzeropageasm.seq",$02
;this is file 'rledecodezeropage2.asm'
myzeropageasm_end

;a sprite
*=$0a00
        incbin "mysprite.bin"
*=$0a40
        incbin "somesprites.bin"
;made 4 more sprites
        incbin "extrasprites.bin"


;tables for offset colormap and finescroll and spriteY-pos
*=$0c00
        incbin "xltable.seq"
        incbin "xhtable.seq"
        incbin "fstable.seq"
        incbin "introtable.seq"


;place to store the repeat table for faster look up
;this is now moved to $ce00. Not allocated. wasting filesize
;freeing up 4 more sprites
;*=$0f00
;reptable

;some music ('Lille_Svin' by Søren Lund (Jeff), 1993 Camelot)
*=$1000
        incbin "Lille_Svin.sid",$7e

;the RLE data stored as 1-byte RLE
;upper 4 bits are repeat length (1..15)
;lower 4 bits are the color
;this repeats until a 0(zero) is found.
;*=$2000 ;1ac2
mydata
        incbin "1byterle256.seq"
mydataend
;        text    "eyvind ebsen2026"      ;some waste to align exomizer 

;colors sorted from high to low intensity and up again
colortab   byte 1,7,13,3,15,5,10,12,14,4,8,2,11,6,9,0,9,6,11,2,8,4,14,12,10,5,15,3,13,7