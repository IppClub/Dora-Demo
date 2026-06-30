-- [yue]: init.yue
local _ENV = Dora(Dora.ImGui, Dora.Platformer, Dora.Platformer.Decision) -- 11
local CircleButton = require("UI.Control.Basic.CircleButton") -- 16
local Set = require("Utils").Set -- 17
local Data <const> = Data -- 18
local App <const> = App -- 18
local Vec2 <const> = Vec2 -- 18
local Size <const> = Size -- 18
local DrawNode <const> = DrawNode -- 18
local Color <const> = Color -- 18
local Line <const> = Line -- 18
local Group <const> = Group -- 18
local PlatformWorld <const> = PlatformWorld -- 18
local table <const> = table -- 18
local math <const> = math -- 18
local View <const> = View -- 18
local BodyDef <const> = BodyDef -- 18
local Body <const> = Body -- 18
local UnitAction <const> = UnitAction -- 18
local once <const> = once -- 18
local Audio <const> = Audio -- 18
local Bullet <const> = Bullet -- 18
local sleep <const> = sleep -- 18
local BulletDef <const> = BulletDef -- 18
local Face <const> = Face -- 18
local cycle <const> = cycle -- 18
local Rect <const> = Rect -- 18
local Dictionary <const> = Dictionary -- 18
local TargetAllow <const> = TargetAllow -- 18
local Array <const> = Array -- 18
local Unit <const> = Unit -- 18
local tostring <const> = tostring -- 18
local Sprite <const> = Sprite -- 18
local pairs <const> = pairs -- 18
local Sel <const> = Sel -- 18
local Seq <const> = Seq -- 18
local Con <const> = Con -- 18
local Accept <const> = Accept -- 18
local Act <const> = Act -- 18
local AI <const> = AI -- 18
local Observer <const> = Observer -- 18
local Action <const> = Action -- 18
local Scale <const> = Scale -- 18
local Ease <const> = Ease -- 18
local Label <const> = Label -- 18
local Sequence <const> = Sequence -- 18
local Y <const> = Y -- 18
local Opacity <const> = Opacity -- 18
local Event <const> = Event -- 18
local Visual <const> = Visual -- 18
local emit <const> = emit -- 18
local Spawn <const> = Spawn -- 18
local Director <const> = Director -- 18
local AlignNode <const> = AlignNode -- 18
local string <const> = string -- 18
local Delay <const> = Delay -- 18
local Entity <const> = Entity -- 18
local SetNextWindowPos <const> = SetNextWindowPos -- 18
local SetNextWindowSize <const> = SetNextWindowSize -- 18
local Begin <const> = Begin -- 18
local ProgressBar <const> = ProgressBar -- 18
local Node <const> = Node -- 18
local PushStyleVar <const> = PushStyleVar -- 18
local Text <const> = Text -- 18
local Image <const> = Image -- 18
local SameLine <const> = SameLine -- 18
local Store = Data.store -- 20
local themeColor = App.themeColor -- 22
local mutables = { -- 27
	"hp", -- 27
	"moveSpeed", -- 28
	"move", -- 29
	"jump", -- 30
	"targetAllow", -- 31
	"attackBase", -- 32
	"attackPower", -- 33
	"attackSpeed", -- 34
	"damageType", -- 35
	"attackBonus", -- 36
	"attackFactor", -- 37
	"attackTarget", -- 38
	"defenceType" -- 39
} -- 26
local elementTypes = { -- 43
	Green = 1, -- 43
	Red = 2, -- 44
	Yellow = 3, -- 45
	Purple = 4 -- 46
} -- 42
Data:setDamageFactor(elementTypes.Green, elementTypes.Red, 3) -- 49
Data:setDamageFactor(elementTypes.Red, elementTypes.Yellow, 3) -- 50
Data:setDamageFactor(elementTypes.Yellow, elementTypes.Green, 3) -- 51
local itemSlots = { -- 54
	"head", -- 54
	"mask", -- 55
	"body", -- 56
	"lhand", -- 57
	"rhand" -- 58
} -- 53
local headItems = { -- 61
	"item_hat", -- 61
	"item_hatTop", -- 62
	"item_helmet", -- 63
	"item_helmetModern" -- 64
} -- 60
local lhandItems = { -- 67
	"item_shield", -- 67
	"item_shieldRound", -- 68
	"tile_heart", -- 69
	"ui_hand" -- 70
} -- 66
local rhandItems = { -- 73
	"item_bow", -- 73
	"item_sword", -- 74
	"item_rod", -- 75
	"item_spear" -- 76
} -- 72
local characterTypes = { -- 79
	"square", -- 79
	"round" -- 80
} -- 78
local characterColors = { -- 83
	"Green", -- 83
	"Red", -- 84
	"Yellow" -- 85
} -- 82
local masks = { -- 88
	"bear", -- 88
	"buffalo", -- 89
	"chick", -- 90
	"chicken", -- 91
	"cow", -- 92
	"crocodile", -- 93
	"dog", -- 94
	"duck", -- 95
	"elephant", -- 96
	"frog", -- 97
	"giraffe", -- 98
	"goat", -- 99
	"gorilla", -- 100
	"hippo", -- 101
	"horse", -- 102
	"monkey", -- 103
	"moose", -- 104
	"narwhal", -- 105
	"owl", -- 106
	"panda", -- 107
	"parrot", -- 108
	"penguin", -- 109
	"pig", -- 110
	"rabbit", -- 111
	"rhino", -- 112
	"sloth", -- 113
	"snake", -- 114
	"walrus", -- 115
	"whale", -- 116
	"zebra" -- 117
} -- 87
local itemSettings = { -- 121
	item_hat = { -- 122
		skill = "jump", -- 122
		offset = Vec2(0, 30) -- 123
	}, -- 121
	item_hatTop = { -- 126
		skill = "evade", -- 126
		offset = Vec2(0, 30) -- 127
	}, -- 125
	item_helmet = { -- 130
		skill = "rush", -- 130
		offset = Vec2(0, 0) -- 131
	}, -- 129
	item_helmetModern = { -- 134
		skill = "rush", -- 134
		offset = Vec2(0, 0) -- 135
	}, -- 133
	item_shield = { -- 138
		skill = "", -- 138
		offset = Vec2(0, 0) -- 139
	}, -- 137
	item_shieldRound = { -- 142
		skill = "jump", -- 142
		offset = Vec2(0, 0) -- 143
	}, -- 141
	tile_heart = { -- 146
		skill = "jump", -- 146
		offset = Vec2(0, 0), -- 147
		attackPower = Vec2(600, 0) -- 148
	}, -- 145
	ui_hand = { -- 151
		skill = "evade", -- 151
		offset = Vec2(0, 0) -- 152
	}, -- 150
	item_bow = { -- 155
		skill = "range", -- 155
		offset = Vec2(10, 0), -- 156
		attackRange = Size(550, 150), -- 157
		sndAttack = "Audio/d_att.wav" -- 158
	}, -- 154
	item_sword = { -- 161
		skill = "meleeAttack", -- 161
		offset = Vec2(15, 50), -- 162
		attackRange = Size(120, 150), -- 163
		sndAttack = "Audio/f_att.wav" -- 164
	}, -- 160
	item_rod = { -- 167
		skill = "meleeAttack", -- 167
		offset = Vec2(15, 50), -- 168
		attackRange = Size(200, 150), -- 169
		attackPower = Vec2(100, 800), -- 170
		sndAttack = "Audio/b_att.wav" -- 171
	}, -- 166
	item_spear = { -- 174
		skill = "meleeAttack", -- 174
		offset = Vec2(15, 50), -- 175
		attackRange = Size(200, 150), -- 176
		sndAttack = "Audio/f_att.wav" -- 177
	} -- 173
} -- 120
local GamePaused = true -- 179
local _anon_func_0 = function(_with_0, grid, size) -- 194
	local _with_1 = Line() -- 194
	_with_1.depthWrite = true -- 195
	_with_1.z = -10 -- 196
	for i = -size / grid, size / grid do -- 197
		_with_1:add({ -- 199
			Vec2(i * grid, size), -- 199
			Vec2(i * grid, -size) -- 200
		}, Color(0xff000000)) -- 198
		_with_1:add({ -- 203
			Vec2(-size, i * grid), -- 203
			Vec2(size, i * grid) -- 204
		}, Color(0xff000000)) -- 202
	end -- 197
	return _with_1 -- 194
