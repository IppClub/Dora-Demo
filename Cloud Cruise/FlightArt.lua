local D=require('Dora');local V,C=D.Vec2,D.Color
local A={ink=0xff203f52,muted=0xff718f9d,orange=0xffe76f48}
function A.poly(d,points,c) local p={};for _,v in ipairs(points) do p[#p+1]=V(v[1],v[2]) end;d:drawPolygon(p,C(c)) end
function A.box(d,x,y,w,h,c) A.poly(d,{{x,y},{x+w,y},{x+w,y+h},{x,y+h}},c) end
function A.dot(d,x,y,r,c) d:drawDot(V(x,y),r,C(c)) end
function A.line(d,x,y,x2,y2,r,c) d:drawSegment(V(x,y),V(x2,y2),r,C(c)) end
function A.pill(d,x,y,w,h,c)
 local points={};local r=h/2
 for i=0,12 do local a=math.pi/2+i*math.pi/12;points[#points+1]={x+r+math.cos(a)*r,y+r+math.sin(a)*r} end
 for i=0,12 do local a=-math.pi/2+i*math.pi/12;points[#points+1]={x+w-r+math.cos(a)*r,y+r+math.sin(a)*r} end
 A.poly(d,points,c)
end
function A.cloud(d,x,y,s,alpha)
 local c=alpha or 0x66ffffff
 A.dot(d,x,y,17*s,c);A.dot(d,x+19*s,y+8*s,23*s,c);A.dot(d,x+45*s,y,17*s,c)
 A.box(d,x,y-16*s,45*s,23*s,c)
end
function A.sky(d,w,t,distance)
 -- Vertex colors produce a continuous sky gradient.
 local bottom,top=C(0xffffe6c3),C(0xff91c6d6)
 d:drawVertices({{V(0,0),bottom},{V(w,0),bottom},{V(w,640),top},{V(0,0),bottom},{V(w,640),top},{V(0,640),top}})
 A.dot(d,w*.78,461,49,0x18ffffff);A.dot(d,w*.78,461,34,0x42fff7da);A.dot(d,w*.78,461,23,0xfffff5d7)
 for i=0,7 do
  local x=((i*173-distance*.14)%(w+220))-110
  A.cloud(d,x,330+(i*61)%185,.65+(i%3)*.22,0xffd4e7e5)
 end
 local ridge={{0,0}};for x=-40,w+45,40 do ridge[#ridge+1]={x,116+math.sin((x+distance*.08)*.013)*22+math.sin(x*.033)*14} end;ridge[#ridge+1]={w,0};A.poly(d,ridge,0xffa8c3c1)
 local near={{0,0}};for x=-35,w+45,35 do near[#near+1]={x,67+math.sin((x+distance*.16)*.021)*15} end;near[#near+1]={w,0};A.poly(d,near,0xff779f9f)
 for i=0,4 do A.cloud(d,((i*210-distance*.3)%(w+240))-120,37+(i%2)*21,1.9,0xffd2e1d7) end
end
function A.gate(d,g,time)
 local x=g.x;local lo=g.center-g.gap/2;local hi=g.center+g.gap/2
 A.box(d,x-25,0,50,lo,0xff507b86);A.box(d,x-25,hi,50,554-hi,0xff507b86)
 A.box(d,x-18,0,8,lo,0xff69939c);A.box(d,x-18,hi,8,554-hi,0xff69939c)
 A.box(d,x+17,0,8,lo,0xff3f6671);A.box(d,x+17,hi,8,554-hi,0xff3f6671)
 for _,edge in ipairs({lo-9,hi}) do
  A.box(d,x-29,edge,58,9,0xfff2dcc0)
  for j=-2,2 do A.poly(d,{{x+j*12-5,edge},{x+j*12+1,edge},{x+j*12+7,edge+9},{x+j*12+1,edge+9}},0xffde8259) end
 end
 A.box(d,x-29,lo-13,58,4,0xff345b66);A.box(d,x-29,hi+9,58,4,0xff345b66)
 for y=20,540,30 do if y<lo-20 or y>hi+20 then A.line(d,x-9,y,x+10,y,1,0xff416977) end end
 -- Dashed beacon through the opening shows the safe flight corridor.
 for y=lo+18,hi-18,18 do A.line(d,x,y,x,y+5,.8,0x44ffffff) end
 -- Small paired chevrons reveal the direction of the moving opening.
 local dir=(g.vy or 1)>=0 and 1 or -1
 for _,offset in ipairs({-7,7}) do
  local cy=g.center+offset
  A.line(d,x-5,cy-dir*3,x,cy+dir*2,1.1,0xaafff4d8)
  A.line(d,x,cy+dir*2,x+5,cy-dir*3,1.1,0xaafff4d8)
 end
 local pulse=.5+.5*math.sin(time*3)
 A.dot(d,x,lo+4,4+pulse*2,0x33ffe4a8);A.dot(d,x,lo+4,2.4,0xffffcc7a)
 A.dot(d,x,hi-4,4+pulse*2,0x33ffe4a8);A.dot(d,x,hi-4,2.4,0xffffcc7a)
end
function A.plane(d,x,y,angle,time,scale)
 scale=scale or 1;local a=angle*math.pi/180;local co,si=math.cos(a),math.sin(a)
 local function point(px,py) return {x+(px*co-py*si)*scale,y+(px*si+py*co)*scale} end
 local function shape(pts,c) local t={};for _,p in ipairs(pts) do t[#t+1]=point(p[1],p[2]) end;A.poly(d,t,c) end
 local function dot(px,py,r,c) local p=point(px,py);A.dot(d,p[1],p[2],r*scale,c) end
 -- Wing silhouette, fuselage, cockpit and striped tail; all rotate together.
 shape({{-11,3},{-21,21},{-11,21},{8,4}},0xffcf6346)
 shape({{-13,4},{-32,13},{-33,5},{-26,-2}},0xffe66d47)
 shape({{-31,2},{-16,8},{13,7},{26,1},{21,-5},{-18,-6}},0xff365c6b)
 shape({{-32,4},{-14,11},{12,10},{26,4},{21,-2},{-18,-3}},0xfffff6df)
 shape({{-10,1},{-21,-21},{-9,-21},{12,1}},0xffee8051)
 shape({{-18,-17},{-11,-17},{-10,-20},{-20,-20}},0xfffff6df)
 shape({{-1,10},{4,16},{13,14},{16,9}},0xff365e70)
 shape({{4,13},{7,15},{12,13},{13,11}},0xff9ed9e2)
 shape({{-25,6},{-31,15},{-25,15},{-18,8}},0xffe77b53)
 dot(22,4,3.2,0xffed8051)
 local h=10+math.sin(time*65)*6;local p=point(27,-h);local q=point(27,h)
 A.line(d,p[1],p[2],q[1],q[2],1.6*scale,0xff436779)
 dot(27,3,2,0xffffe3b8)
end
return A
