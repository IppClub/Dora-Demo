-- [yue]: Dora-Demo/Touch the Sky/init.yue
local _ENV = Dora(Dora.ImGui) -- 11
local Path <const> = Path -- 12
local Content <const> = Content -- 12
local Vec2 <const> = Vec2 -- 12
local Director <const> = Director -- 12
local View <const> = View -- 12
local Node <const> = Node -- 12
local Audio <const> = Audio -- 12
local PhysicsWorld <const> = PhysicsWorld -- 12
local BodyDef <const> = BodyDef -- 12
local Color <const> = Color -- 12
local DrawNode <const> = DrawNode -- 12
local Camera2D <const> = Camera2D -- 12
local Body <const> = Body -- 12
local Sprite <const> = Sprite -- 12
local math <const> = math -- 12
local tostring <const> = tostring -- 12
local once <const> = once -- 12
local sleep <const> = sleep -- 12
local threadLoop <const> = threadLoop -- 12
local App <const> = App -- 12
local SetNextWindowBgAlpha <const> = SetNextWindowBgAlpha -- 12
local SetNextWindowPos <const> = SetNextWindowPos -- 12
local SetNextWindowSize <const> = SetNextWindowSize -- 12
local Begin <const> = Begin -- 12
local Text <const> = Text -- 12
local Separator <const> = Separator -- 12
local TextWrapped <const> = TextWrapped -- 12
local Checkbox <const> = Checkbox -- 12
local scriptPath = Path:getScriptPath(...) -- 14
Content:insertSearchPath(1, scriptPath) -- 15
local gravity <const> = Vec2(0, -10) -- 17
local updateViewScale -- 19
updateViewScale = function() -- 19
	Director.currentCamera.zoom = View.size.width / 1620 -- 20
end -- 19
local root -- 21
do -- 21
	local _with_0 = Node() -- 21
	_with_0:onAppChange(function(settingName) -- 22
		if settingName == "Size" then -- 22
			return updateViewScale() -- 23
		end -- 22
	end) -- 22
	root = _with_0 -- 21
end -- 21
local ui -- 25
do -- 25
	local _with_0 = Node() -- 25
	_with_0:addTo(Director.ui) -- 26
	ui = _with_0 -- 25
end -- 25
local heartNode = nil -- 27
local restartButton = nil -- 28
Audio:playStream("sfx/bgm.ogg", true, 0.2) -- 29
local world -- 31
do -- 31
	local _with_0 = PhysicsWorld() -- 31
	_with_0:setShouldContact(0, 1, true) -- 32
	_with_0.showDebug = false -- 33
	_with_0:addTo(root) -- 34
	world = _with_0 -- 31
end -- 31
local restartGame = nil -- 36
local cube = nil -- 37
local touchTheSky = false -- 38
local isInvincible = false -- 39
local hardMode = false -- 40
local getCubeDef -- 42
getCubeDef = function(width, height) -- 42
	local _with_0 = BodyDef() -- 42
	_with_0.type = "Dynamic" -- 43
	_with_0.linearAcceleration = gravity -- 44
	_with_0.angularDamping = 1.8 -- 45
	_with_0:attachPolygon(width, height, 0.4, 0.4, 0.4) -- 47
	return _with_0 -- 42
end -- 42
local getBlockDef -- 49
getBlockDef = function(width, height) -- 49
	local _with_0 = BodyDef() -- 49
	_with_0.type = "Static" -- 50
	_with_0.linearAcceleration = gravity -- 51
	_with_0:attachPolygon(width, height, 0.4, 0.4, 0.4) -- 52
	return _with_0 -- 49
