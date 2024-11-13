-- [tsx]: init.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local ____exports = {} -- 1
local StartUp, Game -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local useRef = ____DoraX.useRef -- 2
local ____Dora = require("Dora") -- 3
local Audio = ____Dora.Audio -- 3
local Director = ____Dora.Director -- 3
local Node = ____Dora.Node -- 3
local Sprite = ____Dora.Sprite -- 3
local Vec2 = ____Dora.Vec2 -- 3
local View = ____Dora.View -- 3
local emit = ____Dora.emit -- 3
local sleep = ____Dora.sleep -- 3
local thread = ____Dora.thread -- 3
local tolua = ____Dora.tolua -- 3
local ____InputManager = require("InputManager") -- 4
local CreateManager = ____InputManager.CreateManager -- 4
local Trigger = ____InputManager.Trigger -- 4
local GamePad = ____InputManager.GamePad -- 4
local function Pressed(keyName, buttonName) -- 6
	return Trigger.Selector({ -- 7
		Trigger.KeyPressed(keyName), -- 8
		Trigger.ButtonPressed(buttonName) -- 9
	}) -- 9
end -- 6
local inputManager = CreateManager({ -- 13
	Game = { -- 14
		Up = Pressed("W", "dpup"), -- 15
		Down = Pressed("S", "dpdown"), -- 16
		Left = Pressed("A", "dpleft"), -- 17
		Right = Pressed("D", "dpright") -- 18
	}, -- 18
	UI = {Start = Trigger.Selector({ -- 20
		Trigger.KeyDown("Return"), -- 22
		Trigger.ButtonDown("start") -- 23
	})} -- 23
}) -- 23
inputManager:getNode():addTo(Director.ui) -- 28
local ____opt_0 = toNode(React.createElement(GamePad, { -- 28
	inputManager = inputManager, -- 28
	noLeftStick = true, -- 28
	noRightStick = true, -- 28
	noButtonPad = true, -- 28
	noTriggerPad = true, -- 28
	noControlPad = true -- 28
})) -- 28
if ____opt_0 ~= nil then -- 28
	____opt_0:addTo(Director.ui) -- 30
end -- 30
local function playAnimation(node, name) -- 42
	node:removeAllChildren() -- 43
	local interval = 0.2 -- 44
	local frames = { -- 45
		Sprite(("Image/art.clip|" .. name) .. "1") or Sprite(), -- 46
		Sprite(("Image/art.clip|" .. name) .. "2") or Sprite() -- 47
	} -- 47
	for ____, frame in ipairs(frames) do -- 49
		if __TS__StringStartsWith(name, "enemy") then -- 49
			frame.angle = -90 -- 51
		end -- 51
		frame:addTo(node) -- 53
	end -- 53
	local i = 0 -- 55
	node:loop(function() -- 56
		frames[i + 1].visible = true -- 57
		i = (i + 1) % 2 -- 58
		frames[i + 1].visible = false -- 59
		sleep(interval) -- 60
		return false -- 61
	end) -- 56
end -- 42
local width = 480 -- 65
local height = 700 -- 66
local hw = width / 2 -- 67
local hh = height / 2 -- 68
local DesignSceneHeight = height -- 70
local function updateViewSize() -- 71
	local camera = tolua.cast(Director.currentCamera, "Camera2D") -- 72
	if camera then -- 72
		camera.zoom = View.size.height / DesignSceneHeight -- 74
	end -- 74
