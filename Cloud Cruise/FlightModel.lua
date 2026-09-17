-- Inertial altitude-hold flight. No gravity and no impulse tapping.
local M={};M.__index=M
local function clamp(x,a,b) return math.max(a,math.min(b,x)) end
-- Difficulty grows gently with successful passes, then stops escalating.
function M.difficulty(score)
 local t=clamp(score/30,0,1)
 return {speed=165+60*t,gap=124-32*t,amplitude=60+24*t,omega=.85+.35*t,spacing=320,
  stage=score<5 and '初入云层' or (score<15 and '穿云进阶' or (score<30 and '疾风航道' or '王牌巡航'))}
end
function M.new(width,random)
 local self=setmetatable({width=width or 360,random=random or math.random,state='menu',gates={},events={},score=0,
  y=320,vy=0,target=320,input=0,speed=165,distance=0,acc=0,spawningEnabled=true,time=0,bank=0,lastCenter=320},M)
 self.x=math.min(185,self.width*.28);return self
end
function M:spawnGate(spawnX)
 local d=M.difficulty(self.score);local gap=d.gap
 -- Every gate has its own phase and frequency, while altitude bands alternate.
 if self.nextHigh==nil then self.nextHigh=self.random()>=.5 end
 local center=(self.nextHigh and 390 or 242)+(self.random()-.5)*8
 self.nextHigh=not self.nextHigh
 self.lastCenter=center
 local phase=self.random()*math.pi*2;local omega=d.omega*(.9+.2*self.random())
 local previous=self.gates[#self.gates]
 if previous and previous.phase then
  local difference=math.abs((phase-previous.phase+math.pi)%(2*math.pi)-math.pi)
  if difference<.6 then phase=phase+1.2 end
  if math.abs(omega-previous.omega)<.035 then omega=d.omega*(previous.omega>=d.omega and .9 or 1.1) end
 end
 if previous and previous.phase and spawnX then
  -- Check the transfer at the exit of the preceding gate and the entrance of
  -- this one. Reject extreme opposing sweeps without widening the spacing.
  local exitTime=math.max(0,(previous.x-self.x+47)/self.speed)
  local enterTime=math.max(0,(spawnX-self.x-47)/self.speed)
  local from=previous.base+math.sin(previous.phase+previous.omega*exitTime)*previous.amplitude
  local limit=425-self.speed
  local function reachable(p) return math.abs(center+math.sin(p+omega*enterTime)*d.amplitude-from)<=limit end
  for i=1,24 do if reachable(phase) then break end;phase=self.random()*math.pi*2 end
  if not reachable(phase) then phase=math.asin(clamp((from-center)/d.amplitude,-1,1))-omega*enterTime end
 end
 self.gates[#self.gates+1]={x=spawnX or self.width+60,center=center+math.sin(phase)*d.amplitude,base=center,
  phase=phase,omega=omega,amplitude=d.amplitude,vy=math.cos(phase)*d.amplitude*omega,gap=gap,scored=false}
end
function M:start()
 self.state='playing';self.score=0;self.y=320;self.vy=0;self.target=320;self.input=0;self.speed=165
 self.distance=0;self.time=0;self.acc=0;self.spawningEnabled=true;self.lastCenter=320;self.nextHigh=nil;self.gates={};self.events={};self:spawnGate()
end
function M:setTarget(y) self.target=clamp(y,96,532) end
function M:release() self.input=0;self.target=clamp(self.y+self.vy*.13,96,532) end
function M:axis(value) if value==0 and self.input~=0 then self:release() else self.input=value end end
function M:pause()
 if self.state=='playing' then self:release();self.state='paused'
 elseif self.state=='paused' then self.state='playing' end
end
function M:resize(width)
 local old=self.x;self.width=width;self.x=math.min(185,self.width*.28)
 for _,g in ipairs(self.gates) do g.x=g.x+self.x-old end
end
function M:crash()
 if self.state=='playing' then self.state='over';self.events[#self.events+1]={kind='crash',x=self.x,y=self.y} end
end
function M:step(dt)
 self.time=self.time+dt;local difficulty=M.difficulty(self.score);self.speed=difficulty.speed
 if self.input~=0 then self:setTarget(self.target+self.input*330*dt) end
 local acceleration=clamp((self.target-self.y)*65-self.vy*14,-1800,1800)
 self.vy=clamp(self.vy+acceleration*dt,-330,330);self.y=self.y+self.vy*dt
 if self.y<96 then self.y=96;self.vy=math.max(0,self.vy) elseif self.y>532 then self.y=532;self.vy=math.min(0,self.vy) end
 self.bank=self.vy*.08;self.distance=self.distance+self.speed*dt
 -- Prepare the next gate before the current one passes, preserving physical
 -- spacing on narrow screens as well as wide screens.
 local last=self.gates[#self.gates]
 if self.spawningEnabled and (not last or last.x<=self.width+60) then
  self:spawnGate(last and last.x+difficulty.spacing or nil)
 end
 for i=#self.gates,1,-1 do
  local g=self.gates[i];g.x=g.x-self.speed*dt
  if g.base then
   g.phase=g.phase+g.omega*dt
   g.center=g.base+math.sin(g.phase)*g.amplitude
   g.vy=math.cos(g.phase)*g.amplitude*g.omega
  end
  local overlaps=math.abs(g.x-self.x)<47
  if overlaps and (self.y-9<g.center-g.gap/2 or self.y+9>g.center+g.gap/2) then self:crash();return end
  if not g.scored and g.x+29<self.x-18 then
   g.scored=true;self.score=self.score+1;self.events[#self.events+1]={kind='pass',x=self.x,y=self.y}
  end
  if g.x< -65 then table.remove(self.gates,i) end
 end
end
function M:update(dt)
 if self.state~='playing' then return end
 self.acc=self.acc+math.min(dt,.1)
 while self.acc>=1/120 and self.state=='playing' do self.acc=self.acc-1/120;self:step(1/120) end
end
return M
