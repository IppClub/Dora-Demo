-- [yue]: init.yue
local _ENV = Dora -- 11
local Path <const> = Path -- 12
local Content <const> = Content -- 12
local require <const> = require -- 12
local Node <const> = Node -- 12
local Audio <const> = Audio -- 12
local Sprite <const> = Sprite -- 12
local Label <const> = Label -- 12
local Color3 <const> = Color3 -- 12
local PhysicsWorld <const> = PhysicsWorld -- 12
local Director <const> = Director -- 12
local AlignNode <const> = AlignNode -- 12
local Vec2 <const> = Vec2 -- 12
local Grid <const> = Grid -- 12
local X <const> = X -- 12
local math <const> = math -- 12
local Sequence <const> = Sequence -- 12
local Delay <const> = Delay -- 12
local Spawn <const> = Spawn -- 12
local Opacity <const> = Opacity -- 12
local Ease <const> = Ease -- 12
local Y <const> = Y -- 12
local Event <const> = Event -- 12
local Rect <const> = Rect -- 12
local Size <const> = Size -- 12
local Joint <const> = Joint -- 12
local Show <const> = Show -- 12
local Hide <const> = Hide -- 12
local Scale <const> = Scale -- 12
local Color <const> = Color -- 12
local tostring <const> = tostring -- 12
local scriptPath = Path:getScriptPath(...) -- 14
if not scriptPath then -- 15
	return -- 15
end -- 15
Content:insertSearchPath(1, scriptPath) -- 16
local BodyEx = require("BodyEx") -- 18
local SolidRect = require("UI.View.Shape.SolidRect") -- 19
local Struct, Set -- 20
do -- 20
	local _obj_0 = require("Utils") -- 20
	Struct, Set = _obj_0.Struct, _obj_0.Set -- 20
end -- 20
local root -- 22
do -- 22
	local _with_0 = Node() -- 22
	_with_0:slot("Cleanup", function() -- 23
		return Audio:stopStream(0.2) -- 23
	end) -- 23
	root = _with_0 -- 22
end -- 22
local ui -- 24
do -- 24
	local _with_0 = Node() -- 24
	_with_0.scaleX = 0.4 -- 25
	_with_0.scaleY = 0.4 -- 25
	_with_0:addChild(Sprite("Model/duality.clip|stat")) -- 26
	ui = _with_0 -- 24
end -- 24
local score = 0 -- 27
local scoreTxt -- 28
do -- 28
	local _with_0 = Label("sarasa-mono-sc-regular", 40) -- 28
	_with_0.textAlign = "Center" -- 29
	_with_0.color3 = Color3(0x0) -- 30
	_with_0.text = "0" -- 31
	_with_0:addTo(ui) -- 32
	scoreTxt = _with_0 -- 28
end -- 28
local world -- 34
do -- 34
	local _with_0 = PhysicsWorld() -- 34
	_with_0.y = 405 -- 35
	_with_0:setShouldContact(0, 0, true) -- 36
	_with_0:setShouldContact(0, 1, false) -- 37
	_with_0:addTo(root) -- 38
	world = _with_0 -- 34
end -- 34
local isSpace = true -- 40
local switchScene = nil -- 41
local center = nil -- 43
local spaceBack = nil -- 44
local dailyBack = nil -- 45
local _anon_func_0 = function(_with_1, h, w) -- 58
	local _with_0 = Grid("Model/duality.clip|space", 1, 1) -- 58
	_with_0:moveUV(1, 1, Vec2(1, 1)) -- 59
	_with_0:moveUV(2, 1, Vec2(-1, 1)) -- 60
	_with_0:moveUV(1, 2, Vec2(1, -1)) -- 61
	_with_0:moveUV(2, 2, Vec2(-1, -1)) -- 62
	_with_0.scaleX = w / 8 -- 63
	_with_0.scaleY = h / 1078 -- 64
	return _with_0 -- 58
end -- 58
local _anon_func_1 = function(_with_2, x, y) -- 69
	local _with_0 = Sprite("Model/duality.clip|stary") -- 69
	_with_0.anchorX = 0 -- 70
	_with_0.x = -3000 + (x - 1) * 1000 -- 71
	_with_0.y = 3000 - (y - 1) * 1000 -- 72
	return _with_0 -- 69