end -- 49
local colorWhite = Color(0xccffffff) -- 54
local colorRed = Color(0xaae65100) -- 55
local colorBlue = Color(0xaa00b0ff) -- 56
local borderHeight = 19000 -- 58
local borderWidth = 1600 -- 59
local borderPos = Vec2(0, 0) -- 60
local springForce = 1000 -- 62
local heart = 3 -- 63
local cubeInitPos = Vec2(0, 100) -- 64
local borderDef -- 66
do -- 66
	local _with_0 = BodyDef() -- 66
	_with_0.type = "Static" -- 67
	_with_0:attachPolygon(borderPos, borderWidth, 10, 0, 1, 1, 0) -- 68
	_with_0:attachPolygon(Vec2(borderPos.x + borderWidth / 2, borderPos.y + borderHeight / 2), 10, borderHeight, 0, 1, 1, 0) -- 69
	_with_0:attachPolygon(Vec2(borderPos.x - borderWidth / 2, borderPos.y + borderHeight / 2), 10, borderHeight, 0, 1, 1, 0) -- 70
	borderDef = _with_0 -- 66
end -- 66
local destinationDef -- 72
do -- 72
	local _with_0 = BodyDef() -- 72
	_with_0:attachPolygonSensor(1, borderWidth, 10) -- 73
	destinationDef = _with_0 -- 72
