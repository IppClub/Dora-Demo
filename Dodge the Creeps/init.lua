-- [tsx]: init.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local ____exports = {} -- 1
local StartUp, Game -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local reference = ____DoraX.reference -- 2
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
local App = ____Dora.App -- 3
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
local inputManager = CreateManager({ -- 26
	Game = { -- 27
		Up = Pressed("W", "dpup"), -- 28
		Down = Pressed("S", "dpdown"), -- 29
		Left = Pressed("A", "dpleft"), -- 30
		Right = Pressed("D", "dpright") -- 31
	}, -- 31
	UI = {Start = Trigger.Selector({ -- 33
		Trigger.KeyDown("Return"), -- 35
		Trigger.ButtonDown("start") -- 36
	})} -- 36
}) -- 36
local InputUp = inputManager:getEventName("Up") -- 41
local InputDown = inputManager:getEventName("Down") -- 42
local InputLeft = inputManager:getEventName("Left") -- 43
local InputRight = inputManager:getEventName("Right") -- 44
local InputStart = inputManager:getEventName("Start") -- 45
inputManager:getNode():addTo(Director.ui) -- 47
local ____opt_0 = toNode(React.createElement(GamePad, { -- 47
	inputManager = inputManager, -- 47
	noLeftStick = true, -- 47
	noRightStick = true, -- 47
	noButtonPad = true, -- 47
	noTriggerPad = true, -- 47
	noControlPad = true -- 47
})) -- 47
if ____opt_0 ~= nil then -- 47
	____opt_0:addTo(Director.ui) -- 49
end -- 49
local function playAnimation(node, name) -- 61
	node:removeAllChildren() -- 62
	local interval = 0.2 -- 63
	local frames = { -- 64
		Sprite(("Image/art.clip|" .. name) .. "1") or Sprite(), -- 65
		Sprite(("Image/art.clip|" .. name) .. "2") or Sprite() -- 66
	} -- 66
	for ____, frame in ipairs(frames) do -- 68
		if __TS__StringStartsWith(name, "enemy") then -- 68
			frame.angle = -90 -- 70
		end -- 70
		frame:addTo(node) -- 72
	end -- 72
	local i = 0 -- 74
	node:loop(function() -- 75
		frames[i + 1].visible = true -- 76
		i = (i + 1) % 2 -- 77
		frames[i + 1].visible = false -- 78
		sleep(interval) -- 79
		return false -- 80
	end) -- 75
end -- 61
local width = 480 -- 84
local height = 700 -- 85
local hw = width / 2 -- 86
local hh = height / 2 -- 87
local DesignSceneHeight = height -- 89
local function updateViewSize() -- 90
	local camera = tolua.cast(Director.currentCamera, "Camera2D") -- 91
	if camera then -- 91
		camera.zoom = View.size.height / DesignSceneHeight -- 93
	end -- 93
