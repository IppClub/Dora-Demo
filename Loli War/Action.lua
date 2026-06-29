-- [yue]: Dora-Demo/Loli War/Action.yue
local _ENV = Dora(Dora.Platformer) -- 9
local Data <const> = Data -- 10
local UnitAction <const> = UnitAction -- 10
local once <const> = once -- 10
local sleep <const> = sleep -- 10
local Audio <const> = Audio -- 10
local Group <const> = Group -- 10
local Entity <const> = Entity -- 10
local Vec2 <const> = Vec2 -- 10
local emit <const> = emit -- 10
local Bullet <const> = Bullet -- 10
local Store = Data.store -- 12
local LayerBunny, LayerBlock, GroupPlayerPoke, GroupEnemyPoke, GroupPlayer, GroupEnemy, MaxBunnies = Store.LayerBunny, Store.LayerBlock, Store.GroupPlayerPoke, Store.GroupEnemyPoke, Store.GroupPlayer, Store.GroupEnemy, Store.MaxBunnies -- 13
UnitAction:add("fallOff", { -- 24
	priority = 1, -- 24
	reaction = 0.1, -- 25
	recovery = 0, -- 26
	available = function(self) -- 27
		return not self.onSurface -- 27
	end, -- 27
	create = function(self) -- 28
		do -- 29
			local _with_0 = self.playable -- 29
			_with_0.speed = 1.5 -- 30
			_with_0:play("jump", true) -- 31
		end -- 29
		return function(self) -- 32
			return self.onSurface -- 32
		end -- 32
	end -- 28
}) -- 23
local pushSwitchEnd -- 34
pushSwitchEnd = function(name, playable) -- 34
	if "switch" == name or "attack" == name then -- 35
		return playable.parent:stop() -- 36
	end -- 35
end -- 34
UnitAction:add("pushSwitch", { -- 39
	priority = 4, -- 39
	reaction = 3, -- 40
	recovery = 0.2, -- 41
	queued = true, -- 42
	available = function(self) -- 43
		return self.onSurface -- 43
	end, -- 43
	create = function(self) -- 44
		do -- 45
			local _with_0 = self.playable -- 45
			_with_0.speed = 1.5 -- 46
			_with_0.look = "noweapon" -- 47
			_with_0:play("switch") -- 48
			if not _with_0.playing then -- 49
				_with_0:play("attack") -- 50
			end -- 49
			_with_0:slot("AnimationEnd", pushSwitchEnd) -- 51
		end -- 45
		do -- 52
			local _with_0 = self.data.atSwitch -- 52
			_with_0.data.pushed = true -- 53
			_with_0.data.fromRight = self.x > _with_0.x -- 54
		end -- 52
		return function() -- 55
			return false -- 55
		end -- 55
	end, -- 44
	stop = function(self) -- 56
		return self.playable:slot("AnimationEnd"):remove(pushSwitchEnd) -- 57
	end -- 56
}) -- 38
UnitAction:add("waitUser", { -- 60
	priority = 1, -- 60
	reaction = 0.1, -- 61
	recovery = 0.2, -- 62
	available = function() -- 63
		return true -- 63
	end, -- 63
	create = function(self) -- 64
		do -- 65
			local _with_0 = self.playable -- 65
			_with_0.speed = 1 -- 66
			_with_0:play("idle", true) -- 67
		end -- 65
		return function() -- 68
			return false -- 68
		end -- 68
	end -- 64
}) -- 59
local switchPushed -- 70
switchPushed = function(name, playable) -- 70
	if "pushRight" == name or "pushLeft" == name then -- 71
		return playable.parent:stop() -- 72
	end -- 71
