-- [yue]: Dora-Demo/Zombie Escape/Debug.yue
local _ENV = Dora(Dora.ImGui, Dora.Platformer) -- 9
local Star = require("UI.View.Shape.Star") -- 10
local Data <const> = Data -- 11
local Group <const> = Group -- 11
local App <const> = App -- 11
local SetNextWindowPos <const> = SetNextWindowPos -- 11
local Vec2 <const> = Vec2 -- 11
local SetNextWindowSize <const> = SetNextWindowSize -- 11
local Begin <const> = Begin -- 11
local TextWrapped <const> = TextWrapped -- 11
local tostring <const> = tostring -- 11
local SameLine <const> = SameLine -- 11
local Button <const> = Button -- 11
local Rect <const> = Rect -- 11
local Size <const> = Size -- 11
local Entity <const> = Entity -- 11
local DragFloat <const> = DragFloat -- 11
local Checkbox <const> = Checkbox -- 11
local Separator <const> = Separator -- 11
local RadioButton <const> = RadioButton -- 11
local Director <const> = Director -- 11
local table <const> = table -- 11
local Text <const> = Text -- 11
local Observer <const> = Observer -- 11
local Store = Data.store -- 13
local world, ZombieLayer, PlayerGroup = Store.world, Store.ZombieLayer, Store.PlayerGroup -- 14
local playerGroup = Group({ -- 20
	"player", -- 20
	"unit" -- 20
}) -- 20
local zombieGroup = Group({ -- 21
	"zombie", -- 21
	"unit" -- 21
}) -- 21
local userControl = false -- 22
local playerChoice = 1 -- 23
local controlChoice -- 24
do -- 24
	local _exp_0 = App.platform -- 24
	if "iOS" == _exp_0 or "Android" == _exp_0 or "macOS" == _exp_0 then -- 25
		controlChoice = 0 -- 25
	else -- 26
		controlChoice = 1 -- 26
	end -- 24
end -- 24
local camZoom = world.camera.zoom -- 27
local decisions = { } -- 28
local showDecisionTrace = false -- 29
local lastDecisionTree = "" -- 30
local _anon_func_0 = function(controlChoice) -- 135
	if controlChoice == 1 then -- 135
		return "Keyboard: Left(A), Right(D), Shoot(J), Jump(K)" -- 136
	else -- 137
		return "TouchPad: Use buttons in lower screen to control unit." -- 137
	end -- 135
