-- [yue]: Logic.yue
local _ENV = Dora(Dora.Platformer) -- 9
local Data <const> = Data -- 10
local Group <const> = Group -- 10
local Observer <const> = Observer -- 10
local Vec2 <const> = Vec2 -- 10
local Rect <const> = Rect -- 10
local math <const> = math -- 10
local thread <const> = thread -- 10
local sleep <const> = sleep -- 10
local emit <const> = emit -- 10
local Audio <const> = Audio -- 10
local App <const> = App -- 10
local Entity <const> = Entity -- 10
local Unit <const> = Unit -- 10
local Visual <const> = Visual -- 10
local Action <const> = Action -- 10
local Sequence <const> = Sequence -- 10
local Y <const> = Y -- 10
local Ease <const> = Ease -- 10
local Sprite <const> = Sprite -- 10
local Spawn <const> = Spawn -- 10
local Opacity <const> = Opacity -- 10
local Scale <const> = Scale -- 10
local BodyDef <const> = BodyDef -- 10
local Body <const> = Body -- 10
local tostring <const> = tostring -- 10
local once <const> = once -- 10
local Node <const> = Node -- 10
local SpriteEffect <const> = SpriteEffect -- 10
local View <const> = View -- 10
local cycle <const> = cycle -- 10
local Director <const> = Director -- 10
local Store = Data.store -- 12
local GroupPlayer, GroupEnemy, GroupDisplay, GroupPlayerBlock, GroupEnemyBlock, GroupPlayerPoke, GroupEnemyPoke, LayerBunny, LayerPlayerHero, LayerEnemyHero, LayerBlock, MaxEP, MaxHP = Store.GroupPlayer, Store.GroupEnemy, Store.GroupDisplay, Store.GroupPlayerBlock, Store.GroupEnemyBlock, Store.GroupPlayerPoke, Store.GroupEnemyPoke, Store.LayerBunny, Store.LayerPlayerHero, Store.LayerEnemyHero, Store.LayerBlock, Store.MaxEP, Store.MaxHP -- 13
local heroes = Group({ -- 29
	"hero" -- 29
}) -- 29
do -- 30
	local _with_0 = Observer("Add", { -- 30
		"world" -- 30
	}) -- 30
	_with_0:watch(function(_entity, world) -- 31
		do -- 33
			local _with_1 = world.camera -- 33
			_with_1.followRatio = Vec2(0.03, 0.03) -- 34
			_with_1.boundary = Rect(0, -110, 4096, 1004) -- 35
			_with_1.position = Vec2(1024, 274) -- 36
		end -- 33
		world:setIterations(2, 3) -- 37
		world:gslot("BlockValue", function(group, value) -- 38
			return heroes:each(function(hero) -- 38
				if hero.group == group then -- 39
					hero.blocks = value -- 39
				end -- 39
			end) -- 38
		end) -- 38
		world:gslot("BlockChange", function(group, value) -- 40
			return heroes:each(function(hero) -- 40
				if hero.group == group and hero.blocks then -- 41
					hero.blocks = math.max(hero.blocks + value, 0) -- 42
					if value < 0 then -- 43
						hero.defending = true -- 43
					end -- 43
				end -- 41
			end) -- 40
		end) -- 40
		world:gslot("EPChange", function(group, value) -- 44
			return heroes:each(function(hero) -- 44
				if hero.group == group then -- 45
					hero.ep = hero.ep + value -- 45
				end -- 45
			end) -- 44
		end) -- 44
		world:gslot("PlayerSelect", function(hero) -- 46
			return thread(function() -- 46
				sleep(1) -- 47
				world:clearScene() -- 48
				local _list_0 = { -- 49
					6, -- 49
					1, -- 49
					1 -- 49
				} -- 49
				for _index_0 = 1, #_list_0 do -- 49
					local ep = _list_0[_index_0] -- 49
					emit("EPChange", GroupPlayer, ep) -- 50
					emit("EPChange", GroupEnemy, ep) -- 51
				end -- 49
				Store.winner = nil -- 52
				world.playing = true -- 53
				Audio:playStream("Audio/LOOP14.ogg", true) -- 54
				local names -- 55
				do -- 55
					local _accum_0 = { } -- 55
					local _len_0 = 1 -- 55
					local _list_1 = { -- 55
						"Flandre", -- 55
						"Dorothy", -- 55
						"Villy" -- 55
					} -- 55
					for _index_0 = 1, #_list_1 do -- 55
						local n = _list_1[_index_0] -- 55
						if n ~= hero then -- 55
							_accum_0[_len_0] = n -- 55
							_len_0 = _len_0 + 1 -- 55
						end -- 55
					end -- 55
					names = _accum_0 -- 55
				end -- 55
				local enemyHero = names[(App.rand % 2) + 1] -- 56
				Entity({ -- 58
					hero = hero, -- 58
					group = GroupPlayer, -- 59
					faceRight = true, -- 60
					AI = "PlayerControlAI", -- 61
					layer = LayerPlayerHero, -- 62
					position = Vec2(512, 1004 - 712), -- 63
					ep = MaxEP -- 64
				}) -- 57
				Entity({ -- 66
					hero = enemyHero, -- 66
					group = GroupEnemy, -- 67
					faceRight = false, -- 68
					AI = "HeroAI", -- 69
					layer = LayerEnemyHero, -- 70
					position = Vec2(3584, 1004 - 712), -- 71
					ep = MaxEP -- 72
				}) -- 65
				world:buildCastles() -- 73
				world:addBunnySwither(GroupPlayer) -- 74
				return world:addBunnySwither(GroupEnemy) -- 75
			end) -- 46
		end) -- 46
		Store.world = world -- 32
		world:buildBackground() -- 77
		world:buildSwitches() -- 78
		world:buildGameReadme() -- 79
		Audio:playStream("Audio/LOOP13.ogg", true) -- 80
		return false -- 31
	end) -- 31
