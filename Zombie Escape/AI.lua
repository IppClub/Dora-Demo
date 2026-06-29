-- [yue]: Dora-Demo/Zombie Escape/AI.yue
local _ENV = Dora(Dora.Platformer, Dora.Platformer.Decision) -- 9
local BT = require("Platformer").Behavior -- 13
local Data <const> = Data -- 14
local Sel <const> = Sel -- 14
local Seq <const> = Seq -- 14
local Con <const> = Con -- 14
local Unit <const> = Unit -- 14
local Vec2 <const> = Vec2 -- 14
local Act <const> = Act -- 14
local Reject <const> = Reject -- 14
local math <const> = math -- 14
local Behave <const> = Behave -- 14
local AI <const> = AI -- 14
local App <const> = App -- 14
local Accept <const> = Accept -- 14
local Group <const> = Group -- 14
local Store = Data.store -- 16
local rangeAttack = Sel({ -- 19
	Seq({ -- 20
		Con("attack path blocked", function(self) -- 20
			local sensor = self:getSensorByTag(Unit.AttackSensorTag) -- 21
			if sensor.sensedBodies:each(function(body) -- 22
				return body.group == Data.groupTerrain and (self.x > body.x) ~= self.faceRight and body.tag == "Obstacle" -- 23
			end) then -- 22
				local faceObstacle = true -- 26
				local start = self.position -- 27
				local stop = Vec2(start.x + (self.faceRight and 1 or -1) * self.unitDef.attackRange.width, start.y) -- 28
				Store.world:raycast(start, stop, true, function(b) -- 29
					if b.group == Data.groupDetection then -- 30
						return false -- 30
					end -- 30
					if Data:isEnemy(self, b) then -- 31
						faceObstacle = false -- 31
					end -- 31
					return true -- 32
				end) -- 29
				return faceObstacle -- 33
			else -- 34
				return false -- 34
			end -- 22
		end), -- 20
		Act("jump"), -- 35
		Reject() -- 36
	}), -- 19
	Act("rangeAttack") -- 38
}) -- 18
local walk = Sel({ -- 42
	Seq({ -- 43
		Con("obstacles ahead", function(self) -- 43
			local start = self.position -- 44
			local stop = Vec2(start.x + (self.faceRight and 140 or -140), start.y) -- 45
			return Store.world:raycast(start, stop, false, function(b, p) -- 46
				if b.group == Data.groupTerrain and b.tag == "Obstacle" then -- 47
					self.data.obstacleDistance = math.abs(p.x - start.x) -- 48
					return true -- 49
				else -- 50
					return false -- 50
				end -- 47
			end) -- 46
		end), -- 43
		Sel({ -- 52
			Seq({ -- 53
				Con("obstacle distance <= 80", function(self) -- 53
					return self.data.obstacleDistance <= 80 -- 53
				end), -- 53
				Behave("backJump", BT.Seq({ -- 55
					BT.Act("turn"), -- 55
					BT.Countdown(0.3, BT.Act("walk")), -- 56
					BT.Act("turn"), -- 57
					BT.Countdown(0.1, BT.Act("walk")), -- 58
					BT.Act("jump") -- 59
				})) -- 54
			}), -- 52
			Seq({ -- 63
				Con("has forward speed", function(self) -- 63
					return math.abs(self.velocityX) > 10 -- 63
				end), -- 63
				Act("jump") -- 64
			}) -- 62
		}) -- 51
	}), -- 42
	Act("walk") -- 68
}) -- 41
local fightDecision = Seq({ -- 72
	Con("see enemy", function() -- 72
		return (AI:getNearestUnit("Enemy") ~= nil) -- 72
	end), -- 72
	Sel({ -- 74
		Seq({ -- 75
			Con("need evade", function(self) -- 75
				if not self:getAction("rangeAttack" or not self.onSurface) then -- 76
					return false -- 76
				end -- 76
				local evadeLeftEnemy = false -- 77
				local evadeRightEnemy = false -- 78
				local sensor = self:getSensorByTag(Unit.AttackSensorTag) -- 79
				sensor.sensedBodies:each(function(body) -- 80
					if Data:isEnemy(self, body) then -- 81
						local distance = math.abs(self.x - body.x) -- 82
						if distance < 80 then -- 83
							evadeRightEnemy = false -- 84
							evadeLeftEnemy = false -- 85
							return true -- 86
						elseif distance < 200 then -- 87
							if body.x > self.x then -- 88
								evadeRightEnemy = true -- 88
							end -- 88
							if body.x <= self.x then -- 89
								evadeLeftEnemy = true -- 89
							end -- 89
						end -- 83
					end -- 81
				end) -- 80
				local needEvade = not (evadeLeftEnemy == evadeRightEnemy) and math.abs(self.x) < 1000 -- 90
				if needEvade then -- 91
					self.data.evadeRight = evadeRightEnemy -- 91
				end -- 91
				return needEvade -- 92
			end), -- 75
			Sel({ -- 94
				Seq({ -- 95
					Con("face enemy", function(self) -- 95
						return self.data.evadeRight == self.faceRight -- 95
					end), -- 95
					Act("turn"), -- 96
					walk -- 97
				}), -- 94
				walk -- 99
			}) -- 93
		}), -- 74
		Seq({ -- 103
			Con("not facing nearest enemy", function(self) -- 103
				local enemy = AI:getNearestUnit("Enemy") -- 104
				return (self.x > enemy.x) == self.faceRight -- 105
			end), -- 103
			Act("turn") -- 106
		}), -- 102
		Seq({ -- 109
			Con("enemy in attack range", function() -- 109
				local enemy = AI:getNearestUnit("Enemy") -- 110
				local attackUnits = AI:getUnitsInAttackRange() -- 111
				return attackUnits and attackUnits:contains(enemy) or false -- 112
			end), -- 109
			Sel({ -- 114
				rangeAttack, -- 114
				Act("meleeAttack") -- 115
			}) -- 113
		}), -- 108
		Seq({ -- 119
			Con("wanna jump", function() -- 119
				return App.rand % 5 == 0 -- 119
			end), -- 119
			Act("jump") -- 120
		}), -- 118
		walk -- 122
	}) -- 73
}) -- 71
Store["AI_Zombie"] = Sel({ -- 127
	Seq({ -- 128
		Con("is dead", function(self) -- 128
			return self.entity.hp <= 0 -- 128
		end), -- 128
		Accept() -- 129
	}), -- 127
	Seq({ -- 132
		Con("not entered", function(self) -- 132
			return not self.data.entered -- 132
		end), -- 132
		Act("groundEntrance") -- 133
	}), -- 131
	fightDecision, -- 135
	Seq({ -- 137
		Con("need stop", function(self) -- 137
			return not self:isDoing("idle") -- 137
		end), -- 137
		Act("cancel"), -- 138
		Act("idle") -- 139
	}) -- 136
}) -- 126
local playerGroup = Group({ -- 143
	"player" -- 143
}) -- 143
Store["AI_KidFollow"] = Sel({ -- 146
	Seq({ -- 147
		Con("is dead", function(self) -- 147
			return self.entity.hp <= 0 -- 147
		end), -- 147
		Accept() -- 148
	}), -- 146
	fightDecision, -- 150
	Seq({ -- 152
		Con("is falling", function(self) -- 152
			return not self.onSurface -- 152
		end), -- 152
		Act("fallOff") -- 153
	}), -- 151
	Seq({ -- 156
		Con("follow target is away", function(self) -- 156
			local target = playerGroup:find(function(e) -- 157
				return e.unit ~= self -- 157
			end) -- 157
			if target then -- 157
				self.data.followTarget = target.unit -- 158
				return math.abs(self.x - target.unit.x) > 50 -- 159
			else -- 160
				return false -- 160
			end -- 157
		end), -- 156
		Sel({ -- 162
			Seq({ -- 163
				Con("not facing target", function(self) -- 163
					return (self.x > self.data.followTarget.x) == self.faceRight -- 163
				end), -- 163
				Act("turn") -- 164
			}), -- 162
			Accept() -- 166
		}), -- 161
		walk -- 168
	}), -- 155
	Seq({ -- 171
		Con("need stop", function(self) -- 171
			return not self:isDoing("idle") -- 171
		end), -- 171
		Act("cancel"), -- 172
		Act("idle") -- 173
	}) -- 170
}) -- 145
Store["AI_KidSearch"] = Sel({ -- 178
	Seq({ -- 179
		Con("is dead", function(self) -- 179
			return self.entity.hp <= 0 -- 179
		end), -- 179
		Accept() -- 180
	}), -- 178
	fightDecision, -- 182
	Seq({ -- 184
		Con("is falling", function(self) -- 184
			return not self.onSurface -- 184
		end), -- 184
		Act("fallOff") -- 185
	}), -- 183
	Seq({ -- 188
		Con("reach search limit", function(self) -- 188
			return math.abs(self.x) > 1150 and ((self.x > 0) == self.faceRight) -- 188
		end), -- 188
		Act("turn") -- 189
	}), -- 187
	Seq({ -- 192
		Con("continue search", function() -- 192
			return true -- 192
		end), -- 192
		walk -- 193
	}) -- 191
}) -- 177
Store["AI_PlayerControl"] = Sel({ -- 198
	Seq({ -- 199
		Con("is dead", function(self) -- 199
			return self.entity.hp <= 0 -- 199
		end), -- 199
		Accept() -- 200
	}), -- 198
	Seq({ -- 203
		Seq({ -- 204
			Con("move key down", function(self) -- 204
				return not (self.data.keyLeft and self.data.keyRight) and ((self.data.keyLeft and self.faceRight) or (self.data.keyRight and not self.faceRight)) -- 205
			end), -- 204
			Act("turn") -- 210
		}), -- 203
		Reject() -- 212
	}), -- 202
	Seq({ -- 215
		Con("attack key down", function(self) -- 215
			return self.data.keyShoot -- 215
		end), -- 215
		Sel({ -- 217
			Act("meleeAttack"), -- 217
			Act("rangeAttack") -- 218
		}) -- 216
	}), -- 214
	Sel({ -- 222
		Seq({ -- 223
			Con("is falling", function(self) -- 223
				return not self.onSurface -- 223
			end), -- 223
			Act("fallOff") -- 224
		}), -- 222
		Seq({ -- 227
			Con("jump key down", function(self) -- 227
				return self.data.keyUp -- 227
			end), -- 227
			Act("jump") -- 228
		}) -- 226
	}), -- 221
	Seq({ -- 232
		Con("move key down", function(self) -- 232
			return self.data.keyLeft or self.data.keyRight -- 232
		end), -- 232
		Act("walk") -- 233
	}), -- 231
	Seq({ -- 236
		Con("need stop", function(self) -- 236
			return not self:isDoing("idle") -- 236
		end), -- 236
		Act("cancel"), -- 237
		Act("idle") -- 238
	}) -- 235
}) -- 197