end -- 72
local blockLevel = { -- 75
	300, -- 75
	5200, -- 75
	9800, -- 75
	14400 -- 75
} -- 75
local blocks1 = { -- 78
	{ -- 78
		200, -- 78
		200, -- 78
		Vec2(-700, 0), -- 78
		2 -- 78
	}, -- 78
	{ -- 79
		1000, -- 79
		200, -- 79
		Vec2(300, 400), -- 79
		0 -- 79
	}, -- 79
	{ -- 80
		200, -- 80
		200, -- 80
		Vec2(500, 800), -- 80
		1 -- 80
	}, -- 80
	{ -- 81
		600, -- 81
		200, -- 81
		Vec2(-500, 1000), -- 81
		2 -- 81
	}, -- 81
	{ -- 82
		200, -- 82
		200, -- 82
		Vec2(-300, 1400), -- 82
		0 -- 82
	}, -- 82
	{ -- 83
		200, -- 83
		200, -- 83
		Vec2(-100, 1600), -- 83
		0 -- 83
	}, -- 83
	{ -- 84
		200, -- 84
		200, -- 84
		Vec2(-300, 2000), -- 84
		2 -- 84
	}, -- 84
	{ -- 85
		200, -- 85
		200, -- 85
		Vec2(-500, 2200), -- 85
		2 -- 85
	}, -- 85
	{ -- 86
		200, -- 86
		200, -- 86
		Vec2(500, 2200), -- 86
		0 -- 86
	}, -- 86
	{ -- 87
		200, -- 87
		200, -- 87
		Vec2(300, 2400), -- 87
		0 -- 87
	}, -- 87
	{ -- 88
		200, -- 88
		200, -- 88
		Vec2(500, 2600), -- 88
		1 -- 88
	}, -- 88
	{ -- 89
		200, -- 89
		200, -- 89
		Vec2(-500, 2800), -- 89
		0 -- 89
	}, -- 89
	{ -- 90
		200, -- 90
		200, -- 90
		Vec2(-300, 3000), -- 90
		0 -- 90
	}, -- 90
	{ -- 91
		200, -- 91
		400, -- 91
		Vec2(700, 3100), -- 91
		0 -- 91
	}, -- 91
	{ -- 92
		1200, -- 92
		200, -- 92
		Vec2(-200, 3600), -- 92
		2 -- 92
	} -- 92
} -- 77
local blocks2 = { -- 96
	{ -- 96
		200, -- 96
		1000, -- 96
		Vec2(-300, 0), -- 96
		2 -- 96
	}, -- 96
	{ -- 97
		200, -- 97
		200, -- 97
		Vec2(300, -200), -- 97
		1 -- 97
	}, -- 97
	{ -- 98
		200, -- 98
		1000, -- 98
		Vec2(300, 800), -- 98
		2 -- 98
	}, -- 98
	{ -- 99
		200, -- 99
		200, -- 99
		Vec2(300, 1400), -- 99
		1 -- 99
	}, -- 99
	{ -- 100
		200, -- 100
		1600, -- 100
		Vec2(-300, 1500), -- 100
		2 -- 100
	}, -- 100
	{ -- 101
		200, -- 101
		200, -- 101
		Vec2(-500, 2400), -- 101
		1 -- 101
	}, -- 101
	{ -- 102
		200, -- 102
		1200, -- 102
		Vec2(500, 2500), -- 102
		0 -- 102
	}, -- 102
	{ -- 103
		200, -- 103
		200, -- 103
		Vec2(-700, 3000), -- 103
		2 -- 103
	}, -- 103
	{ -- 104
		200, -- 104
		200, -- 104
		Vec2(-500, 3200), -- 104
		2 -- 104
	}, -- 104
	{ -- 105
		200, -- 105
		200, -- 105
		Vec2(-300, 3400), -- 105
		2 -- 105
	}, -- 105
	{ -- 106
		800, -- 106
		200, -- 106
		Vec2(400, 4000), -- 106
		0 -- 106
	} -- 106
} -- 95
local blocks3 = { -- 110
	{ -- 110
		200, -- 110
		4000, -- 110
		Vec2(-700, 1900), -- 110
		2 -- 110
	}, -- 110
	{ -- 111
		200, -- 111
		200, -- 111
		Vec2(-100, 400), -- 111
		2 -- 111
	}, -- 111
	{ -- 112
		200, -- 112
		200, -- 112
		Vec2(100, 600), -- 112
		1 -- 112
	}, -- 112
	{ -- 113
		200, -- 113
		200, -- 113
		Vec2(300, 1200), -- 113
		1 -- 113
	}, -- 113
	{ -- 114
		200, -- 114
		200, -- 114
		Vec2(100, 1400), -- 114
		1 -- 114
	}, -- 114
	{ -- 115
		200, -- 115
		200, -- 115
		Vec2(300, 1800), -- 115
		1 -- 115
	}, -- 115
	{ -- 116
		400, -- 116
		200, -- 116
		Vec2(600, 2000), -- 116
		0 -- 116
	}, -- 116
	{ -- 117
		200, -- 117
		200, -- 117
		Vec2(100, 3000), -- 117
		1 -- 117
	}, -- 117
	{ -- 118
		200, -- 118
		200, -- 118
		Vec2(300, 3200), -- 118
		1 -- 118
	}, -- 118
	{ -- 119
		200, -- 119
		200, -- 119
		Vec2(300, 3400), -- 119
		2 -- 119
	}, -- 119
	{ -- 120
		200, -- 120
		200, -- 120
		Vec2(100, 3600), -- 120
		1 -- 120
	}, -- 120
	{ -- 121
		200, -- 121
		200, -- 121
		Vec2(-100, 3800), -- 121
		1 -- 121
	}, -- 121
	{ -- 122
		400, -- 122
		200, -- 122
		Vec2(0, 4000), -- 122
		0 -- 122
	} -- 122
} -- 109
local blocks4 = { -- 126
	{ -- 126
		200, -- 126
		200, -- 126
		Vec2(-300, 0), -- 126
		1 -- 126
	}, -- 126
	{ -- 127
		200, -- 127
		200, -- 127
		Vec2(300, 0), -- 127
		1 -- 127
	}, -- 127
	{ -- 128
		200, -- 128
		200, -- 128
		Vec2(-500, 600), -- 128
		1 -- 128
	}, -- 128
	{ -- 129
		200, -- 129
		200, -- 129
		Vec2(100, 600), -- 129
		1 -- 129
	}, -- 129
	{ -- 130
		200, -- 130
		200, -- 130
		Vec2(700, 600), -- 130
		1 -- 130
	}, -- 130
	{ -- 131
		600, -- 131
		200, -- 131
		Vec2(0, 1200), -- 131
		0 -- 131
	}, -- 131
	{ -- 132
		200, -- 132
		600, -- 132
		Vec2(700, 1400), -- 132
		2 -- 132
	}, -- 132
	{ -- 133
		200, -- 133
		1000, -- 133
		Vec2(-700, 1800), -- 133
		2 -- 133
	}, -- 133
	{ -- 134
		200, -- 134
		600, -- 134
		Vec2(-100, 2200), -- 134
		2 -- 134
	}, -- 134
	{ -- 135
		200, -- 135
		600, -- 135
		Vec2(500, 2400), -- 135
		1 -- 135
	}, -- 135
	{ -- 136
		200, -- 136
		200, -- 136
		Vec2(100, 2800), -- 136
		2 -- 136
	}, -- 136
	{ -- 137
		200, -- 137
		200, -- 137
		Vec2(300, 3000), -- 137
		2 -- 137
	}, -- 137
	{ -- 138
		200, -- 138
		200, -- 138
		Vec2(-300, 3400), -- 138
		2 -- 138
	}, -- 138
	{ -- 139
		200, -- 139
		1200, -- 139
		Vec2(500, 3700), -- 139
		2 -- 139
	}, -- 139
	{ -- 140
		200, -- 140
		800, -- 140
		Vec2(-500, 3900), -- 140
		2 -- 140
	} -- 140
} -- 125
local blockTypes = { -- 144
	blocks1, -- 144
	blocks2, -- 145
	blocks3, -- 146
	blocks4 -- 147
} -- 143
local blockBodies = { } -- 149
local ropeNode -- 151
do -- 151
	local _with_0 = DrawNode() -- 151
	_with_0:addTo(root) -- 152
	ropeNode = _with_0 -- 151
