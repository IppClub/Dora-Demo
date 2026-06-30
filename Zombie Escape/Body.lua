-- [yue]: Body.yue
local _ENV = Dora(Dora.Platformer) -- 9
local Data <const> = Data -- 10
local BodyDef <const> = BodyDef -- 10
local Vec2 <const> = Vec2 -- 10
local Store = Data.store -- 12
do -- 14
	local _with_0 = BodyDef() -- 14
	_with_0.type = "Static" -- 15
	_with_0:attachPolygon(100, 60, 1, 1, 0) -- 16
	Store["Body_ObstacleS"] = _with_0 -- 14
end -- 14
do -- 18
	local _with_0 = BodyDef() -- 18
	_with_0.type = "Static" -- 19
	_with_0:attachPolygon(260, 60, 1, 1, 0) -- 20
	Store["Body_ObstacleM"] = _with_0 -- 18
end -- 18
local _with_0 = BodyDef() -- 22
_with_0.type = "Dynamic" -- 23
_with_0.linearAcceleration = Vec2(0, -10) -- 24
_with_0:attachDisk(40, 1, 0.6, 0.4) -- 25
Store["Body_ObstacleC"] = _with_0 -- 22
