local a={}a.none=function()local b={camera=nil}function b:setCamera(c)end;function b:update(d,e)end;return b end;a.keyboard=function(f,g,h)local f=f or 5;local g=g or 180;local i=not h or not h.disableFlight;local b={}function b:setCamera(c)b.camera=c end;local j=math.sin;local k=math.cos;local l=math.min;local m=math.max;local n=math.rad;function b:update(d,e)local o,p,q=0,0,0;local c=self.camera;if not c then return end;if e.isDown[keys.left]then c.rotY=(c.rotY-g*d)%360 end;if e.isDown[keys.right]then c.rotY=(c.rotY+g*d)%360 end;if e.isDown[keys.down]then c.rotZ=m(-80,c.rotZ-g*d)end;if e.isDown[keys.up]then c.rotZ=l(80,c.rotZ+g*d)end;if e.isDown[keys.w]then o=f*k(n(c.rotY))+o;q=f*j(n(c.rotY))+q end;if e.isDown[keys.s]then o=-f*k(n(c.rotY))+o;q=-f*j(n(c.rotY))+q end;if e.isDown[keys.a]then o=f*k(n(c.rotY-90))+o;q=f*j(n(c.rotY-90))+q end;if e.isDown[keys.d]then o=f*k(n(c.rotY+90))+o;q=f*j(n(c.rotY+90))+q end;if i then if e.isDown[keys.space]then p=f+p end;if e.isDown[keys.leftShift]then p=-f+p end end;c.x=c.x+o*d;c.y=c.y+p*d;c.z=c.z+q*d end;return b end;a.follow=function(r)local b={}function b:setCamera(c)b.camera=c end;local s=(r or{}).offsetVertical or 2;local t=(r or{}).offsetHorizontal or-3;local u=(r or{}).downAngle or-20;local v=(r or{}).smoothing or 0.01;local w;function b:setTarget(x)w=x end;function b:update(d,e)local c=self.camera;if not c then return end;local y=w.x;local z=w.y+s;local A=w.z;local B=(w.rotY or 0)+math.pi*0.5;y=y+math.sin(B)*t;A=A+math.cos(B)*t;local C=math.pow(v,d)local D=c.x*C+y*(1-C)local E=c.y*C+z*(1-C)local F=c.z*C+A*(1-C)local G=-math.deg(B-math.pi*0.5)local H=c.rotY*C+G*(1-C)c:setPos(D,E,F,nil,H,u)end;return b end;return a