end -- 194
do -- 183
	local size <const>, grid <const> = 1500, 150 -- 184
	local background -- 186
	background = function() -- 186
		local _with_0 = DrawNode() -- 186
		_with_0.depthWrite = true -- 187
		_with_0:drawPolygon({ -- 189
			Vec2(-size, size), -- 189
			Vec2(size, size), -- 190
			Vec2(size, -size), -- 191
			Vec2(-size, -size) -- 192
		}, Color(0xff888888)) -- 188
		_with_0:addChild(_anon_func_0(_with_0, grid, size)) -- 194
		return _with_0 -- 186
	end -- 186
	do -- 207
		local _with_0 = background() -- 207
		_with_0.z = 600 -- 208
	end -- 207
	local _with_0 = background() -- 209
	_with_0.angleX = 45 -- 210
end -- 183
local TerrainLayer = 0 -- 214
local EnemyLayer = 1 -- 215
local PlayerLayer = 2 -- 216
local PlayerGroup = 1 -- 218
local EnemyGroup = 2 -- 219
Data:setRelation(PlayerGroup, EnemyGroup, "Enemy") -- 221
Data:setShouldContact(PlayerGroup, EnemyGroup, true) -- 222
local unitGroup = Group({ -- 224
	"unit" -- 224
}) -- 224
local world -- 226
do -- 226
	local _with_0 = PlatformWorld() -- 226
	_with_0:schedule(function() -- 227
		local origin = Vec2.zero -- 228
		local locs = { -- 229
			origin -- 229
		} -- 229
		unitGroup:each(function(self) -- 230
			return table.insert(locs, self.unit.position) -- 230
		end) -- 230
		local dist = 0.0 -- 231
		for _index_0 = 1, #locs do -- 232
			local loc = locs[_index_0] -- 232
			dist = math.max(dist, loc:distance(origin)) -- 233
		end -- 232
		local DesignWidth <const> = 1250 -- 234
		local currentZoom = _with_0.camera.zoom -- 235
		local baseZoom = View.size.width / DesignWidth -- 236
		local targetZoom = baseZoom * math.max(math.min(3.0, (DesignWidth / dist / 4)), 0.8) -- 237
		_with_0.camera.zoom = currentZoom + (targetZoom - currentZoom) * 0.005 -- 238
	end) -- 227
	world = _with_0 -- 226
end -- 226
Store["world"] = world -- 240
local terrainDef -- 242
do -- 242
	local _with_0 = BodyDef() -- 242
	_with_0.type = "Static" -- 243
	_with_0:attachPolygon(Vec2(0, 0), 2500, 10, 0, 1, 1, 0) -- 244
	_with_0:attachPolygon(Vec2(0, 1000), 2500, 10, 0, 1, 1, 0) -- 245
	_with_0:attachPolygon(Vec2(800, 1000), 10, 2000, 0, 1, 1, 0) -- 246
	_with_0:attachPolygon(Vec2(-800, 1000), 10, 2000, 0, 1, 1, 0) -- 247
	terrainDef = _with_0 -- 242
end -- 242
do -- 249
	local _with_0 = Body(terrainDef, world, Vec2.zero) -- 249
	_with_0.order = TerrainLayer -- 250
	_with_0.group = Data.groupTerrain -- 251
	_with_0:addTo(world) -- 252
end -- 249
local rangeAttackEnd -- 256
rangeAttackEnd = function(name, playable) -- 256
	if name == "range" then -- 257
		return playable.parent:stop() -- 257
	end -- 257
end -- 256
UnitAction:add("range", { -- 260
	priority = 3, -- 260
	reaction = 10, -- 261
	recovery = 0.1, -- 262
	queued = true, -- 263
	available = function() -- 264
		return true -- 264
	end, -- 264
	create = function(self) -- 265
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 266
		do -- 266
			local _obj_0 = self.entity -- 271
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 266
		end -- 266
		do -- 272
			local _with_0 = self.playable -- 272
			_with_0.speed = attackSpeed -- 273
			_with_0:play("range") -- 274
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 275
		end -- 272
		return once(function(self) -- 276
			local bulletDef = Store[self.unitDef.bulletType] -- 277
			local onAttack -- 278
			onAttack = function() -- 278
				Audio:play(self.unitDef.sndAttack) -- 279
				local _with_0 = Bullet(bulletDef, self) -- 280
				if self.group == EnemyGroup then -- 281
					_with_0.color = Color(0xff666666) -- 281
				end -- 281
				_with_0.targetAllow = targetAllow -- 282
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 283
					do -- 284
						local _with_1 = target.data -- 284
						_with_1.hitPoint = pos -- 285
						_with_1.hitPower = attackPower -- 286
						_with_1.hitFromRight = bullet.velocityX < 0 -- 287
					end -- 284
					local entity = target.entity -- 288
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 289
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 290
					entity.hp = entity.hp - damage -- 291
					bullet.hitStop = true -- 292
				end) -- 283
				_with_0:addTo(self.world, self.order) -- 293
				return _with_0 -- 280
			end -- 278
			sleep(0.5 * 28.0 / 30.0 / attackSpeed) -- 294
			onAttack() -- 295
			while true do -- 296
				sleep() -- 296
			end -- 296
		end) -- 276
	end, -- 265
	stop = function(self) -- 297
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 298
	end -- 297
}) -- 259
local BigArrow -- 300
do -- 300
	local _with_0 = BulletDef() -- 300
	_with_0.tag = "" -- 301
	_with_0.endEffect = "" -- 302
	_with_0.lifeTime = 5 -- 303
	_with_0.damageRadius = 0 -- 304
	_with_0.highSpeedFix = false -- 305
	_with_0.gravity = Vec2(0, -10) -- 306
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2(-100, 0), 2) -- 307
	_with_0:setAsCircle(10) -- 308
	_with_0:setVelocity(25, 800) -- 309
	BigArrow = _with_0 -- 300
