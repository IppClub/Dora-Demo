local D=require('Dora');local M=require('FlightModel');local A=require('FlightArt');local V=D.Vec2
local root=D.Node();root.anchor=V(0,0);root:addTo(D.Director.entry)
local art=D.DrawNode();art:addTo(root)
local hud=D.Node();hud:addTo(root)
local card=D.DrawNode();card:addTo(root)
local cardUI=D.Node();cardUI:addTo(root)
local m=M.new(360);local clock=0;local best=0;local mute=false;local keys={};local trail={};local sparks={}
local dragging=false;local dragY,dragTarget=0,320;local lastW,lastH=0,0;local width=360;local lastState=''
local qa=D.Content:exist('test-mode.txt');local qaTime=0
local savePath=D.Path(D.Content.writablePath,'cloud-cruise-best.txt')
pcall(function() if D.Content:exist(savePath) then best=tonumber(D.Content:load(savePath)) or 0 end end)
local function save() if m.score>best then best=m.score;pcall(function() D.Content:save(savePath,tostring(best)) end) end end
local function text(parent,value,size,color)
 local l=D.Label('sarasa-mono-sc-regular',size,true);assert(l,'Missing Dora font');l.text=value;l.color=D.Color(color or A.ink);l:addTo(parent);return l
end
local title=text(hud,'云际巡航',25);local score=text(hud,'穿越  00',15);local record=text(hud,'最佳  00',13,A.muted)
local pause=text(hud,'Ⅱ',18);local audio=text(hud,'♪',22)
local heading=text(cardUI,'云际巡航',28)
local sub=text(cardUI,'拖动升降，松手平飞',14,A.muted)
 local detail=text(cardUI,'穿越移动航道，挑战渐进难度',12,A.muted)
local actionText=text(cardUI,'开 始 飞 行',16,0xfffffcf0)
local extra=text(cardUI,'',12,A.muted)
local function layout()
 local sz=D.View.size;local scale=sz.height/640;width=math.max(320,sz.width/scale)
 local camera=D.tolua.cast(D.Director.currentCamera,'Camera2D');if camera then camera.zoom=scale end
 root.position=V(-width/2,-320);root.size=D.Size(width,640);m:resize(width)
 title.position=V(91,604);score.position=V(88,570);record.position=V(width-87,570)
 pause.position=V(width-34,604);audio.position=V(width-76,604)
 heading.position=V(width/2,382);sub.position=V(width/2,343);detail.position=V(width/2,315)
 actionText.position=V(width/2,250);extra.position=V(width/2,205)
 lastW,lastH=sz.width,sz.height
end
layout()
local function beep(kind)
 if not mute then pcall(function() D.Audio:play('Audio/'..kind..'.wav') end) end
end
local function start() save();m:start();trail={};sparks={};dragging=false;keys={};beep('start') end
local function action()
 if m.state=='menu' or m.state=='over' then start() elseif m.state=='paused' then m:pause() end
end
root:onTapBegan(function(t)
 if not t.first then return end;local p=t.location
 if p.y>581 then
  if p.x>width-54 then m:pause();dragging=false;keys={}
  elseif p.x>width-97 then mute=not mute end
  return
 end
 if m.state~='playing' then
  if p.x>width/2-110 and p.x<width/2+110 and p.y>225 and p.y<275 then action()
  elseif m.state=='paused' and p.y>185 and p.y<221 then start() end
  return
 end
 dragging=true;dragY=p.y;dragTarget=m.target
end)
root:onTapMoved(function(t)
 if t.first and dragging and m.state=='playing' then m:setTarget(dragTarget+(t.location.y-dragY)*1.25) end
end)
root:onTapEnded(function(t) if t.first and dragging then dragging=false;m:release() end end)
root:onKeyDown(function(k)
 keys[k]=true
 if k=='Space' or k=='Return' then if m.state=='playing' then m:pause() else action() end
 elseif k=='P' or k=='Escape' then m:pause();keys={};dragging=false
 elseif k=='R' then start()
 elseif k=='M' then mute=not mute end
end)
root:onKeyUp(function(k) keys[k]=nil end)
root:gslot('AppEvent',function(event)
 if event=='DidEnterBackground' then keys={};dragging=false;if m.state=='playing' then m:pause() end;save() end
end)
local function popup()
 card:clear();local visible=m.state~='playing';cardUI.visible=visible
 if not visible then return end
 A.box(card,0,0,width,553,0x66416471)
 A.box(card,width/2-143,181,286,269,0x20324950)
 A.box(card,width/2-141,187,282,269,0xfffff7e7)
 A.box(card,width/2-141,450,72,6,A.orange)
 A.pill(card,width/2-110,226,220,48,A.orange)
 if m.state=='menu' then
  heading.text='云际巡航';sub.text='拖动升降，松手平飞';detail.text='穿越移动航道，挑战渐进难度';actionText.text='开 始 飞 行';extra.text=''
 elseif m.state=='paused' then
  heading.text='飞行暂停';sub.text='已穿越 '..m.score..' 道障碍';detail.text='飞机将保持当前飞行状态';actionText.text='继 续 飞 行';extra.text='重新开始'
 else
  heading.text='本次飞行结束';sub.text='穿越 '..m.score..' 道障碍  ·  最佳 '..best
  detail.text='提前调整高度，对准航道';actionText.text='再 飞 一 次';extra.text=''
 end
