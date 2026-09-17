from pathlib import Path
from PIL import Image, ImageDraw
import math, struct, wave
root=Path(__file__).resolve().parent.parent
audio=root/'Audio';audio.mkdir(parents=True,exist_ok=True)
for name,freqs,duration in [('eat',[660,880],.12),('bounce',[330,440],.085),('miss',[240,170,110],.3),('clear',[523,659,784,1047],.45)]:
    data=[];rate=22050
    for i in range(int(rate*duration)):
        t=i/rate;part=min(len(freqs)-1,int(t/duration*len(freqs)));f=freqs[part]
        env=min(1,t/.008)*max(0,1-t/duration)**1.8
        v=(math.sin(2*math.pi*f*t)+.15*math.sin(4*math.pi*f*t))*env*.19
        data.append(struct.pack('<h',int(v*32767)))
    with wave.open(str(audio/(name+'.wav')),'wb') as out:
        out.setnchannels(1);out.setsampwidth(2);out.setframerate(rate);out.writeframes(b''.join(data))
im=Image.new('RGB',(1024,1024),'#080d19');d=ImageDraw.Draw(im)
d.rounded_rectangle((55,55,969,969),radius=80,fill='#0c1527',outline='#223954',width=5)
for i in range(128,960,80):
    d.line((i,60,i,965),fill='#12243b',width=2)
    d.line((60,i,965,i),fill='#12243b',width=2)
d.line((58,185,58,58,185,58),fill='#34d9f7',width=9)
d.line((966,839,966,966,839,966),fill='#34d9f7',width=9)
d.rounded_rectangle((210,790,814,866),radius=9,fill='#15394d')
d.rectangle((217,789,807,801),fill='#34d9f7')
d.rectangle((453,823,571,831),fill='#a5f1ff')
for i in range(20,0,-1):
    x=480+math.sin(i*.20)*150;y=328+i*20;r=55-i*.75
    d.ellipse((x-r-8,y-r-8,x+r+8,y+r+8),fill='#123349')
    d.ellipse((x-r,y-r,x+r,y+r),fill=('#3789b7' if i%3==0 else '#26b7d5'))
x,y=480,328
d.ellipse((x-86,y-86,x+86,y+86),fill='#174b64')
d.ellipse((x-76,y-76,x+76,y+76),fill='#62e6ff')
for ex in (449,511):
    d.ellipse((ex-21,272,ex+21,314),fill='#081524');d.ellipse((ex-9,274,ex+9,292),fill='#e8fcff')
d.ellipse((680,110,880,310),fill='#35232b')
d.polygon([(780,136),(864,220),(780,304),(696,220)],fill='#ff7956')
d.polygon([(780,174),(826,220),(780,266),(734,220)],fill='#ffd5b0')
im.resize((512,512),Image.Resampling.LANCZOS).save(root/'icon.png')
print('Generated neon snake icon and synthesized sound effects')