end -- 71
updateViewSize() -- 77
Director.entry:onAppChange(function(settingName) -- 78
	if settingName == "Size" then -- 78
		updateViewSize() -- 80
	end -- 80
end) -- 78
local function Enemy(world, score) -- 84
	local dir = math.random(0, 3) -- 85
	local angle = math.random(dir * 90 + 25, dir * 90 + 180 - 25) -- 86
	local pos = Vec2.zero -- 87
	local minW = -hw - 40 -- 88
	local maxW = hw + 40 -- 88
	local minH = -hh - 40 -- 89
	local maxH = hh + 40 -- 89
	local randW = math.random(minW, maxW) -- 90
	local randH = math.random(minH, maxH) -- 91
	repeat -- 91
		local ____switch13 = dir -- 91
		local ____cond13 = ____switch13 == 0 -- 91
		if ____cond13 then -- 91
			pos = Vec2(minW, randH) -- 93
			break -- 93
		end -- 93
		____cond13 = ____cond13 or ____switch13 == 1 -- 93
		if ____cond13 then -- 93
			pos = Vec2(randW, maxH) -- 94
			break -- 94
		end -- 94
		____cond13 = ____cond13 or ____switch13 == 2 -- 94
		if ____cond13 then -- 94
			pos = Vec2(maxW, randH) -- 95
			break -- 95
		end -- 95
		____cond13 = ____cond13 or ____switch13 == 3 -- 95
		if ____cond13 then -- 95
			pos = Vec2(randW, minH) -- 96
			break -- 96
		end -- 96
	until true -- 96
	local radian = math.rad(angle) -- 98
	local velocity = Vec2( -- 99
		math.sin(radian), -- 99
		math.cos(radian) -- 99
	):normalize():mul(200 + score * 2) -- 99
	local ____opt_2 = toNode(React.createElement( -- 99
		"body", -- 99
		{ -- 99
			world = world, -- 99
			group = 0, -- 99
			type = "Dynamic", -- 99
			linearAcceleration = Vec2.zero, -- 99
			x = pos.x, -- 99
			y = pos.y, -- 99
			velocityX = velocity.x, -- 99
			velocityY = velocity.y, -- 99
			angle = angle, -- 99
			onMount = function(node) -- 99
				local enemys = {"enemyFlyingAlt_", "enemySwimming_", "enemyWalking_"} -- 104
				playAnimation( -- 105
					node, -- 105
					enemys[math.random(0, 2) + 1] -- 105
				) -- 105
			end -- 103
		}, -- 103
		React.createElement("disk-fixture", {radius = 40}) -- 103
	)) -- 103
	if ____opt_2 ~= nil then -- 103
		____opt_2:addTo(world) -- 100
	end -- 100
end -- 84
local function Player(world) -- 112
	local node -- 113
	node = toNode(React.createElement( -- 113
		"body", -- 113
		{ -- 113
			world = world, -- 113
			group = 1, -- 113
			type = "Dynamic", -- 113
			linearAcceleration = Vec2.zero, -- 113
			onContactStart = function(other) -- 113
				if other.group == 0 then -- 113
					toNode(React.createElement("label", {fontName = "Xolonium-Regular", fontSize = 80, text = "Game Over", textWidth = 300})) -- 117
					if node ~= nil then -- 117
						node:removeFromParent() -- 118
					end -- 118
					thread(function() -- 119
						sleep(2) -- 120
						Director.entry:removeAllChildren() -- 121
						toNode(React.createElement(StartUp, nil)) -- 122
					end) -- 119
					Audio:stopStream(0.5) -- 124
					Audio:play("Audio/gameover.wav") -- 125
				end -- 125
			end -- 115
		}, -- 115
		React.createElement("disk-fixture", {radius = 40}) -- 115
	)) -- 115
	if not node then -- 115
		error("failed to create player!") -- 131
	end -- 131
	node:addTo(world) -- 132
	local x = 0 -- 133
	local y = 0 -- 133
	node:gslot( -- 134
		"Input.Up", -- 134
		function() -- 134
			y = 1 -- 135
			node.angle = 0 -- 136
		end -- 134
	) -- 134
	node:gslot( -- 138
		"Input.Down", -- 138
		function() -- 138
			y = -1 -- 139
			node.angle = 180 -- 140
		end -- 138
	) -- 138
	node:gslot( -- 142
		"Input.Left", -- 142
		function() -- 142
			x = -1 -- 142
			return x -- 142
		end -- 142
	) -- 142
	node:gslot( -- 143
		"Input.Right", -- 143
		function() -- 143
			x = 1 -- 143
			return x -- 143
		end -- 143
	) -- 143
	node:loop(function() -- 144
		local newPos = node.position:add(Vec2(x, y):normalize():mul(10)) -- 145
		node.position = newPos:clamp( -- 146
			Vec2(-hw + 40, -hh + 40), -- 146
			Vec2(hw - 40, hh - 40) -- 146
		) -- 146
		x = 0 -- 147
		y = 0 -- 147
		return false -- 148
	end) -- 144
	local animNode = Node():addTo(node) -- 150
	playAnimation(animNode, "playerGrey_walk") -- 151
