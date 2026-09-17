local M=require('FlightModel');local count=0
local function ok(v,s) assert(v,s);count=count+1 end
local function new() local m=M.new(360,function() return .5 end);m:start();return m end
local function run(m,t) for i=1,math.floor(t*120) do m:update(1/120) end end
local m=new();m.gates={};m.spawningEnabled=false;run(m,4);ok(math.abs(m.y-320)<.01,'no gravity without input');ok(math.abs(m.vy)<.01,'idle stable')
m=new();m.gates={};m.spawningEnabled=false;m:setTarget(430);run(m,1);ok(m.y>410,'climb');m:release();run(m,2);local y=m.y;run(m,1);ok(math.abs(m.y-y)<.15,'release stabilizes');ok(math.abs(m.vy)<.2,'no perpetual drift')
m:setTarget(210);run(m,1.5);ok(m.y<230,'descent');m:setTarget(-999);run(m,3);ok(m.y>=96,'lower flight limit');m:setTarget(999);run(m,3);ok(m.y<=532,'upper flight limit')
m=new();m:axis(1);run(m,.6);ok(m.y>360,'keyboard climb');m:axis(0);run(m,2);y=m.y;run(m,.3);ok(math.abs(m.y-y)<.2,'keyboard release')
m=new();m:pause();y=m.y;local x=m.gates[1].x;run(m,1);ok(m.y==y and m.gates[1].x==x,'pause freezes');m:pause();ok(m.state=='playing','resume')
m=new();m.gates={{x=m.x,center=m.y+160,gap=160,scored=false}};m:update(1/60);ok(m.state=='over','hit obstacle')
m=new();m.gates={{x=m.x,center=m.y,gap=160,scored=false}};m:update(1/60);ok(m.state=='playing','safe gap')
m=new();m.gates={{x=m.x-50,center=m.y,gap=160,scored=false}};m:update(1/60);ok(m.score==1,'score once');run(m,.2);ok(m.score==1,'no repeat score')
local a,b=new(),new();a.gates={};b.gates={};a.spawningEnabled=false;b.spawningEnabled=false;a:setTarget(400);b:setTarget(400);for i=1,120 do a:update(1/120) end;for i=1,60 do b:update(1/60) end;ok(math.abs(a.y-b.y)<.01,'frame rate independent')
m=new();m.score=9999;run(m,.1);ok(m.speed<=225,'speed capped');m:spawnGate();ok(m.gates[#m.gates].gap>=92,'gap remains playable')
m=new();local old=m.gates[1].x-m.x;m:resize(900);ok(math.abs(m.gates[1].x-m.x-old)<.1,'resize keeps time to next gate');ok(m.width==900,'desktop width')
m=new();m.gates={};m.spawningEnabled=false;m:setTarget(500);for i=1,240 do local v=m.vy;m:update(1/120);ok(math.abs(m.vy)<=330.01,'vertical speed capped');ok(math.abs(m.vy-v)<=1800/120+.001,'acceleration capped') end
m=new();local gate=m.gates[1];local cy=gate.center;run(m,.5);ok(math.abs(gate.center-cy)>1,'opening moves vertically from first gate')
m:pause();cy=gate.center;run(m,1);ok(gate.center==cy,'pause freezes moving opening')
local previous=M.difficulty(0)
for score=1,80 do
 local d=M.difficulty(score)
 ok(d.speed>=previous.speed and d.speed<=225,'progressive capped forward speed')
 ok(d.amplitude>=previous.amplitude and d.amplitude<=84,'progressive capped movement')
 ok(d.gap<=previous.gap and d.gap>=92,'progressive safe opening')
 ok(d.amplitude*d.omega<=100.81,'obstacles slower than plane')
 ok(d.omega>=previous.omega and d.omega<=1.2,'progressive capped oscillation frequency')
 ok(d.spacing==320,'dense gate spacing stays capped at every stage')
 previous=d
end
-- Exercise varied phases and adjacent moving gates through all four stages.
for seed=1,128 do
 local r=seed
 local function random() r=(r*48271)%2147483647;return r/2147483647 end
 local sim=M.new(seed%2==0 and 360 or 910,random);sim:start()
 if seed>96 then sim.score=30;sim.gates={};sim:spawnGate() end
 local elapsed=0
 while sim.state=='playing' and sim.score<60 and elapsed<180 do
  local nearest=nil
  for _,g in ipairs(sim.gates) do
   if g.x>sim.x-48 and (not nearest or g.x<nearest.x) then nearest=g end
   assert(g.center-g.gap/2>=99.9 and g.center+g.gap/2<=532.1,'opening within flight lane')
  end
  if nearest and math.floor(elapsed*120)%12==0 then
   -- Outside the viewport, only anticipate the alternating altitude band;
   -- do not use the hidden gate's current oscillation position.
   local target=nearest.center+(nearest.vy or 0)*.22
   if nearest.x>sim.width+29 then target=sim.score==0 and 320 or (nearest.base>320 and 390 or 242) end
   sim:setTarget(target)
  end
  sim:update(1/120);elapsed=elapsed+1/120
 end
 local context='';for _,g in ipairs(sim.gates) do if math.abs(g.x-sim.x)<50 then context=string.format(' y=%.1f target=%.1f vy=%.1f gate=%.1f gap=%.1f',sim.y,sim.target,sim.vy,g.center,g.gap) end end
 ok(sim.score>=60,'all stages reachable, seed '..seed..', score '..sim.score..context)
end
local sweep=new();sweep.score=30;sweep.gates={};sweep.spawningEnabled=false;sweep:spawnGate(10000)
local minY,maxY=999,-999
for i=1,840 do sweep:update(1/120);local cy=sweep.gates[1].center;minY=math.min(minY,cy);maxY=math.max(maxY,cy) end
ok(maxY-minY>167,'full wide obstacle sweep is observable')
-- Check the generation constraint independently of the steering controller.
m=M.new(360);m:start();m.score=30
for i=1,300 do
 local previous=m.gates[#m.gates];m:spawnGate();local g=m.gates[#m.gates]
 local separation=math.abs(previous.base-g.base)
 ok(separation>=140 and separation<=156,'adjacent altitude bands are separated')
 ok(math.abs(previous.omega-g.omega)>=.035,'adjacent gates have different oscillation frequencies')
end
for seed=1,32 do
 local r=seed;local idle=M.new(360,function()r=(r*48271)%2147483647;return r/2147483647 end);idle:start();run(idle,30)
 ok(idle.state=='over','independent motion has no permanently safe idle lane')
end
local independent=new();independent.score=30;independent.gates={};independent.spawningEnabled=false
independent:spawnGate(10000);independent:spawnGate(10320)
local opposing=0;local a,b=independent.gates[1],independent.gates[2]
for i=1,960 do independent:update(1/120);if a.vy*b.vy<0 then opposing=opposing+1 end end
ok(opposing>120,'neighboring gates visibly move in opposing directions')
independent:pause();local ay,by=a.center,b.center;run(independent,1)
ok(a.center==ay and b.center==by,'pause freezes each independent motion')
print('FLIGHT_TESTS_PASS '..count)
return count
