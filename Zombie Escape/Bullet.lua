-- [yue]: Dora-Demo/Zombie Escape/Bullet.yue
local _ENV = Dora(Dora.Platformer) -- 9
local Rectangle = require("UI.View.Shape.Rectangle") -- 10
local Star = require("UI.View.Shape.Star") -- 11
local Data <const> = Data -- 12
local BulletDef <const> = BulletDef -- 12
local Vec2 <const> = Vec2 -- 12
local Face <const> = Face -- 12
local Store = Data.store -- 14
do -- 16
	local _with_0 = BulletDef() -- 16
	_with_0.tag = "" -- 17
	_with_0.endEffect = "" -- 18
	_with_0.lifeTime = 1 -- 19
	_with_0.damageRadius = 0 -- 20
	_with_0.highSpeedFix = false -- 21
	_with_0.gravity = Vec2.zero -- 22
	_with_0.face = Face(function() -- 23
		return Rectangle({ -- 24
			width = 6, -- 24
			height = 6, -- 25
			borderColor = 0xffff0088, -- 26
			fillColor = 0x66ff0088, -- 27
			fillOrder = 1, -- 28
			lineOrder = 2 -- 29
		}) -- 23
	end) -- 23
	_with_0:setAsCircle(6) -- 31
	_with_0:setVelocity(0, 600) -- 32
	Store["Bullet_KidM"] = _with_0 -- 16
end -- 16
local _with_0 = BulletDef() -- 34
_with_0.tag = "" -- 35
_with_0.endEffect = "" -- 36
_with_0.lifeTime = 5 -- 37
_with_0.damageRadius = 0 -- 38
_with_0.highSpeedFix = false -- 39
_with_0.gravity = Vec2(0, -10) -- 40
_with_0.face = Face(function() -- 41
	return Star({ -- 42
		size = 15, -- 42
		borderColor = 0xffff0088, -- 43
		fillColor = 0x66ff0088, -- 44
		fillOrder = 1, -- 45
		lineOrder = 2 -- 46
	}) -- 41
end) -- 41
_with_0:setAsCircle(10) -- 48
_with_0:setVelocity(60, 600) -- 49
Store["Bullet_KidW"] = _with_0 -- 34