end -- 112
local function Rect() -- 154
	return React.createElement( -- 154
		"draw-node", -- 154
		nil, -- 154
		React.createElement("rect-shape", {width = width, height = height, fillColor = 4283132780}) -- 154
	) -- 154
end -- 154
StartUp = function() -- 156
	inputManager:popContext() -- 157
	inputManager:pushContext("UI") -- 158
	return React.createElement( -- 159
		React.Fragment, -- 159
		nil, -- 159
		React.createElement(Rect, nil), -- 159
		React.createElement("label", {fontName = "Xolonium-Regular", fontSize = 80, text = "Dodge the Creeps!", textWidth = 400}), -- 159
		React.createElement( -- 159
			"draw-node", -- 159
			{y = -150}, -- 159
			React.createElement("rect-shape", {width = 250, height = 80, fillColor = 4282006074}), -- 159
			React.createElement("label", {fontName = "Xolonium-Regular", fontSize = 60, text = "Start"}), -- 159
			React.createElement( -- 159
				"node", -- 159
				{ -- 159
					width = 250, -- 159
					height = 80, -- 159
					onTapped = function() return emit("Input.Start") end, -- 159
					onMount = function(node) -- 159
						node:gslot( -- 167
							"Input.Start", -- 167
							function() -- 167
								Director.entry:removeAllChildren() -- 168
								toNode(React.createElement(Game, nil)) -- 169
							end -- 167
						) -- 167
					end -- 166
				} -- 166
			) -- 166
		) -- 166
	) -- 166
end -- 156
Game = function() -- 177
	inputManager:popContext() -- 178
	inputManager:pushContext("Game") -- 179
	local score = 0 -- 180
	local label = useRef() -- 181
	Audio:playStream("Audio/House In a Forest Loop.ogg", true) -- 182
	return React.createElement( -- 183
		"clip-node", -- 183
		{stencil = React.createElement(Rect, nil)}, -- 183
		React.createElement(Rect, nil), -- 183
		React.createElement( -- 183
			"physics-world", -- 183
			{onMount = function(world) -- 183
				Player(world) -- 187
				world:once(function() -- 188
					local msg = toNode(React.createElement("label", {fontName = "Xolonium-Regular", fontSize = 80, text = "Get Ready!", y = 200})) -- 189
					sleep(1) -- 192
					if msg ~= nil then -- 192
						msg:removeFromParent() -- 193
					end -- 193
					if label.current then -- 193
						label.current.visible = true -- 195
					end -- 195
					world:loop(function() -- 197
						sleep(0.5) -- 198
						Enemy(world, score) -- 199
						return false -- 200
					end) -- 197
				end) -- 188
			end}, -- 186
			React.createElement("contact", {groupA = 0, groupB = 0, enabled = false}), -- 186
			React.createElement("contact", {groupA = 0, groupB = 1, enabled = true}), -- 186
			React.createElement("contact", {groupA = 1, groupB = 1, enabled = true}), -- 186
			React.createElement( -- 186
				"body", -- 186
				{ -- 186
					type = "Static", -- 186
					group = 1, -- 186
					onBodyLeave = function() -- 186
						score = score + 1 -- 208
						if label.current then -- 208
							label.current.text = tostring(score) -- 210
						end -- 210
					end -- 207
				}, -- 207
				React.createElement("rect-fixture", {sensorTag = 0, width = width, height = height}) -- 207
			) -- 207
		), -- 207
		React.createElement("label", { -- 207
			ref = label, -- 207
			fontName = "Xolonium-Regular", -- 207
			fontSize = 60, -- 207
			text = "0", -- 207
			y = 300, -- 207
			visible = false -- 207
		}) -- 207
	) -- 207
end -- 177
toNode(React.createElement(StartUp, nil)) -- 221
return ____exports -- 221