end -- 135
world:schedule(function() -- 31
	local width = App.visualSize.width -- 32
	SetNextWindowPos(Vec2(width - 250, 10), "FirstUseEver") -- 33
	SetNextWindowSize(Vec2(240, userControl and 500 or 300)) -- 34
	Begin("Zombie Game Demo", { -- 35
		"NoResize", -- 35
		"NoSavedSettings" -- 35
	}, function() -- 35
		TextWrapped("Zombie Killed: " .. tostring(Store.zombieKilled)) -- 36
		SameLine() -- 37
		if Button("Army") then -- 38
			for _i = 0, 10 do -- 39
				local available = false -- 40
				local pos = Vec2.zero -- 41
				while not available do -- 42
					pos = Vec2(App.rand % 2400 - 1200, -430) -- 43
					available = not world:query(Rect(pos, Size(5, 5)), function(self) -- 44
						return self.group == Data.groupTerrain -- 44
					end) -- 44
				end -- 42
				Entity({ -- 46
					unitDef = "Unit_Zombie" .. tostring(App.rand % 2 + 1), -- 46
					order = ZombieLayer, -- 47
					position = pos, -- 48
					group = PlayerGroup, -- 49
					faceRight = App.rand % 2 == 0, -- 50
					stared = true -- 51
				}) -- 45
			end -- 39
		end -- 38
		local changed -- 52
		changed, camZoom = DragFloat("Zoom", camZoom, 0.01, 0.5, 2, "%.2f") -- 52
		if changed then -- 53
			world.camera.zoom = camZoom -- 53
		end -- 53
		playerGroup:each(function(self) -- 54
			return TextWrapped(tostring(self.unit.tag) .. " HP: " .. tostring(self.hp)) -- 54
		end) -- 54
		local result -- 55
		changed, result = Checkbox("Physics Debug", world.showDebug) -- 55
		if changed then -- 56
			world.showDebug = result -- 56
		end -- 56
		changed, showDecisionTrace = Checkbox("AI Debug", showDecisionTrace) -- 57
		if changed then -- 58
			playerGroup:each(function(self) -- 59
				self.unit.receivingDecisionTrace = showDecisionTrace -- 59
			end) -- 59
		end -- 58
		changed, userControl = Checkbox("Take Control", userControl) -- 60
		if userControl then -- 61
			if Store.controlPlayer == "Zombie" and not playerGroup:each(function(self) -- 63
				if self.unit.tag == "Zombie" then -- 64
					if self.hp <= 0 then -- 65
						self.player = nil -- 66
						self.unit.children.last:removeFromParent() -- 67
						self.unit.decisionTree = "" -- 68
						self.unit.tag = "ZombieDead" -- 69
						return false -- 70
					else -- 71
						return true -- 71
					end -- 65
				end -- 64
				return false -- 72
			end) then -- 62
				zombieGroup:each(function(self) -- 73
					if self.hp <= 0 then -- 74
						return false -- 74
					end -- 74
					self.player = true -- 75
					self.zombie = nil -- 76
					do -- 77
						local _with_0 = self.unit -- 77
						_with_0.tag = "Zombie" -- 78
						_with_0.group = PlayerGroup -- 79
						_with_0.decisionTree = "AI_PlayerControl" -- 80
						_with_0.sensity = 0 -- 81
						_with_0:addChild(Star({ -- 83
							y = 100, -- 83
							size = 18, -- 84
							borderColor = 0xffff8800, -- 85
							fillColor = 0x66ff8800, -- 86
							fillOrder = 1, -- 87
							lineOrder = 2 -- 88
						})) -- 82
						world.camera.followTarget = _with_0 -- 77
					end -- 77
					return true -- 90
				end) -- 73
			end -- 62
			Separator() -- 91
			local pressedA, choice = RadioButton("Male", playerChoice, 0) -- 92
			if pressedA then -- 93
				playerChoice = choice -- 93
			end -- 93
			local pressedB -- 94
			pressedB, choice = RadioButton("Female", playerChoice, 1) -- 94
			if pressedB then -- 95
				playerChoice = choice -- 95
			end -- 95
			local pressedC -- 96
			pressedC, choice = RadioButton("Zombie", playerChoice, 2) -- 96
			if pressedC then -- 97
				playerChoice = choice -- 97
			end -- 97
			if pressedA or pressedB or pressedC or changed then -- 98
				if 0 == playerChoice then -- 100
					Store.controlPlayer = "KidM" -- 100
				elseif 1 == playerChoice then -- 101
					Store.controlPlayer = "KidW" -- 101
				elseif 2 == playerChoice then -- 102
					Store.controlPlayer = "Zombie" -- 102
				end -- 99
				if Store.controlPlayer == "Zombie" and not playerGroup:each(function(self) -- 104
					return self.unit.tag == "Zombie" -- 104
				end) then -- 103
					zombieGroup:each(function(self) -- 105
						self.player = true -- 106
						self.zombie = nil -- 107
						do -- 108
							local _with_0 = self.unit -- 108
							_with_0.tag = "Zombie" -- 109
							_with_0.group = PlayerGroup -- 110
							_with_0:addChild(Star({ -- 112
								y = 100, -- 112
								size = 18, -- 113
								borderColor = 0xffff8800, -- 114
								fillColor = 0x66ff8800, -- 115
								fillOrder = 1, -- 116
								lineOrder = 2 -- 117
							})) -- 111
						end -- 108
						return true -- 119
					end) -- 105
				end -- 103
				playerGroup:each(function(self) -- 120
					if self.unit.tag == Store.controlPlayer then -- 121
						self.unit.decisionTree = "AI_PlayerControl" -- 122
						self.unit.sensity = 0 -- 123
						world.camera.followTarget = self.unit -- 124
					else -- 126
						do -- 126
							local _exp_0 = self.unit.tag -- 126
							if "KidM" == _exp_0 then -- 127
								self.unit.decisionTree = "AI_KidFollow" -- 127
							elseif "KidW" == _exp_0 then -- 128
								self.unit.decisionTree = "AI_KidSearch" -- 128
							elseif "Zombie" == _exp_0 then -- 129
								self.unit.decisionTree = "AI_Zombie" -- 129
							end -- 126
						end -- 126
						self.unit.sensity = 0.1 -- 130
					end -- 121
				end) -- 120
			end -- 98
			if changed then -- 131
				Store.keyboardEnabled = controlChoice == 1 -- 132
				Director.ui.children.first.visible = controlChoice == 0 -- 133
			end -- 131
			Separator() -- 134
			TextWrapped(_anon_func_0(controlChoice)) -- 135
			Separator() -- 138
			pressedA, choice = RadioButton("TouchPad", controlChoice, 0) -- 139
			if pressedA then -- 140
				controlChoice = choice -- 141
				Store.keyboardEnabled = false -- 142
				Director.ui:eachChild(function(self) -- 143
					self.visible = true -- 143
				end) -- 143
			end -- 140
			pressedB, choice = RadioButton("Keyboard", controlChoice, 1) -- 144
			if pressedB then -- 145
				controlChoice = choice -- 146
				Store.keyboardEnabled = true -- 147
				Director.ui.children.first.visible = false -- 148
			end -- 145
		elseif changed then -- 149
			playerGroup:each(function(self) -- 150
				do -- 151
					local _exp_0 = self.unit.tag -- 151
					if "KidM" == _exp_0 then -- 152
						self.unit.decisionTree = "AI_KidFollow" -- 152
					elseif "KidW" == _exp_0 then -- 153
						self.unit.decisionTree = "AI_KidSearch" -- 153
					elseif "Zombie" == _exp_0 then -- 154
						self.unit.decisionTree = "AI_Zombie" -- 154
					end -- 151
				end -- 151
				self.unit.sensity = 0.1 -- 155
			end) -- 150
			Store.keyboardEnabled = false -- 156
			Director.ui.children.first.visible = false -- 157
		end -- 61
	end) -- 35
	local target = world.camera.followTarget -- 159
	if target then -- 160
		local player = target.entity -- 161
		local decisionTrace = player.decisionTrace -- 162
		local lastDecision = decisions[#decisions] -- 163
		if lastDecision ~= decisionTrace then -- 164
			decisions[#decisions + 1] = decisionTrace -- 165
		end -- 164
		if #decisions > 5 then -- 166
			table.remove(decisions, 1) -- 166
		end -- 166
		lastDecisionTree = target.decisionTree -- 167
	end -- 160
	if showDecisionTrace then -- 169
		SetNextWindowPos(Vec2(width / 2 - 200, 10), "FirstUseEver") -- 170
		SetNextWindowSize(Vec2(400, 160), "FirstUseEver") -- 171
		return Begin("Decision Trace (" .. tostring(lastDecisionTree) .. ")", { -- 172
			"NoSavedSettings" -- 172
		}, function() -- 172
			return Text(table.concat(decisions, "\n")) -- 173
		end) -- 172
	end -- 169
end) -- 31
do -- 175
	local _with_0 = Observer("Add", { -- 175
		"group", -- 175
		"unit", -- 175
		"player", -- 175
		"stared" -- 175
	}) -- 175
	_with_0:watch(function(_entity, _group, unit) -- 176
		unit:addChild(Star({ -- 178
			y = 100, -- 178
			size = 18, -- 179
			borderColor = 0xff66ccff, -- 180
			fillColor = 0x6666ccff, -- 181
			fillOrder = 1, -- 182
			lineOrder = 2 -- 183
		})) -- 177
		return false -- 176
	end) -- 176
end -- 175
local _with_0 = Observer("Add", { -- 186
	"unit", -- 186
	"player" -- 186
}) -- 186
_with_0:watch(function(_entity, unit) -- 187
	unit.receivingDecisionTrace = true -- 187
	return false -- 187
end) -- 187
return _with_0 -- 186
