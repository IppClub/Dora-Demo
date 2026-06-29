-- [yue]: Dora-Demo/Loli War/UI/Control/ButtonGlow.yue
local _module_0 = nil -- 1
local _ENV = Dora(Dora.Platformer) -- 9
local require <const> = require -- 10
local Class <const> = Class -- 10
local Visual <const> = Visual -- 10
local Director <const> = Director -- 10
local Audio <const> = Audio -- 10
local loop <const> = loop -- 10
local sleep <const> = sleep -- 10
local ButtonGlow = require("UI.View.ButtonGlow") -- 11
_module_0 = Class(ButtonGlow, { -- 14
	__init = function(self) -- 14
		return self:slot("Tapped", function(touch) -- 15
			local _with_0 = Visual("Particle/select.par") -- 16
			if touch then -- 17
				_with_0.position = self:convertToWorldSpace(touch.location) -- 18
			else -- 20
				_with_0.position = self.parent:convertToWorldSpace(self.position) -- 20
			end -- 17
			_with_0:addTo(Director.ui) -- 21
			_with_0:autoRemove() -- 22
			_with_0:start() -- 23
			return _with_0 -- 16
		end) -- 15
	end, -- 14
	glow = function(self) -- 25
		if not self.scheduled then -- 26
			Audio:play("Audio/select.wav") -- 27
			return self:schedule(loop(function() -- 28
				self.up.visible = false -- 29
				self.down.visible = true -- 30
				sleep(0.5) -- 31
				self.up.visible = true -- 32
				self.down.visible = false -- 33
				return sleep(0.5) -- 34
			end)) -- 28
		end -- 26
	end, -- 25
	stopGlow = function(self) -- 36
		if self.scheduled then -- 37
			self:unschedule() -- 38
			self.up.visible = true -- 39
			self.down.visible = false -- 40
		end -- 37
	end -- 36
}) -- 13
return _module_0 -- 1
