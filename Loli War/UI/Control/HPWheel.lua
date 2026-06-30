-- [yue]: UI/Control/HPWheel.yue
local _module_0 = nil -- 1
local _ENV = Dora(Dora.Platformer) -- 9
local require <const> = require -- 10
local Data <const> = Data -- 10
local Class <const> = Class -- 10
local math <const> = math -- 10
local tostring <const> = tostring -- 10
local ScaleX <const> = ScaleX -- 10
local string <const> = string -- 10
local table <const> = table -- 10
local ipairs <const> = ipairs -- 10
local X <const> = X -- 10
local HPWheel = require("UI.View.HPWheel") -- 11
local EPHint = require("UI.View.EPHint") -- 12
local GroupPlayer, GroupEnemy, MaxEP, MaxHP -- 14
do -- 14
	local _obj_0 = Data.store -- 19
	GroupPlayer, GroupEnemy, MaxEP, MaxHP = _obj_0.GroupPlayer, _obj_0.GroupEnemy, _obj_0.MaxEP, _obj_0.MaxHP -- 14
end -- 14
_module_0 = Class(HPWheel, { -- 22
	__init = function(self) -- 22
		self.ep = MaxEP -- 23
		self.hp = MaxHP -- 24
		self.hints = { } -- 25
		self.hpShow:slot("AnimationEnd", function(name) -- 27
			if name == "hit" then -- 28
				return self.hpShow:play("idle", true) -- 28
			end -- 28
		end) -- 27
		self:gslot("HPChange", function(group, value) -- 30
			if group == GroupPlayer then -- 31
				local newHP = math.max(self.hp + value, 0) -- 32
				self.hp = math.floor(math.max(math.min(MaxHP, newHP), 0) + 0.5) -- 33
				self.hpShow.look = tostring(self.hp) -- 34
				if value < 0 then -- 35
					return self.hpShow:play("hit") -- 35
				end -- 35
			end -- 31
		end) -- 30
		self:gslot("EPChange", function(group, value) -- 37
			if group == GroupPlayer then -- 38
				if 1 == value or (-1) == value or (-2) == value or 6 == value then -- 40
					self.ep = math.floor(math.max(math.min(MaxEP, self.ep + value), 0) + 0.5) -- 41
					self.fill:perform(ScaleX(0.2, self.fill.scaleX, self.ep / MaxEP)) -- 42
					local hint -- 43
					do -- 43
						local _with_0 = EPHint({ -- 43
							index = #self.hints + 1, -- 43
							clip = string.format("%+d", value) -- 43
						}) -- 43
						_with_0.index = #self.hints + 1 -- 44
						_with_0:slot("DisplayEnd", function() -- 45
							local index = hint.index -- 46
							hint:removeFromParent() -- 47
							table.remove(self.hints, index) -- 48
							for i, v in ipairs(self.hints) do -- 49
								v:runAction(X(0.2, v.x, 55 + 25 * (i - 1))) -- 50
								v.index = i -- 51
							end -- 49
						end) -- 45
						hint = _with_0 -- 43
					end -- 43
					table.insert(self.hints, hint) -- 52
					return self.energy:addChild(hint) -- 53
				end -- 39
			end -- 38
		end) -- 37
		self:gslot("BlockValue", function(group, value) -- 55
			if GroupPlayer == group then -- 57
				self.playerBlocks.value = value -- 58
			elseif GroupEnemy == group then -- 59
				self.enemyBlocks.value = value -- 60
			end -- 56
		end) -- 55
		return self:gslot("BlockChange", function(group, value) -- 62
			if GroupPlayer == group then -- 64
				self.playerBlocks.value = math.max(self.playerBlocks.value + value, 0) -- 65
			elseif GroupEnemy == group then -- 66
				self.enemyBlocks.value = math.max(self.enemyBlocks.value + value, 0) -- 67
			end -- 63
		end) -- 62
	end -- 22
}) -- 21
return _module_0 -- 1
