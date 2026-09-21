-- Pure Lua rules; coordinates are in a 360 x 640 play space, y points up.
local M={};M.__index=M
local function clamp(v,a,b) return math.max(a,math.min(b,v)) end
function M.new(random)
 local self=setmetatable({score=0,level=1,lives=3,length=9,paddle=180,width=84,
  events={},trail={},bounces=0,combo=0,acc=0,time=0,eaten=0,random=random or math.random},M)
 self:makeLevel();return self
end
function M:event(kind,x,y,value) self.events[#self.events+1]={kind=kind,x=x or self.x,y=y or self.y,value=value or 0} end
function M:resetHead()
 self.x=self.paddle;self.y=124;self.vx=94;self.vy=math.sqrt(self.speed*self.speed-94*94)
 self.trail={};for i=1,self.length*5+5 do local t=(i-1)*.085;self.trail[i]={x=clamp(self.x-25*math.sin(t),34,326),y=self.y+25*(1-math.cos(t))} end
 self.state='ready';self.acc=0;self.combo=0
end
function M:makeLevel()
 self.speed=math.min(340,214+(self.level-1)*15);self.food={}
 self.remaining=10;self.total=10;self:resetHead();self:spawnFood()
end
function M:spawnFood()
 local body=self:body();local previous=self.food[1]
 local function clearance(x,y)
  local gap=(x-self.x)^2+(y-self.y)^2
  for _,p in ipairs(body) do gap=math.min(gap,(x-p.x)^2+(y-p.y)^2) end
  if previous then gap=math.min(gap,((x-previous.x)^2+(y-previous.y)^2)*.44) end
  return gap
 end
 local x,y,bestX,bestY,bestGap
 bestGap=-1
 for _=1,64 do
  x=50+self.random()*260;y=185+self.random()*265
  local gap=clearance(x,y)
  if gap>bestGap then bestX,bestY,bestGap=x,y,gap end
  if gap>=36^2 then break end
 end
 if bestGap<36^2 then
  for gx=50,310,20 do for gy=185,445,20 do
   local gap=clearance(gx,gy);if gap>bestGap then bestX,bestY,bestGap=gx,gy,gap end
  end end
 end
 self.food={{x=bestX,y=bestY,kind=0,alive=true}}
end
function M:setPaddle(x)
 local nextX=clamp(x,24+self.width/2,336-self.width/2)
 if self.state=='ready' then
  local dx=nextX-self.paddle;self.x=nextX
  for _,p in ipairs(self.trail) do p.x=clamp(p.x+dx,32,328) end
 end
 self.paddle=nextX
end
function M:launch() if self.state=='ready' then self.state='playing';self:event('launch') end end
function M:pause()
 if self.state=='paused' then self.state=self.resumeState or 'playing'
 elseif self.state=='playing' or self.state=='ready' then self.resumeState=self.state;self.state='paused' end
end
function M:nextLevel() self.level=self.level+1;self:makeLevel() end
function M:step(dt)
 self.time=self.time+dt
 local previousY=self.y
 self.x=self.x+self.vx*dt;self.y=self.y+self.vy*dt
 if self.x<32 then self.x=64-self.x;self.vx=math.abs(self.vx);self:event('wall')
 elseif self.x>328 then self.x=656-self.x;self.vx=-math.abs(self.vx);self:event('wall') end
 if self.y>479 then self.y=958-self.y;self.vy=-math.abs(self.vy);self:event('wall') end
 if self.vy<0 and previousY>=112 and self.y<=112 and math.abs(self.x-self.paddle)<=self.width/2+8 then
  local offset=clamp((self.x-self.paddle)/(self.width/2),-1,1)
  local angle=offset*1.02
  self.vx=self.speed*math.sin(angle);self.vy=self.speed*math.cos(angle)
  if math.abs(self.vx)<24 then self.vx=(offset<0 and -1 or 1)*24;self.vy=math.sqrt(self.speed^2-self.vx^2) end
  self.y=112+(112-self.y);self.bounces=self.bounces+1;self.combo=0;self:event('bounce',self.x,102)
 end
 for _,f in ipairs(self.food) do if f.alive and (self.x-f.x)^2+(self.y-f.y)^2<19^2 then
  f.alive=false;self.remaining=self.remaining-1;self.eaten=self.eaten+1;self.combo=self.combo+1
  local points=10*math.min(5,self.combo);self.score=self.score+points
  self.length=math.min(42,self.length+1);self:event('eat',f.x,f.y,points)
 end end
 table.insert(self.trail,1,{x=self.x,y=self.y})
 -- Save a fixed-distance path to keep body length stable when speed changes.
 local previous=self.trail[2]
 if previous and (self.x-previous.x)^2+(self.y-previous.y)^2<2.0^2 then table.remove(self.trail,1) end
 while #self.trail>self.length*9+20 do table.remove(self.trail) end
 if self.remaining==0 then self.food={};self.state='clear';self.score=self.score+100;self:event('clear');return end
 if not self.food[1].alive then self:spawnFood() end
 if self.y<65 then
  self.lives=self.lives-1;self:event('miss');self.length=math.max(9,self.length-4)
  if self.lives<=0 then self.state='over';self:event('over') else self:resetHead() end
 end
end
function M:update(dt)
 if self.state=='ready' then self.x=self.paddle;self.y=124;return end
 if self.state~='playing' then return end
 self.acc=self.acc+math.min(dt,0.1)
 while self.acc>=1/120 and self.state=='playing' do self.acc=self.acc-1/120;self:step(1/120) end
end
function M:body()
 local result={{x=self.x,y=self.y}};local wanted=9;local distance=0;local last={x=self.x,y=self.y}
 for _,p in ipairs(self.trail) do
  local dx,dy=p.x-last.x,p.y-last.y;local d=math.sqrt(dx*dx+dy*dy)
  while d>0 and distance+d>=wanted and #result<self.length do
   local t=(wanted-distance)/d;result[#result+1]={x=last.x+dx*t,y=last.y+dy*t};wanted=wanted+9
  end
  distance=distance+d;last=p;if #result>=self.length then break end
 end
 return result
end
return M