end -- 70
local _anon_func_0 = function(GroupEnemy, GroupEnemyPoke, GroupPlayer, GroupPlayerPoke, LayerBlock, self) -- 111
	local _with_0 = { } -- 111
	_with_0.layer = LayerBlock -- 112
	local _exp_0 = self.group -- 113
	if GroupPlayer == _exp_0 then -- 114
		_with_0.poke, _with_0.group, _with_0.position = "pokeb", GroupPlayerPoke, Vec2(192, 1004 - 512) -- 115
	elseif GroupEnemy == _exp_0 then -- 116
		_with_0.poke, _with_0.group, _with_0.position = "pokep", GroupEnemyPoke, Vec2(3904, 1004 - 512) -- 117
	end -- 113
	return _with_0 -- 111
end -- 111
UnitAction:add("pushed", { -- 75
	priority = 2, -- 75
	reaction = 0.1, -- 76
	recovery = 0.2, -- 77
	queued = true, -- 78
	available = function() -- 79
		return true -- 79
	end, -- 79
	create = function(self) -- 80
		do -- 81
			local _with_0 = self.playable -- 81
			_with_0.recovery = 0.2 -- 82
			_with_0.speed = 1.5 -- 83
			_with_0:play(self.data.fromRight and "pushLeft" or "pushRight") -- 84
			_with_0:slot("AnimationEnd", switchPushed) -- 85
		end -- 81
		return once(function(self) -- 86
			sleep(0.5) -- 87
			Audio:play("Audio/switch.wav") -- 88
			local heroes = Group({ -- 89
				"hero" -- 89
			}) -- 89
			do -- 90
				local _exp_0 = self.entity.switch -- 90
				if "Switch" == _exp_0 then -- 91
					heroes:each(function(hero) -- 92
						if self.group == hero.group and hero.ep >= 1 then -- 93
							Entity((function() -- 94
								local _with_0 = { } -- 94
								do -- 95
									local _exp_1 = self.group -- 95
									if GroupPlayer == _exp_1 then -- 96
										_with_0.bunny, _with_0.group, _with_0.faceRight, _with_0.position = "BunnyG", GroupPlayer, true, Vec2(1000, 1004 - 500) -- 97
									elseif GroupEnemy == _exp_1 then -- 98
										_with_0.bunny, _with_0.group, _with_0.faceRight, _with_0.position = "BunnyP", GroupEnemy, false, Vec2(3130, 1004 - 500) -- 99
									end -- 95
								end -- 95
								_with_0.AI = "BunnyForwardReturnAI" -- 100
								_with_0.layer = LayerBunny -- 101
								local bunnyCount = 0 -- 102
								Group({ -- 103
									"bunny" -- 103
								}):each(function(bunny) -- 103
									if bunny.group == self.group then -- 104
										bunnyCount = bunnyCount + 1 -- 104
									end -- 104
								end) -- 103
								if bunnyCount > MaxBunnies then -- 105
									_with_0.hp = 0.0 -- 105
								end -- 105
								return _with_0 -- 94
							end)()) -- 94
							emit("EPChange", self.group, -1) -- 106
							return true -- 107
						end -- 93
					end) -- 92
				elseif "SwitchG" == _exp_0 then -- 108
					heroes:each(function(hero) -- 109
						if self.group == hero.group and hero.ep >= 2 then -- 110
							Entity(_anon_func_0(GroupEnemy, GroupEnemyPoke, GroupPlayer, GroupPlayerPoke, LayerBlock, self)) -- 111
							emit("EPChange", self.group, -2) -- 118
							return true -- 119
						end -- 110
					end) -- 109
				end -- 90
			end -- 90
			while true do -- 120
				sleep() -- 121
			end -- 120
		end) -- 86
	end, -- 80
	stop = function(self) -- 122
		self.data.pushed = false -- 123
		return self.playable:slot("AnimationEnd"):remove(pushSwitchEnd) -- 124
	end -- 122
}) -- 74
local strikeEnd -- 126
strikeEnd = function(name, playable) -- 126
	if name == "hit" then -- 127
		return playable.parent:stop() -- 127
	end -- 127
