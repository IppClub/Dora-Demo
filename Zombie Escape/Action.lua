-- [yue]: Action.yue
local _ENV = Dora(Dora.Platformer) -- 9
local UnitAction <const> = UnitAction -- 10
local groundEntranceEnd -- 12
groundEntranceEnd = function(name, playable) -- 12
	if not (name == "groundEntrance") then -- 13
		return -- 13
	end -- 13
	return playable.parent:stop() -- 14
end -- 12
UnitAction:add("groundEntrance", { -- 17
	priority = 6, -- 17
	reaction = -1, -- 18
	recovery = 0, -- 19
	queued = true, -- 20
	create = function(self) -- 21
		self.data.lastGroup = self.group -- 22
		self.group = 0 -- 23
		do -- 24
			local _with_0 = self.playable -- 24
			_with_0.speed = 1 -- 25
			_with_0:slot("AnimationEnd", groundEntranceEnd) -- 26
			_with_0:play("groundEntrance") -- 27
		end -- 24
		return function() -- 28
			return false -- 28
		end -- 28
	end, -- 21
	stop = function(self) -- 29
		self.playable:slot("AnimationEnd"):remove(groundEntranceEnd) -- 30
		self.group = self.data.lastGroup -- 31
		self.data.lastGroup = nil -- 32
		self.data.entered = true -- 33
	end -- 29
}) -- 16
return UnitAction:add("fallOff", { -- 36
	priority = 1, -- 36
	reaction = 1, -- 37
	recovery = 0, -- 38
	available = function(self) -- 39
		return not self.onSurface -- 39
	end, -- 39
	create = function(self) -- 40
		if self.velocityY <= 0 then -- 41
			self.data.fallDown = true -- 42
			local _with_0 = self.playable -- 43
			_with_0.speed = 1 -- 44
			_with_0:play("fallOff") -- 45
		else -- 46
			self.data.fallDown = false -- 46
		end -- 41
		return function(self) -- 47
			if self.onSurface then -- 48
				return true -- 48
			end -- 48
			if not self.data.fallDown and self.playable.current ~= "fallOff" and self.velocityY <= 0 then -- 49
				self.data.fallDown = true -- 52
				local _with_0 = self.playable -- 53
				_with_0.speed = 1 -- 54
				_with_0:play("fallOff") -- 55
			end -- 49
			return false -- 56
		end -- 47
	end -- 40
}) -- 35
