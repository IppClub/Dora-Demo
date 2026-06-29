-- [yue]: Dora-Demo/Loli War/Bullet.yue
local _ENV = Dora(Dora.Platformer) -- 9
local Data <const> = Data -- 10
local BulletDef <const> = BulletDef -- 10
local Vec2 <const> = Vec2 -- 10
local Face <const> = Face -- 10
local Store = Data.store -- 12
do -- 14
	local _with_0 = BulletDef() -- 14
	_with_0.tag = "" -- 15
	_with_0.endEffect = "" -- 16
	_with_0.lifeTime = 1 -- 17
	_with_0.damageRadius = 0 -- 18
	_with_0.highSpeedFix = false -- 19
	_with_0.gravity = Vec2(0, -10) -- 20
	_with_0.face = Face("Model/misc.clip|arrow", Vec2(-20, 0), 2) -- 21
	_with_0:setAsCircle(10) -- 22
	_with_0:setVelocity(15, 1200) -- 23
	Store["Arrow"] = _with_0 -- 14
end -- 14
local _with_0 = BulletDef() -- 25
_with_0.tag = "" -- 26
_with_0.endEffect = "" -- 27
_with_0.lifeTime = 3.0 -- 28
_with_0.damageRadius = 0 -- 29
_with_0.highSpeedFix = false -- 30
_with_0.gravity = Vec2(0, 4) -- 31
_with_0.face = Face("Model/misc.clip|heartbullet", Vec2.zero, 2) -- 32
_with_0:setAsCircle(15) -- 33
_with_0:setVelocity(0, 400) -- 34
Store["Bubble"] = _with_0 -- 25
