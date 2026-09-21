local D=require('Dora')
local M=require('SnakeModel');local A=require('SnackArt');local V=D.Vec2
local root=D.Node();root.anchor=V(0,0);root.size=D.Size(360,640);root.position=V(-180,-320);root:addTo(D.Director.entry)
local bg=D.DrawNode();bg:addTo(root)
local field=D.DrawNode();field:addTo(root)
local drawing=D.DrawNode();drawing:addTo(root)
local ui=D.Node();ui:addTo(root)
local overlay=D.DrawNode();overlay:addTo(root)
local overlayUI=D.Node();overlayUI:addTo(root)
local colors=A.colors;local m=M.new();m.state='menu'
local time=0;local particles={};local floating={};local lastState='';local keys={};local best=0;local muted=false
local diagnostics=D.Content:exist('test-mode.txt');local diagnosticTime=0;local inputX=0;local inputY=0;local worldX=0
local savePath=D.Path(D.Content.writablePath,'snake-neon-save.txt')
pcall(function() if D.Content:exist(savePath) then best=tonumber(D.Content:load(savePath)) or 0 end end)
local function save() if m.score>best then best=m.score;pcall(function() D.Content:save(savePath,tostring(best)) end) end end
local function label(parent,text,x,y,size,color)
 local l=D.Label('sarasa-mono-sc-regular',size,true)
 assert(l,'Dora bundled font missing');l.text=text;l.position=V(x,y);l.color=D.Color(color or colors.ink);l:addTo(parent);return l
end
local title=label(ui,'奇怪的贪吃蛇',129,601,28)
label(ui,'分数',49,546,10,colors.muted)
local scoreLabel=label(ui,'0000',66,522,27)
label(ui,'最高纪录',162,546,10,colors.muted)
local bestLabel=label(ui,'0',162,522,22)
local levelLabel=label(ui,'LEVEL 01',268,546,11)
local livesLabel=label(ui,'● ● ●',268,522,16,colors.orange)
local progressLabel=label(ui,'能量收集   0 / 10',180,473,10,colors.muted)
local soundLabel=label(ui,'♪',273,601,22)
local pauseLabel=label(ui,'Ⅱ',315,601,19)
local popupTitle=label(overlayUI,'',180,372,23)
local popupSub=label(overlayUI,'',180,338,11,colors.muted)
local popupHint=label(overlayUI,'',180,314,11,colors.muted)
local popupExtra=label(overlayUI,'',180,290,11,colors.muted)
local buttonLabel=label(overlayUI,'',180,245,15,0xff081524)
local secondary=label(overlayUI,'',180,205,11,colors.muted)
local readyLabel=label(ui,'点击场地发射',180,196,13,colors.ink)
local readyHint=label(ui,'挡板边缘，可以改变反弹方向',180,174,9,colors.muted)

A.box(bg,-400,-400,1160,1440,1,colors.cream)
A.line(bg,24,564,336,564,.5,colors.line);A.line(bg,116,512,116,551,.5,colors.line);A.line(bg,216,512,216,551,.5,colors.line)
A.box(bg,253,584,39,34,4,0xff142238);A.box(bg,298,584,34,34,4,0xff142238)
A.box(field,22,80,316,414,5,colors.line);A.box(field,24,83,312,409,4,colors.paper)
for x=42,322,28 do A.line(field,x,117,x,455,.35,0xff12243b) end
for y=119,454,28 do A.line(field,26,y,334,y,.35,0xff12243b) end
A.line(field,42,458,318,458,.5,colors.line)
for _,x in ipairs({24,336}) do
 local sign=x==24 and 1 or -1
 A.line(field,x,492,x+22*sign,492,1.1,colors.green);A.line(field,x,492,x,470,1.1,colors.green)
 A.line(field,x,83,x+22*sign,83,1.1,colors.green)
end
A.line(field,54,87,306,87,.8,0xffad483f)
A.box(field,48,94,264,16,2,0xff101f33)

local function layout()
 local sz=D.View.size;local scale=math.min(sz.width/360,sz.height/640)
 local camera=D.tolua.cast(D.Director.currentCamera,'Camera2D');if camera then camera.zoom=scale end
end
layout();root:gslot('AppChange',function(setting) if setting=='Size' then layout() end end)
local function sound(kind)
 if muted then return end
 local clip=({eat='eat',bounce='bounce',miss='miss',clear='clear',launch='bounce'})[kind]
 if clip then pcall(function() D.Audio:play('Audio/'..clip..'.wav') end) end