end -- 69
Director.ui:addChild((function() -- 46
	local _with_0 = AlignNode(true) -- 46
	_with_0:css("flex-direction: column") -- 47
	_with_0:slot("AlignLayout", function(w, h) -- 48
		local worldScale = w / 2970 -- 49
		root.scaleX = worldScale -- 50
		root.scaleY = worldScale -- 51
		center.position = Vec2(w / 2, h / 2) -- 52
		if spaceBack then -- 53
			spaceBack:removeFromParent() -- 53
		end -- 53
		do -- 54
			local _with_1 = Node() -- 54
			_with_1.position = Vec2(w / 2, h / 2) -- 55
			_with_1.visible = isSpace -- 56
			_with_1.order = -1 -- 57
			_with_1:addChild(_anon_func_0(_with_1, h, w)) -- 58
			_with_1:addChild((function() -- 65
				local _with_2 = Node() -- 65
				_with_2.scaleX = worldScale -- 66
				_with_2.scaleY = worldScale -- 67
				for y = 1, 8 do -- 68
					for x = 1, 8 do -- 68
						_with_2:addChild(_anon_func_1(_with_2, x, y)) -- 69
					end -- 68
				end -- 68
				_with_2:perform(X(10, 0, -1000 * worldScale)) -- 73
				_with_2:slot("ActionEnd", function() -- 74
					return _with_2:perform(X(10, 0, -1000 * worldScale)) -- 74
				end) -- 74
				return _with_2 -- 65
			end)()) -- 65
			spaceBack = _with_1 -- 54
		end -- 54
		_with_0:addChild(spaceBack) -- 75
		if dailyBack then -- 76
			dailyBack:removeFromParent() -- 76
		end -- 76
		do -- 77
			local _with_1 = Grid("Model/duality.clip|day", 1, 1) -- 77
			_with_1.position = Vec2(w / 2, h / 2) -- 78
			_with_1.visible = not isSpace -- 79
			_with_1.order = -1 -- 80
			_with_1:moveUV(1, 1, Vec2(1, 1)) -- 81
			_with_1:moveUV(2, 1, Vec2(-1, 1)) -- 82
			_with_1:moveUV(1, 2, Vec2(1, -1)) -- 83
			_with_1:moveUV(2, 2, Vec2(-1, -1)) -- 84
			_with_1.scaleX = w / 8 -- 85
			_with_1.scaleY = h / 1078 -- 86
			dailyBack = _with_1 -- 77
		end -- 77
		return _with_0:addChild(dailyBack) -- 87
	end) -- 48
	_with_0:addChild((function() -- 88
		local _with_1 = AlignNode() -- 88
		_with_1.order = 1 -- 89
		_with_1:css("height: 30%; flex-direction: row-reverse") -- 90
		_with_1:addChild((function() -- 91
			local _with_2 = AlignNode() -- 91
			_with_2:css("height: 25; margin-right: 45") -- 92
			_with_2:addChild(ui) -- 93
			return _with_2 -- 91
		end)()) -- 91
		return _with_1 -- 88
	end)()) -- 88
	_with_0:addChild((function() -- 94
		center = AlignNode() -- 94
		center.order = 2 -- 95
		center:css("height: 40%") -- 96
		center:addChild((function() -- 97
			local _with_1 = Node() -- 97
			_with_1.touchEnabled = true -- 98
			_with_1.swallowTouches = true -- 99
			_with_1:addChild((function() -- 100
				local banner = Sprite("Model/duality.clip|dismantlism") -- 100
				center:slot("AlignLayout", function(w, h) -- 101
					banner.position = Vec2(w / 2, h / 2) -- 102
					do -- 103
						local _tmp_0 = 0.9 * math.min(w / banner.width, h / banner.height) -- 103
						banner.scaleX = _tmp_0 -- 103
						banner.scaleY = _tmp_0 -- 103
					end -- 103
				end) -- 101
				return banner -- 100
			end)()) -- 100
			_with_1:perform(Sequence(Delay(1), Spawn(Opacity(1, 1, 0, Ease.OutQuad), Y(1, 0, 100, Ease.InQuad)), Event("Start"))) -- 104
			_with_1:slot("Start", function() -- 112
				isSpace = false -- 113
				switchScene() -- 114
				center:slot("AlignLayout", nil) -- 115
				return _with_1:removeFromParent() -- 116
			end) -- 112
			return _with_1 -- 97
		end)()) -- 97
		return center -- 94
	end)()) -- 94
	_with_0:addChild((function() -- 117
		local _with_1 = AlignNode() -- 117
		_with_1:css("height: 30%") -- 118
		_with_1:addChild(root) -- 119
		_with_1:slot("AlignLayout", function(w) -- 120
			root.x = w / 2 -- 120
		end) -- 120
		return _with_1 -- 117
	end)()) -- 117
	return _with_0 -- 46
end)()) -- 46
local moveJoint = nil -- 122
local movingBody = nil -- 123
do -- 124
	local _with_0 = Node() -- 124
	_with_0.touchEnabled = true -- 125
	_with_0:slot("TapBegan", function(touch) -- 126
		local worldPos = _with_0:convertToWorldSpace(touch.location) -- 127
		local pos = world:convertToNodeSpace(worldPos) -- 128
		return world:query(Rect(pos - Vec2(1, 1), Size(2, 2)), function(body) -- 129
			if body.tag ~= "" and body.tag ~= (isSpace and "space" or "daily") then -- 130
				return false -- 130
			end -- 130
			if moveJoint then -- 131
				moveJoint:destroy() -- 131
			end -- 131
			moveJoint = Joint:move(true, body, pos, 400) -- 132
			movingBody = body -- 133
			return true -- 134
		end) -- 129
	end) -- 126
	_with_0:slot("TapMoved", function(touch) -- 135
		if moveJoint then -- 136
			local worldPos = _with_0:convertToWorldSpace(touch.location) -- 137
			local pos = world:convertToNodeSpace(worldPos) -- 138
			moveJoint.position = pos -- 139
		end -- 136
	end) -- 135
	_with_0:slot("TapEnded", function() -- 140
		if moveJoint then -- 141
			moveJoint:destroy() -- 142
			moveJoint = nil -- 143
			movingBody = nil -- 144
		end -- 141
	end) -- 140
