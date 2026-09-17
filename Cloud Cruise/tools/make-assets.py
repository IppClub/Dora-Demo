from pathlib import Path
from PIL import Image,ImageDraw
import math,wave,struct
root=Path(__file__).resolve().parent.parent
out=root/'Audio';out.mkdir(parents=True,exist_ok=True)
for name,notes,duration in [('start',[440,660],.2),('pass',[740,980],.15),('crash',[190,140,80],.4)]:
    frames=[];rate=22050
    for i in range(int(duration*rate)):
        t=i/rate;f=notes[min(len(notes)-1,int(t/duration*len(notes)))];env=min(1,t/.01)*(1-t/duration)**2
        frames.append(struct.pack('<h',int(math.sin(2*math.pi*f*t)*env*6000)))
    with wave.open(str(out/(name+'.wav')),'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(rate);w.writeframes(b''.join(frames))
im=Image.new('RGB',(1024,1024));d=ImageDraw.Draw(im)
for y in range(1024):
    t=y/1023;c=tuple(int(a*(1-t)+b*t) for a,b in zip((123,184,205),(255,225,184)));d.line((0,y,1024,y),fill=c)
d.ellipse((730,90,920,280),fill='#fff4ce')
for x,y,r in [(0,830,120),(140,840,160),(780,870,150),(930,810,130)]:d.ellipse((x-r,y-r,x+r,y+r),fill='#eaf2e8')
def poly(points,color):d.polygon([(512+x*12,470-y*12) for x,y in points],fill=color)
poly([(-11,3),(-21,21),(-11,21),(8,4)],'#cf6346')
poly([(-13,4),(-32,13),(-33,5),(-26,-2)],'#e66d47')
poly([(-31,2),(-16,8),(13,7),(26,1),(21,-5),(-18,-6)],'#365c6b')
poly([(-32,4),(-14,11),(12,10),(26,4),(21,-2),(-18,-3)],'#fff6df')
poly([(-10,1),(-21,-21),(-9,-21),(12,1)],'#ee8051')
poly([(-18,-17),(-11,-17),(-10,-20),(-20,-20)],'#fff6df')
poly([(-1,10),(4,16),(13,14),(16,9)],'#365e70')
poly([(4,13),(7,15),(12,13),(13,11)],'#9ed9e2')
poly([(-25,6),(-31,15),(-25,15),(-18,8)],'#e77b53')
d.line((840,350,840,610),fill='#436779',width=20)
d.ellipse((826,422,856,452),fill='#ffe3b8')
im.resize((512,512),Image.Resampling.LANCZOS).save(root/'icon.png')
print('Plane icon and three audio effects generated')