end
root:schedule(function(dt)
 dt=math.min(dt,.05);clock=clock+dt
 local sz=D.View.size;if sz.width~=lastW or sz.height~=lastH then layout() end
 if m.state=='playing' then
  local axis=((keys.Up or keys.W) and 1 or 0)-((keys.Down or keys.S) and 1 or 0)
  m:axis(axis);m:update(dt)
  if #trail==0 or clock-trail[#trail].t>.025 then trail[#trail+1]={x=m.x-27,y=m.y,t=clock} end
 end
 for _,e in ipairs(m.events) do
  if e.kind=='pass' then beep('pass')
  elseif e.kind=='crash' then
   beep('crash');save();dragging=false;keys={}
   for i=1,22 do local a=i*2.39996;sparks[#sparks+1]={x=m.x,y=m.y,vx=math.cos(a)*(30+i*4),vy=math.sin(a)*(30+i*4),life=1} end
  end
 end;m.events={}
 art:clear()
 local dist=m.state=='menu' and clock*20 or m.distance
 A.sky(art,width,clock,dist)
 for _,g in ipairs(m.gates) do A.gate(art,g,clock) end
 for i=#trail,1,-1 do
  local p=trail[i];if m.state=='playing' then p.x=p.x-m.speed*dt end
  if clock-p.t>1 or p.x< -20 then table.remove(trail,i) else
   local life=1-(clock-p.t);A.dot(art,p.x,p.y,1.1+(1-life)*2.5,0x50ffffff)
  end
 end
 local y=m.state=='menu' and 320+math.sin(clock*1.5)*6 or m.y
 local bank=m.state=='menu' and math.sin(clock)*3 or m.bank
 A.plane(art,m.x,y,bank,clock,1)
 for i=#sparks,1,-1 do local p=sparks[i];p.life=p.life-dt;p.x=p.x+p.vx*dt;p.y=p.y+p.vy*dt;p.vy=p.vy-90*dt
  if p.life<=0 then table.remove(sparks,i) else A.dot(art,p.x,p.y,p.life*3.5,i%2==0 and A.orange or 0xffffe1a3) end
 end
 -- Flight deck remains clear of the obstacle lane.
 A.box(art,0,554,width,86,0xeaf3f5e9)
 A.line(art,20,552,width-20,552,.7,0xff80a2a7)
 A.pill(art,width-95,585,38,37,0xffe3eae0);A.pill(art,width-53,585,38,37,0xffe3eae0)
 score.text=string.format('穿越  %02d',m.score);record.text=string.format('最佳  %02d',math.max(best,m.score))
 audio.text=mute and '×' or '♪';pause.text=m.state=='paused' and '▶' or 'Ⅱ'
 popup()
 if qa and clock-qaTime>.08 then
  qaTime=clock;local g=nil;for _,gate in ipairs(m.gates) do if gate.x>m.x-48 and (not g or gate.x<g.x) then g=gate end end
  D.Content:save(D.Path(D.Content.writablePath,'flight-debug.json'),string.format('{"state":"%s","y":%.3f,"vy":%.3f,"target":%.3f,"score":%d,"best":%d,"width":%.2f,"x":%.2f,"gateX":%.2f,"gateY":%.2f,"gap":%.2f,"speed":%.2f,"muted":%s}',m.state,m.y,m.vy,m.target,m.score,best,width,m.x,g and g.x or -999,g and g.center or 320,g and g.gap or 192,m.speed,tostring(mute)))
 end
 return false
end)
return root
