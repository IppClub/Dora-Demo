-- [yue]: Dora-Demo/Loli War/UI/Control/Digit.yue
local _module_0 = nil -- 1
local _ENV = Dora(Dora.Platformer) -- 9
local require <const> = require -- 10
local Class <const> = Class -- 10
local property <const> = property -- 10
local math <const> = math -- 10
local Sprite <const> = Sprite -- 10
local tostring <const> = tostring -- 10
local Vec2 <const> = Vec2 -- 10
local Digit = require("UI.View.Digit") -- 11
_module_0 = Class(Digit, { -- 14
	__init = function(self) -- 14
		self._value = 99 -- 15
		self.maxValue = 99 -- 16
	end, -- 14
	value = property((function(self) -- 18
		return self._value -- 18
	end), function(self, value) -- 19
		self._value = math.max(math.min(self.maxValue, value), 0) -- 20
		self:removeAllChildren() -- 21
		local two = math.floor(self._value / 10) -- 22
		if two > 0 then -- 23
			local _with_0 = Sprite("Model/misc.clip|" .. tostring(two)) -- 24
			_with_0.anchor = Vec2(0, 0.5) -- 25
			_with_0:addTo(self) -- 26
		end -- 23
		local one = math.floor(self._value % 10) -- 27
		local _with_0 = Sprite("Model/misc.clip|" .. tostring(one)) -- 28
		_with_0.x = 6 -- 29
		_with_0.anchor = Vec2(0, 0.5) -- 30
		_with_0:addTo(self) -- 31
		return _with_0 -- 28
	end) -- 18
}) -- 13
return _module_0 -- 1