end -- 300
UnitAction:add("multiArrow", { -- 312
	priority = 3, -- 312
	reaction = 10, -- 313
	recovery = 0.1, -- 314
	queued = true, -- 315
	available = function() -- 316
		return true -- 316
	end, -- 316
	create = function(self) -- 317
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 318
		do -- 318
			local _obj_0 = self.entity -- 323
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 318
		end -- 318
		do -- 324
			local _with_0 = self.playable -- 324
			_with_0.speed = attackSpeed -- 325
			_with_0:play("range") -- 326
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 327
		end -- 324
		return once(function(self) -- 328
			local onAttack -- 329
			onAttack = function(angle, speed) -- 329
				BigArrow:setVelocity(angle, speed) -- 330
				local _with_0 = Bullet(BigArrow, self) -- 331
				if self.group == EnemyGroup then -- 332
					_with_0.color = Color(0xff666666) -- 332
				end -- 332
				_with_0.targetAllow = targetAllow -- 333
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 334
					do -- 335
						local _with_1 = target.data -- 335
						_with_1.hitPoint = pos -- 336
						_with_1.hitPower = attackPower -- 337
						_with_1.hitFromRight = bullet.velocityX < 0 -- 338
					end -- 335
					local entity = target.entity -- 339
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 340
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 341
					entity.hp = entity.hp - damage -- 342
					bullet.hitStop = true -- 343
				end) -- 334
				_with_0:addTo(self.world, self.order) -- 344
				return _with_0 -- 331
			end -- 329
			sleep(30.0 / 60.0 / attackSpeed) -- 345
			Audio:play("Audio/d_att.wav") -- 346
			onAttack(30, 1100) -- 347
			onAttack(10, 1000) -- 348
			onAttack(-10, 900) -- 349
			onAttack(-30, 800) -- 350
			onAttack(-50, 700) -- 351
			while true do -- 352
				sleep() -- 352
			end -- 352
		end) -- 328
	end, -- 317
	stop = function(self) -- 353
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 354
	end -- 353
}) -- 311
UnitAction:add("fallOff", { -- 357
	priority = 1, -- 357
	reaction = 1, -- 358
	recovery = 0, -- 359
	available = function(self) -- 360
		return not self.onSurface -- 360
	end, -- 360
	create = function(self) -- 361
		if self.velocityY <= 0 then -- 362
			self.data.fallDown = true -- 363
			local _with_0 = self.playable -- 364
			_with_0.speed = 2.5 -- 365
			_with_0:play("idle") -- 366
		else -- 367
			self.data.fallDown = false -- 367
		end -- 362
		return function(self) -- 368
			if self.onSurface then -- 369
				return true -- 369
			end -- 369
			if not self.data.fallDown and self.velocityY <= 0 then -- 370
				self.data.fallDown = true -- 371
				local _with_0 = self.playable -- 372
				_with_0.speed = 2.5 -- 373
				_with_0:play("idle") -- 374
			end -- 370
			return false -- 375
		end -- 368
	end -- 361
}) -- 356
UnitAction:add("evade", { -- 378
	priority = 10, -- 378
	reaction = 10, -- 379
	recovery = 0, -- 380
	queued = true, -- 381
	available = function() -- 382
		return true -- 382
	end, -- 382
	create = function(self) -- 383
		do -- 384
			local _with_0 = self.playable -- 384
			_with_0.speed = 1.0 -- 385
			_with_0.recovery = 0.0 -- 386
			_with_0:play("bevade") -- 387
		end -- 384
		return once(function(self) -- 388
			local group = self.group -- 389
			self.group = Data.groupHide -- 390
			local dir = self.faceRight and -1 or 1 -- 391
			cycle(0.1, function() -- 392
				self.velocityX = 400 * dir -- 392
			end) -- 392
			self.group = group -- 393
			sleep(0.1) -- 394
			do -- 395
				local _with_0 = self.playable -- 395
				_with_0.speed = 1.0 -- 396
				_with_0:play("idle") -- 397
			end -- 395
			sleep(0.3) -- 398
			return true -- 399
		end) -- 388
	end -- 383
}) -- 377
UnitAction:add("rush", { -- 402
	priority = 10, -- 402
	reaction = 10, -- 403
	recovery = 0, -- 404
	queued = true, -- 405
	available = function() -- 406
		return true -- 406
	end, -- 406
	create = function(self) -- 407
		do -- 408
			local _with_0 = self.playable -- 408
			_with_0.speed = 1.0 -- 409
			_with_0.recovery = 0.0 -- 410
			_with_0:play("fevade") -- 411
		end -- 408
		return once(function(self) -- 412
			local group = self.group -- 413
			self.group = Data.groupHide -- 414
			local dir = self.faceRight and 1 or -1 -- 415
			cycle(0.1, function() -- 416
				self.velocityX = 800 * dir -- 416
			end) -- 416
			self.group = group -- 417
			sleep(0.1) -- 418
			do -- 419
				local _with_0 = self.playable -- 419
				_with_0.speed = 1.0 -- 420
				_with_0:play("idle") -- 421
			end -- 419
			sleep(0.3) -- 422
			return true -- 423
		end) -- 412
	end -- 407
}) -- 401
local spearAttackEnd -- 425
spearAttackEnd = function(name, playable) -- 425
	if name == "spear" then -- 426
		return playable.parent:stop() -- 426
	end -- 426