end -- 30
local mutables = { -- 83
	"hp", -- 83
	"moveSpeed", -- 84
	"move", -- 85
	"jump", -- 86
	"targetAllow", -- 87
	"attackBase", -- 88
	"attackPower", -- 89
	"attackSpeed", -- 90
	"damageType", -- 91
	"attackBonus", -- 92
	"attackFactor", -- 93
	"attackTarget", -- 94
	"defenceType" -- 95
} -- 82
local _anon_func_0 = function(_with_1) -- 115
	local _with_0 = Visual("Particle/select.par") -- 115
	_with_0:autoRemove() -- 116
	_with_0:start() -- 117
	return _with_0 -- 115
end -- 115
do -- 97
	local _with_0 = Observer("Add", { -- 97
		"hero", -- 97
		"group", -- 97
		"layer", -- 97
		"position", -- 97
		"faceRight", -- 97
		"AI" -- 97
	}) -- 97
	_with_0:watch(function(self, hero, group, layer, position, faceRight, AI) -- 98
		local world = Store.world -- 99
		local def = Store[hero] -- 100
		for _index_0 = 1, #mutables do -- 101
			local var = mutables[_index_0] -- 101
			self[var] = def[var] -- 102
		end -- 101
		local unit -- 103
		do -- 103
			local _with_1 = Unit(def, world, self, position) -- 103
			_with_1.group = group -- 104
			_with_1.faceRight = faceRight -- 105
			_with_1.order = layer -- 106
			_with_1.decisionTree = AI -- 107
			if "Dorothy" == hero then -- 109
				self.attackSpeed = 1.2 -- 109
			elseif "Villy" == hero then -- 110
				self.attackSpeed = 1.3 -- 110
			elseif "Flandre" == hero then -- 111
				self.attackSpeed = 1.8 -- 111
			end -- 108
			self.moveSpeed = 1.5 -- 112
			_with_1:eachAction(function(self) -- 113
				self.recovery = 0.05 -- 113
			end) -- 113
			_with_1:addTo(world) -- 114
			_with_1:addChild(_anon_func_0(_with_1)) -- 115
			unit = _with_1 -- 103
		end -- 103
		if group == GroupPlayer then -- 118
			world.camera.followTarget = unit -- 119
		end -- 118
		emit("HPChange", self.group, self.hp) -- 120
		return false -- 98
	end) -- 98
end -- 97
do -- 122
	local _with_0 = Observer("Add", { -- 122
		"bunny", -- 122
		"group", -- 122
		"layer", -- 122
		"position", -- 122
		"faceRight", -- 122
		"AI" -- 122
	}) -- 122
	_with_0:watch(function(self, bunny, group, layer, position, faceRight, AI) -- 123
		local world = Store.world -- 124
		local def = Store[bunny] -- 125
		for _index_0 = 1, #mutables do -- 126
			local var = mutables[_index_0] -- 126
			if var == "hp" and self[var] ~= nil then -- 127
				goto _continue_0 -- 128
			end -- 127
			self[var] = def[var] -- 129
			::_continue_0:: -- 127
		end -- 126
		do -- 130
			local _with_1 = Unit(def, world, self, position) -- 130
			_with_1.group = group -- 131
			_with_1.faceRight = faceRight -- 132
			_with_1.order = layer -- 133
			_with_1.decisionTree = AI -- 134
			_with_1:eachAction(function(self) -- 135
				self.recovery = 0.1 -- 135
			end) -- 135
			_with_1:addTo(world) -- 136
			if self.hp == 0.0 then -- 137
				self.hp = self.hp - 1.0 -- 137
			end -- 137
		end -- 130
		return false -- 123
	end) -- 123
