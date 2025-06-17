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
			y = 1 -- 134
			return y -- 134
		end -- 134
	) -- 134
	node:gslot( -- 135
		"Input.Down", -- 135
		function() -- 135
			y = -1 -- 135
			return y -- 135
		end -- 135
	) -- 135
	node:gslot( -- 136
		"Input.Left", -- 136
		function() -- 136
			x = -1 -- 136
			return x -- 136
		end -- 136
	) -- 136
	node:gslot( -- 137
		"Input.Right", -- 137
		function() -- 137
			x = 1 -- 137
			return x -- 137
		end -- 137
	) -- 137
	node:loop(function() -- 138
		local direction = Vec2(x, y):normalize() -- 139
		if direction.length > 0 then -- 139
			node.angle = -math.deg(math.atan(direction.y, direction.x)) + 90 -- 141
		end -- 141
		local newPos = node.position:add(Vec2(x, y):normalize():mul(10)) -- 143
		node.position = newPos:clamp( -- 144
			Vec2(-hw + 40, -hh + 40), -- 144
			Vec2(hw - 40, hh - 40) -- 144
		) -- 144
		x = 0 -- 145
		y = 0 -- 145
		return false -- 146
	end) -- 138
	local animNode = Node():addTo(node) -- 148
	playAnimation(animNode, "playerGrey_walk") -- 149
end -- 112
local function Background() -- 152
	return React.createElement( -- 152
		"draw-node", -- 152
		nil, -- 152
		React.createElement("rect-shape", {width = width, height = height, fillColor = 4283132780}) -- 152
	) -- 152
end -- 152
StartUp = function() -- 154
	inputManager:popContext() -- 155
	inputManager:pushContext("UI") -- 156
	return React.createElement( -- 157
		React.Fragment, -- 157
		nil, -- 157
		React.createElement(Background, nil), -- 157
		React.createElement("label", {fontName = "Xolonium-Regular", fontSize = 80, text = "Dodge the Creeps!", textWidth = 400}), -- 157
		React.createElement( -- 157
			"draw-node", -- 157
			{y = -150}, -- 157
			React.createElement("rect-shape", {width = 250, height = 80, fillColor = 4282006074}), -- 157
			React.createElement("label", {fontName = "Xolonium-Regular", fontSize = 60, text = "Start"}), -- 157
			React.createElement( -- 157
				"node", -- 157
				{ -- 157
					width = 250, -- 157
					height = 80, -- 157
					onTapped = function() return emit("Input.Start") end, -- 157
					onMount = function(node) -- 157
						node:gslot( -- 165
							"Input.Start", -- 165
							function() -- 165
								Director.entry:removeAllChildren() -- 166
								toNode(React.createElement(Game, nil)) -- 167
							end -- 165
						) -- 165
					end -- 164
				} -- 164
			) -- 164
		) -- 164
	) -- 164
end -- 154
Game = function() -- 175
	inputManager:popContext() -- 176
	inputManager:pushContext("Game") -- 177
	local score = 0 -- 178
	local label = useRef() -- 179
	Audio:playStream("Audio/House In a Forest Loop.ogg", true) -- 180
	return React.createElement( -- 181
		"clip-node", -- 181
		{stencil = React.createElement(Background, nil)}, -- 181
		React.createElement(Background, nil), -- 181
		React.createElement( -- 181
			"physics-world", -- 181
			{onMount = function(world) -- 181
				Player(world) -- 185
				world:once(function() -- 186
					local msg = toNode(React.createElement("label", {fontName = "Xolonium-Regular", fontSize = 80, text = "Get Ready!", y = 200})) -- 187
					sleep(1) -- 190
					if msg ~= nil then -- 190
						msg:removeFromParent() -- 191
					end -- 191
					if label.current then -- 191
						label.current.visible = true -- 193
					end -- 193
					world:loop(function() -- 195
						sleep(0.5) -- 196
						Enemy(world, score) -- 197
						return false -- 198
					end) -- 195
				end) -- 186
			end}, -- 184
			React.createElement("contact", {groupA = 0, groupB = 0, enabled = false}), -- 184
			React.createElement("contact", {groupA = 0, groupB = 1, enabled = true}), -- 184
			React.createElement( -- 184
				"body", -- 184
				{ -- 184
					type = "Static", -- 184
					group = 1, -- 184
					onBodyLeave = function() -- 184
						score = score + 1 -- 205
						if label.current then -- 205
							label.current.text = tostring(score) -- 207
						end -- 207
					end -- 204
				}, -- 204
				React.createElement("rect-fixture", {sensorTag = 0, width = width, height = height}) -- 204
			) -- 204
		), -- 204
		React.createElement("label", { -- 204
			ref = label, -- 204
			fontName = "Xolonium-Regular", -- 204
			fontSize = 60, -- 204
			text = "0", -- 204
			y = 300, -- 204
			visible = false -- 204
		}) -- 204
	) -- 204
end -- 175
toNode(React.createElement(StartUp, nil)) -- 218
return ____exports -- 218