end -- 425
UnitAction:add("spearAttack", { -- 429
	priority = 3, -- 429
	reaction = 10, -- 430
	recovery = 0.1, -- 431
	queued = true, -- 432
	available = function() -- 433
		return true -- 433
	end, -- 433
	create = function(self) -- 434
		local attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor -- 435
		do -- 435
			local _obj_0 = self.entity -- 439
			attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 435
		end -- 435
		do -- 440
			local _with_0 = self.playable -- 440
			_with_0.speed = attackSpeed -- 441
			_with_0.recovery = 0.2 -- 442
			_with_0:play("spear") -- 443
			_with_0:slot("AnimationEnd", spearAttackEnd) -- 444
		end -- 440
		return once(function(self) -- 445
			sleep(50.0 / 60.0) -- 446
			Audio:play("Audio/f_att.wav") -- 447
			local dir = self.faceRight and 0 or -900 -- 448
			local origin = self.position - Vec2(0, 205) + Vec2(dir, 0) -- 449
			local size = Size(900, 40) -- 450
			world:query(Rect(origin, size), function(body) -- 451
				local entity = body.entity -- 452
				if entity and Data:isEnemy(body, self) then -- 453
					do -- 454
						local _with_0 = body.data -- 454
						_with_0.hitPoint = body.position -- 455
						_with_0.hitPower = attackPower -- 456
						_with_0.hitFromRight = not self.faceRight -- 457
					end -- 454
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 458
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 459
					entity.hp = entity.hp - damage -- 460
				end -- 453
				return false -- 461
			end) -- 451
			while true do -- 462
				sleep() -- 462
			end -- 462
		end) -- 445
	end -- 434
}) -- 428
do -- 464
	local _with_0 = BulletDef() -- 464
	_with_0.tag = "" -- 465
	_with_0.endEffect = "" -- 466
	_with_0.lifeTime = 5 -- 467
	_with_0.damageRadius = 0 -- 468
	_with_0.highSpeedFix = false -- 469
	_with_0.gravity = Vec2(0, -10) -- 470
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2.zero) -- 471
	_with_0:setAsCircle(10) -- 472
	_with_0:setVelocity(25, 800) -- 473
	Store["Bullet_Arrow"] = _with_0 -- 464