end -- 122
do -- 139
	local _with_0 = Observer("Add", { -- 139
		"switch", -- 139
		"group", -- 139
		"layer", -- 139
		"look", -- 139
		"position" -- 139
	}) -- 139
	_with_0:watch(function(self, switchType, group, layer, look, position) -- 140
		local world = Store.world -- 141
		local unit -- 142
		do -- 142
			local _with_1 = Unit(Store[switchType], world, self, position) -- 142
			_with_1.group = group -- 143
			_with_1.order = layer -- 144
			do -- 145
				local _with_2 = _with_1.playable -- 145
				_with_2.look = look -- 146
				_with_2.scaleX = 2 -- 147
				_with_2.scaleY = 2 -- 148
			end -- 145
			_with_1:addTo(world) -- 149
			_with_1.emittingEvent = true -- 150
			_with_1:slot("BodyEnter", function(self, sensorTag) -- 151
				if _with_1.attackSensor.tag == sensorTag and self.entity and Data:isFriend(self, unit) then -- 152
					if self.group == GroupPlayer and self.entity.hero and not self.data.tip then -- 153
						local floating = Action(Sequence(Y(0.5, 140, 150, Ease.OutQuad), Y(0.3, 150, 140, Ease.InQuad))) -- 154
						local _with_2 = Sprite("Model/items.clip|keyf_down") -- 158
						_with_2.y = 140 -- 159
						local scaleOut = Action(Spawn(Opacity(0.3, 0, 1), Scale(0.3, 0, 1, Ease.OutQuad))) -- 160
						_with_2:runAction(scaleOut) -- 164
						_with_2:slot("ActionEnd", function() -- 165
							return _with_2:runAction(floating) -- 165
						end) -- 165
						_with_2:addTo(self) -- 166
						self.data.tip = _with_2 -- 158
					end -- 153
					self.data.atSwitch = unit -- 167
				end -- 152
			end) -- 151
			_with_1:slot("BodyLeave", function(self, sensorTag) -- 168
				if _with_1.attackSensor.tag == sensorTag and Data:isFriend(self, unit) then -- 169
					self.data.atSwitch = nil -- 170
					if self.data.tip then -- 171
						do -- 172
							local _with_2 = self.data.tip -- 172
							_with_2:perform(Spawn(Scale(0.3, _with_2.scaleX, 0), Opacity(0.3, 1, 0))) -- 173
							_with_2:slot("ActionEnd"):set(function() -- 177
								return _with_2:removeFromParent() -- 177
							end) -- 177
						end -- 172
						self.data.tip = nil -- 178
					end -- 171
				end -- 169
			end) -- 168
			unit = _with_1 -- 142
		end -- 142
		return false -- 140
	end) -- 140
end -- 139
do -- 180
	local _with_0 = Observer("Add", { -- 180
		"block", -- 180
		"group", -- 180
		"layer", -- 180
		"look", -- 180
		"position" -- 180
	}) -- 180
	_with_0:watch(function(self, block, group, layer, look, position) -- 181
		local world = Store.world -- 182
		local def = Store[block] -- 183
		self.hp = def.hp -- 184
		self.defenceType = 0 -- 185
		do -- 186
			local _with_1 = Unit(def, world, self, position) -- 186
			_with_1.group = group -- 187
			_with_1.order = layer -- 188
			_with_1.playable.look = look -- 189
			_with_1:addTo(world) -- 190
		end -- 186
		return false -- 181
	end) -- 181
end -- 180
local _anon_func_1 = function(GroupEnemy, GroupPlayer, _with_1, self) -- 217
	local _exp_0 = self.group -- 217
	if GroupPlayer == _exp_0 or GroupEnemy == _exp_0 then -- 218
		return Data:isEnemy(self.group, _with_1.group) -- 218
	else -- 219
		return false -- 219
	end -- 217