end -- 151
local isGrabbing = false -- 153
local isGrabbed = false -- 154
local grabBlock = Node() -- 155
local emitRope -- 157
emitRope = function(cubeBody, endPoint) -- 157
	local startPoint = cubeBody.position -- 158
	local isBlock = false -- 159
	local isSelf = true -- 160
	local grabPoint = endPoint -- 161
	Audio:play("sfx/slime_touch.wav") -- 162
	world:raycast(startPoint, endPoint, false, function(_body, point) -- 163
		if isBlock then -- 164
			isGrabbed = true -- 165
			grabPoint = point -- 166
			isBlock = false -- 167
		end -- 164
		if isSelf then -- 168
			isSelf = false -- 169
			isBlock = true -- 170
		end -- 168
	end) -- 163
	ropeNode:schedule(function() -- 172
		ropeNode:clear() -- 173
		if not hardMode or isGrabbed then -- 174
			return ropeNode:drawSegment(cubeBody.position, grabPoint, 10, Color(0xaaffffff)) -- 181
		end -- 174
	end) -- 172
	return ropeNode -- 171
end -- 157
local getGrabForce -- 183
getGrabForce = function(body, target) -- 183
	local prePos = body.position -- 184
	local force = target - prePos -- 185
	force = force:normalize() * 30 -- 186
	return force -- 187
end -- 183
local camera = Camera2D() -- 189
Director:pushCamera(camera) -- 190
updateViewScale() -- 191
local cameraFollow -- 193
cameraFollow = function(body) -- 193
	local _with_0 = Node() -- 194
	_with_0:schedule(function() -- 195
		camera.position = Vec2(0, (body.position.y - camera.position.y) * 0.1 + camera.position.y + 30) -- 196
	end) -- 195
	return _with_0 -- 194
end -- 193
local _anon_func_0 = function(_with_0, scale) -- 208
	local _with_1 = Sprite("Image/cube.png") -- 208
	_with_1.scaleX = scale -- 209
	_with_1.scaleY = scale -- 209
	return _with_1 -- 208
