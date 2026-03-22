1 rem sinejump - rotates a sprite around the screen--- just ugly! - not used
6 poke53280,11:poke53281,0:print"{clear}{white}"
10 v=53248:dim xt(255),yt(255),ot(255)
20 pokev+21,1:poke2040,0
30 rem pokev+16,1
40 ta=({pi}*2)/256:y={pi}
50 forx=.to255:yp=140+sin(cs)*90
54 xp=172+cos(cs)*146:ot(x)=-(xp>255):xt(x)=xpand255:yt(x)=yp
56 print"{home}"x; xt(x);yt(x);ot(x)
57 pokev,xt(x):pokev+16,ot(x):pokev+1,yt(x)
60 cs=cs+ta
70 next:pokev+21,0:end:goto100:rem save tables
80 y=0:goto50
100 print"saving x table..."
110 open2,8,2,"xt,s,w":forx=.to255:print#2,chr$(xt(x));:next:print"done{down}":close2
120 print"saving y table..."
130 open2,8,2,"yt,s,w":forx=.to255:print#2,chr$(yt(x));:next:print"done{down}":close2
140 print"saving o table..."
150 open2,8,2,"ot,s,w":forx=.to255:print#2,chr$(ot(x));:next:print"done{down}":close2