end
local function burst(x,y,color,count)
 for i=1,count do
  local angle=i*2.39996+time;local speed=28+(i*37)%110
  particles[#particles+1]={x=x,y=y,vx=math.cos(angle)*speed,vy=math.sin(angle)*speed,life=.6,max=.6,c=color,r=2+i%3}
 end
end
local function action()
 if m.state=='menu' or m.state=='over' then save();m=M.new();m:launch()
 elseif m.state=='paused' then m:pause()
 elseif m.state=='clear' then m:nextLevel();m:launch()
 elseif m.state=='ready' then m:launch() end
end
local function tap(t)
 if not t.first then return end
 local p=t.location
 if p.y>579 then
  if p.x>294 then m:pause() elseif p.x>250 then muted=not muted end
  return
 end
 if m.state=='menu' or m.state=='over' or m.state=='clear' or m.state=='paused' then
  if p.x>60 and p.x<300 and p.y>224 and p.y<265 then action()
  elseif m.state=='paused' and p.y>187 and p.y<218 then save();m=M.new();m:launch() end
  return
 end
 m:setPaddle(p.x);if m.state=='ready' then m:launch() end
end
root:onTapBegan(tap)
root:onTapMoved(function(t) if t.first and (m.state=='playing' or m.state=='ready') then m:setPaddle(t.location.x) end end)
root:onMouseMove(function(t) inputX=t.location.x;inputY=t.location.y;worldX=t.worldLocation.x;if m.state=='playing' or m.state=='ready' then m:setPaddle(t.location.x) end end)
root:onKeyDown(function(k)
 keys[k]=true
 if k=='Space' or k=='Return' then if m.state=='playing' then m:pause() else action() end
 elseif k=='Escape' or k=='P' then m:pause()
 elseif k=='R' then save();m=M.new();m:launch()
 elseif k=='M' then muted=not muted end
end)
root:onKeyUp(function(k) keys[k]=nil end)
root:gslot('AppEvent',function(event) if event=='DidEnterBackground' then keys={};if m.state=='playing' or m.state=='ready' then m:pause() end;save() end end)
local function showPopup()
 local st=m.state;overlay:clear()
 local visible=st=='menu' or st=='paused' or st=='clear' or st=='over';overlayUI.visible=visible
 if not visible then return end
 A.box(overlay,24,83,312,411,4,0xc5080d19)
 A.box(overlay,39,186,282,233,6,colors.line);A.box(overlay,40,187,280,231,5,0xff101d32)
 A.line(overlay,60,417,145,417,1.5,colors.green)
 A.box(overlay,69,223,222,44,4,colors.green)
 if st=='menu' then
  popupTitle.text='追逐能量';popupSub.text='移动挡板，让蛇头反弹吃掉食物'
  popupHint.text='一次一个目标 · 吃掉后随机刷新';popupExtra.text='收集 10 个升级 · 共有三条生命'
  buttonLabel.text='开 始 游 戏';secondary.text=''
 elseif st=='paused' then
  popupTitle.text='已暂停';popupSub.text='准备好了，就继续';popupHint.text='当前分数  '..m.score
  popupExtra.text='按空格或点击下方继续';buttonLabel.text='继 续 游 戏';secondary.text='重新开始'
 elseif st=='clear' then
  popupTitle.text='能量充满';popupSub.text='第 '..m.level..' 关完成 · 奖励 100 分'
  popupHint.text='下一关，速度提升';popupExtra.text='当前分数  '..m.score
  buttonLabel.text='下 一 关';secondary.text='保持反弹，继续吞噬'
 else
  popupTitle.text='本轮结束';popupSub.text='本次得分  '..m.score..'   ·   最佳  '..best
  popupHint.text='吃掉 '..m.eaten..' 个食物 · 到达第 '..m.level..' 关'
  popupExtra.text='试试用挡板边缘瞄准目标';buttonLabel.text='再 来 一 局';secondary.text='按 R 也能重新开始'
 end
end
local lastW,lastH=0,0;local visualAngle=math.pi/2
root:schedule(function(dt)
 dt=math.min(dt,.05);time=time+dt
 local sz=D.View.size;if lastW~=sz.width or lastH~=sz.height then layout();lastW,lastH=sz.width,sz.height end
 if m.state=='playing' or m.state=='ready' then
  local direction=((keys.Right or keys.D) and 1 or 0)-((keys.Left or keys.A) and 1 or 0)
  if direction~=0 then m:setPaddle(m.paddle+direction*380*dt) end
 end
 m:update(dt)
 for _,e in ipairs(m.events) do
  sound(e.kind)
  if e.kind=='eat' then burst(e.x,e.y,colors.orange,12);floating[#floating+1]={label=label(ui,'+'..e.value,e.x,e.y+10,12,colors.green),life=.7}
  elseif e.kind=='bounce' then burst(e.x,e.y,colors.green,8)
  elseif e.kind=='miss' then burst(m.paddle,93,colors.orange,16)
  elseif e.kind=='clear' then for x=60,300,60 do burst(x,365,colors.green,20) end;save()
  elseif e.kind=='over' then save() end
 end;m.events={}
 drawing:clear()
 for _,f in ipairs(m.food) do if f.alive then A.fruit(drawing,f.x,f.y,f.kind,1+math.sin(time*4)*.065) end end
 -- A subtle center seam makes the paddle's aiming surface readable.
 A.box(drawing,m.paddle-m.width/2-3,93,m.width+6,18,4,0x2034d9f7)
 A.box(drawing,m.paddle-m.width/2,97,m.width,11,2,0xff257791)
 A.line(drawing,m.paddle-m.width/2+2,108,m.paddle+m.width/2-2,108,1.4,colors.green)
 A.line(drawing,m.paddle-8,102,m.paddle+8,102,.8,0xffa5f1ff)
 if m.state=='ready' then
  local points={};for i=1,9 do points[i]={x=m.x-25*math.sin((i-1)*.3),y=m.y+25*(1-math.cos((i-1)*.3))} end
  A.snake(drawing,points,math.pi/2,time)
  for i=1,6 do A.dot(drawing,m.x+i*5,139+i*10,1.2,0xff345471) end
 elseif m.state=='menu' then
  local points={};for i=1,13 do points[i]={x=180+math.sin(time*1.4-i*.22)*33,y=160-i*4} end
  A.snake(drawing,points,math.pi/2,time)
 else
  visualAngle=math.atan(m.vy,m.vx);A.snake(drawing,m:body(),visualAngle,time)
 end
 for i=#particles,1,-1 do
  local p=particles[i];p.life=p.life-dt
  if p.life<=0 then table.remove(particles,i) else
   p.x=p.x+p.vx*dt;p.y=p.y+p.vy*dt;p.vy=p.vy-130*dt
   A.dot(drawing,p.x,p.y,p.r*p.life/p.max,p.c)
  end
 end
 for i=#floating,1,-1 do local f=floating[i];f.life=f.life-dt;f.label.y=f.label.y+24*dt;f.label.opacity=math.min(1,f.life*3);if f.life<=0 then f.label:removeFromParent();table.remove(floating,i) end end
 scoreLabel.text=string.format('%04d',m.score);bestLabel.text=tostring(math.max(best,m.score))
 levelLabel.text=string.format('LEVEL %02d',m.level);livesLabel.text=string.rep('● ',m.lives)..string.rep('○ ',3-m.lives)
 progressLabel.text='能量收集   '..(m.total-m.remaining)..' / '..m.total
 readyLabel.visible=m.state=='ready';readyHint.visible=m.state=='ready'
 soundLabel.text=muted and '×' or '♪';pauseLabel.text=m.state=='paused' and '▶' or 'Ⅱ'
 if m.state~=lastState then lastState=m.state;showPopup() end
 if diagnostics and time-diagnosticTime>.08 then
  diagnosticTime=time
  D.Content:save(D.Path(D.Content.writablePath,'snake-debug.json'),string.format('{"state":"%s","x":%.2f,"y":%.2f,"vx":%.2f,"vy":%.2f,"paddle":%.2f,"score":%d,"best":%d,"lives":%d,"remaining":%d,"level":%d,"length":%d,"bounces":%d,"inputX":%.2f,"inputY":%.2f,"worldX":%.2f,"muted":%s,"foodCount":%d,"foodX":%.2f,"foodY":%.2f}',m.state,m.x,m.y,m.vx,m.vy,m.paddle,m.score,best,m.lives,m.remaining,m.level,m.length,m.bounces,inputX,inputY,worldX,tostring(muted),#m.food,m.food[1] and m.food[1].x or 0,m.food[1] and m.food[1].y or 0))
 end
 return false
end)
return root