end -- 90
updateViewSize() -- 96
Director.entry:onAppChange(function(settingName) -- 97
	if settingName == "Size" then -- 97
		updateViewSize() -- 99
	end -- 99
end) -- 97
local function Enemy(world, score) -- 103
	local dir = math.random(0, 3) -- 104
	local angle = math.random(dir * 90 + 25, dir * 90 + 180 - 25) -- 105
	local pos = Vec2.zero -- 106
	local minW = -hw - 40 -- 107
	local maxW = hw + 40 -- 107
	local minH = -hh - 40 -- 108
	local maxH = hh + 40 -- 108
	local randW = math.random(minW, maxW) -- 109
	local randH = math.random(minH, maxH) -- 110
	repeat -- 110
		local ____switch13 = dir -- 110
		local ____cond13 = ____switch13 == 0 -- 110
		if ____cond13 then -- 110
			pos = Vec2(minW, randH) -- 112
			break -- 112
		end -- 112
		____cond13 = ____cond13 or ____switch13 == 1 -- 112
		if ____cond13 then -- 112
			pos = Vec2(randW, maxH) -- 113
			break -- 113
		end -- 113
		____cond13 = ____cond13 or ____switch13 == 2 -- 113
		if ____cond13 then -- 113
			pos = Vec2(maxW, randH) -- 114
			break -- 114
		end -- 114
		____cond13 = ____cond13 or ____switch13 == 3 -- 114
		if ____cond13 then -- 114
			pos = Vec2(randW, minH) -- 115
			break -- 115
		end -- 115
	until true -- 115
	local radian = math.rad(angle) -- 117
	local velocity = Vec2( -- 118
		math.sin(radian), -- 118
		math.cos(radian) -- 118
	):normalize():mul(200 + score * 2) -- 118
	local ____opt_2 = toNode(React.createElement( -- 118
		"body", -- 118
		{ -- 118
			world = world, -- 118
			group = 0, -- 118
			type = "Dynamic", -- 118
			linearAcceleration = Vec2.zero, -- 118
			x = pos.x, -- 118
			y = pos.y, -- 118
			velocityX = velocity.x, -- 118
			velocityY = velocity.y, -- 118
			angle = angle, -- 118
			onMount = function(node) -- 118
				local enemys = {"enemyFlyingAlt_", "enemySwimming_", "enemyWalking_"} -- 123
				playAnimation( -- 124
					node, -- 124
					enemys[math.random(0, 2) + 1] -- 124
				) -- 124
			end -- 122
		}, -- 122
		React.createElement("disk-fixture", {radius = 40}) -- 122
	)) -- 122
	if ____opt_2 ~= nil then -- 122
		____opt_2:addTo(world) -- 119
	end -- 119
end -- 103
local function Player(world) -- 131
	local node -- 132
	node = toNode(React.createElement( -- 132
		"body", -- 132
		{ -- 132
			world = world, -- 132
			group = 1, -- 132
			type = "Dynamic", -- 132
			linearAcceleration = Vec2.zero, -- 132
			onContactStart = function(other) -- 132
				if other.group == 0 then -- 132
					toNode(React.createElement("label", {fontName = "Xolonium-Regular", fontSize = 80, text = "Game Over", textWidth = 300})) -- 136
					if node ~= nil then -- 136
						node:removeFromParent() -- 137
					end -- 137
					thread(function() -- 138
						sleep(2) -- 139
						Director.entry:removeAllChildren() -- 140
						toNode(React.createElement(StartUp, nil)) -- 141
					end) -- 138
					Audio:stopStream(0.5) -- 143
					Audio:play("Audio/gameover.wav") -- 144
				end -- 144
			end -- 134
		}, -- 134
		React.createElement("disk-fixture", {radius = 40}) -- 134
	)) -- 134
	if not node then -- 134
		error("failed to create player!") -- 150
	end -- 150
	node:addTo(world) -- 151
	local x = 0 -- 152
	local y = 0 -- 152
	node:gslot( -- 153
		InputUp, -- 153
		function() -- 153
			y = 1 -- 153
			return y -- 153
		end -- 153
	) -- 153
	node:gslot( -- 154
		InputDown, -- 154
		function() -- 154
			y = -1 -- 154
			return y -- 154
		end -- 154
	) -- 154
	node:gslot( -- 155
		InputLeft, -- 155
		function() -- 155
			x = -1 -- 155
			return x -- 155
		end -- 155
	) -- 155
	node:gslot( -- 156
		InputRight, -- 156
		function() -- 156
			x = 1 -- 156
			return x -- 156
		end -- 156
	) -- 156
	node:loop(function() -- 157
		local direction = Vec2(x, y):normalize() -- 158
		if direction.length > 0 then -- 158
			node.angle = -math.deg(math.atan(direction.y, direction.x)) + 90 -- 160
		end -- 160
		local newPos = node.position:add(Vec2(x, y):normalize():mul(10 * 60 * App.deltaTime)) -- 162
		node.position = newPos:clamp( -- 163
			Vec2(-hw + 40, -hh + 40), -- 163
			Vec2(hw - 40, hh - 40) -- 163
		) -- 163
		x = 0 -- 164
		y = 0 -- 164
		return false -- 165
	end) -- 157
	local animNode = Node():addTo(node) -- 167
	playAnimation(animNode, "playerGrey_walk") -- 168