end -- 217
do -- 192
	local _with_0 = Observer("Add", { -- 192
		"poke", -- 192
		"group", -- 192
		"layer", -- 192
		"position" -- 192
	}) -- 192
	_with_0:watch(function(_entity, poke, group, layer, position) -- 193
		local world = Store.world -- 194
		local pokeDef -- 195
		do -- 195
			local _with_1 = BodyDef() -- 195
			_with_1.linearAcceleration = Vec2(0, -10) -- 196
			_with_1.type = "Dynamic" -- 197
			_with_1:attachDisk(192, 10.0, 0.1, 0.4) -- 198
			_with_1:attachDiskSensor(0, 194) -- 199
			pokeDef = _with_1 -- 195
		end -- 195
		do -- 200
			local _with_1 = Body(pokeDef, world, position) -- 200
			_with_1.group = group -- 201
			if GroupPlayerPoke == group then -- 203
				_with_1.velocityX = 400 -- 203
			elseif GroupEnemyPoke == group then -- 204
				_with_1.velocityX = -400 -- 204
			end -- 202
			local normal -- 205
			do -- 205
				local _with_2 = Sprite("Model/poke.clip|" .. tostring(poke)) -- 205
				_with_2.scaleX = 4 -- 206
				_with_2.scaleY = 4 -- 207
				_with_2.filter = "Point" -- 208
				normal = _with_2 -- 205
			end -- 205
			_with_1:addChild(normal) -- 209
			local glow -- 210
			do -- 210
				local _with_2 = Sprite("Model/poke.clip|" .. tostring(poke) .. "l") -- 210
				_with_2.scaleX = 4 -- 211
				_with_2.scaleY = 4 -- 212
				_with_2.filter = "Point" -- 213
				_with_2.visible = false -- 214
				glow = _with_2 -- 210
			end -- 210
			_with_1:addChild(glow) -- 215
			_with_1:slot("BodyEnter", function(self, sensorTag) -- 216
				if sensorTag == 0 and _anon_func_1(GroupEnemy, GroupPlayer, _with_1, self) then -- 217
					if (_with_1.x < self.x) == (_with_1.velocityX > 0) then -- 220
						self.velocity = Vec2(_with_1.velocityX > 0 and 500 or -500, 400) -- 221
						return self:start("strike") -- 222
					end -- 220
				end -- 217
			end) -- 216
			_with_1:schedule(once(function() -- 223
				while 50 < math.abs(_with_1.velocityX) do -- 224
					sleep(0.1) -- 225
				end -- 224
				for _ = 1, 6 do -- 226
					Audio:play("Audio/di.wav") -- 227
					normal.visible = not normal.visible -- 228
					glow.visible = not glow.visible -- 229
					sleep(0.5) -- 230
				end -- 226
				local sensor = _with_1:attachSensor(1, BodyDef:disk(500)) -- 231
				sleep() -- 233
				local _list_0 = sensor.sensedBodies -- 234
				for _index_0 = 1, #_list_0 do -- 234
					local body = _list_0[_index_0] -- 234
					if Data:isEnemy(body.group, _with_1.group) then -- 235
						local entity = body.entity -- 236
						if entity and entity.hp > 0 then -- 237
							local x = _with_1.x -- 238
							do -- 239
								local _with_2 = body.data -- 239
								_with_2.hitPoint = body:convertToWorldSpace(Vec2.zero) -- 240
								_with_2.hitPower = Vec2(2000, 2400) -- 241
								_with_2.hitFromRight = body.x < x -- 242
							end -- 239
							entity.hp = entity.hp - 1 -- 243
						end -- 237
					end -- 235
				end -- 234
				local pos = _with_1:convertToWorldSpace(Vec2.zero) -- 244
				do -- 245
					local _with_2 = Visual("Particle/boom.par") -- 245
					_with_2.position = pos -- 246
					_with_2.scaleX = 4 -- 247
					_with_2.scaleY = 4 -- 248
					_with_2:addTo(world, LayerBlock) -- 249
					_with_2:autoRemove() -- 250
					_with_2:start() -- 251
				end -- 245
				_with_1:removeFromParent() -- 252
				return Audio:play("Audio/explosion.wav") -- 253
			end)) -- 223
			_with_1:addTo(world, layer) -- 254
		end -- 200
		Audio:play("Audio/quake.wav") -- 255
		return false -- 193
	end) -- 193
