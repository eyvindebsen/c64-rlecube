!-better bresenham
!-https://github.com/HNE74/cbmprogs/blob/master/Bresenham/bresenham.bas
!-3d cube code from:
!-https://retro64.altervista.org/blog/3d-graphics-rotating-cube-with-freebasic-pc-and-simons-basic-c64/
!-
!-try to implement a z-buffer, since lines that are behind will overlap
!-done! -- looks much better
!-
!-compress to rle.
!- done!
!-
!- now uses 2 rle compression modes. 
!- big chunk   : cmd byte 15 - handles lenghts >15 - this is gonna read 2 nibbles
!- small chunk : cmd byte 14 - handles lenghts <15 - this saves a nibble with short repeats
!- this also means i cant use colors >13 - but im using 13, so no worries.
!- can still use cmd byte 13 ... for the future
!-
!- had a terrible bug flushing the last byte...called wrong routine lol
!-
!-now uses a 3rd rle compression method
!-semi chunk  : cmd byte 13 - handles length of 16-31 - saves more nibbles
!-this means only colors from 0-12 are valid. blue(6) is background
!-
!- z calc to w should be average of point a-b
!- done, also got rid of all the INTs
!- z value is a float
!-
!- data needs to be re-arranged for a faster asm decode
!-  length, color
!- still not fast enough to decode -- 
!- too complex because of the nibble handling in asm
!-
!-
!-New RLE encode scheme fast version
!-
!-All in bytes for faster decode (KISS)
!-
!-Read byte
!-  if byte bit 7 set, lower 4 bits are color, next byte is len of repeat
!-  if not, its a single color, plot it
!-until screenfull
!-
!- now to make that encoder--- not fast enough .. misses about 100 raster lines
!-
!-
!- new 1byte rle version. 
!- 1 byte: upper 4 bits= replen
!-         lower 4 bits= color.
!- a 0 is marked at end of each frame for faster asm display
!-
!-
1 rem ********************************
2 rem *** bresenham line algorithm
3 rem ********************************
9 poke646,6:print"{blue}{clear}test":rem goto2600
10 dim v(999),do(500):sc=1024:ch=160:rem v array is z buffer
15 open2,8,2,"1byterle256,s,w":rem save frames to disk
20 xs=10:ys=10:xt=15:yt=3
25 xp=0:yp=0:rl=40
30 dx=0:dy=0:fe=0:tt=0
40 goto 2000
100 a=sc+yp*rl+xp:ifa<1024ora>2023thenreturn
102 rem check z buffer
103 ifv(a-1024)<wthenreturn
104 v(a-1024)=w
105 pokea,ch:poke54272+a,cl
110 return
200 rem print "{clear}":print "bresenham line algorithm demo":print "*****************************"
205 rem input "x start";xs:input "y start";ys:input "x end";xt:input "y end";yt
208 rem print "{clear}"
210 xs=int(xs):ys=int(ys):xt=int(xt):yt=int(yt)
214 dx=abs(xt-xs):dy=abs(yt-ys)
215 rem printw;
220 if xt>=xs and ys=>yt then gosub 310:return:rem goto 250
230 if xt>=xs and ys<yt then gosub 710:return:rem goto 250
235 if xt<xs and ys<yt then gosub 910:return:rem goto 250
240 gosub 510
250 return:rem poke 198,0:wait 198,1:goto 200
300 rem *** sector 1
305 rem print "sector 1"
310 if dy>dx then gosub 400:return
320 fe=dx/2
330 xp=xs:yp=ys:gosub100
340 for xp=xs+1 to xt
350 fe=fe-dy
360 if fe<0 then yp=yp-1:fe=fe+dx
370 gosub 100
380 next
390 return
400 fe=dy/2
410 xp=xs:yp=ys:gosub 100
420 for yp=ys-1 to yt step-1
430 fe=fe-dx
440 if fe<0 then xp=xp+1:fe=fe+dy
450 gosub 100
460 next
470 return
500 rem *** sector 4
505 rem print "sector 4"
510 if dy>dx then gosub 600:return
520 fe=dx/2
530 xp=xs:yp=ys:gosub100
540 for xp=xs-1 to xt step-1
550 fe=fe-dy
560 if fe<0 then yp=yp-1:fe=fe+dx
570 gosub 100
580 next
590 return
600 fe=dy/2
610 xp=xs:yp=ys:gosub 100
620 for yp=ys-1 to yt step-1
630 fe=fe-dx
640 if fe<0 then xp=xp-1:fe=fe+dy
650 gosub 100
660 next
670 return
700 rem *** sector 2
705 rem print "sector 2"
710 if dy>dx then gosub 800:return
720 fe=dx/2
730 xp=xs:yp=ys:gosub100
740 for xp=xs+1 to xt
750 fe=fe-dy
760 if fe<0 then yp=yp+1:fe=fe+dx
770 gosub 100
780 next 
790 return
800 fe=dy/2
810 xp=xs:yp=ys:gosub 100
820 for yp=ys+1 to yt
830 fe=fe-dx
840 if fe<0 then xp=xp+1:fe=fe+dy
850 gosub 100
860 next
870 return
900 rem *** sector 3
905 rem print "sector 3"
910 if dy>dx then gosub 1000:return
920 fe=dx/2
930 xp=xs:yp=ys:gosub100
940 for xp=xs-1 to xt step-1
950 fe=fe-dy
960 if fe<0 then yp=yp+1:fe=fe+dx
970 gosub 100
980 next
990 return
1000 fe=dy/2
1010 xp=xs:yp=ys:gosub 100
1020 for yp=ys+1 to yt
1030 fe=fe-dx
1040 if fe<0 then xp=xp-1:fe=fe+dy
1050 gosub 100
1060 next
1070 return
2000 rx=0:l=80:fs=200+fr:l=l/2:zo=6:rem normal fs=200
2005 ra=(2*{pi})/256:rem set number of frames . 2 rotations
2010 rem *** edges ***
2020 fs=200:rem fs=100+fr*2
2025 x(1)=-l:y(1)=-l:z(1)=-l
2030 x(2)=-l:y(2)=l:z(2)=-l
2040 x(3)=l:y(3)=l:z(3)=-l
2050 x(4)=l:y(4)=-l:z(4)=-l
2060 x(5)=-l:y(5)=-l:z(5)=l
2070 x(6)=-l:y(6)=l:z(6)=l
2080 x(7)=l:y(7)=l:z(7)=l
2090 x(8)=l:y(8)=-l:z(8)=l
2100 c=cos(rx):s=sin(rx):rem rotate
2110 fornp=1to8
2120 yt=y(np):y(np)=c*yt-s*z(np):z(np)=s*yt+c*z(np):rem D ation on x axes
2130 xt=x(np):x(np)=c*xt+s*z(np):z(np)=-s*xt+c*z(np):rem D ation on y axes
2140 xt=x(np):x(np)=xt*c-y(np)*s:y(np)=xt*s+y(np)*c:rem D ation on z axes
2150 rem projections and translations
2160 vx(np)=(120+(x(np)*fs)/(z(np)+fs))/zo
2170 vy(np)=(75+(y(np)*fs)/(z(np)+fs))/zo
2175 vz(np)=z(np):rem for the z-buffer
2180 next
2190 rx=rx+ra:rem advance rotation
2200 gosub2400:print"{blue}{clear}";:cl=0:rem color
2205 xs=vx(1):ys=vy(1):xt=vx(2):yt=vy(2):w=(vz(1)+vz(2))/2:gosub210:cl=cl+1
2220 xs=vx(2):ys=vy(2):xt=vx(3):yt=vy(3):w=(vz(2)+vz(3))/2:gosub210:cl=cl+1
2230 xs=vx(3):ys=vy(3):xt=vx(4):yt=vy(4):w=(vz(3)+vz(4))/2:gosub210:cl=cl+1
2240 xs=vx(4):ys=vy(4):xt=vx(1):yt=vy(1):w=(vz(4)+vz(1))/2:gosub210:cl=cl+1
2250 xs=vx(5):ys=vy(5):xt=vx(6):yt=vy(6):w=(vz(5)+vz(6))/2:gosub210:cl=cl+1
2260 xs=vx(6):ys=vy(6):xt=vx(7):yt=vy(7):w=(vz(6)+vz(7))/2:gosub210:cl=cl+2:rem blue background
2270 xs=vx(7):ys=vy(7):xt=vx(8):yt=vy(8):w=(vz(7)+vz(8))/2:gosub210:cl=cl+1
2280 xs=vx(8):ys=vy(8):xt=vx(5):yt=vy(5):w=(vz(8)+vz(5))/2:gosub210:cl=cl+1
2290 xs=vx(1):ys=vy(1):xt=vx(5):yt=vy(5):w=(vz(1)+vz(5))/2:gosub210:cl=cl+1
2300 xs=vx(4):ys=vy(4):xt=vx(8):yt=vy(8):w=(vz(4)+vz(8))/2:gosub210:cl=cl+1
2310 xs=vx(2):ys=vy(2):xt=vx(6):yt=vy(6):w=(vz(2)+vz(6))/2:gosub210:cl=cl+1
2320 xs=vx(3):ys=vy(3):xt=vx(7):yt=vy(7):w=(vz(3)+vz(7))/2:gosub210:rem cl=cl+1
2325 rem gosub 2500:rem save frame
2326 gosub 2600:rem rle encode screen
2328 fr=fr+1:if fr>255 then goto 2900
2330 goto2020
2399 rem clear z-buffer
2400 fora=0to999:v(a)=200:next
2410 return
2499 rem save color ram as seq nibbles... 500 bytes
2500 for a=0to999step2:d=(peek(55296+a)and15)*16+(peek(55297+a)and15)
2510 rem print"{home}"peek(55296+a)and15,peek(55297+a)and15,d;:ifd>255 thenprint"ups!"
2520 print#2,chr$(d);
2530 next
2540 print"{home}frame "fr" saved"
2550 return
2598 rem run length encode color ram the quicker way
2599 rem upper 4 bits are repeat length;lower 4 bits are color
2600 a=55296:lb=0:mr=0:tw=0:wn=0
2605 lc=peek(a)and15:rp=1
2610 a=a+1:ifa>56295 then gosub 2706:goto 2650:rem flush and end
2620 if (peek(a)and15)<>lc then gosub 2706:goto2605:rem repeat end, flush buffer
2630 rp=rp+1:rem same color repeats
2635 if rp>15 then rp=rp-1:gosub2706:goto2605:rem rep buffer full
2640 goto2610
2650 lb=lb:rem if lb=1thenda=0:gosub2770:rem flush the last nibble
2653 print:print"{white}frame "fr" rle done! used "tw" bytes"
2654 if tw>mw then mw=tw:rem set max frame len stats
2655 print"max reps "mr", max frame"mw:print"saving "tw" bytes..."
2656 forx=.totw-1:print#2,chr$(do(x));:next
2657 print#2,chr$(0);:tt=tt+tw+1:rem save a 0 when fram done, for faster display
2658 rem print"data":fora=0totw-1:printdo(a);:next:input"ok";a$
2660 return:goto2800:end:rem decode
2699 rem flush buffer
2700 goto2706:rem ifrp=1thenda=lc:gosub2760:return
2705 rem print"{home}{white}found    {left*3}"rp"{left*1} repeats  ";
2706 if rp>mr then mr=rp:rem count up max for stats
2708 rem compress to 1 byte - replen max 15
2710 da=rp*16:da=da or lc:gosub2760:return:rem save a color with rep set
2759 rem handle new 8 bits for output
2760 wn=wn+1
2765 do(tw)=da:rem print#2,chr$(by);:rem write data byte
2775 tw=tw+1:lb=0
2780 return
2799 rem reconstruct image from rle data
2800 a=55296:lb=0:db=0:rn=0
2805 poke646,1:print"{white}{clear}":forx=1024to2023:pokex,160:next
2810 gosub 2890:rem get a byte
2830 gosub 2870:goto2860:rem do a long repeat
2840 pokea,da:a=a+1:rem poke the single color
2860 ifa<=56295then goto 2810
2862 if lb=1thendb=db+1:rem correct the last byte actual value
2865 print"{white}rle decoded "db" bytes done. was "tw
2867 print"wrote "wn", read "rn" nibbles"
2868 end
2869 rem decde a large rle chunk (1 byte)
2870 cl=da and 15:rp=(da and 240)/16
2874 pokea,cl:rp=rp-1:a=a+1:ifrp>0then2874:rem plot the long repeaet
2878 return
2889 rem get byte from data stream
2890 rn=rn+1
2892 da=do(db):db=db+1:lb=0
2896 return
2899 rem close file and finish
2900 print"{white}closing file":close2:print"complete"
2905 print"data bytes saved:"tt
2906 print"max frame len "mw
2910 print"time taken ",ti,ti$