end -- 208
local addCube -- 198
addCube = function() -- 198
	do -- 199
		local _with_0 = Node() -- 199
		_with_0:addTo(world) -- 200
		cube = _with_0 -- 199
	end -- 199
	local scale = 0.5 -- 201
	local cubebody -- 202
	do -- 202
		local _with_0 = Body(getCubeDef(256 * scale, 256 * scale), world, cubeInitPos) -- 202
		_with_0.receivingContact = true -- 203
		_with_0.tag = "cubeBody" -- 204
		_with_0.group = 0 -- 205
		_with_0.angularRate = 0 -- 206
		_with_0.velocity = Vec2.zero -- 207
		_with_0:addChild(_anon_func_0(_with_0, scale)) -- 208
		_with_0:addTo(cube) -- 210
		cubebody = _with_0 -- 202
	end -- 202
	return cameraFollow(cubebody) -- 211
end -- 198
local _anon_func_1 = function(_with_0) -- 215
	local _with_1 = Sprite("Image/heart_3.png") -- 215
	_with_1.tag = "heartSprite" -- 216
	_with_1.y = View.size.height / 2 - 100 -- 217
	_with_1.scaleX = 6 -- 218
	_with_1.scaleY = 6 -- 218
	return _with_1 -- 215
end -- 215
local addHeartUI -- 213
addHeartUI = function() -- 213
	do -- 214
		local _with_0 = Node() -- 214
		_with_0:addChild(_anon_func_1(_with_0)) -- 215
		heartNode = _with_0 -- 214
	end -- 214
	return ui:addChild(heartNode) -- 219
end -- 213
local _anon_func_2 = function(heartSprite) -- 228
	heartSprite.tag = "heartSprite" -- 229
	heartSprite.y = View.size.height / 2 - 100 -- 230
	heartSprite.scaleX = 6 -- 231
	heartSprite.scaleY = 6 -- 231
	return heartSprite -- 228
end -- 228
local loseHeart -- 221
loseHeart = function() -- 221
	heart = heart - 1 -- 222
	heartNode:removeAllChildren() -- 223
	local heartSprite -- 224
	if 0 <= heart and heart <= 3 then -- 224
		heartSprite = Sprite("Image/heart_" .. tostring(math.tointeger(heart)) .. ".png") -- 225
	else -- 227
		heartSprite = Sprite("Image/heart_0.png") -- 227
	end -- 224
	return heartNode:addChild(_anon_func_2(heartSprite)) -- 228
end -- 221
local arriveDest -- 233
arriveDest = function() -- 233
	touchTheSky = true -- 234
	Audio:play("sfx/sky3.mp3") -- 235
	Audio:playStream("sfx/victory.ogg", true, 0.2) -- 236
	local body = cube:getChildByTag("cubeBody") -- 237
	body:applyLinearImpulse(Vec2(0, 1500), body.position) -- 238
	local _with_0 = Node() -- 239
	_with_0:addChild((function() -- 240
		local _with_1 = Sprite("Image/restart.png") -- 240
		_with_1.scaleX = 2 -- 241
		_with_1.scaleY = 2 -- 241
		_with_1.touchEnabled = true -- 242
		_with_1:slot("TapBegan", function() -- 243
			restartButton:removeFromParent() -- 244
			return restartGame() -- 245
		end) -- 243
		return _with_1 -- 240
	end)()) -- 240
	_with_0:addTo(ui) -- 246
	restartButton = _with_0 -- 239
end -- 233
local _anon_func_3 = function(_with_0) -- 285
	local _with_1 = Sprite("Image/red.png") -- 285
	_with_1.scaleX = 0.15 -- 286
	_with_1.scaleY = 0.15 -- 286
	return _with_1 -- 285
end -- 285
local _anon_func_4 = function(_with_0) -- 289
	local _with_1 = Sprite("Image/spring.png") -- 289
	_with_1.scaleX = 0.15 -- 290
	_with_1.scaleY = 0.15 -- 290
	return _with_1 -- 289
end -- 289
local _anon_func_5 = function(_with_0, blockColor, height, width) -- 300
	local _with_1 = DrawNode() -- 300
	local verts = { -- 302
		Vec2(-width / 2, height / 2), -- 302
		Vec2(width / 2, height / 2), -- 303
		Vec2(width / 2, -height / 2), -- 304
		Vec2(-width / 2, -height / 2) -- 305
	} -- 301
	_with_1:drawPolygon(verts, blockColor) -- 307
	return _with_1 -- 300
