1 rem sine fine scroll pet cube and offset tables
6 rem  poke53280,11:poke53281,0:print"{clear}{white}"
10 dim xl(255),xh(255),fs(255)
20 rem v=53248:pokev+21,1:poke2040,0
30 rem pokev+16,1
40 ta=({pi}*2)/256:rem cs={pi}
50 forq=.to255:xp=int(56+sin(cs)*56):ad=55289+int(xp/8)
56 rem printx; xp;int(xp/8);xp and 7;ad:rem xt(x);yt(x);ot(x)
58 xh(q)=int(ad/256):xl(q)=ad-xh(q)*256:fs(q)=xp and 7
59 printq,xh(q),xl(q),fs(q)
60 cs=cs+ta
70 next:pokev+21,0:goto100:rem save tables
80 y=0:goto50
100 print"saving xl table..."
110 open2,8,2,"xltable,s,w":forx=.to255:print#2,chr$(xl(x));:next:print"done{down}":close2
120 print"saving xh table..."
130 open2,8,2,"xhtable,s,w":forx=.to255:print#2,chr$(xh(x));:next:print"done{down}":close2
140 print"saving fs table..."
150 open2,8,2,"fstable,s,w":forx=.to255:print#2,chr$(fs(x));:next:print"done{down}":close2