end -- 126
UnitAction:add("strike", { -- 130
	priority = 4, -- 130
	reaction = 3, -- 131
	recovery = 0, -- 132
	queued = true, -- 133
	available = function() -- 134
		return true -- 134
	end, -- 134
	create = function(self) -- 135
		do -- 136
			local _with_0 = self.playable -- 136
			_with_0.speed = 1 -- 137
			_with_0.look = "fail" -- 138
			_with_0:play("hit") -- 139
			_with_0:slot("AnimationEnd", strikeEnd) -- 140
		end -- 136
		Audio:play("Audio/hit.wav") -- 141
		return function() -- 142
			return false -- 142
		end -- 142
	end, -- 135
	stop = function(self) -- 143
		return self.playable:slot("AnimationEnd"):remove(strikeEnd) -- 144
	end -- 143
}) -- 129
local villyAttackEnd -- 146
villyAttackEnd = function(name, playable) -- 146
	if name == "attack" then -- 147
		return playable.parent:stop() -- 147
	end -- 147
end -- 146
UnitAction:add("villyAttack", { -- 150
	priority = 3, -- 150
	reaction = 10, -- 151
	recovery = 0.1, -- 152
	queued = true, -- 153
	available = function() -- 154
		return true -- 154
	end, -- 154
	create = function(self) -- 155
		local attackSpeed, targetAllow, damageType, attackBase, attackBonus, attackFactor, attackPower -- 156
		do -- 156
			local _obj_0 = self.entity -- 164
			attackSpeed, targetAllow, damageType, attackBase, attackBonus, attackFactor, attackPower = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor, _obj_0.attackPower -- 156
		end -- 156
		do -- 165
			local _with_0 = self.playable -- 165
			_with_0.speed = attackSpeed -- 166
			_with_0.look = "fight" -- 167
			_with_0:play("attack") -- 168
			_with_0:slot("AnimationEnd", villyAttackEnd) -- 169
		end -- 165
		return once(function(self) -- 170
			local bulletDef = Store[self.unitDef.bulletType] -- 171
			local onAttack -- 172
			onAttack = function() -- 172
				Audio:play("Audio/v_att.wav") -- 173
				local _with_0 = Bullet(bulletDef, self) -- 174
				_with_0.targetAllow = targetAllow -- 175
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 176
					do -- 177
						local _with_1 = target.data -- 177
						_with_1.hitPoint = pos -- 178
						_with_1.hitPower = attackPower -- 179
						_with_1.hitFromRight = bullet.velocityX < 0 -- 180
					end -- 177
					local entity = target.entity -- 181
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 182
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 183
					entity.hp = entity.hp - damage -- 184
					bullet.hitStop = true -- 185
				end) -- 176
				_with_0:addTo(self.world, self.order) -- 186
				return _with_0 -- 174
			end -- 172
			sleep(0.17 / attackSpeed) -- 187
			onAttack() -- 188
			sleep(0.63 / attackSpeed) -- 189
			onAttack() -- 190
			sleep(1.0) -- 191
			return true -- 192
		end) -- 170
	end, -- 155
	stop = function(self) -- 193
		return self.playable:slot("AnimationEnd"):remove(villyAttackEnd) -- 194
	end -- 193
}) -- 149
return UnitAction:add("wait", { -- 197
	priority = 1, -- 197
	reaction = 0.1, -- 198
	recovery = 0, -- 199
	available = function(self) -- 200
		return self.onSurface -- 200
	end, -- 200
	create = function(self) -- 201
		do -- 202
			local _with_0 = self.playable -- 202
			_with_0.speed = 1 -- 203
			_with_0.look = Store.winner == self.group and "happy" or "fail" -- 204
			_with_0:play("idle", true) -- 205
		end -- 202
		return function(self) -- 206
			if not self.onSurface then -- 207
				return true -- 208
			end -- 207
			return false -- 209
		end -- 206
	end -- 201
}) -- 196