end -- 192
do -- 257
	local _with_0 = Observer("Change", { -- 257
		"hp", -- 257
		"unit", -- 257
		"block" -- 257
	}) -- 257
	_with_0:watch(function(self, hp, unit) -- 258
		local lastHp = self.oldValues.hp -- 259
		if hp < lastHp then -- 260
			if unit:isDoing("hit") then -- 261
				unit:start("cancel") -- 261
			end -- 261
			if hp > 0 then -- 262
				unit:start("hit") -- 263
				unit.faceRight = true -- 264
				local _with_1 = unit.playable -- 265
				_with_1.recovery = 0.5 -- 266
				_with_1:play("hp" .. tostring(math.floor(hp))) -- 267
			else -- 269
				unit:start("hit") -- 269
				unit.faceRight = true -- 270
				unit.group = Data.groupHide -- 271
				unit.playable:perform(Scale(0.3, 1, 0, Ease.OutQuad)) -- 272
				unit:schedule(once(function() -- 273
					sleep(5) -- 274
					return unit:removeFromParent() -- 275
				end)) -- 273
				local group -- 276
				do -- 276
					local _exp_0 = self.group -- 276
					if GroupPlayerBlock == _exp_0 then -- 277
						group = GroupEnemy -- 277
					elseif GroupEnemyBlock == _exp_0 then -- 278
						group = GroupPlayer -- 278
					end -- 276
				end -- 276
				emit("EPChange", group, 1) -- 279
			end -- 262
			local group -- 280
			do -- 280
				local _exp_0 = self.group -- 280
				if GroupPlayerBlock == _exp_0 then -- 281
					group = GroupPlayer -- 281
				elseif GroupEnemyBlock == _exp_0 then -- 282
					group = GroupEnemy -- 282
				end -- 280
			end -- 280
			emit("BlockChange", group, math.max(hp, 0) - lastHp) -- 283
		end -- 260
		return false -- 258
	end) -- 258
end -- 257
do -- 285
	local _with_0 = Observer("Change", { -- 285
		"hp", -- 285
		"bunny" -- 285
	}) -- 285
	_with_0:watch(function(self, hp) -- 286
		local unit = self.unit -- 287
		local lastHp = self.oldValues.hp -- 288
		if hp < lastHp then -- 289
			if unit:isDoing("hit") then -- 290
				unit:start("cancel") -- 290
			end -- 290
			if hp > 0 then -- 291
				unit:start("hit") -- 292
			else -- 294
				unit:start("hit") -- 294
				unit:start("fall") -- 295
				unit.group = Data.groupHide -- 296
				local group -- 297
				do -- 297
					local _exp_0 = self.group -- 297
					if GroupPlayer == _exp_0 then -- 298
						group = GroupEnemy -- 298
					elseif GroupEnemy == _exp_0 then -- 299
						group = GroupPlayer -- 299
					end -- 297
				end -- 297
				emit("EPChange", group, 1) -- 300
				unit:schedule(once(function() -- 301
					sleep(5) -- 302
					return unit:removeFromParent() -- 303
				end)) -- 301
			end -- 291
		end -- 289
		return false -- 286
	end) -- 286