end -- 124
local scene = require("scene") -- 146
Struct.Body("name", "file", "position", "angle") -- 147
Struct:load(scene) -- 148
local spaceItems = Set({ -- 151
	"rocket", -- 151
	"satlite", -- 152
	"spacestation", -- 153
	"star1", -- 154
	"star2", -- 155
	"ufo", -- 156
	"get" -- 157
}) -- 150
local dailyItems = Set({ -- 160
	"baseball", -- 160
	"burger", -- 161
	"donut", -- 162
	"fish", -- 163
	"radio", -- 164
	"tv", -- 165
	"pizza" -- 166
}) -- 159
local spaceBodies = { } -- 168
local dailyBodies = { } -- 169
switchScene = function(init) -- 171
	if isSpace then -- 172
		Audio:playStream("Audio/Dismantlism Space.ogg", true, 0.2) -- 173
		if not init then -- 174
			dailyBack:perform(Sequence(Show(), Opacity(0.5, 1, 0), Hide())) -- 175
			spaceBack:perform(Sequence(Show(), Opacity(0.5, 0, 1))) -- 180
		end -- 174
		for _index_0 = 1, #dailyBodies do -- 184
			local body = dailyBodies[_index_0] -- 184
			if body.children and #body.children > 0 then -- 185
				local _with_0 = body.children[1] -- 186
				if _with_0.actionCount == 0 then -- 187
					_with_0:perform(Sequence(Show(), Scale(0.5, 1, 0, Ease.OutBack), Hide())) -- 188
				end -- 187
			end -- 185
		end -- 184
		for _index_0 = 1, #spaceBodies do -- 193
			local body = spaceBodies[_index_0] -- 193
			if body.children and #body.children > 0 then -- 194
				local _with_0 = body.children[1] -- 195
				if _with_0.actionCount == 0 then -- 196
					_with_0:perform(Sequence(Show(), Scale(0.5, 0, 1, Ease.OutBack))) -- 197
				end -- 196
			end -- 194
		end -- 193
	else -- 202
		Audio:playStream("Audio/Dismantlism Daily.ogg", true, 0.2) -- 202
		if not init then -- 203
			spaceBack:perform(Sequence(Show(), Opacity(0.5, 1, 0), Hide())) -- 204
			dailyBack:perform(Sequence(Show(), Opacity(0.5, 0, 1))) -- 209
		end -- 203
		for _index_0 = 1, #spaceBodies do -- 213
			local body = spaceBodies[_index_0] -- 213
			if body.children and #body.children > 0 then -- 214
				local _with_0 = body.children[1] -- 215
				if _with_0.actionCount == 0 then -- 216
					_with_0:perform(Sequence(Show(), Scale(0.5, 1, 0, Ease.OutBack), Hide())) -- 217
				end -- 216
			end -- 214
		end -- 213
		for _index_0 = 1, #dailyBodies do -- 222
			local body = dailyBodies[_index_0] -- 222
			if body.children and #body.children > 0 then -- 223
				local _with_0 = body.children[1] -- 224
				if _with_0.actionCount == 0 then -- 225
					_with_0:perform(Sequence(Show(), Scale(0.5, 0, 1, Ease.OutBack))) -- 226
				end -- 225
			end -- 223
		end -- 222
	end -- 172
