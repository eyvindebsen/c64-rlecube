1 rem sinejump3 the sprite frame in/out
6 poke53280,11:poke53281,0:print"{clear}{white}"
10 v=53248:dim yt(255)
15 pokev,58
20 pokev+21,1:poke2040,13:forx=.to63:poke832+x,255:next
30 pokev+16,1
40 ta=({pi}*2)/64:forq=.to15:cs=cs+ta:next:rem y={pi}
50 forq=.to31:yp=239+sin(cs)*12:yt(q)=yp:cs=cs+ta:next
51 forq=32to224:yt(q)=227:next
52 forq=.to31:yt(224+q)=yt(31-q):next
54 rem xp=172+cos(cs)*146:ot(x)=-(xp>255):xt(x)=xpand255:yt(x)=yp
55 forq=.to255:
56 print"{home}"q; yt(q)
57 pokev+1,yt(q)
60 cs=cs+ta
70 next:pokev+21,0:goto100:rem save tables
80 y=0:goto50
100 print"saving intro table..."
110 open2,8,2,"introtable,s,w":forx=.to255:print#2,chr$(yt(x));:next:close2
120 print"done"