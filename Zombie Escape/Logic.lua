-- [yue]: Dora-Demo/Zombie Escape/Logic.yue
local _ENV = Dora(Dora.Platformer) -- 9
local Rectangle = require("UI.View.Shape.Rectangle") -- 10
local Circle = require("UI.View.Shape.Circle") -- 11
local Star = require("UI.View.Shape.Star") -- 12
local Data <const> = Data -- 13
local Observer <const> = Observer -- 13
local Color3 <const> = Color3 -- 13
local Body <const> = Body -- 13
local type <const> = type -- 13
local Color <const> = Color -- 13
local Unit <const> = Unit -- 13
local once <const> = once -- 13
local sleep <const> = sleep -- 13
local Opacity <const> = Opacity -- 13
local Ease <const> = Ease -- 13
local Group <const> = Group -- 13
local threadLoop <const> = threadLoop -- 13
local Vec2 <const> = Vec2 -- 13
local App <const> = App -- 13
local Rect <const> = Rect -- 13
local Size <const> = Size -- 13
local Entity <const> = Entity -- 13
local math <const> = math -- 13
local tostring <const> = tostring -- 13
local Store = Data.store -- 15
do -- 17
	local _with_0 = Observer("Add", { -- 17
		"obstacleDef", -- 17
		"size", -- 17
		"position", -- 17
		"color" -- 17
	}) -- 17
	_with_0:watch(function(self, obstacleDef, size, position, color) -- 18
		local world, TerrainLayer = Store.world, Store.TerrainLayer -- 19
		color = Color3(color) -- 20
		do -- 21
			local _with_1 = Body(Store[obstacleDef], world, position) -- 21
			_with_1.tag = "Obstacle" -- 22
			_with_1.order = TerrainLayer -- 23
			_with_1.group = Data.groupTerrain -- 24
			if "number" == type(size) then -- 25
				_with_1:addChild(Circle({ -- 27
					radius = size, -- 27
					fillColor = Color(color, 0x66):toARGB(), -- 28
					borderColor = Color(color, 0xff):toARGB(), -- 29
					fillOrder = 1, -- 30
					lineOrder = 2 -- 31
				})) -- 26
				_with_1:addChild(Star({ -- 34
					size = 20, -- 34
					borderColor = 0xffffffff, -- 35
					fillColor = 0x66ffffff, -- 36
					fillOrder = 1, -- 37
					lineOrder = 2 -- 38
				})) -- 33
			else -- 41
				_with_1:addChild(Rectangle({ -- 42
					width = size.width, -- 42
					height = size.height, -- 43
					fillColor = Color(color, 0x66):toARGB(), -- 44
					borderColor = Color(color, 0xff):toARGB(), -- 45
					fillOrder = 1, -- 46
					lineOrder = 2 -- 47
				})) -- 41
			end -- 25
			_with_1:addTo(world) -- 49
		end -- 21
		self:destroy() -- 50
		return false -- 18
	end) -- 18
end -- 17
local mutables = { -- 53
	"hp", -- 53
	"moveSpeed", -- 54
	"move", -- 55
	"jump", -- 56
	"targetAllow", -- 57
	"attackPower", -- 58
	"attackSpeed" -- 59
} -- 52
do -- 61
	local _with_0 = Observer("Add", { -- 61
		"unitDef", -- 61
		"position", -- 61
		"order", -- 61
		"group", -- 61
		"faceRight" -- 61
	}) -- 61
	_with_0:watch(function(self, unitDef, position, order, group, faceRight) -- 62
		local world = Store.world -- 63
		local def = Store[unitDef] -- 64
		for _index_0 = 1, #mutables do -- 65
			local var = mutables[_index_0] -- 65
			self[var] = def[var] -- 66
		end -- 65
		local unit -- 67
		do -- 67
			local _with_1 = Unit(def, world, self, position) -- 67
			_with_1.group = group -- 68
			_with_1.order = order -- 69
			_with_1.faceRight = faceRight -- 70
			_with_1:addTo(world) -- 71
			_with_1:eachAction(function(self) -- 72
				self.recovery = 0 -- 72
			end) -- 72
			local _with_2 = _with_1.playable -- 73
			_with_2:eachNode(function(sp) -- 74
				sp.filter = "Point" -- 74
			end) -- 74
			if self.zombie then -- 75
				_with_2:play("groundEntrance") -- 75
			end -- 75
			unit = _with_1 -- 67
		end -- 67
		if self.player and unit.decisionTree == "AI_KidSearch" then -- 76
			world.camera.followTarget = unit -- 76
		end -- 76
		return false -- 62
	end) -- 62
end -- 61
do -- 78
	local _with_0 = Observer("Change", { -- 78
		"hp", -- 78
		"unit" -- 78
	}) -- 78
	_with_0:watch(function(self, hp, unit) -- 79
		local lastHp = self.oldValues.hp -- 80
		if hp < lastHp then -- 81
			if hp > 0 then -- 82
				unit:start("hit") -- 83
			else -- 85
				unit:start("hit") -- 85
				unit:start("fall") -- 86
				unit.group = Data.groupHide -- 87
				unit:schedule(once(function() -- 88
					sleep(5) -- 89
					unit:runAction(Opacity(0.5, 1, 0, Ease.OutQuad)) -- 90
					sleep(0.5) -- 91
					if Store.world.camera.followTarget == unit then -- 92
						local player = Group({ -- 93
							"player", -- 93
							"unit" -- 93
						}):find(function(self) -- 93
							return self.player -- 93
						end) -- 93
						if player then -- 93
							Store.world.camera.followTarget = player.unit -- 94
						end -- 93
					end -- 92
					return unit:removeFromParent() -- 95
				end)) -- 88
			end -- 82
		end -- 81
		return false -- 79
	end) -- 79
end -- 78
Store.zombieKilled = 0 -- 97
do -- 98
	local _with_0 = Observer("Change", { -- 98
		"hp", -- 98
		"zombie" -- 98
	}) -- 98
	_with_0:watch(function(_entity, hp) -- 99
		if hp <= 0 then -- 100
			Store.zombieKilled = Store.zombieKilled + 1 -- 100
		end -- 100
		return false -- 99
	end) -- 99
end -- 98
local zombieGroup = Group({ -- 102
	"zombie" -- 102
}) -- 102
return threadLoop(function() -- 103
	local ZombieLayer, ZombieGroup, MaxZombies, ZombieWaveDelay, world = Store.ZombieLayer, Store.ZombieGroup, Store.MaxZombies, Store.ZombieWaveDelay, Store.world -- 104
	if zombieGroup.count < MaxZombies then -- 111
		for _ = zombieGroup.count + 1, MaxZombies do -- 112
			local available = false -- 113
			local pos = Vec2.zero -- 114
			while not available do -- 115
				pos = Vec2(App.rand % 2400 - 1200, -430) -- 116
				available = not world:query(Rect(pos, Size(5, 5)), function(self) -- 117
					return self.group == Data.groupTerrain -- 117
				end) -- 117
			end -- 115
			Entity({ -- 119
				unitDef = "Unit_Zombie" .. tostring(math.floor(App.rand % 2 + 1)), -- 119
				order = ZombieLayer, -- 120
				position = pos, -- 121
				group = ZombieGroup, -- 122
				faceRight = App.rand % 2 == 0, -- 123
				zombie = true -- 124
			}) -- 118
			sleep(0.1 * App.rand % 5) -- 125
		end -- 112
	end -- 111
	return sleep(ZombieWaveDelay) -- 126
end) -- 103