end -- 171
local restartScene = nil -- 231
local gameEnded = false -- 232
local _anon_func_2 = function(_with_0) -- 260
	local _with_1 = Label("sarasa-mono-sc-regular", 80) -- 260
	_with_1.textAlign = "Center" -- 261
	_with_1.color = Color(0x66ffffff) -- 262
	_with_1.text = "Drag It\nHere" -- 263
	return _with_1 -- 260
end -- 260
local _anon_func_3 = function(_with_1, body) -- 285
	local _with_0 = Node() -- 285
	_with_0:addChild(Sprite("Model/duality.clip|window")) -- 286
	_with_0:addChild(Sprite("Model/duality.clip|credits1")) -- 287
	_with_0.position = body.position -- 288
	_with_0:perform(Sequence(Spawn(Scale(0.5, 0, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(3), Scale(0.5, 1, 0, Ease.InBack), Event("End"))) -- 289
	_with_0:slot("End", function() -- 298
		return _with_0:removeFromParent() -- 298
	end) -- 298
	return _with_0 -- 285
end -- 285
local buildScene -- 233
buildScene = function() -- 233
	for i = 1, scene:count() do -- 234
		local name, file, position, angle -- 235
		do -- 235
			local _obj_0 = scene:get(i) -- 240
			name, file, position, angle = _obj_0.name, _obj_0.file, _obj_0.position, _obj_0.angle -- 235
			if position == nil then -- 238
				position = Vec2.zero -- 238
			end -- 238
			if angle == nil then -- 239
				angle = 0 -- 239
			end -- 239
		end -- 235
		local node = BodyEx(Path("Physics", file), world, position, angle) -- 241
		world:addChild(node) -- 242
		if spaceItems[file] then -- 243
			node.data:each(function(self) -- 244
				self.tag = "space" -- 245
				self.children[1].tag = file -- 246
				spaceBodies[#spaceBodies + 1] = self -- 247
			end) -- 244
		elseif dailyItems[file] then -- 248
			node.data:each(function(self) -- 249
				self.tag = "daily" -- 250
				self.children[1].tag = file -- 251
				dailyBodies[#dailyBodies + 1] = self -- 252
			end) -- 249
		else -- 254
			node.data:each(function(self) -- 254
				if self.children and #self.children > 0 then -- 255
					self.children[1].tag = file -- 255
				end -- 255
			end) -- 254
		end -- 243
		if "removearea" == file then -- 257
			local _with_0 = node.data.rect -- 258
			_with_0:addChild(SolidRect({ -- 259
				x = -200, -- 259
				y = -200, -- 259
				width = 400, -- 259
				height = 400, -- 259
				color = 0x66000000 -- 259
			})) -- 259
			_with_0:addChild(_anon_func_2(_with_0)) -- 260
			_with_0:slot("BodyEnter", function(body) -- 264
				if body.tag ~= "" and body.tag ~= (isSpace and "space" or "daily") then -- 265
					return -- 265
				end -- 265
				if body.group == 1 then -- 266
					return -- 266
				end -- 266
				body.group = 1 -- 267
				local _with_1 = body.children[1] -- 268
				_with_1:perform(Sequence(Spawn(Opacity(0.5, 1, 0), Scale(0.5, 1, 1.5, Ease.OutBack)), Event("Destroy"))) -- 269
				_with_1:slot("Destroy", function() -- 273
					do -- 274
						local _exp_0 = _with_1.tag -- 274
						if "star2" == _exp_0 or "pizza" == _exp_0 then -- 275
							score = score + 10 -- 276
							isSpace = not isSpace -- 277
							switchScene() -- 278
						elseif "quit" == _exp_0 then -- 279
						elseif "get" == _exp_0 or "fish" == _exp_0 then -- 281
							score = score + 100 -- 282
						elseif "credit" == _exp_0 then -- 283
							score = score + 50 -- 284
							world:addChild(_anon_func_3(_with_1, body)) -- 285
						else -- 300
							score = score + 10 -- 300
						end -- 274
					end -- 274
					scoreTxt.text = tostring(score) -- 301
					if score > 600 then -- 302
						gameEnded = true -- 303
						center:addChild((function() -- 304
							local _with_2 = Node() -- 304
							_with_2:addChild(Sprite("Model/duality.clip|window")) -- 305
							_with_2:addChild(Sprite("Model/duality.clip|win")) -- 306
							_with_2:perform(Sequence(Spawn(Scale(0.5, 0, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(3), Scale(0.5, 1, 0, Ease.InBack), Event("End"))) -- 307
							_with_2:slot("End", function() -- 316
								_with_2:removeFromParent() -- 317
								return restartScene() -- 318
							end) -- 316
							return _with_2 -- 304
						end)()) -- 304
					end -- 302
					if movingBody == body and moveJoint then -- 319
						moveJoint:destroy() -- 320
						moveJoint = nil -- 321
						movingBody = nil -- 322
					end -- 319
					return body:removeFromParent() -- 323
				end) -- 273
				return _with_1 -- 268
			end) -- 264
		elseif "safearea" == file then -- 324
			local _with_0 = node.data.rect -- 325
			_with_0:slot("BodyEnter", function(body) -- 326
				if body == movingBody then -- 327
					return -- 327
				end -- 327
				local tag = body.children[1].tag -- 328
				if (name == "safe1" and tag == "get") or (name == "safe2" and tag == "fish") then -- 329
					if not gameEnded then -- 331
						gameEnded = true -- 332
						return world:addChild((function() -- 333
							local _with_1 = Node() -- 333
							_with_1:addChild(Sprite("Model/duality.clip|window")) -- 334
							_with_1:addChild(Sprite("Model/duality.clip|lose")) -- 335
							_with_1.position = body.position -- 336
							_with_1:perform(Sequence(Spawn(Scale(0.5, 0, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(2), Scale(0.5, 1, 0, Ease.InBack), Event("End"))) -- 337
							_with_1:slot("End", function() -- 346
								return restartScene() -- 346
							end) -- 346
							return _with_1 -- 333
						end)()) -- 333
					end -- 331
				end -- 329
			end) -- 326
		end -- 256
	end -- 234
end -- 233
buildScene() -- 348
switchScene(true) -- 349
restartScene = function() -- 351
	score = 0 -- 352
	scoreTxt.text = "0" -- 353
	isSpace = false -- 354
	gameEnded = false -- 355
	spaceBodies = { } -- 356
	dailyBodies = { } -- 357
	if moveJoint then -- 358
		moveJoint:destroy() -- 359
		moveJoint = nil -- 360
		movingBody = nil -- 361
	end -- 358
	world:removeFromParent() -- 362
	do -- 363
		local _with_0 = PhysicsWorld() -- 363
		_with_0.y = 405 -- 364
		_with_0:setShouldContact(0, 0, true) -- 365
		_with_0:setShouldContact(0, 1, false) -- 366
		_with_0:addTo(root) -- 367
		world = _with_0 -- 363
	end -- 363
	buildScene() -- 368
	return switchScene() -- 369
end -- 351
