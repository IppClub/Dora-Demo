local M = require('SnakeModel')
local n=0
local function check(v,name) assert(v,name);n=n+1 end
local function active() local m=M.new(function() return .63 end);m:launch();return m end
local initial=M.new();check(#initial.food==1,'exactly one initial food')
local positions={}
for i=1,100 do
 initial:spawnFood();check(#initial.food==1 and initial.food[1].alive,'one food after spawn')
 local f=initial.food[1];check(f.x>=50 and f.x<=310 and f.y>=185 and f.y<=450,'food inside safe play area')
 for _,p in ipairs(initial:body()) do check((f.x-p.x)^2+(f.y-p.y)^2>=32^2,'food avoids snake') end
 positions[math.floor(f.x)..','..math.floor(f.y)]=true
end
local unique=0;for _ in pairs(positions) do unique=unique+1 end;check(unique>20,'food positions vary')
local m=active();m.x=32;m.vx=-100;m.vy=200;m:update(0.1);check(m.vx>0 and m.x>=30,'left wall')
m=active();m.x=328;m.vx=100;m.vy=200;m:update(0.1);check(m.vx<0 and m.x<=330,'right wall')
m=active();m.y=478;m.vx=80;m.vy=200;m:update(0.1);check(m.vy<0,'top wall')
m=active();m.x=m.paddle;m.y=118;m.vx=0;m.vy=-230;m:update(0.1);check(m.vy>0,'paddle catches');check(m.bounces==1,'one bounce event')
m=active();m.x=m.paddle+32;m.y=118;m.vx=0;m.vy=-230;m:update(0.1);check(m.vx>0 and m.vy>0,'right edge aims right')
m=active();m.x=m.paddle-32;m.y=118;m.vx=0;m.vy=-230;m:update(0.1);check(m.vx<0 and m.vy>0,'left edge aims left')
m=active();m.x=40;m.y=118;m.vx=0;m.vy=-230;for i=1,3 do m:update(0.1) end;check(m.lives==2 and m.state=='ready','miss costs exactly one life')
m=active();m.lives=1;m.x=40;m.y=50;m.vy=-230;m:update(0.1);check(m.state=='over' and m.lives==0,'game over')
m=active();local f=m.food[1];m.x=f.x;m.y=f.y-12;m.vx=0;m.vy=230;local len=m.length;m:update(0.08);check(m.score>0 and not f.alive,'eat');check(m.length>len,'grow');check(m.vy>0,'food does not reflect');check(#m.food==1 and m.food[1]~=f and m.food[1].alive,'eating replaces food');check((m.food[1].x-f.x)^2+(m.food[1].y-f.y)^2>=48^2,'new food away from previous location')
m=active();for i=2,#m.food do m.food[i].alive=false end;m.remaining=1;f=m.food[1];m.x=f.x;m.y=f.y-12;m.vx=0;m.vy=230;m:update(0.08);check(m.state=='clear','clear level');m:nextLevel();check(m.level==2 and m.remaining>0 and m.state=='ready','next level')
m=active();local x,y=m.x,m.y;m:pause();m:update(0.5);check(m.x==x and m.y==y and m.state=='paused','pause');m:pause();check(m.state=='playing','resume')
m=M.new();m:setPaddle(-500);check(m.paddle>=66,'left clamp');m:setPaddle(999);check(m.paddle<=294,'right clamp');check(m.x==m.paddle,'ready head follows paddle');m:launch();check(m.state=='playing','launch')
local a,b=active(),active();for i=1,120 do a:update(1/120) end;for i=1,60 do b:update(1/60) end;check(math.abs(a.x-b.x)<0.01 and math.abs(a.y-b.y)<0.01,'frame independent')
m=active();for i=1,100 do m.level=i;m:makeLevel();check(m.speed<=340,'speed cap') end
for _,edge in ipairs({-49,49}) do m=active();m.x=m.paddle+edge;m.y=113;m.vx=0;m.vy=-340;m:update(1/60);check(m.vy>0,'paddle radius edge');check(m.vy>=m.speed*.5,'minimum vertical speed') end
m=active();for i=1,30 do m:update(1/120) end;local body=m:body();check(#body==m.length,'full body length');for _,p in ipairs(body) do check(p.x==p.x and p.y==p.y,'finite trail') end
m=M.new();m:pause();check(m.state=='paused','pause ready');m:pause();check(m.state=='ready','resume ready')
print('SNAKE_TESTS_PASS '..n)
return n
