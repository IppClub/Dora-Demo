-- Resolution-independent fruit illustrations and soft UI geometry.
local D=require('Dora')
local V,C=D.Vec2,D.Color
local M={}
local function ellipse(n,x,y,rx,ry,color,angle)
 local points={};angle=angle or 0
 local ca,sa=math.cos(angle),math.sin(angle)
 for i=0,47 do local a=i*math.pi/24;local u,v=math.cos(a)*rx,math.sin(a)*ry;points[#points+1]=V(x+u*ca-v*sa,y+u*sa+v*ca) end
 n:drawPolygon(points,color)
end
function M.roundedRect(n,x,y,w,h,r,color)
 local pts={};r=math.min(r,w/2,h/2)
 for _,p in ipairs({{x+w/2-r,y+h/2-r,0},{x-w/2+r,y+h/2-r,90},{x-w/2+r,y-h/2+r,180},{x+w/2-r,y-h/2+r,270}}) do
  for j=0,8 do local a=(p[3]+j*90/8)*math.pi/180;pts[#pts+1]=V(p[1]+math.cos(a)*r,p[2]+math.sin(a)*r) end
 end
 n:drawPolygon(pts,color)
end
local green=C(87,147,89,255)
local deepGreen=C(54,110,67,255)
local stemColor=C(105,115,58,255)
local cream=C(255,251,209,255)
local function leaf(n,x,y,r,angle)
 ellipse(n,x,y,r*.46,r*.19,green,angle or .35)
 n:drawSegment(V(x-r*.25,y-r*.10),V(x+r*.26,y+r*.10),r*.015,deepGreen)
end
local function shine(n,x,y,r)
 ellipse(n,x,y,r*.12,r*.23,C(255,255,255,118),-.4)
end
local function ovalFruit(n,x,y,rx,ry,body,shade)
 ellipse(n,x,y-.07*ry,rx,ry,shade)
 ellipse(n,x-.04*rx,y+.055*ry,rx*.94,ry*.91,body)
 shine(n,x-rx*.36,y+ry*.3,math.min(rx,ry))
end
function M.drawFruit(n,tier,r)
 n:clear()
 -- Lift each occupied cell off the soft recessed board.
 local h=r/0.29
 M.roundedRect(n,0,-h*.10-1,h*.86,h*.86,10,C(179,200,173,115))
 M.roundedRect(n,0,-h*.10,h*.86,h*.86,10,C(255,253,245,255))
 ellipse(n,0,-r*.76,r*.77,r*.14,C(64,100,66,23))
 if tier==0 then
  n:drawSegment(V(-r*.40,0),V(r*.02,r*.95),r*.048,stemColor)
  n:drawSegment(V(r*.39,-r*.08),V(r*.02,r*.95),r*.048,stemColor)
  leaf(n,r*.23,r*.91,r,.18)
  ovalFruit(n,-r*.36,-r*.17,r*.48,r*.49,C(233,87,94,255),C(193,56,69,255))
  ovalFruit(n,r*.36,-r*.23,r*.47,r*.48,C(218,62,81,255),C(177,49,66,255))
 elseif tier==1 then
  local points={}
  for i=0,47 do local a=i*math.pi/24;local x=math.cos(a)*(.75+.24*math.sin(a));points[#points+1]=V(r*x,r*math.sin(a)*.9) end
  n:drawPolygon(points,C(236,101,112,255))
  ellipse(n,-r*.28,r*.28,r*.14,r*.26,C(255,174,170,125),-.4)
  for row=0,2 do for col=0,2 do local x=(col-1)*r*.38;local y=(row-1)*r*.4;if not(row==0 and col==0)then ellipse(n,x,y,r*.038,r*.065,cream,.25)end end end
  for i=-2,2 do leaf(n,i*r*.18,r*.75,r*.65,i*.5) end
 elseif tier==2 then
  n:drawSegment(V(0,r*.65),V(r*.06,r*1.05),r*.055,stemColor)
  leaf(n,r*.30,r*.84,r,.4)
  for _,p in ipairs({{-.34,.42},{.34,.42},{-.57,0},{0,0},{.57,0},{-.29,-.4},{.29,-.4},{0,-.72}}) do
   ovalFruit(n,p[1]*r,p[2]*r,r*.32,r*.33,C(150,124,187,255),C(123,98,159,255))
  end
 elseif tier==3 then
  ovalFruit(n,0,0,r*.94,r*.65,C(246,218,98,255),C(224,190,69,255))
  ellipse(n,-r*.87,0,r*.16,r*.12,C(241,210,89,255))
  ellipse(n,r*.87,0,r*.16,r*.12,C(241,210,89,255))
  leaf(n,r*.36,r*.72,r,.4)
 elseif tier==4 then
  ovalFruit(n,0,0,r*.80,r*.78,C(246,170,91,255),C(222,137,57,255))
  leaf(n,r*.29,r*.76,r,.35)
  for i=0,6 do local a=i*.85;ellipse(n,math.cos(a)*r*.5,math.sin(a)*r*.45,r*.025,r*.025,C(231,142,58,190))end
 elseif tier==5 then
  ovalFruit(n,-r*.28,0,r*.56,r*.75,C(224,98,106,255),C(197,77,83,255))
  ovalFruit(n,r*.27,0,r*.55,r*.74,C(231,111,116,255),C(197,77,83,255))
  n:drawSegment(V(0,r*.5),V(r*.09,r*.94),r*.07,stemColor);leaf(n,r*.38,r*.80,r,.38)
 elseif tier==6 then
  ovalFruit(n,-r*.23,0,r*.62,r*.71,C(247,176,160,255),C(228,143,132,255))
  ovalFruit(n,r*.21,.02*r,r*.60,r*.71,C(250,189,169,255),C(228,143,132,255))
  n:drawSegment(V(r*.05,r*.36),V(-r*.1,-r*.45),r*.025,C(218,133,128,150));leaf(n,r*.28,r*.75,r,.25)
 elseif tier==7 then
  ovalFruit(n,0,-r*.12,r*.63,r*.77,C(240,202,105,255),C(213,173,77,255))
  for row=-1,1 do for col=-1,1 do local x=col*r*.31;local y=row*r*.32-r*.1;n:drawSegment(V(x-r*.08,y),V(x+r*.08,y+r*.12),r*.024,C(195,158,68,190))end end
  for i=-2,2 do n:drawPolygon({V(i*r*.08,r*.42),V(i*r*.26,r*(1.05-math.abs(i)*.12)),V(i*r*.16+r*.13,r*.50)},i%2==0 and green or deepGreen)end
 elseif tier==8 then
  ovalFruit(n,0,0,r*.82,r*.76,C(188,209,132,255),C(150,179,102,255))
  for i=-2,2 do ellipse(n,i*r*.25,0,r*.022,r*.59,C(234,241,194,180),i*.1)end
  n:drawSegment(V(0,r*.7),V(r*.16,r*.97),r*.05,stemColor)
 elseif tier==9 then
  local pts={}
  for i=0,32 do local a=math.pi+i*math.pi/32;pts[#pts+1]=V(math.cos(a)*r*.96,math.sin(a)*r*.96+r*.45)end
  n:drawPolygon(pts,deepGreen)
  local inner={}
  for i=0,32 do local a=math.pi+i*math.pi/32;inner[#inner+1]=V(math.cos(a)*r*.82,math.sin(a)*r*.82+r*.44)end
  n:drawPolygon(inner,C(241,130,135,255))
  for i=-1,1 do ellipse(n,i*r*.35,0,r*.038,r*.075,C(91,70,62,255),i*.25)end
 else
  ovalFruit(n,0,0,r*.82,r*.91,C(190,194,103,255),C(147,158,70,255))
  for row=-2,2 do for col=-2,2 do local x=col*r*.27;local y=row*r*.28;if x*x+y*y<r*r*.55 then n:drawPolygon({V(x-r*.11,y-r*.07),V(x,y+r*.15),V(x+r*.11,y-r*.07)},C(144,163,72,255))end end end
  n:drawSegment(V(0,r*.83),V(r*.1,r*1.12),r*.07,stemColor)
 end
end
return M
