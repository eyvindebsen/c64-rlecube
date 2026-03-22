# c64-rlecube
RLE Cube in 256 frames.

256 frames of rle color data decoded at the blazing speed of
50 FPS; that is 256.000 bytes, blasted to color ram in 5.12 seconds.
And there is even time for a quick SID,  scrolling around and fly a sprite.

The colorful cube is conpletely precalculated from BASIC (see file "1byterle.bas")
using RLE compression: (https://en.wikipedia.org/wiki/Run-length_encoding)
Each frame is using around 100-200 bytes, so there is room to store 256 frames.
(file: 1byterle256.seq; 45.793 bytes)

So are the tables precalculated offsets in color-ram, finescrool and sprite y positions.
Check the .BAS files.

Each frame is seperated by a zero, which cannot exist in the RLE data.

Upper 4 bits = repeat length. (Will always be >0)
Lower 4 bits = color

This speeds up the decoder in the Zero-page ASM routine.
First version; i kept checking if i had reached the last color address... super slow.
I am a newbie at democoding. 
So this wastes 256 bytes but its faster, sue me! :)

A big thanks to ปุ้มปุ้ย มะเทืยด for suggesting a table that will look up repeat lengths, instead of doing 4 LSR's.
(https://www.facebook.com/groups/1622769802100240/permalink/1622835148760372/)
This saves 4 cycles in the inner most critical loop. (potientially 400+? cycles)
Kinda making the movement in X, music and sprite possible.
Ofcourse moving all the code to Zero-page ($03) gave a further speed boost.

But i still wanted to change the colors on the fly, or it quickly gets boring, preferebly with a look up in different color tables.
Sadly its not fast enough for a lookup (takes 4 cycles), but i can do an EOR on the color (using 2 cycles)

So where to get those 2 cycles?

One day i had a piece of toast with salmon (yummy), the word for salmon in Danish is "Laks"...
then i remembered the illegal upcode: LAX!

I was reading data from memory with
lda $data (4 cycles)
tax       (2 cycles)

This eats 6 cycles, but LAX loads the A and X register at the same time using only 4 cycles
(https://www.c64-wiki.com/wiki/LAX)

Now the colorchange can happen in the data read loop.
All i gotta do is change the EOR value when the animation is ending.
(Tried with inc, dec, adc, sbc, or, and ... eor is magic)
Btw, the start and end of the animation takes less cycles to decode since its a simpler image.
So there is time to change some values in the running code at this time. Not fully exploited yet.

I know this is probably a DOH moment for many, but as mentioned; i am new at democoding.

Guess there are better and more efficient RLE encoder/decoders out there.
Because i'm kinda convinced you cannot make the actual calculations,  draw the 12 lines in color ram, in 1 frame.

Hope you enjoy the demo :)

PS. I am not sure why the raster jumps up in the screen @1:30 of the video i recorded (rlecube8.mp4)
(Using VICE to record video)
Anyone knows?