end -- 285
do -- 305
	local _with_0 = Observer("Change", { -- 305
		"hp", -- 305
		"hero" -- 305
	}) -- 305
	_with_0:watch(function(self, hp) -- 306
		local unit = self.unit -- 307
		local lastHp = self.oldValues.hp -- 308
		local world = Store.world -- 309
		if hp < lastHp then -- 310
			if unit:isDoing("hit") then -- 311
				unit:start("cancel") -- 311
			end -- 311
			if hp > 0 then -- 312
				unit:start("hit") -- 313
			else -- 315
				unit:start("hit") -- 315
				unit:start("fall") -- 316
				local lastGroup = unit.group -- 317
				unit.group = Data.groupHide -- 318
				if unit.data.tip then -- 319
					unit.data.tip:removeFromParent() -- 320
					unit.data.tip = nil -- 321
				end -- 319
				emit("EPChange", lastGroup, 6) -- 322
				if GroupPlayer == lastGroup then -- 324
					Audio:play("Audio/hero_fall.wav") -- 325
				elseif GroupEnemy == lastGroup then -- 326
					Audio:play("Audio/hero_kill.wav") -- 327
				end -- 323
				if lastGroup == GroupPlayer then -- 328
					world:addChild((function() -- 329
						local _with_1 = Node() -- 329
						_with_1:schedule(once(function() -- 330
							do -- 331
								local _with_2 = SpriteEffect("builtin:vs_sprite", "builtin:fs_spritesaturation") -- 331
								_with_2:get(1):set("u_adjustment", 0) -- 332
								View.postEffect = _with_2 -- 331
							end -- 331
							sleep(3) -- 333
							cycle(5, function(dt) -- 334
								return View.postEffect:get(1):set("u_adjustment", dt) -- 334
							end) -- 334
							View.postEffect = nil -- 335
						end)) -- 330
						_with_1:slot("Cleanup", function() -- 336
							View.postEffect = nil -- 337
							Director.scheduler.timeScale = 1 -- 338
						end) -- 336
						return _with_1 -- 329
					end)()) -- 329
				end -- 328
				unit:schedule(once(function() -- 339
					Director.scheduler.timeScale = 0.25 -- 340
					sleep(3) -- 341
					Director.scheduler.timeScale = 1 -- 342
					sleep(2) -- 343
					world:addBunnySwither(lastGroup) -- 344
					unit.visible = false -- 345
					local start = unit.position -- 346
					local stop -- 347
					if GroupPlayer == lastGroup then -- 348
						stop = Vec2(512, 1004 - 512) -- 348
					elseif GroupEnemy == lastGroup then -- 349
						stop = Vec2(3584, 1004 - 512) -- 349
					end -- 347
					cycle(5, function(dt) -- 350
						unit.position = start + (stop - start) * Ease:func(Ease.OutQuad, dt) -- 350
					end) -- 350
					unit.playable.look = "happy" -- 351
					unit.visible = true -- 352
					unit.velocityY = 1 -- 353
					unit.group = lastGroup -- 354
					self.hp = MaxHP -- 355
					emit("HPChange", lastGroup, MaxHP) -- 356
					local _with_1 = Visual("Particle/select.par") -- 357
					_with_1:addTo(unit) -- 358
					_with_1:start() -- 359
					_with_1:autoRemove() -- 360
					return _with_1 -- 357
				end)) -- 339
				local group -- 361
				do -- 361
					local _exp_0 = self.group -- 361
					if GroupPlayer == _exp_0 then -- 362
						group = GroupEnemy -- 362
					elseif GroupEnemy == _exp_0 then -- 363
						group = GroupPlayer -- 363
					end -- 361
				end -- 361
				emit("EPChange", group, 1) -- 364
			end -- 312
		end -- 310
		emit("HPChange", self.group, math.max(hp, 0) - lastHp) -- 365
		return false -- 306
	end) -- 306
end -- 305
local _with_0 = Observer("Change", { -- 367
	"blocks", -- 367
	"group" -- 367
}) -- 367
_with_0:watch(function(_entity, blocks, group) -- 368
	local world = Store.world -- 369
	if not world.playing then -- 370
		return false -- 370
	end -- 370
	if blocks == 0 then -- 371
		world.playing = false -- 372
		Audio:playStream("Audio/LOOP11.ogg", true) -- 373
		local clip, sound -- 374
		if GroupPlayer == group then -- 375
			Store.winner, clip, sound = GroupEnemy, "lose", "hero_lose" -- 375
		elseif GroupEnemy == group then -- 376
			Store.winner, clip, sound = GroupPlayer, "win", "hero_win" -- 376
		end -- 374
		Audio:play("Audio/" .. tostring(sound) .. ".wav") -- 377
		local sp -- 378
		do -- 378
			local _with_1 = Sprite("Model/misc.clip|" .. tostring(clip)) -- 378
			_with_1.scaleX = 2 -- 379
			_with_1.scaleY = 2 -- 380
			_with_1.filter = "Point" -- 381
			sp = _with_1 -- 378
		end -- 378
		local rectDef -- 382
		do -- 382
			local _with_1 = BodyDef() -- 382
			_with_1.linearAcceleration = Vec2(0, -10) -- 383
			_with_1.type = "Dynamic" -- 384
			_with_1:attachPolygon(sp.width * 2, sp.height * 2, 1, 0, 1) -- 385
			rectDef = _with_1 -- 382
		end -- 382
		heroes:each(function(hero) -- 386
			if hero.group == GroupPlayer then -- 387
				local _with_1 = Body(rectDef, world, Vec2(hero.unit.x, 512)) -- 388
				_with_1.order = LayerBunny -- 389
				_with_1.group = GroupDisplay -- 390
				_with_1:addChild(sp) -- 391
				_with_1:addTo(world) -- 392
				return _with_1 -- 388
			end -- 387
		end) -- 386
	end -- 371
	return false -- 368
end) -- 368
return _with_0 -- 367