end -- 131
local function Background() -- 171
	return React.createElement( -- 171
		"draw-node", -- 171
		nil, -- 171
		React.createElement("rect-shape", {width = width, height = height, fillColor = 4283132780}) -- 171
	) -- 171
end -- 171
StartUp = function() -- 173
	inputManager:popContext() -- 174
	inputManager:pushContext("UI") -- 175
	return React.createElement( -- 176
		React.Fragment, -- 176
		nil, -- 176
		React.createElement(Background, nil), -- 176
		React.createElement("label", {fontName = "Xolonium-Regular", fontSize = 80, text = "Dodge the Creeps!", textWidth = 400}), -- 176
		React.createElement( -- 176
			"draw-node", -- 176
			{y = -150}, -- 176
			React.createElement("rect-shape", {width = 250, height = 80, fillColor = 4282006074}), -- 176
			React.createElement("label", {fontName = "Xolonium-Regular", fontSize = 60, text = "Start"}), -- 176
			React.createElement( -- 176
				"node", -- 176
				{ -- 176
					width = 250, -- 176
					height = 80, -- 176
					onTapped = function() return emit(InputStart) end, -- 176
					onMount = function(node) -- 176
						node:gslot( -- 184
							InputStart, -- 184
							function() -- 184
								Director.entry:removeAllChildren() -- 185
								toNode(React.createElement(Game, nil)) -- 186
							end -- 184
						) -- 184
					end -- 183
				} -- 183
			) -- 183
		) -- 183
	) -- 183
end -- 173
Game = function() -- 194
	inputManager:popContext() -- 195
	inputManager:pushContext("Game") -- 196
	local score = 0 -- 197
	local label = reference() -- 198
	Audio:playStream("Audio/House In a Forest Loop.ogg", true) -- 199
	return React.createElement( -- 200
		"clip-node", -- 200
		{stencil = React.createElement(Background, nil)}, -- 200
		React.createElement(Background, nil), -- 200
		React.createElement( -- 200
			"physics-world", -- 200
			{onMount = function(world) -- 200
				Player(world) -- 204
				world:once(function() -- 205
					local msg = toNode(React.createElement("label", {fontName = "Xolonium-Regular", fontSize = 80, text = "Get Ready!", y = 200})) -- 206
					sleep(1) -- 209
					if msg ~= nil then -- 209
						msg:removeFromParent() -- 210
					end -- 210
					if label.current then -- 210
						label.current.visible = true -- 212
					end -- 212
					world:loop(function() -- 214
						sleep(0.5) -- 215
						Enemy(world, score) -- 216
						return false -- 217
					end) -- 214
				end) -- 205
			end}, -- 203
			React.createElement("contact", {groupA = 0, groupB = 0, enabled = false}), -- 203
			React.createElement("contact", {groupA = 0, groupB = 1, enabled = true}), -- 203
			React.createElement( -- 203
				"body", -- 203
				{ -- 203
					type = "Static", -- 203
					group = 1, -- 203
					onBodyLeave = function() -- 203
						score = score + 1 -- 224
						if label.current then -- 224
							label.current.text = tostring(score) -- 226
						end -- 226
					end -- 223
				}, -- 223
				React.createElement("rect-fixture", {sensorTag = 0, width = width, height = height}) -- 223
			) -- 223
		), -- 223
		React.createElement("label", { -- 223
			ref = label, -- 223
			fontName = "Xolonium-Regular", -- 223
			fontSize = 60, -- 223
			text = "0", -- 223
			y = 300, -- 223
			visible = false -- 223
		}) -- 223
	) -- 223
end -- 194
toNode(React.createElement(StartUp, nil)) -- 237
return ____exports -- 237