-- [yue]: Dora-Demo/Loli War/AI.yue
local _ENV = Dora(Dora.Platformer, Dora.Platformer.Decision) -- 9
local Data <const> = Data -- 13
local Group <const> = Group -- 13
local Seq <const> = Seq -- 13
local Con <const> = Con -- 13
local Sel <const> = Sel -- 13
local Act <const> = Act -- 13
local Accept <const> = Accept -- 13
local Reject <const> = Reject -- 13
local AI <const> = AI -- 13
local App <const> = App -- 13
local math <const> = math -- 13
local Store = Data.store -- 15
local MaxBunnies = Store.MaxBunnies -- 16
local heroes = Group({ -- 20
	"hero" -- 20
}) -- 20
local gameEndWait = Seq({ -- 23
	Con("game end", function() -- 23
		return (Store.winner ~= nil) -- 23
	end), -- 23
	Sel({ -- 25
		Seq({ -- 26
			Con("need wait", function(self) -- 26
				return self.onSurface and not self:isDoing("wait") -- 26
			end), -- 26
			Act("cancel"), -- 27
			Act("wait") -- 28
		}), -- 25
		Accept() -- 30
	}) -- 24
}) -- 22
Store["PlayerControlAI"] = Sel({ -- 35
	Seq({ -- 36
		Con("is dead", function(self) -- 36
			return self.entity.hp <= 0 -- 36
		end), -- 36
		Accept() -- 37
	}), -- 35
	Seq({ -- 40
		Con("pushing switch", function(self) -- 40
			return self:isDoing("pushSwitch") -- 40
		end), -- 40
		Accept() -- 41
	}), -- 39
	Seq({ -- 44
		Seq({ -- 45
			Con("move key down", function(self) -- 45
				return not (self.data.keyLeft and self.data.keyRight) and ((self.data.keyLeft and self.faceRight) or (self.data.keyRight and not self.faceRight)) -- 46
			end), -- 45
			Act("turn") -- 51
		}), -- 44
		Reject() -- 53
	}), -- 43
	Seq({ -- 56
		Con("attack key down", function(self) -- 56
			return Store.winner == nil and self.data.keyF -- 56
		end), -- 56
		Sel({ -- 58
			Seq({ -- 59
				Con("at switch", function(self) -- 59
					local theSwitch = self.data.atSwitch -- 60
					return (theSwitch ~= nil) and not theSwitch.data.pushed and ((self.x < theSwitch.x) == self.faceRight) -- 61
				end), -- 59
				Act("pushSwitch") -- 63
			}), -- 58
			Act("villyAttack"), -- 65
			Act("meleeAttack"), -- 66
			Act("rangeAttack") -- 67
		}) -- 57
	}), -- 55
	Sel({ -- 71
		Seq({ -- 72
			Con("is falling", function(self) -- 72
				return not self.onSurface -- 72
			end), -- 72
			Act("fallOff") -- 73
		}), -- 71
		Seq({ -- 76
			Con("jump key down", function(self) -- 76
				return self.data.keyUp -- 76
			end), -- 76
			Act("jump") -- 77
		}) -- 75
	}), -- 70
	Seq({ -- 81
		Con("move key down", function(self) -- 81
			return self.data.keyLeft or self.data.keyRight -- 81
		end), -- 81
		Act("walk") -- 82
	}), -- 80
	Act("idle") -- 84
}) -- 34
Store["HeroAI"] = Sel({ -- 88
	Seq({ -- 89
		Con("is dead", function(self) -- 89
			return self.entity.hp <= 0 -- 89
		end), -- 89
		Accept() -- 90
	}), -- 88
	Seq({ -- 93
		Con("is falling", function(self) -- 93
			return not self.onSurface -- 93
		end), -- 93
		Act("fallOff") -- 94
	}), -- 92
	gameEndWait, -- 96
	Seq({ -- 98
		Con("need attack", function(self) -- 98
			local attackUnits = AI:getUnitsInAttackRange() -- 99
			for _index_0 = 1, #attackUnits do -- 100
				local unit = attackUnits[_index_0] -- 100
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 101
					return true -- 103
				end -- 101
			end -- 100
			return false -- 104
		end), -- 98
		Sel({ -- 106
			Act("villyAttack"), -- 106
			Act("rangeAttack"), -- 107
			Act("meleeAttack") -- 108
		}) -- 105
	}), -- 97
	Seq({ -- 112
		Con("not facing enemy", function(self) -- 112
			return heroes:each(function(hero) -- 112
				local unit = hero.unit -- 113
				if Data:isEnemy(unit, self) then -- 114
					if (self.x > unit.x) == self.faceRight then -- 115
						return true -- 116
					end -- 115
				end -- 114
			end) -- 112
		end), -- 112
		Act("turn") -- 117
	}), -- 111
	Seq({ -- 120
		Con("need turn", function(self) -- 120
			return (self.x < 100 and not self.faceRight) or (self.x > 3990 and self.faceRight) -- 121
		end), -- 120
		Act("turn") -- 122
	}), -- 119
	Seq({ -- 125
		Con("wanna jump", function() -- 125
			return App.rand % 20 == 0 -- 125
		end), -- 125
		Act("jump") -- 126
	}), -- 124
	Seq({ -- 129
		Con("is at enemy side", function(self) -- 129
			return heroes:each(function(hero) -- 129
				local unit = hero.unit -- 130
				if Data:isEnemy(unit, self) then -- 131
					if math.abs(self.x - unit.x) < 50 then -- 132
						return true -- 133
					end -- 132
				end -- 131
			end) -- 129
		end), -- 129
		Act("idle") -- 134
	}), -- 128
	Act("walk") -- 136
}) -- 87
Store["BunnyForwardReturnAI"] = Sel({ -- 140
	Seq({ -- 141
		Con("is dead", function(self) -- 141
			return self.entity.hp <= 0 -- 141
		end), -- 141
		Accept() -- 142
	}), -- 140
	Seq({ -- 145
		Con("is falling", function(self) -- 145
			return not self.onSurface -- 145
		end), -- 145
		Act("fallOff") -- 146
	}), -- 144
	gameEndWait, -- 148
	Seq({ -- 150
		Con("need attack", function(self) -- 150
			local attackUnits = AI:getUnitsInAttackRange() -- 151
			for _index_0 = 1, #attackUnits do -- 152
				local unit = attackUnits[_index_0] -- 152
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 153
					return App.rand % 5 ~= 0 -- 155
				end -- 153
			end -- 152
			return false -- 156
		end), -- 150
		Act("meleeAttack") -- 157
	}), -- 149
	Seq({ -- 160
		Con("need turn", function(self) -- 160
			return (self.x < 100 and not self.faceRight) or (self.x > 3990 and self.faceRight) -- 161
		end), -- 160
		Act("turn") -- 162
	}), -- 159
	Act("walk") -- 164
}) -- 139
Store["SwitchAI"] = Sel({ -- 168
	Seq({ -- 169
		Con("is pushed", function(self) -- 169
			return self.data.pushed -- 169
		end), -- 169
		Act("pushed") -- 170
	}), -- 168
	Act("waitUser") -- 172
}) -- 167
local switches = Group({ -- 175
	"switch" -- 175
}) -- 175
local turnToSwitch = Seq({ -- 177
	Con("go to switch", function(self) -- 177
		return switches:each(function(item) -- 177
			if item.group == self.group and self.entity and self.entity.targetSwitch == item.switch then -- 178
				return (self.x > item.unit.x) == self.faceRight -- 179
			end -- 178
		end) -- 177
	end), -- 177
	Act("turn"), -- 180
	Reject() -- 181
}) -- 176
Store["BunnySwitcherAI"] = Sel({ -- 184
	Seq({ -- 185
		Con("is dead", function(self) -- 185
			return self.entity.hp <= 0 -- 185
		end), -- 185
		Accept() -- 186
	}), -- 184
	Seq({ -- 189
		Con("is falling", function(self) -- 189
			return not self.onSurface -- 189
		end), -- 189
		Act("fallOff") -- 190
	}), -- 188
	gameEndWait, -- 192
	Seq({ -- 194
		Con("need attack", function(self) -- 194
			local attackUnits = AI:getUnitsInAttackRange() -- 195
			for _index_0 = 1, #attackUnits do -- 196
				local unit = attackUnits[_index_0] -- 196
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 197
					return App.rand % 5 ~= 0 -- 199
				end -- 197
			end -- 196
			return false -- 200
		end), -- 194
		Act("meleeAttack") -- 201
	}), -- 193
	Seq({ -- 204
		Con("at switch", function(self) -- 204
			local _with_0 = self.data -- 204
			return (_with_0.atSwitch ~= nil) and _with_0.atSwitch.entity.switch == self.entity.targetSwitch -- 205
		end), -- 204
		Sel({ -- 207
			Seq({ -- 208
				Con("switch available", function(self) -- 208
					return heroes:each(function(hero) -- 208
						if self.group ~= hero.group then -- 209
							return false -- 209
						end -- 209
						local needEP, available -- 210
						do -- 210
							local _exp_0 = self.entity.targetSwitch -- 210
							if "Switch" == _exp_0 then -- 211
								local bunnyCount = 0 -- 212
								Group({ -- 213
									"bunny" -- 213
								}):each(function(bunny) -- 213
									if bunny.group == self.group then -- 214
										bunnyCount = bunnyCount + 1 -- 214
									end -- 214
								end) -- 213
								needEP, available = 1, bunnyCount < MaxBunnies -- 215
							elseif "SwitchG" == _exp_0 then -- 216
								needEP, available = 2, hero.defending -- 217
							end -- 210
						end -- 210
						if hero.ep >= needEP and available then -- 218
							if not self.data.atSwitch:isDoing("pushed") then -- 219
								if self.entity.targetSwitch == "SwitchG" then -- 220
									hero.defending = false -- 220
								end -- 220
								return true -- 221
							end -- 219
						end -- 218
						return false -- 222
					end) -- 208
				end), -- 208
				Act("pushSwitch") -- 223
			}), -- 207
			turnToSwitch, -- 225
			Act("idle") -- 226
		}) -- 206
	}), -- 203
	Seq({ -- 230
		Con("need turn", function(self) -- 230
			return (self.x < 100 and not self.faceRight) or (self.x > 3990 and self.faceRight) -- 231
		end), -- 230
		Act("turn") -- 232
	}), -- 229
	turnToSwitch, -- 234
	Act("walk") -- 235
}) -- 183