end -- 300
local buildBlocks -- 248
buildBlocks = function(index) -- 248
	local blocks = blockTypes[index] -- 249
	for _index_0 = 1, #blocks do -- 250
		local block = blocks[_index_0] -- 250
		local width, height, pos, blockType = block[1], block[2], block[3], block[4] -- 251
		pos = pos + Vec2(0, blockLevel[index]) -- 252
		local _with_0 = Body(getBlockDef(width, height), world, pos) -- 253
		_with_0.group = 1 -- 254
		local blockColor = Color(0xffffffff) -- 255
		_with_0:attachSensor(1, BodyDef:polygon(width + 15, height + 15)) -- 256
		if 0 == blockType then -- 257
			_with_0:slot("BodyEnter", function() -- 258
				return Audio:play("sfx/strike.wav") -- 259
			end) -- 258
			blockColor = colorWhite -- 260
		elseif 1 == blockType then -- 261
			_with_0:slot("BodyEnter", function(body) -- 262
				if not isInvincible then -- 263
					loseHeart() -- 264
					body:applyLinearImpulse(Vec2(math.random(-1000, 1000), math.random(-1000, -500)), body.position) -- 265
					Audio:play("sfx/explode2.wav") -- 269
				end -- 263
				_with_0:schedule(once(function() -- 270
					isInvincible = true -- 271
					sleep(1) -- 272
					isInvincible = false -- 273
				end)) -- 270
				if heart <= 0 then -- 274
					isGrabbing = false -- 275
					isGrabbed = false -- 276
					grabBlock:unschedule() -- 277
					ropeNode:clear() -- 278
					ropeNode:unschedule() -- 279
					Audio:play("sfx/game_over.wav") -- 280
					return _with_0:schedule(once(function() -- 281
						sleep(0.5) -- 282
						return restartGame() -- 283
					end)) -- 281
				end -- 274
			end) -- 262
			blockColor = colorRed -- 284
			_with_0:addChild(_anon_func_3(_with_0)) -- 285
		elseif 2 == blockType then -- 287
			blockColor = colorBlue -- 288
			_with_0:addChild(_anon_func_4(_with_0)) -- 289
			local implulseAvailable = true -- 291
			_with_0:slot("BodyEnter", function(body) -- 292
				if not implulseAvailable then -- 293
					return -- 293
				end -- 293
				Audio:play("sfx/rebound.wav") -- 294
				body:applyLinearImpulse(Vec2(0, springForce), body.position) -- 295
				implulseAvailable = false -- 296
				return _with_0:schedule(once(function() -- 297
					sleep(0.2) -- 298
					implulseAvailable = true -- 299
				end)) -- 297
			end) -- 292
		end -- 257
		_with_0:addChild(_anon_func_5(_with_0, blockColor, height, width)) -- 300
		_with_0:addTo(world) -- 308
		blockBodies[#blockBodies + 1] = _with_0 -- 253
	end -- 250
end -- 248
local _anon_func_6 = function(_with_0) -- 317
	local _with_1 = Sprite("Image/sky.png") -- 317
	_with_1.x = 90 -- 318
	_with_1.y = 100 -- 319
	_with_1.scaleX = 2.7 -- 320
	_with_1.scaleY = 2.7 -- 320
	return _with_1 -- 317
end -- 317
local _anon_func_7 = function(_with_0, borderHeight, borderWidth, colorWhite) -- 326
	local _with_1 = DrawNode() -- 326
	_with_1:drawSegment(Vec2(-borderWidth / 2, 0), Vec2(borderWidth / 2, 0), 10, colorWhite) -- 327
	_with_1:drawSegment(Vec2(-borderWidth / 2, 0), Vec2(-borderWidth / 2, borderHeight), 10, colorWhite) -- 328
	_with_1:drawSegment(Vec2(borderWidth / 2, 0), Vec2(borderWidth / 2, borderHeight), 10, colorWhite) -- 329
	return _with_1 -- 326
end -- 326
local buildWorld -- 310
buildWorld = function() -- 310
	buildBlocks(1) -- 311
	buildBlocks(2) -- 312
	buildBlocks(3) -- 313
	buildBlocks(4) -- 314
	do -- 315
		local _with_0 = Body(destinationDef, world, Vec2(borderPos.x, borderPos.y + borderHeight)) -- 315
		_with_0.group = 1 -- 316
		_with_0:addChild(_anon_func_6(_with_0)) -- 317
		_with_0:slot("BodyEnter", function() -- 321
			if not touchTheSky then -- 322
				return arriveDest() -- 322
			end -- 322
		end) -- 321
		_with_0:addTo(world) -- 323
	end -- 315
	do -- 324
		local _with_0 = Body(borderDef, world, Vec2.zero) -- 324
		_with_0.group = 1 -- 325
		_with_0:addChild(_anon_func_7(_with_0, borderHeight, borderWidth, colorWhite)) -- 326
		_with_0:addTo(world) -- 330
	end -- 324
	local _with_0 = Node() -- 331
	_with_0.touchEnabled = true -- 332
	_with_0:slot("TapBegan", function(touch) -- 333
		isGrabbing = true -- 334
		if not touch.first then -- 335
			return -- 335
		end -- 335
		local location = touch.location -- 336
		local body = cube:getChildByTag("cubeBody") -- 337
		emitRope(body, location) -- 338
		if not hardMode or isGrabbed then -- 339
			grabBlock:schedule(function() -- 341
				return body:applyLinearImpulse(getGrabForce(body, location), body.position) -- 342
			end) -- 341
			return grabBlock -- 340
		end -- 339
	end) -- 333
	_with_0:slot("TapEnded", function() -- 343
		isGrabbing = false -- 344
		isGrabbed = false -- 345
		grabBlock:unschedule() -- 346
		ropeNode:clear() -- 347
		return ropeNode:unschedule() -- 348
	end) -- 343
	_with_0:addTo(root) -- 349
	return _with_0 -- 331
end -- 310
addCube() -- 351
buildWorld() -- 352
addHeartUI() -- 353
restartGame = function() -- 355
	if touchTheSky then -- 356
		Audio:playStream("sfx/bgm.ogg", true, 0.2) -- 357
	end -- 356
	heart = 3 -- 358
	touchTheSky = false -- 359
	local body = cube:getChildByTag("cubeBody") -- 360
	body.position = Vec2.zero -- 361
	body.angularRate = 0 -- 362
	ui:removeFromParent() -- 363
	do -- 364
		local _with_0 = Node() -- 364
		_with_0:addTo(Director.ui) -- 365
		heartNode:removeFromParent() -- 366
		ui = _with_0 -- 364
	end -- 364
	return addHeartUI() -- 367
end -- 355
local windowFlags = { -- 370
	"NoDecoration", -- 370
	"NoSavedSettings", -- 371
	"NoFocusOnAppearing", -- 372
	"NoMove" -- 373
} -- 369
return threadLoop(function() -- 374
	local width, height -- 375
	do -- 375
		local _obj_0 = App.visualSize -- 375
		width, height = _obj_0.width, _obj_0.height -- 375
	end -- 375
	SetNextWindowBgAlpha(0.35) -- 376
	SetNextWindowPos(Vec2(width - 140, height - 170), "Always", Vec2.zero) -- 377
	SetNextWindowSize(Vec2(140, 0), "Always") -- 378
	return Begin("Touch The Sky", windowFlags, function() -- 379
		Text("Touch The Sky") -- 380
		Separator() -- 381
		TextWrapped("Click to grab!") -- 382
		local changed, isHardMode = Checkbox("Hard Mode", hardMode) -- 383
		if changed then -- 383
			hardMode = isHardMode -- 384
		end -- 383
	end) -- 379
end) -- 374