end -- 464
local GetBoss -- 475
GetBoss = function(entity, pos, black) -- 475
	local unitDef -- 476
	do -- 476
		local _with_0 = Dictionary() -- 476
		_with_0.linearAcceleration = Vec2(0, -10) -- 477
		_with_0.bodyType = "Dynamic" -- 478
		_with_0.scale = 2 -- 479
		_with_0.density = 10.0 -- 480
		_with_0.friction = 1.0 -- 481
		_with_0.restitution = 0.0 -- 482
		_with_0.playable = "model:Model/bossp.model" -- 483
		_with_0.size = Size(150, 410) -- 484
		_with_0.tag = "Boss" -- 485
		_with_0.sensity = 0 -- 486
		_with_0.move = 100 -- 487
		_with_0.moveSpeed = 1.0 -- 488
		_with_0.jump = 600 -- 489
		_with_0.detectDistance = 1500 -- 490
		_with_0.hp = 30.0 -- 491
		_with_0.attackSpeed = 1.0 -- 492
		_with_0.attackBase = 2.5 -- 493
		_with_0.attackDelay = 50.0 / 60.0 -- 494
		_with_0.attackEffectDelay = 50.0 / 60.0 -- 495
		_with_0.attackBonus = 0.0 -- 496
		_with_0.attackFactor = 1.0 -- 497
		_with_0.attackRange = Size(780, 300) -- 498
		_with_0.attackPower = Vec2(200, 200) -- 499
		_with_0.attackTarget = "Multi" -- 500
		do -- 501
			local conf -- 502
			do -- 502
				local _with_1 = TargetAllow() -- 502
				_with_1.terrainAllowed = true -- 503
				_with_1:allow("Enemy", true) -- 504
				conf = _with_1 -- 502
			end -- 502
			_with_0.targetAllow = conf:toValue() -- 505
		end -- 501
		_with_0.damageType = elementTypes.Purple -- 506
		_with_0.defenceType = elementTypes.Purple -- 507
		_with_0.bulletType = "Bullet_Arrow" -- 508
		_with_0.attackEffect = "" -- 509
		_with_0.hitEffect = "Particle/bloodp.par" -- 510
		_with_0.sndAttack = "Audio/f_att.wav" -- 511
		_with_0.sndFallen = "" -- 512
		_with_0.decisionTree = "AI_Boss" -- 513
		_with_0.usePreciseHit = true -- 514
		_with_0.actions = Array({ -- 516
			"walk", -- 516
			"turn", -- 517
			"meleeAttack", -- 518
			"multiArrow", -- 519
			"spearAttack", -- 520
			"idle", -- 521
			"cancel", -- 522
			"jump", -- 523
			"fall", -- 524
			"fallOff" -- 525
		}) -- 515
		unitDef = _with_0 -- 476
	end -- 476
	for _index_0 = 1, #mutables do -- 527
		local var = mutables[_index_0] -- 527
		entity[var] = unitDef[var] -- 528
	end -- 527
	local _with_0 = Unit(unitDef, world, entity, pos) -- 529
	if black then -- 530
		for i = 1, 7 do -- 531
			local node = _with_0.playable:getNodeByName("w" .. tostring(i)) -- 532
			if node then -- 532
				node.color = Color(0xff666666) -- 533
			end -- 532
		end -- 531
	end -- 530
	local node = _with_0.playable:getNodeByName("mask") -- 534
	if node then -- 534
		node:addChild(Sprite("Model/patreon.clip|" .. tostring(masks[math.random(1, #masks)]))) -- 535
	end -- 534
	return _with_0 -- 529
end -- 475
local _anon_func_1 = function(entity, itemSettings, items) -- 553
	local _accum_0 = { } -- 553
	local _len_0 = 1 -- 553
	for _, v in pairs(items) do -- 553
		local skill = itemSettings[v].skill -- 554
		if skill then -- 554
			entity[tostring(skill) .. "Skill"] = true -- 555
			_accum_0[_len_0] = skill -- 556
			_len_0 = _len_0 + 1 -- 554
		end -- 554
	end -- 553
	return _accum_0 -- 553
end -- 553
local _anon_func_2 = function(_with_0, black, item, itemSettings) -- 618
	local _with_1 = Sprite("Model/patreon.clip|" .. tostring(item)) -- 618
	if black then -- 619
		_with_1.color = Color(0xff666666) -- 619
	end -- 619
	_with_1.position = itemSettings[item].offset -- 620
	return _with_1 -- 618
end -- 618
local GetUnit -- 537
GetUnit = function(entity, pos, black) -- 537
	local characterType = characterTypes[math.random(1, #characterTypes)] -- 538
	local characterColor = characterColors[math.random(1, #characterColors)] -- 539
	local character = { -- 541
		body = "character_" .. tostring(characterType) .. tostring(characterColor), -- 541
		lhand = "character_hand" .. tostring(characterColor), -- 542
		rhand = "character_hand" .. tostring(characterColor), -- 543
		mask = masks[math.random(1, #masks)] -- 544
	} -- 540
	local items = { -- 546
		head = headItems[math.random(1, #headItems)], -- 546
		lhand = lhandItems[math.random(1, #lhandItems)], -- 547
		rhand = rhandItems[math.random(1, #rhandItems)] -- 548
	} -- 545
	local attackRange = itemSettings[items.rhand].attackRange or Size(350, 150) -- 549
	local bonusPower = itemSettings[items.lhand].attackPower or Vec2.zero -- 550
	local attackPower = bonusPower + (itemSettings[items.rhand].attackPower or Vec2(100, 100)) -- 551
	local sndAttack = itemSettings[items.rhand].sndAttack or "" -- 552
	local skills = Set(_anon_func_1(entity, itemSettings, items)) -- 553
	local actions = Array({ -- 558
		"walk", -- 558
		"turn", -- 559
		"idle", -- 560
		"cancel", -- 561
		"hit", -- 562
		"fall", -- 563
		"fallOff" -- 564
	}) -- 557
	for k in pairs(skills) do -- 566
		actions:add(k) -- 567
	end -- 566
	local unitDef -- 568
	do -- 568
		local _with_0 = Dictionary() -- 568
		_with_0.linearAcceleration = Vec2(0, -10) -- 569
		_with_0.bodyType = "Dynamic" -- 570
		_with_0.scale = 1 -- 571
		_with_0.density = 1.0 -- 572
		_with_0.friction = 1.0 -- 573
		_with_0.restitution = 0.0 -- 574
		_with_0.playable = "model:Model/patreon.model" -- 575
		_with_0.size = Size(64, 128) -- 576
		_with_0.tag = "Fighter" -- 577
		_with_0.sensity = 0 -- 578
		_with_0.move = 250 -- 579
		_with_0.moveSpeed = 1.0 -- 580
		_with_0.jump = 700 -- 581
		_with_0.detectDistance = 800 -- 582
		_with_0.hp = 10.0 -- 583
		_with_0.attackSpeed = 1.0 -- 584
		_with_0.attackBase = 2.5 -- 585
		_with_0.attackDelay = 20.0 / 60.0 -- 586
		_with_0.attackEffectDelay = 20.0 / 60.0 -- 587
		_with_0.attackBonus = 0.0 -- 588
		_with_0.attackFactor = 1.0 -- 589
		_with_0.attackRange = attackRange -- 590
		_with_0.attackPower = attackPower -- 591
		_with_0.attackTarget = "Single" -- 592
		do -- 593
			local conf -- 594
			do -- 594
				local _with_1 = TargetAllow() -- 594
				_with_1.terrainAllowed = true -- 595
				_with_1:allow("Enemy", true) -- 596
				conf = _with_1 -- 594
			end -- 594
			_with_0.targetAllow = conf:toValue() -- 597
		end -- 593
		_with_0.damageType = elementTypes[characterColor] -- 598
		_with_0.defenceType = elementTypes[characterColor] -- 599
		_with_0.bulletType = "Bullet_Arrow" -- 600
		_with_0.attackEffect = "" -- 601
		_with_0.hitEffect = "Particle/bloodp.par" -- 602
		_with_0.name = "Fighter" -- 603
		_with_0.desc = "" -- 604
		_with_0.sndAttack = sndAttack -- 605
		_with_0.sndFallen = "" -- 606
		_with_0.decisionTree = "AI_Common" -- 607
		_with_0.usePreciseHit = true -- 608
		_with_0.actions = actions -- 609
		unitDef = _with_0 -- 568
	end -- 568
	for _index_0 = 1, #mutables do -- 610
		local var = mutables[_index_0] -- 610
		entity[var] = unitDef[var] -- 611
	end -- 610
	local _with_0 = Unit(unitDef, world, entity, pos) -- 612
	for _index_0 = 1, #itemSlots do -- 613
		local slot = itemSlots[_index_0] -- 613
		local node = _with_0.playable:getNodeByName(slot) -- 614
		do -- 615
			local item = character[slot] -- 615
			if item then -- 615
				node:addChild(Sprite("Model/patreon.clip|" .. tostring(item))) -- 616
			end -- 615
		end -- 615
		local item = items[slot] -- 617
		if item then -- 617
			node:addChild(_anon_func_2(_with_0, black, item, itemSettings)) -- 618
		end -- 617
	end -- 613
	return _with_0 -- 612
end -- 537
Store["AI_Common"] = Sel({ -- 625
	Seq({ -- 626
		Con("is dead", function(self) -- 626
			return self.entity.hp <= 0 -- 626
		end), -- 626
		Accept() -- 627
	}), -- 625
	Seq({ -- 630
		Con("is falling", function(self) -- 630
			return not self.onSurface -- 630
		end), -- 630
		Act("fallOff") -- 631
	}), -- 629
	Seq({ -- 634
		Con("game paused", function() -- 634
			return GamePaused -- 634
		end), -- 634
		Act("idle") -- 635
	}), -- 633
	Seq({ -- 638
		Con("is not attacking", function(self) -- 638
			return not self:isDoing("melee") and not self:isDoing("range") -- 639
		end), -- 638
		Con("need attack", function(self) -- 641
			local attackUnits = AI:getUnitsInAttackRange() -- 642
			for _index_0 = 1, #attackUnits do -- 643
				local unit = attackUnits[_index_0] -- 643
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 644
					return true -- 646
				end -- 644
			end -- 643
			return false -- 647
		end), -- 641
		Sel({ -- 649
			Seq({ -- 650
				Con("attack", function() -- 650
					return App.rand % 10 == 0 -- 650
				end), -- 650
				Sel({ -- 652
					Act("meleeAttack"), -- 652
					Act("range") -- 653
				}) -- 651
			}), -- 649
			Act("idle") -- 656
		}) -- 648
	}), -- 637
	Seq({ -- 660
		Con("rush or evade", function(self) -- 660
			return not self:isDoing("rush") and not self:isDoing("evade") and App.rand % 300 == 0 -- 661
		end), -- 660
		Sel({ -- 663
			Seq({ -- 664
				Con("too far away", function(self) -- 664
					if self.entity.rushSkill then -- 665
						local units = AI:getDetectedUnits() -- 666
						for _index_0 = 1, #units do -- 667
							local unit = units[_index_0] -- 667
							if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight and self.position:distance(unit.position) > 300 then -- 668
								return true -- 670
							end -- 668
						end -- 667
					end -- 665
					return false -- 671
				end), -- 664
				Act("rush") -- 672
			}), -- 663
			Seq({ -- 675
				Con("too close", function(self) -- 675
					if self.entity.evadeSkill then -- 676
						local units = AI:getDetectedUnits() -- 677
						for _index_0 = 1, #units do -- 678
							local unit = units[_index_0] -- 678
							if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight and self.position:distance(unit.position) < 300 then -- 679
								return true -- 681
							end -- 679
						end -- 678
					end -- 676
					return false -- 682
				end), -- 675
				Act("evade") -- 683
			}) -- 674
		}) -- 662
	}), -- 659
	Seq({ -- 688
		Con("need turn", function(self) -- 688
			return (self.x < -750 and not self.faceRight) or (self.x > 750 and self.faceRight) -- 689
		end), -- 688
		Act("turn") -- 690
	}), -- 687
	Act("walk") -- 692
}) -- 624
Store["AI_Boss"] = Sel({ -- 696
	Seq({ -- 697
		Con("is dead", function(self) -- 697
			return self.entity.hp <= 0 -- 697
		end), -- 697
		Accept() -- 698
	}), -- 696
	Seq({ -- 701
		Con("is falling", function(self) -- 701
			return not self.onSurface -- 701
		end), -- 701
		Act("fallOff") -- 702
	}), -- 700
	Seq({ -- 705
		Con("game paused", function() -- 705
			return GamePaused -- 705
		end), -- 705
		Act("idle") -- 706
	}), -- 704
	Seq({ -- 709
		Con("is not attacking", function(self) -- 709
			return not self:isDoing("meleeAttack") and not self:isDoing("multiArrow") and not self:isDoing("spearAttack") -- 710
		end), -- 709
		Con("need attack", function(self) -- 713
			local attackUnits = AI:getUnitsInAttackRange() -- 714
			for _index_0 = 1, #attackUnits do -- 715
				local unit = attackUnits[_index_0] -- 715
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 716
					return true -- 718
				end -- 716
			end -- 715
			return false -- 719
		end), -- 713
		Sel({ -- 721
			Seq({ -- 722
				Con("melee attack", function() -- 722
					return App.rand % 40 == 0 -- 722
				end), -- 722
				Act("meleeAttack") -- 723
			}), -- 721
			Seq({ -- 726
				Con("multi Arrow", function() -- 726
					return App.rand % 40 == 0 -- 726
				end), -- 726
				Act("multiArrow") -- 727
			}), -- 725
			Seq({ -- 730
				Con("spear attack", function() -- 730
					return App.rand % 40 == 0 -- 730
				end), -- 730
				Act("spearAttack") -- 731
			}), -- 729
			Act("idle") -- 733
		}) -- 720
	}), -- 708
	Seq({ -- 737
		Con("need turn", function(self) -- 737
			return (self.x < -750 and not self.faceRight) or (self.x > 750 and self.faceRight) -- 738
		end), -- 737
		Act("turn") -- 739
	}), -- 736
	Act("walk") -- 741
}) -- 695
do -- 744
	local _with_0 = Observer("Add", { -- 744
		"position", -- 744
		"order", -- 744
		"group", -- 744
		"faceRight" -- 744
	}) -- 744
	_with_0:watch(function(self, position, order, group, faceRight) -- 745
		world = Store.world -- 746
		if group == PlayerGroup then -- 747
			self.player = true -- 747
		end -- 747
		if group == EnemyGroup then -- 748
			self.enemy = true -- 748
		end -- 748
		local unit -- 749
		if self.boss then -- 749
			unit = GetBoss(self, position, group == EnemyGroup) -- 750
		else -- 752
			unit = GetUnit(self, position, group == EnemyGroup) -- 752
		end -- 749
		unit.group = group -- 754
		unit.order = order -- 755
		unit.playable:runAction(Action(Scale(0.5, 0, self.unit.unitDef.scale, Ease.OutBack))) -- 756
		unit.faceRight = faceRight -- 757
		unit:addTo(world) -- 758
		return false -- 745
	end) -- 745
end -- 744
do -- 760
	local _with_0 = Observer("Change", { -- 760
		"hp", -- 760
		"unit" -- 760
	}) -- 760
	_with_0:watch(function(self, hp, unit) -- 761
		local boss = self.boss -- 762
		local lastHp = self.oldValues.hp -- 763
		if hp < lastHp then -- 764
			if not boss and unit:isDoing("hit") then -- 765
				unit:start("cancel") -- 765
			end -- 765
			do -- 766
				local _with_1 = Label("sarasa-mono-sc-regular", 30) -- 766
				_with_1.order = PlayerLayer -- 767
				_with_1.color = Color(0xffff0000) -- 768
				_with_1.position = unit.position + Vec2(0, 40) -- 769
				_with_1.text = "-" .. tostring(lastHp - hp) -- 770
				_with_1:runAction(Action(Sequence(Y(0.5, _with_1.y, _with_1.y + 100), Opacity(0.2, 1, 0), Event("End")))) -- 771
				_with_1:slot("End", function() -- 776
					return _with_1:removeFromParent() -- 776
				end) -- 776
				_with_1:addTo(world) -- 777
			end -- 766
			if boss then -- 778
				local _with_1 = Visual("Particle/bloodp.par") -- 779
				_with_1.position = unit.data.hitPoint -- 780
				_with_1:addTo(world, unit.order) -- 781
				_with_1:autoRemove() -- 782
				_with_1:start() -- 783
			end -- 778
			if hp > 0 then -- 784
				unit:start("hit") -- 785
			else -- 787
				unit:start("cancel") -- 787
				unit:start("hit") -- 788
				unit:start("fall") -- 789
				unit.group = Data.groupHide -- 790
				unit:schedule(once(function() -- 791
					sleep(3) -- 792
					unit:removeFromParent() -- 793
					if not Group({ -- 794
						"unit" -- 794
					}):each(function(self) -- 794
						return self.group == PlayerGroup -- 794
					end) then -- 794
						return emit("Lost") -- 795
					elseif not Group({ -- 796
						"unit" -- 796
					}):each(function(self) -- 796
						return self.group == EnemyGroup -- 796
					end) then -- 796
						return emit("Win") -- 797
					end -- 794
				end)) -- 791
			end -- 784
		end -- 764
		return false -- 761
	end) -- 761
end -- 760
local WaitForSignal -- 799
WaitForSignal = function(text, duration) -- 799
	local _with_0 = Label("sarasa-mono-sc-regular", 100) -- 800
	_with_0.color = themeColor -- 801
	_with_0.text = text -- 802
	_with_0:runAction(Spawn(Scale(0.5, 0.3, 1, Ease.OutBack), Opacity(0.3, 0, 1))) -- 803
	sleep(duration - 0.3) -- 807
	_with_0:runAction(Spawn(Scale(0.3, 1, 1.5, Ease.OutQuad), Opacity(0.3, 1, 0, Ease.OutQuad))) -- 808
	sleep(0.3) -- 812
	_with_0:removeFromParent() -- 813
	return _with_0 -- 800
end -- 799
local GameScore = 20 -- 815
local _anon_func_3 = function(_with_2, themeColor, value) -- 825
	local _with_0 = Label("sarasa-mono-sc-regular", 32) -- 825
	_with_0.color = themeColor -- 826
	_with_0.text = string.format(tostring(value > 0 and '+' or '') .. "%d", value) -- 827
	_with_0:runAction(Sequence(Spawn(Scale(0.5, 0.3, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(0.5), Spawn(Scale(0.3, 1, 1.5, Ease.OutQuad), Opacity(0.3, 1, 0, Ease.OutQuad)), Event("End"))) -- 828
	_with_0:slot("End", function() -- 840
		return _with_0:removeFromParent() -- 840
	end) -- 840
	return _with_0 -- 825
end -- 825
Director.ui:addChild((function() -- 817
	local _with_0 = AlignNode(true) -- 817
	_with_0:css('flex-direction: row') -- 818
	_with_0:addChild((function() -- 819
		local _with_1 = AlignNode() -- 819
		_with_1:css('width: 30%') -- 820
		_with_1:addChild((function() -- 821
			local _with_2 = AlignNode() -- 821
			_with_2:css('margin-left: 165; margin-top: 40; width: 0; height: 1') -- 822
			_with_2:gslot("AddScore", function(value) -- 823
				if value < 0 and GameScore == 0 then -- 824
					return -- 824
				end -- 824
				_with_2:addChild(_anon_func_3(_with_2, themeColor, value)) -- 825
				GameScore = math.max(0, GameScore + value) -- 841
				if GameScore == 0 then -- 842
					return _with_2:schedule(once(function() -- 843
						Audio:play("Audio/game_over.wav") -- 844
						WaitForSignal("FOREVER LOST!", 3) -- 845
						return emit("GameLost") -- 846
					end)) -- 843
				end -- 842
			end) -- 823
			return _with_2 -- 821
		end)()) -- 821
		return _with_1 -- 819
	end)()) -- 819
	_with_0:addChild((function() -- 847
		local _with_1 = AlignNode() -- 847
		_with_1:css('width: 40%; flex-direction: row; justify-content: center; align-items: center') -- 848
		_with_1:addChild((function() -- 849
			local _with_2 = AlignNode() -- 849
			_with_2:css('height: 1; width: 0; margin-top: 200; margin-right: 80') -- 850
			_with_2:addChild((function() -- 851
				local _with_3 = CircleButton({ -- 852
					text = "FIGHT", -- 852
					radius = 40, -- 853
					fontName = "sarasa-mono-sc-regular", -- 854
					fontSize = 24 -- 855
				}) -- 851
				_with_3:slot("Tapped", function() -- 857
					if GameScore <= 0 then -- 858
						return -- 858
					end -- 858
					GamePaused = false -- 859
					return _with_3.parent:schedule(once(function() -- 860
						emit("Fight") -- 861
						Audio:play("Audio/choose.wav") -- 862
						return WaitForSignal("FIGHT!", 1) -- 863
					end)) -- 860
				end) -- 857
				return _with_3 -- 851
			end)()) -- 851
			return _with_2 -- 849
		end)()) -- 849
		_with_1:addChild((function() -- 864
			local _with_2 = AlignNode() -- 864
			_with_2:css('height: 1; width: 0; margin-top: 200') -- 865
			_with_2:addChild((function() -- 866
				local _with_3 = CircleButton({ -- 867
					text = "STRIKE\nBACK", -- 867
					radius = 40, -- 868
					fontName = "sarasa-mono-sc-regular", -- 869
					fontSize = 24 -- 870
				}) -- 866
				_with_3.visible = false -- 872
				_with_3:gslot("GameLost", function() -- 873
					_with_3.visible = true -- 874
					_with_3.parent.visible = true -- 875
					_with_3.touchEnabled = true -- 876
				end) -- 873
				_with_3:slot("Tapped", function() -- 877
					_with_3.touchEnabled = false -- 878
					Audio:play("Audio/v_att.wav") -- 879
					return _with_3:schedule(once(function() -- 880
						sleep(0.5) -- 881
						_with_3.visible = false -- 882
						emit("AddScore", 20) -- 883
						return emit("Start") -- 884
					end)) -- 880
				end) -- 877
				return _with_3 -- 866
			end)()) -- 866
			return _with_2 -- 864
		end)()) -- 864
		_with_1:addChild((function() -- 885
			local _with_2 = AlignNode() -- 885
			_with_2:css('height: 1; width: 0; margin-top: 200; margin-left: 80') -- 886
			_with_2:addChild((function() -- 887
				local _with_3 = CircleButton({ -- 888
					text = "ANOTHER\nWAY", -- 888
					radius = 40, -- 889
					fontName = "sarasa-mono-sc-regular", -- 890
					fontSize = 24 -- 891
				}) -- 887
				_with_3:slot("Tapped", function() -- 893
					Audio:play("Audio/switch.wav") -- 894
					if GameScore <= 5 then -- 895
						local _with_4 = _with_3.parent.parent -- 896
						_with_4:eachChild(function(self) -- 897
							self.visible = false -- 897
						end) -- 897
						_with_4:unschedule() -- 898
					end -- 895
					emit("AddScore", -5) -- 899
					return emit("Start") -- 900
				end) -- 893
				return _with_3 -- 887
			end)()) -- 887
			return _with_2 -- 885
		end)()) -- 885
		_with_1:gslot("Lost", function() -- 901
			return _with_1:schedule(once(function() -- 902
				emit("AddScore", -(10 + math.floor(GameScore / 20) * 5)) -- 903
				if GameScore == 0 then -- 904
					return -- 904
				end -- 904
				Audio:play("Audio/hero_fall.wav") -- 905
				WaitForSignal("LOST!", 1.5) -- 906
				return emit("Start") -- 907
			end)) -- 902
		end) -- 901
		_with_1:gslot("Win", function() -- 908
			return _with_1:schedule(once(function() -- 909
				local score = 5 * Group({ -- 910
					"player" -- 910
				}).count -- 910
				emit("AddScore", score) -- 911
				Audio:play("Audio/hero_win.wav") -- 912
				WaitForSignal("WIN!", 1.5) -- 913
				return emit("Start") -- 914
			end)) -- 909
		end) -- 908
		_with_1:gslot("Wasted", function() -- 915
			_with_1:eachChild(function(self) -- 916
				self.visible = false -- 917
			end) -- 916
			return emit("AddScore", -20) -- 918
		end) -- 915
		_with_1:gslot("Fight", function() -- 919
			_with_1:eachChild(function(self) -- 920
				self.visible = false -- 920
			end) -- 920
			return _with_1:unschedule() -- 921
		end) -- 919
		_with_1:gslot("Start", function() -- 922
			if GameScore == 0 then -- 923
				return -- 923
			end -- 923
			GamePaused = true -- 924
			_with_1:eachChild(function(self) -- 925
				self.visible = true -- 925
			end) -- 925
			Group({ -- 926
				"unit" -- 926
			}):each(function(self) -- 926
				return self.unit:removeFromParent() -- 926
			end) -- 926
			local unitCount -- 927
			if GameScore < 40 then -- 927
				unitCount = 1 + math.min(2, math.floor(math.max(0, GameScore - 20) / 5)) -- 928
			else -- 930
				unitCount = 3 + math.min(3, math.floor(GameScore / 35)) -- 930
			end -- 927
			if math.random(1, 100) == 1 then -- 931
				Entity({ -- 933
					position = Vec2(-200, 100), -- 933
					order = PlayerLayer, -- 934
					group = PlayerGroup, -- 935
					boss = true, -- 936
					faceRight = true -- 937
				}) -- 932
			else -- 939
				for i = 1, unitCount do -- 939
					Entity({ -- 941
						position = Vec2(-100 * i, 100), -- 941
						order = PlayerLayer, -- 942
						group = PlayerGroup, -- 943
						faceRight = true -- 944
					}) -- 940
				end -- 939
			end -- 931
			if math.random(1, 100) == 1 then -- 945
				Entity({ -- 947
					position = Vec2(200, 100), -- 947
					order = EnemyLayer, -- 948
					group = EnemyGroup, -- 949
					boss = true, -- 950
					faceRight = false -- 951
				}) -- 946
			else -- 953
				for i = 1, unitCount do -- 953
					Entity({ -- 955
						position = Vec2(100 * i, 100), -- 955
						order = EnemyLayer, -- 956
						group = EnemyGroup, -- 957
						faceRight = false -- 958
					}) -- 954
				end -- 953
			end -- 945
			return _with_1:schedule(once(function() -- 959
				local time = 2 -- 960
				cycle(time, function(dt) -- 961
					local width, height -- 962
					do -- 962
						local _obj_0 = App.visualSize -- 962
						width, height = _obj_0.width, _obj_0.height -- 962
					end -- 962
					SetNextWindowPos(Vec2(width / 2 - 150, height / 2)) -- 963
					SetNextWindowSize(Vec2(300, 50), "FirstUseEver") -- 964
					return Begin("CountDown", { -- 965
						"NoResize", -- 965
						"NoSavedSettings", -- 965
						"NoTitleBar", -- 965
						"NoMove" -- 965
					}, function() -- 965
						return ProgressBar(1.0 - dt, Vec2(-1, 30), string.format("%.2fs", (1 - dt) * time)) -- 966
					end) -- 965
				end) -- 961
				emit("Wasted") -- 967
				if GameScore == 0 then -- 968
					return -- 968
				end -- 968
				Audio:play("Audio/choose.wav") -- 969
				WaitForSignal("WASTED!", 1.5) -- 970
				return emit("Start") -- 971
			end)) -- 959
		end) -- 922
		_with_1:addChild((function() -- 972
			local _with_2 = Node() -- 972
			_with_2:schedule(function() -- 973
				SetNextWindowPos(Vec2(20, 20)) -- 974
				SetNextWindowSize(Vec2(120, 280), "FirstUseEver") -- 975
				return PushStyleVar("ItemSpacing", Vec2.zero, function() -- 976
					return Begin("Stats", { -- 977
						"NoResize", -- 977
						"NoSavedSettings", -- 977
						"NoTitleBar", -- 977
						"NoMove" -- 977
					}, function() -- 977
						Text("VALUE: " .. tostring(GameScore)) -- 978
						Image("Model/patreon.clip|character_handGreen", Vec2(30, 30)) -- 979
						SameLine() -- 980
						Text("->") -- 981
						SameLine() -- 982
						Image("Model/patreon.clip|character_handRed", Vec2(30, 30)) -- 983
						SameLine() -- 984
						Text("x3") -- 985
						Image("Model/patreon.clip|character_handRed", Vec2(30, 30)) -- 986
						SameLine() -- 987
						Text("->") -- 988
						SameLine() -- 989
						Image("Model/patreon.clip|character_handYellow", Vec2(30, 30)) -- 990
						SameLine() -- 991
						Text("x3") -- 992
						Image("Model/patreon.clip|character_handYellow", Vec2(30, 30)) -- 993
						SameLine() -- 994
						Text("->") -- 995
						SameLine() -- 996
						Image("Model/patreon.clip|character_handGreen", Vec2(30, 30)) -- 997
						SameLine() -- 998
						Text("x3") -- 999
						Image("Model/patreon.clip|item_bow", Vec2(30, 30)) -- 1000
						SameLine() -- 1001
						Text(">") -- 1002
						SameLine() -- 1003
						Image("Model/patreon.clip|item_sword", Vec2(30, 30)) -- 1004
						Image("Model/patreon.clip|item_hatTop", Vec2(30, 30)) -- 1005
						SameLine() -- 1006
						Text("dodge") -- 1007
						Image("Model/patreon.clip|item_helmet", Vec2(30, 30)) -- 1008
						SameLine() -- 1009
						Text("rush") -- 1010
						Image("Model/patreon.clip|item_rod", Vec2(30, 30)) -- 1011
						SameLine() -- 1012
						Text("knock") -- 1013
						Image("Model/patreon.clip|tile_heart", Vec2(30, 30)) -- 1014
						SameLine() -- 1015
						return Text("bash") -- 1016
					end) -- 977
				end) -- 976
			end) -- 973
			return _with_2 -- 972
		end)()) -- 972
		return _with_1 -- 847
	end)()) -- 847
	return _with_0 -- 817
end)()) -- 817
return emit("Start") -- 1018
