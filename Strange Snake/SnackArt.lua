local D=require('Dora');local V,C=D.Vec2,D.Color
local A={}
A.colors={ink=0xffe6f5ff,muted=0xff7894b3,cream=0xff080d19,paper=0xff0c1527,green=0xff34d9f7,mint=0xff193c56,orange=0xffff7956,line=0xff223954}
function A.dot(d,x,y,r,c) d:drawDot(V(x,y),r,C(c)) end
function A.line(d,x,y,x2,y2,r,c) d:drawSegment(V(x,y),V(x2,y2),r,C(c)) end
function A.box(d,x,y,w,h,r,c)
 d:drawPolygon({V(x+r,y),V(x+w-r,y),V(x+w-r,y+h),V(x+r,y+h)},C(c))
 d:drawPolygon({V(x,y+r),V(x+w,y+r),V(x+w,y+h-r),V(x,y+h-r)},C(c))
 for _,p in ipairs({{x+r,y+r},{x+w-r,y+r},{x+r,y+h-r},{x+w-r,y+h-r}}) do A.dot(d,p[1],p[2],r,c) end
end
function A.fruit(d,x,y,kind,s)
 s=s or 1
 A.dot(d,x,y,24*s,0x08ff7956);A.dot(d,x,y,18*s,0x18ff7956)
 local outer={V(x,y+12*s),V(x+12*s,y),V(x,y-12*s),V(x-12*s,y)}
 d:drawPolygon(outer,C(0xffff7956),1,C(0xffffbea0))
 d:drawPolygon({V(x,y+7*s),V(x+7*s,y),V(x,y-7*s),V(x-7*s,y)},C(0xffffd5b0))
 A.line(d,x-20*s,y,x-16*s,y,.8,0xff855141);A.line(d,x+16*s,y,x+20*s,y,.8,0xff855141)
 A.line(d,x,y-20*s,x,y-16*s,.8,0xff855141);A.line(d,x,y+16*s,x,y+20*s,.8,0xff855141)
end
function A.head(d,x,y,angle,r)
 A.dot(d,x,y,r+7,0x1034d9f7);A.dot(d,x,y,r+3,0x2434d9f7);A.dot(d,x,y,r,0xff62e6ff)
 local vx,vy=math.cos(angle),math.sin(angle);local px,py=-vy,vx
 for _,side in ipairs({-1,1}) do
  local ex,ey=x+vx*4+px*side*4.5,y+vy*4+py*side*4.5
  A.dot(d,ex,ey,3.1,0xff081524);A.dot(d,ex+vx*1,ey+vy*1,1.2,0xffe8fcff)
 end
 A.line(d,x-vx*5+px*3,y-vy*5+py*3,x-vx*5-px*3,y-vy*5-py*3,.8,0xff268fbd)
end
function A.snake(d,points,angle,time)
 for i=#points,2,-1 do
  local p=points[i];local r=math.max(3,8.5-(i/#points)*3)
  if p.y>=93 then
   A.dot(d,p.x,p.y,r+4,0x1034d9f7)
   A.dot(d,p.x,p.y,r,i%3==0 and 0xff3789b7 or 0xff26b7d5)
   if i%3==0 then A.dot(d,p.x-1,p.y+2,1.4,0xffa5f1ff) end
  end
 end
 if points[1].y>=93 then A.head(d,points[1].x,points[1].y,angle,10.5) end
end
return A
