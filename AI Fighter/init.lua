-- [yue]: init.yue
local _ENV = Dora(Dora.ImGui, Dora.Platformer, Dora.Platformer.Decision) -- 11
local CircleButton = require("UI.Control.Basic.CircleButton") -- 16
local Data <const> = Data -- 17
local Vec2 <const> = Vec2 -- 17
local Size <const> = Size -- 17
local Group <const> = Group -- 17
local App <const> = App -- 17
local Seq <const> = Seq -- 17
local Con <const> = Con -- 17
local AI <const> = AI -- 17
local math <const> = math -- 17
local Sel <const> = Sel -- 17
local Act <const> = Act -- 17
local Node <const> = Node -- 17
local type <const> = type -- 17
local tostring <const> = tostring -- 17
local table <const> = table -- 17
local thread <const> = thread -- 17
local ML <const> = ML -- 17
local string <const> = string -- 17
local print <const> = print -- 17
local require <const> = require -- 17
local load <const> = load -- 17
local emit <const> = emit -- 17
local Accept <const> = Accept -- 17
local BulletDef <const> = BulletDef -- 17
local Face <const> = Face -- 17
local Reject <const> = Reject -- 17
local Dictionary <const> = Dictionary -- 17
local TargetAllow <const> = TargetAllow -- 17
local Array <const> = Array -- 17
local Columns <const> = Columns -- 17
local TextColored <const> = TextColored -- 17
local NextColumn <const> = NextColumn -- 17
local PushID <const> = PushID -- 17
local Button <const> = Button -- 17
local ImageButton <const> = ImageButton -- 17
local Text <const> = Text -- 17
local Color <const> = Color -- 17
local TextWrapped <const> = TextWrapped -- 17
local DrawNode <const> = DrawNode -- 17
local Line <const> = Line -- 17
local PlatformWorld <const> = PlatformWorld -- 17
local Rect <const> = Rect -- 17
local View <const> = View -- 17
local BodyDef <const> = BodyDef -- 17
local Body <const> = Body -- 17
local Sprite <const> = Sprite -- 17
local Model <const> = Model -- 17
local Scale <const> = Scale -- 17
local Ease <const> = Ease -- 17
local SetNextWindowSize <const> = SetNextWindowSize -- 17
local OpenPopup <const> = OpenPopup -- 17
local BeginPopupModal <const> = BeginPopupModal -- 17
local RadioButton <const> = RadioButton -- 17
local SameLine <const> = SameLine -- 17
local CloseCurrentPopup <const> = CloseCurrentPopup -- 17
local Entity <const> = Entity -- 17
local Sequence <const> = Sequence -- 17
local Spawn <const> = Spawn -- 17
local Opacity <const> = Opacity -- 17
local Event <const> = Event -- 17
local Director <const> = Director -- 17
local AlignNode <const> = AlignNode -- 17
local SetNextWindowPos <const> = SetNextWindowPos -- 17
local Begin <const> = Begin -- 17
local Menu <const> = Menu -- 17
local Keyboard <const> = Keyboard -- 17
local UnitAction <const> = UnitAction -- 17
local once <const> = once -- 17
local Bullet <const> = Bullet -- 17
local sleep <const> = sleep -- 17
local cycle <const> = cycle -- 17
local Observer <const> = Observer -- 17
local Unit <const> = Unit -- 17
local Visual <const> = Visual -- 17
local Store = Data.store -- 18
local characters = { -- 23
	{ -- 23
		body = "character_roundGreen", -- 23
		lhand = "character_handGreen", -- 24
		rhand = "character_handGreen" -- 25
	}, -- 23
	{ -- 27
		body = "character_roundRed", -- 27
		lhand = "character_handRed", -- 28
		rhand = "character_handRed" -- 29
	}, -- 27
	{ -- 31
		body = "character_roundYellow", -- 31
		lhand = "character_handYellow", -- 32
		rhand = "character_handYellow" -- 33
	} -- 31
} -- 22
local headItems = { -- 36
	"item_hat", -- 36
	"item_hatTop", -- 37
	"item_helmet", -- 38
	"item_helmetModern" -- 39
} -- 35
local lhandItems = { -- 42
	"item_shield", -- 42
	"item_shieldRound", -- 43
	"tile_heart", -- 44
	"ui_hand" -- 45
} -- 41
local rhandItems = { -- 48
	"item_bow", -- 48
	"item_sword", -- 49
	"item_rod", -- 50
	"item_spear" -- 51
} -- 47
local characterTypes = { -- 54
	"square", -- 54
	"round" -- 55
} -- 53
local characterColors = { -- 58
	"Green", -- 58
	"Red", -- 59
	"Yellow" -- 60
} -- 57
local itemSettings = { -- 63
	item_hat = { -- 64
		name = "普通帽子", -- 64
		desc = "就是很普通的帽子，增加许些防御力", -- 65
		cost = 1, -- 66
		skill = "jump", -- 67
		skillDesc = "跳跃", -- 68
		offset = Vec2(0, 30) -- 69
	}, -- 63
	item_hatTop = { -- 72
		name = "高帽子", -- 72
		desc = "就是很普通的帽子，增加许些防御力", -- 73
		cost = 1, -- 74
		skill = "evade", -- 75
		skillDesc = "闪避", -- 76
		offset = Vec2(0, 30) -- 77
	}, -- 71
	item_helmet = { -- 80
		name = "战盔", -- 80
		desc = "就是很普通的帽子，增加许些防御力", -- 81
		cost = 1, -- 82
		skill = "evade", -- 83
		skillDesc = "闪避", -- 84
		offset = Vec2(0, 0) -- 85
	}, -- 79
	item_helmetModern = { -- 88
		name = "橄榄球盔", -- 88
		desc = "就是很普通的帽子，增加许些防御力", -- 89
		cost = 1, -- 90
		skill = "", -- 91
		skillDesc = "无", -- 92
		offset = Vec2(0, 0) -- 93
	}, -- 87
	item_shield = { -- 96
		name = "方形盾", -- 96
		desc = "无", -- 97
		cost = 1, -- 98
		skill = "evade", -- 99
		skillDesc = "闪避", -- 100
		offset = Vec2(0, 0) -- 101
	}, -- 95
	item_shieldRound = { -- 104
		name = "小圆盾", -- 104
		desc = "无", -- 105
		cost = 1, -- 106
		skill = "jump", -- 107
		skillDesc = "跳跃", -- 108
		offset = Vec2(0, 0) -- 109
	}, -- 103
	tile_heart = { -- 112
		name = "爱心", -- 112
		desc = "无", -- 113
		cost = 1, -- 114
		skill = "jump", -- 115
		skillDesc = "跳跃", -- 116
		offset = Vec2(0, 0) -- 117
	}, -- 111
	ui_hand = { -- 120
		name = "手套", -- 120
		desc = "无", -- 121
		cost = 1, -- 122
		skill = "evade", -- 123
		skillDesc = "闪避", -- 124
		offset = Vec2(0, 0) -- 125
	}, -- 119
	item_bow = { -- 128
		name = "短弓", -- 128
		desc = "无", -- 129
		cost = 1, -- 130
		skill = "range", -- 131
		skillDesc = "远程攻击", -- 132
		offset = Vec2(10, 0), -- 133
		attackRange = Size(630, 150) -- 134
	}, -- 127
	item_sword = { -- 137
		name = "剑", -- 137
		desc = "无", -- 138
		cost = 1, -- 139
		skill = "meleeAttack", -- 140
		skillDesc = "近程攻击", -- 141
		offset = Vec2(15, 50), -- 142
		attackRange = Size(120, 150) -- 143
	}, -- 136
	item_rod = { -- 146
		name = "法杖", -- 146
		desc = "无", -- 147
		cost = 1, -- 148
		skill = "meleeAttack", -- 149
		skillDesc = "近程攻击", -- 150
		offset = Vec2(15, 50), -- 151
		attackRange = Size(200, 150) -- 152
	}, -- 145
	item_spear = { -- 155
		name = "长矛", -- 155
		desc = "无", -- 156
		cost = 1, -- 157
		skill = "meleeAttack", -- 158
		skillDesc = "近程攻击", -- 159
		offset = Vec2(15, 50), -- 160
		attackRange = Size(200, 150) -- 161
	} -- 154
} -- 62
local itemSlots = { -- 164
	"head", -- 164
	"lhand", -- 165
	"rhand" -- 166
} -- 163
characters = { -- 169
	{ -- 169
		head = nil, -- 169
		lhand = nil, -- 170
		rhand = nil, -- 171
		type = 1, -- 172
		color = 1, -- 173
		learnedAI = function() -- 174
			return "unknown" -- 174
		end -- 174
	}, -- 169
	{ -- 176
		head = nil, -- 176
		lhand = nil, -- 177
		rhand = nil, -- 178
		type = 1, -- 179
		color = 2, -- 180
		learnedAI = function() -- 181
			return "unknown" -- 181
		end -- 181
	}, -- 176
	{ -- 183
		head = nil, -- 183
		lhand = nil, -- 184
		rhand = nil, -- 185
		type = 1, -- 186
		color = 3, -- 187
		learnedAI = function() -- 188
			return "unknown" -- 188
		end -- 188
	} -- 183
} -- 168
local bossGroup = Group({ -- 190
	"boss" -- 190
}) -- 190
local lastAction = "idle" -- 192
local lastActionFrame = App.frame -- 193
local data = { } -- 194
local row = nil -- 195
local _anon_func_0 = function(enemy) -- 237
	local _obj_0 = enemy.currentAction -- 237
	if _obj_0 ~= nil then -- 237
		return _obj_0.name -- 237
	end -- 237
	return nil -- 237
end -- 237
local Do -- 196
Do = function(name) -- 196
	return Seq({ -- 197
		Con("Collect data", function(self) -- 197
			if self:isDoing(name) then -- 198
				row = nil -- 199
				return true -- 200
			end -- 198
			if not (AI:getNearestUnit("Enemy") ~= nil) then -- 202
				row = nil -- 203
				return true -- 204
			end -- 202
			local attack_ready -- 206
			do -- 206
				local attackUnits = AI:getUnitsInAttackRange() -- 207
				local ready = false -- 208
				for _index_0 = 1, #attackUnits do -- 209
					local unit = attackUnits[_index_0] -- 209
					if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 210
						ready = true -- 212
						break -- 213
					end -- 210
				end -- 209
				attack_ready = ready -- 214
			end -- 206
			local not_facing_enemy -- 216
			do -- 216
				local enemy = AI:getNearestUnit("Enemy") -- 217
				if enemy then -- 218
					not_facing_enemy = (self.x > enemy.x) == self.faceRight -- 219
				else -- 221
					not_facing_enemy = false -- 221
				end -- 218
			end -- 216
			local enemy_in_attack_range -- 223
			do -- 223
				local enemy = AI:getNearestUnit("Enemy") -- 224
				local attackUnits = AI:getUnitsInAttackRange() -- 225
				enemy_in_attack_range = attackUnits and attackUnits:contains(enemy) or false -- 226
			end -- 223
			local nearest_enemy_distance -- 228
			do -- 228
				local enemy = AI:getNearestUnit("Enemy") -- 229
				if (enemy ~= nil) then -- 230
					nearest_enemy_distance = math.abs(enemy.x - self.x) -- 231
				else -- 233
					nearest_enemy_distance = 999999 -- 233
				end -- 230
			end -- 228
			local enemy_hero_action -- 235
			do -- 235
				local enemy = AI:getNearestUnit("Enemy") -- 236
				enemy_hero_action = _anon_func_0(enemy) or "unknown" -- 237
			end -- 235
			row = { -- 240
				not_facing_enemy = not_facing_enemy, -- 240
				enemy_in_attack_range = enemy_in_attack_range, -- 241
				attack_ready = attack_ready, -- 242
				enemy_hero_action = enemy_hero_action, -- 243
				nearest_enemy_distance = nearest_enemy_distance, -- 244
				action = name -- 245
			} -- 239
			return true -- 247
		end), -- 197
		Sel({ -- 249
			Con("is doing", function(self) -- 249
				return self:isDoing(name) -- 249
			end), -- 249
			Seq({ -- 251
				Act(name), -- 251
				Con("action succeeded", function() -- 252
					lastAction = name -- 253
					lastActionFrame = App.frame -- 254
					return true -- 255
				end) -- 252
			}) -- 250
		}), -- 248
		Con("Save data", function() -- 258
			if row == nil then -- 259
				return true -- 259
			end -- 259
			data[#data + 1] = row -- 260
			return true -- 261
		end) -- 258
	}) -- 196
end -- 196
local rowNames = { -- 265
	"not_facing_enemy", -- 265
	"enemy_in_attack_range", -- 266
	"attack_ready", -- 268
	"enemy_hero_action", -- 269
	"nearest_enemy_distance", -- 270
	"action" -- 272
} -- 264
local rowTypes = { -- 276
	'C', -- 276
	'C', -- 276
	'C', -- 277
	'C', -- 277
	'N', -- 277
	'C' -- 278
} -- 275
local _anon_func_1 = function(_with_0, name, op, value) -- 296
	if name ~= "" then -- 296
		return "if " .. tostring(name) .. " " .. tostring(op) .. " " .. tostring(op == '==' and "\"" .. tostring(value) .. "\"" or value) -- 297
	else -- 299
		return tostring(op) .. " \"" .. tostring(value) .. "\"" -- 299
	end -- 296
end -- 296
local _anon_func_2 = function(_with_0, luaCodes) -- 307
	local _obj_0 = load(luaCodes) -- 307
	if _obj_0 ~= nil then -- 307
		return _obj_0() -- 307
	end -- 307
	return nil -- 307
end -- 307
do -- 281
	local _with_0 = Node() -- 281
	_with_0:gslot("TrainAI", function(charSet) -- 282
		local csvData -- 283
		do -- 283
			local _accum_0 = { } -- 283
			local _len_0 = 1 -- 283
			for _index_0 = 1, #data do -- 283
				local row = data[_index_0] -- 283
				local rd -- 284
				do -- 284
					local _accum_1 = { } -- 284
					local _len_1 = 1 -- 284
					for _index_1 = 1, #rowNames do -- 284
						local name = rowNames[_index_1] -- 284
						local val -- 285
						if (row[name] ~= nil) then -- 285
							val = row[name] -- 285
						else -- 285
							val = "N" -- 285
						end -- 285
						if "boolean" == type(val) then -- 286
							if val then -- 287
								val = "T" -- 287
							else -- 287
								val = "F" -- 287
							end -- 287
						end -- 286
						_accum_1[_len_1] = tostring(val) -- 288
						_len_1 = _len_1 + 1 -- 285
					end -- 284
					rd = _accum_1 -- 284
				end -- 284
				_accum_0[_len_0] = table.concat(rd, ",") -- 289
				_len_0 = _len_0 + 1 -- 284
			end -- 283
			csvData = _accum_0 -- 283
		end -- 283
		local names = tostring(table.concat(rowNames, ',')) .. "\n" -- 290
		local dataStr = tostring(names) .. tostring(table.concat(rowTypes, ',')) .. "\n" .. tostring(table.concat(csvData, '\n')) -- 291
		data = { } -- 292
		return thread(function() -- 293
			local lines = { -- 294
				"(_ENV) ->" -- 294
			} -- 294
			local accuracy = ML.BuildDecisionTreeAsync(dataStr, 0, function(depth, name, op, value) -- 295
				local line = string.rep("\t", depth + 1) .. _anon_func_1(_with_0, name, op, value) -- 296
				lines[#lines + 1] = line -- 300
			end) -- 295
			local codes = table.concat(lines, "\n") -- 301
			print("learning accuracy: " .. tostring(accuracy)) -- 302
			print(codes) -- 303
			local yue = require("yue") -- 305
			local luaCodes = yue.to_lua(codes, { -- 306
				reserve_line_number = false -- 306
			}) -- 306
			local learnedAI = _anon_func_2(_with_0, luaCodes) or function() -- 307
				return "unknown" -- 307
			end -- 307
			characters[charSet].learnedAI = learnedAI -- 308
			return emit("LearnedAI", learnedAI) -- 309
		end) -- 293
	end) -- 282
end -- 281
local _anon_func_3 = function(enemy) -- 365
	local _obj_0 = enemy.currentAction -- 365
	if _obj_0 ~= nil then -- 365
		return _obj_0.name -- 365
	end -- 365
	return nil -- 365
end -- 365
Store["AI_Learned"] = Sel({ -- 312
	Seq({ -- 313
		Con("is dead", function(self) -- 313
			return self.entity.hp <= 0 -- 313
		end), -- 313
		Accept() -- 314
	}), -- 312
	Seq({ -- 317
		Con("is falling", function(self) -- 317
			return not self.onSurface -- 317
		end), -- 317
		Act("fallOff") -- 318
	}), -- 316
	Seq({ -- 321
		Con("run learned AI", function(self) -- 321
			local _obj_0 = self.data -- 322
			_obj_0.lastActionTime = _obj_0.lastActionTime or 0.0 -- 322
			if not (AI:getNearestUnit("Enemy") ~= nil) then -- 324
				return false -- 324
			end -- 324
			if App.totalTime - self.data.lastActionTime < 0.1 then -- 326
				return false -- 327
			else -- 329
				self.data.lastActionTime = App.totalTime -- 329
			end -- 326
			local attack_ready -- 331
			do -- 331
				local attackUnits = AI:getUnitsInAttackRange() -- 332
				local ready = "F" -- 333
				for _index_0 = 1, #attackUnits do -- 334
					local unit = attackUnits[_index_0] -- 334
					if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 335
						ready = "T" -- 337
						break -- 338
					end -- 335
				end -- 334
				attack_ready = ready -- 339
			end -- 331
			local not_facing_enemy -- 341
			do -- 341
				local enemy = AI:getNearestUnit("Enemy") -- 342
				if enemy then -- 343
					if (self.x > enemy.x) == self.faceRight then -- 344
						not_facing_enemy = "T" -- 345
					else -- 347
						not_facing_enemy = "F" -- 347
					end -- 344
				else -- 349
					not_facing_enemy = "F" -- 349
				end -- 343
			end -- 341
			local enemy_in_attack_range -- 351
			do -- 351
				local enemy = AI:getNearestUnit("Enemy") -- 352
				local attackUnits = AI:getUnitsInAttackRange() -- 353
				enemy_in_attack_range = (attackUnits and attackUnits:contains(enemy)) and "T" or "F" -- 354
			end -- 351
			local nearest_enemy_distance -- 356
			do -- 356
				local enemy = AI:getNearestUnit("Enemy") -- 357
				if (enemy ~= nil) then -- 358
					nearest_enemy_distance = math.abs(enemy.x - self.x) -- 359
				else -- 361
					nearest_enemy_distance = 999999 -- 361
				end -- 358
			end -- 356
			local enemy_hero_action -- 363
			do -- 363
				local enemy = AI:getNearestUnit("Enemy") -- 364
				enemy_hero_action = _anon_func_3(enemy) or "unknown" -- 365
			end -- 363
			self.entity.learnedAction = characters[self.entity.charSet].learnedAI({ -- 368
				not_facing_enemy = not_facing_enemy, -- 368
				enemy_in_attack_range = enemy_in_attack_range, -- 369
				attack_ready = attack_ready, -- 370
				enemy_hero_action = enemy_hero_action, -- 371
				nearest_enemy_distance = nearest_enemy_distance -- 372
			}) or "unknown" -- 367
			return true -- 374
		end), -- 321
		Sel({ -- 376
			Con("is doing", function(self) -- 376
				return self:isDoing(self.entity.learnedAction) -- 376
			end), -- 376
			Seq({ -- 378
				Act(function(self) -- 378
					return self.entity.learnedAction -- 378
				end), -- 378
				Con("Succeeded prediction", function() -- 379
					emit("Prediction", true) -- 380
					return true -- 381
				end) -- 379
			}), -- 377
			Con("Failed prediction", function() -- 383
				emit("Prediction", false) -- 384
				return false -- 385
			end) -- 383
		}) -- 375
	}), -- 320
	Seq({ -- 389
		Con("not facing enemy", function(self) -- 389
			return bossGroup:each(function(boss) -- 389
				local unit = boss.unit -- 390
				if Data:isEnemy(unit, self) then -- 391
					if (self.x > unit.x) == self.faceRight then -- 392
						return true -- 393
					end -- 392
				end -- 391
			end) -- 389
		end), -- 389
		Act("turn") -- 394
	}), -- 388
	Seq({ -- 397
		Con("need turn", function(self) -- 397
			return (self.x < -1000 and not self.faceRight) or (self.x > 1000 and self.faceRight) -- 398
		end), -- 397
		Act("turn") -- 399
	}), -- 396
	Sel({ -- 402
		Seq({ -- 403
			Con("take a break", function() -- 403
				return App.rand % 60 == 0 -- 403
			end), -- 403
			Act("idle") -- 404
		}), -- 402
		Act("walk") -- 406
	}) -- 401
}) -- 311
do -- 410
	local _with_0 = BulletDef() -- 410
	_with_0.tag = "" -- 411
	_with_0.endEffect = "" -- 412
	_with_0.lifeTime = 5 -- 413
	_with_0.damageRadius = 0 -- 414
	_with_0.highSpeedFix = false -- 415
	_with_0.gravity = Vec2(0, -10) -- 416
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2(0, 0)) -- 417
	_with_0:setAsCircle(10) -- 418
	_with_0:setVelocity(25, 800) -- 419
	Store["Bullet_Arrow"] = _with_0 -- 410
end -- 410
Store["AI_Boss"] = Sel({ -- 422
	Seq({ -- 423
		Con("is dead", function(self) -- 423
			return self.entity.hp <= 0 -- 423
		end), -- 423
		Accept() -- 424
	}), -- 422
	Seq({ -- 427
		Con("is falling", function(self) -- 427
			return not self.onSurface -- 427
		end), -- 427
		Act("fallOff") -- 428
	}), -- 426
	Seq({ -- 431
		Con("is not attacking", function(self) -- 431
			return not self:isDoing("meleeAttack") and not self:isDoing("multiArrow") and not self:isDoing("spearAttack") -- 432
		end), -- 431
		Con("need attack", function(self) -- 435
			local attackUnits = AI:getUnitsInAttackRange() -- 436
			for _index_0 = 1, #attackUnits do -- 437
				local unit = attackUnits[_index_0] -- 437
				if Data:isEnemy(self, unit) and (self.x < unit.x) == self.faceRight then -- 438
					return true -- 440
				end -- 438
			end -- 437
			return false -- 441
		end), -- 435
		Sel({ -- 443
			Seq({ -- 444
				Con("melee attack", function() -- 444
					return App.rand % 250 == 0 -- 444
				end), -- 444
				Act("meleeAttack") -- 445
			}), -- 443
			Seq({ -- 448
				Con("range attack", function() -- 448
					return App.rand % 250 == 0 -- 448
				end), -- 448
				Act("multiArrow") -- 449
			}), -- 447
			Seq({ -- 452
				Con("spear attack", function() -- 452
					return App.rand % 250 == 0 -- 452
				end), -- 452
				Act("spearAttack") -- 453
			}), -- 451
			Act("idle") -- 455
		}) -- 442
	}), -- 430
	Seq({ -- 459
		Con("need turn", function(self) -- 459
			return (self.x < -1000 and not self.faceRight) or (self.x > 1000 and self.faceRight) -- 460
		end), -- 459
		Act("turn") -- 461
	}), -- 458
	Act("walk") -- 463
}) -- 421
Store["AI_PlayerControl"] = Sel({ -- 467
	Seq({ -- 468
		Con("is dead", function(self) -- 468
			return self.entity.hp <= 0 -- 468
		end), -- 468
		Accept() -- 469
	}), -- 467
	Seq({ -- 472
		Seq({ -- 473
			Con("move key down", function(self) -- 473
				return not (self.data.keyLeft and self.data.keyRight) and ((self.data.keyLeft and self.faceRight) or (self.data.keyRight and not self.faceRight)) -- 474
			end), -- 473
			Act("turn") -- 479
		}), -- 472
		Reject() -- 481
	}), -- 471
	Seq({ -- 484
		Con("evade key down", function(self) -- 484
			return self.data.keyE -- 484
		end), -- 484
		Do("evade") -- 485
	}), -- 483
	Seq({ -- 488
		Con("attack key down", function(self) -- 488
			return self.data.keyF -- 488
		end), -- 488
		Sel({ -- 490
			Do("meleeAttack"), -- 490
			Do("range") -- 491
		}) -- 489
	}), -- 487
	Sel({ -- 495
		Seq({ -- 496
			Con("is falling", function(self) -- 496
				return not self.onSurface and not self:isDoing("evade") -- 496
			end), -- 496
			Act("fallOff") -- 497
		}), -- 495
		Seq({ -- 500
			Con("jump key down", function(self) -- 500
				return self.data.keyUp -- 500
			end), -- 500
			Do("jump") -- 501
		}) -- 499
	}), -- 494
	Seq({ -- 505
		Con("move key down", function(self) -- 505
			return self.data.keyLeft or self.data.keyRight -- 505
		end), -- 505
		Do("walk") -- 506
	}), -- 504
	Act("idle") -- 508
}) -- 466
local NewFighterDef -- 511
NewFighterDef = function() -- 511
	local _with_0 = Dictionary() -- 511
	_with_0.linearAcceleration = Vec2(0, -10) -- 512
	_with_0.bodyType = "Dynamic" -- 513
	_with_0.scale = 1 -- 514
	_with_0.density = 1.0 -- 515
	_with_0.friction = 1.0 -- 516
	_with_0.restitution = 0.0 -- 517
	_with_0.playable = "model:Model/patreon" -- 518
	_with_0.size = Size(64, 128) -- 519
	_with_0.tag = "Fighter" -- 520
	_with_0.sensity = 0 -- 521
	_with_0.move = 250 -- 522
	_with_0.moveSpeed = 1.0 -- 523
	_with_0.jump = 700 -- 524
	_with_0.detectDistance = 800 -- 525
	_with_0.hp = 50.0 -- 526
	_with_0.attackSpeed = 1.0 -- 527
	_with_0.attackBase = 2.5 -- 528
	_with_0.attackDelay = 20.0 / 60.0 -- 529
	_with_0.attackEffectDelay = 20.0 / 60.0 -- 530
	_with_0.attackBonus = 0.0 -- 531
	_with_0.attackFactor = 1.0 -- 532
	_with_0.attackRange = Size(350, 150) -- 533
	_with_0.attackPower = Vec2(100, 100) -- 534
	_with_0.attackTarget = "Single" -- 535
	do -- 536
		local conf -- 537
		do -- 537
			local _with_1 = TargetAllow() -- 537
			_with_1.terrainAllowed = true -- 538
			_with_1:allow("Enemy", true) -- 539
			conf = _with_1 -- 537
		end -- 537
		_with_0.targetAllow = conf:toValue() -- 540
	end -- 536
	_with_0.damageType = 0 -- 541
	_with_0.defenceType = 0 -- 542
	_with_0.bulletType = "Bullet_Arrow" -- 543
	_with_0.attackEffect = "" -- 544
	_with_0.hitEffect = "Particle/bloodp.par" -- 545
	_with_0.name = "Fighter" -- 546
	_with_0.desc = "" -- 547
	_with_0.sndAttack = "" -- 548
	_with_0.sndFallen = "" -- 549
	_with_0.decisionTree = "AI_PlayerControl" -- 550
	_with_0.usePreciseHit = true -- 551
	_with_0.actions = Array({ -- 553
		"walk", -- 553
		"turn", -- 554
		"idle", -- 555
		"cancel", -- 556
		"hit", -- 557
		"fall", -- 558
		"fallOff" -- 559
	}) -- 552
	return _with_0 -- 511
end -- 511
local NewBossDef -- 562
NewBossDef = function() -- 562
	local _with_0 = Dictionary() -- 562
	_with_0.linearAcceleration = Vec2(0, -10) -- 563
	_with_0.bodyType = "Dynamic" -- 564
	_with_0.scale = 2 -- 565
	_with_0.density = 10.0 -- 566
	_with_0.friction = 1.0 -- 567
	_with_0.restitution = 0.0 -- 568
	_with_0.playable = "model:Model/bossp.model" -- 569
	_with_0.size = Size(150, 410) -- 570
	_with_0.tag = "Boss" -- 571
	_with_0.sensity = 0 -- 572
	_with_0.move = 100 -- 573
	_with_0.moveSpeed = 1.0 -- 574
	_with_0.jump = 600 -- 575
	_with_0.detectDistance = 1500 -- 576
	_with_0.hp = 200.0 -- 577
	_with_0.attackSpeed = 1.0 -- 578
	_with_0.attackBase = 2.5 -- 579
	_with_0.attackDelay = 50.0 / 60.0 -- 580
	_with_0.attackEffectDelay = 50.0 / 60.0 -- 581
	_with_0.attackBonus = 0.0 -- 582
	_with_0.attackFactor = 1.0 -- 583
	_with_0.attackRange = Size(780, 300) -- 584
	_with_0.attackPower = Vec2(200, 200) -- 585
	_with_0.attackTarget = "Multi" -- 586
	do -- 587
		local conf -- 588
		do -- 588
			local _with_1 = TargetAllow() -- 588
			_with_1.terrainAllowed = true -- 589
			_with_1:allow("Enemy", true) -- 590
			conf = _with_1 -- 588
		end -- 588
		_with_0.targetAllow = conf:toValue() -- 591
	end -- 587
	_with_0.damageType = 0 -- 592
	_with_0.defenceType = 0 -- 593
	_with_0.bulletType = "Bullet_Arrow" -- 594
	_with_0.attackEffect = "" -- 595
	_with_0.hitEffect = "Particle/bloodp.par" -- 596
	_with_0.sndAttack = "" -- 597
	_with_0.sndFallen = "" -- 598
	_with_0.decisionTree = "AI_Boss" -- 599
	_with_0.usePreciseHit = true -- 600
	_with_0.actions = Array({ -- 602
		"walk", -- 602
		"turn", -- 603
		"meleeAttack", -- 604
		"multiArrow", -- 605
		"spearAttack", -- 606
		"idle", -- 607
		"cancel", -- 608
		"jump", -- 609
		"fall", -- 610
		"fallOff" -- 611
	}) -- 601
	return _with_0 -- 562
end -- 562
local UnitDefFuncs = { -- 615
	fighter = NewFighterDef, -- 615
	boss = NewBossDef -- 616
} -- 614
local themeColor = App.themeColor -- 619
local itemSize = 64 -- 620
local NewItemPanel -- 621
NewItemPanel = function(displayName, itemName, itemOptions, currentSet) -- 621
	local selectItems = false -- 622
	return function() -- 623
		Columns(1, false) -- 624
		TextColored(themeColor, displayName) -- 625
		NextColumn() -- 626
		if selectItems then -- 627
			Columns(#itemOptions + 1, false) -- 628
			PushID(tostring(itemName) .. "x", function() -- 629
				if Button("x", Vec2(itemSize + 10, itemSize + 10)) then -- 630
					currentSet[itemName] = nil -- 631
					selectItems = false -- 632
				end -- 630
			end) -- 629
			NextColumn() -- 633
			for i = 1, #itemOptions do -- 634
				local item = itemOptions[i] -- 635
				if ImageButton(tostring(itemName) .. tostring(i), "Model/patreon.clip|" .. tostring(item), Vec2(itemSize, itemSize)) then -- 636
					currentSet[itemName] = item -- 637
					selectItems = false -- 638
				end -- 636
				NextColumn() -- 639
			end -- 634
		else -- 641
			if not currentSet[itemName] then -- 641
				Columns(3, false) -- 642
				PushID(tostring(itemName) .. "c1", function() -- 643
					if Button("x", Vec2(itemSize + 10, itemSize + 10)) then -- 644
						selectItems = true -- 644
					end -- 644
				end) -- 643
				NextColumn() -- 645
				return Text("未装备") -- 646
			else -- 648
				Columns(3, false) -- 648
				local item = currentSet[itemName] -- 649
				if ImageButton(tostring(itemName) .. "c2", "Model/patreon.clip|" .. tostring(item), Vec2(itemSize, itemSize)) then -- 650
					selectItems = true -- 650
				end -- 650
				NextColumn() -- 651
				TextColored(Color(0xfffffa0a), itemSettings[item].name) -- 652
				TextWrapped(itemSettings[item].desc) -- 653
				NextColumn() -- 654
				TextColored(Color(0xffff0a90), "消耗: " .. tostring(itemSettings[item].cost)) -- 655
				Text("特技: " .. tostring(itemSettings[item].skillDesc)) -- 656
				return NextColumn() -- 657
			end -- 641
		end -- 627
	end -- 623
end -- 621
local size, grid = 2000, 150 -- 661
local _anon_func_4 = function(_with_0, grid, size) -- 671
	local _with_1 = Line() -- 671
	_with_1.depthWrite = true -- 672
	_with_1.z = -10 -- 673
	for i = -size / grid, size / grid do -- 674
		_with_1:add({ -- 676
			Vec2(i * grid, size), -- 676
			Vec2(i * grid, -size) -- 677
		}, Color(0xff000000)) -- 675
		_with_1:add({ -- 680
			Vec2(-size, i * grid), -- 680
			Vec2(size, i * grid) -- 681
		}, Color(0xff000000)) -- 679
	end -- 674
	return _with_1 -- 671
end -- 671
local background -- 663
background = function() -- 663
	local _with_0 = DrawNode() -- 663
	_with_0.depthWrite = true -- 664
	_with_0:drawPolygon({ -- 666
		Vec2(-size, size), -- 666
		Vec2(size, size), -- 667
		Vec2(size, -size), -- 668
		Vec2(-size, -size) -- 669
	}, Color(0xff888888)) -- 665
	_with_0:addChild(_anon_func_4(_with_0, grid, size)) -- 671
	return _with_0 -- 663
end -- 663
do -- 684
	local _with_0 = background() -- 684
	_with_0.z = 600 -- 685
end -- 684
do -- 686
	local _with_0 = background() -- 686
	_with_0.angleX = 45 -- 687
end -- 686
local TerrainLayer = 0 -- 691
local EnemyLayer = 1 -- 692
local PlayerLayer = 2 -- 693
local PlayerGroup = 1 -- 695
local EnemyGroup = 2 -- 696
local DesignWidth <const> = 1500 -- 698
Data:setRelation(PlayerGroup, EnemyGroup, "Enemy") -- 700
Data:setShouldContact(PlayerGroup, EnemyGroup, true) -- 701
local world -- 703
do -- 703
	local _with_0 = PlatformWorld() -- 703
	_with_0.camera.boundary = Rect(-1250, -500, 2500, 1000) -- 704
	_with_0.camera.followRatio = Vec2(0.01, 0.01) -- 705
	_with_0.camera.zoom = View.size.width / DesignWidth -- 706
	_with_0:onAppChange(function(settingName) -- 707
		if settingName == "Size" then -- 707
			local zoom = View.size.width / DesignWidth -- 708
			_with_0.camera.zoom = zoom -- 709
		end -- 707
	end) -- 707
	world = _with_0 -- 703
end -- 703
Store["world"] = world -- 710
local terrainDef -- 712
do -- 712
	local _with_0 = BodyDef() -- 712
	_with_0.type = "Static" -- 713
	_with_0:attachPolygon(Vec2(0, 0), 2500, 10, 0, 1, 1, 0) -- 714
	_with_0:attachPolygon(Vec2(0, 1000), 2500, 10, 0, 1, 1, 0) -- 715
	_with_0:attachPolygon(Vec2(1250, 500), 10, 1000, 0, 1, 1, 0) -- 716
	_with_0:attachPolygon(Vec2(-1250, 500), 10, 1000, 0, 1, 1, 0) -- 717
	terrainDef = _with_0 -- 712
end -- 712
do -- 719
	local _with_0 = Body(terrainDef, world, Vec2.zero) -- 719
	_with_0.order = TerrainLayer -- 720
	_with_0.group = Data.groupTerrain -- 721
	_with_0:addTo(world) -- 722
end -- 719
local _anon_func_5 = function(item, offset) -- 742
	local _with_0 = Sprite("Model/patreon.clip|" .. tostring(item)) -- 742
	_with_0.position = offset -- 743
	return _with_0 -- 742
end -- 742
local updateModel -- 724
updateModel = function(model, currentSet) -- 724
	local node = model:getNodeByName("body") -- 725
	node:removeAllChildren() -- 726
	local charType = characterTypes[currentSet.type] -- 727
	local charColor = characterColors[currentSet.color] -- 728
	node:addChild(Sprite("Model/patreon.clip|character_" .. tostring(charType) .. tostring(charColor))) -- 729
	node = model:getNodeByName("lhand") -- 730
	node:removeAllChildren() -- 731
	node:addChild(Sprite("Model/patreon.clip|character_hand" .. tostring(charColor))) -- 732
	node = model:getNodeByName("rhand") -- 733
	node:removeAllChildren() -- 734
	node:addChild(Sprite("Model/patreon.clip|character_hand" .. tostring(charColor))) -- 735
	model:getNodeByName("head"):removeAllChildren() -- 736
	for _index_0 = 1, #itemSlots do -- 737
		local slot = itemSlots[_index_0] -- 737
		node = model:getNodeByName(slot) -- 738
		local item = currentSet[slot] -- 739
		if item then -- 740
			local offset = itemSettings[item].offset -- 741
			node:addChild(_anon_func_5(item, offset)) -- 742
		end -- 740
	end -- 737
end -- 724
local NewFighter -- 745
NewFighter = function(name, currentSet) -- 745
	local assembleFighter = false -- 746
	local fighter -- 747
	do -- 747
		local _with_0 = Model("Model/patreon.model") -- 747
		local modelRect = Rect(-128, -128, 256, 256) -- 748
		_with_0.recovery = 0.2 -- 749
		_with_0.order = PlayerLayer -- 750
		_with_0.touchEnabled = true -- 751
		_with_0.swallowTouches = true -- 752
		_with_0:slot("TapFilter", function(touch) -- 753
			if not modelRect:containsPoint(touch.location) then -- 754
				touch.enabled = false -- 755
			end -- 754
		end) -- 753
		_with_0:slot("Tapped", function() -- 756
			if not fighter:getChildByTag("select") then -- 757
				local selectFrame -- 758
				local _with_1 = Sprite("Model/patreon.clip|ui_select") -- 758
				_with_1:addTo(fighter, 0, "select") -- 759
				_with_1:runAction(Scale(0.3, 0, 1.8, Ease.OutBack)) -- 760
				assembleFighter = true -- 761
				selectFrame = _with_1 -- 758
			end -- 757
		end) -- 756
		_with_0:play("idle", true) -- 762
		fighter = _with_0 -- 747
	end -- 747
	updateModel(fighter, currentSet) -- 763
	local HeadItemPanel = NewItemPanel("头部", "head", headItems, currentSet) -- 764
	local LHandItemPanel = NewItemPanel("副手", "lhand", lhandItems, currentSet) -- 765
	local RHandItemPanel = NewItemPanel("主手", "rhand", rhandItems, currentSet) -- 766
	return fighter, function() -- 767
		SetNextWindowSize(Vec2(445, 600), "FirstUseEver") -- 768
		if assembleFighter then -- 769
			assembleFighter = false -- 770
			OpenPopup("战士" .. tostring(name)) -- 771
		end -- 769
		return BeginPopupModal("战士" .. tostring(name), { -- 772
			"NoResize", -- 772
			"NoSavedSettings" -- 772
		}, function() -- 772
			HeadItemPanel() -- 773
			RHandItemPanel() -- 774
			LHandItemPanel() -- 775
			Columns(1, false) -- 776
			TextColored(themeColor, "性别") -- 777
			NextColumn() -- 778
			local _ -- 779
			_, currentSet.type = RadioButton("男", currentSet.type, 1) -- 779
			SameLine() -- 780
			_, currentSet.type = RadioButton("女", currentSet.type, 2) -- 781
			Columns(1, false) -- 782
			local cost = 0 -- 783
			for _index_0 = 1, #itemSlots do -- 784
				local slot = itemSlots[_index_0] -- 784
				local item = currentSet[slot] -- 785
				cost = cost + (item and itemSettings[item].cost or 0) -- 786
			end -- 784
			TextColored(themeColor, "累计消耗资源：" .. tostring(cost)) -- 787
			NextColumn() -- 788
			Columns(2, false) -- 789
			if Button("进行训练！", Vec2(200, 80)) then -- 790
				updateModel(fighter, currentSet) -- 791
				CloseCurrentPopup() -- 792
				do -- 793
					local _with_0 = fighter:getChildByTag("select") -- 793
					_with_0:removeFromParent() -- 794
				end -- 793
				emit("ShowSetting", false) -- 795
				local charSet = 1 -- 796
				for i = 1, #characters do -- 797
					if currentSet == characters[i] then -- 798
						charSet = i -- 799
						break -- 800
					end -- 798
				end -- 797
				Entity({ -- 802
					unitDef = "fighter", -- 802
					charSet = charSet, -- 803
					order = PlayerLayer, -- 804
					position = Vec2(-400, 400), -- 805
					group = PlayerGroup, -- 806
					faceRight = true, -- 807
					player = true, -- 808
					decisionTree = "AI_PlayerControl" -- 809
				}) -- 801
				Entity({ -- 811
					unitDef = "boss", -- 811
					order = EnemyLayer, -- 812
					position = Vec2(400, 400), -- 813
					group = EnemyGroup, -- 814
					faceRight = false, -- 815
					boss = true -- 816
				}) -- 810
				emit("ShowTraining", true) -- 817
			end -- 790
			NextColumn() -- 818
			if Button("装备完成！", Vec2(200, 80)) then -- 819
				updateModel(fighter, currentSet) -- 820
				CloseCurrentPopup() -- 821
				local _with_0 = fighter:getChildByTag("select") -- 822
				_with_0:runAction(Sequence(Spawn(Scale(0.3, 1.8, 2.5), Opacity(0.3, 1, 0)), Event("End"))) -- 823
				_with_0:slot("End", function() -- 827
					return _with_0:removeFromParent() -- 827
				end) -- 827
			end -- 819
			return NextColumn() -- 828
		end) -- 772
	end -- 767
end -- 745
local fighterFigures = { } -- 830
local fighterPanels = { } -- 831
for i = 1, #characters do -- 832
	local fighter, fighterPanel = NewFighter(string.rep("I", i), characters[i]) -- 833
	table.insert(fighterFigures, fighter) -- 834
	table.insert(fighterPanels, fighterPanel) -- 835
end -- 832
local playerGroup = Group({ -- 837
	"player", -- 837
	"unit" -- 837
}) -- 837
local playerInput = { -- 838
	keyboard = { }, -- 838
	virtual = { } -- 838
} -- 838
local updatePlayerControl -- 839
updatePlayerControl = function(key, flag, source) -- 839
	if source == nil then -- 839
		source = "virtual" -- 839
	end -- 839
	playerInput[source][key] = flag -- 840
	return playerGroup:each(function(self) -- 841
		self.unit.data[key] = (playerInput.keyboard[key] or playerInput.virtual[key]) == true -- 841
	end) -- 841
end -- 839
Director.ui:gslot("ShowTraining", function() -- 842
	local _list_0 = { -- 843
		"keyboard", -- 843
		"virtual" -- 843
	} -- 843
	for _index_0 = 1, #_list_0 do -- 843
		local source = _list_0[_index_0] -- 843
		local _list_1 = { -- 844
			"keyLeft", -- 844
			"keyRight", -- 844
			"keyUp", -- 844
			"keyF", -- 844
			"keyE" -- 844
		} -- 844
		for _index_1 = 1, #_list_1 do -- 844
			local key = _list_1[_index_1] -- 844
			updatePlayerControl(key, false, source) -- 845
		end -- 844
	end -- 843
end) -- 842
Director.ui:addChild((function() -- 847
	local _with_0 = AlignNode(true) -- 847
	_with_0:css('flex-direction: column') -- 848
	_with_0:schedule(function() -- 849
		local width, height -- 850
		do -- 850
			local _obj_0 = App.visualSize -- 850
			width, height = _obj_0.width, _obj_0.height -- 850
		end -- 850
		SetNextWindowPos(Vec2(10, 10), "FirstUseEver") -- 851
		SetNextWindowSize(Vec2(350, 160), "FirstUseEver") -- 852
		return Begin("AI军团", { -- 853
			"NoResize", -- 853
			"NoSavedSettings" -- 853
		}, function() -- 853
			local isPC -- 854
			do -- 854
				local _exp_0 = App.platform -- 854
				if "macOS" == _exp_0 or "Windows" == _exp_0 or "Linux" == _exp_0 or "Web" == _exp_0 then -- 855
					isPC = true -- 855
				else -- 856
					isPC = false -- 856
				end -- 854
			end -- 854
			return TextWrapped("点击你的学员部队配备装备，并亲自进行战斗方法的训练，最后带领部队挑战敌人。\n学员战斗AI通过玩家操作自动学习生成。" .. tostring(isPC and '训练操作按键：向左A，向右D，闪避E，攻击J，跳跃K' or '')) -- 857
		end) -- 853
	end) -- 849
	_with_0:addChild((function() -- 858
		local _with_1 = AlignNode() -- 858
		_with_1:css("height: 30%") -- 859
		return _with_1 -- 858
	end)()) -- 858
	_with_0:addChild((function() -- 860
		local _with_1 = AlignNode() -- 860
		_with_1:css("height: 40%; align-items: center; justify-content: center") -- 861
		_with_1:addChild((function() -- 862
			local _with_2 = AlignNode() -- 862
			_with_2:css('height: 1; width: 0') -- 863
			_with_2:addChild((function() -- 864
				local _with_3 = Node() -- 864
				_with_3.visible = false -- 865
				_with_3.scaleX = 0.5 -- 866
				_with_3.scaleY = 0.5 -- 866
				_with_3:gslot("ShowTraining", function(show) -- 867
					_with_3.visible = show -- 868
					if show then -- 869
						return _with_3:addChild((function() -- 870
							local _with_4 = CircleButton({ -- 871
								text = "训练\n结束！", -- 871
								y = -150, -- 872
								radius = 80, -- 873
								fontName = "sarasa-mono-sc-regular", -- 874
								fontSize = 48 -- 875
							}) -- 870
							_with_4:slot("Tapped", function() -- 877
								emit("ShowTraining", false) -- 878
								Group({ -- 879
									"player" -- 879
								}):each(function(e) -- 879
									if e.charSet then -- 880
										emit("TrainAI", e.charSet) -- 881
										return e.unit:removeFromParent() -- 882
									end -- 880
								end) -- 879
								Group({ -- 883
									"boss" -- 883
								}):each(function(e) -- 883
									return e.unit:removeFromParent() -- 884
								end) -- 883
								return emit("ShowSetting", true) -- 885
							end) -- 877
							return _with_4 -- 870
						end)()) -- 870
					else -- 887
						return _with_3:removeAllChildren() -- 887
					end -- 869
				end) -- 867
				_with_3:gslot("ShowFight", function(show) -- 888
					_with_3.visible = show -- 889
					if show then -- 890
						return _with_3:addChild((function() -- 891
							local _with_4 = CircleButton({ -- 892
								text = "离开\n战斗", -- 892
								y = -150, -- 893
								radius = 80, -- 894
								fontName = "sarasa-mono-sc-regular", -- 895
								fontSize = 48 -- 896
							}) -- 891
							_with_4:slot("Tapped", function() -- 898
								Group({ -- 899
									"unitDef" -- 899
								}):each(function(e) -- 899
									local _obj_0 = e.unit -- 900
									if _obj_0 ~= nil then -- 900
										return _obj_0:removeFromParent() -- 900
									end -- 900
									return nil -- 900
								end) -- 899
								emit("ShowSetting", true) -- 901
								return thread(function() -- 902
									return emit("ShowFight", false) -- 902
								end) -- 902
							end) -- 898
							return _with_4 -- 891
						end)()) -- 891
					else -- 904
						return _with_3:removeAllChildren() -- 904
					end -- 890
				end) -- 888
				return _with_3 -- 864
			end)()) -- 864
			_with_2:addChild((function() -- 905
				local _with_3 = Node() -- 905
				_with_3:gslot("ShowSetting", function(show) -- 906
					_with_3.visible = show -- 906
				end) -- 906
				_with_3.scaleX = 0.5 -- 907
				_with_3.scaleY = 0.5 -- 907
				_with_3:addChild((function() -- 908
					local _with_4 = Model("Model/bossp.model") -- 908
					_with_4.x = 500 -- 909
					_with_4.y = 100 -- 910
					_with_4.fliped = true -- 911
					_with_4.speed = 0.8 -- 912
					_with_4.recovery = 0.2 -- 913
					_with_4.scaleX = 2 -- 914
					_with_4.scaleY = 2 -- 914
					_with_4:play("idle", true) -- 915
					return _with_4 -- 908
				end)()) -- 908
				for i = 1, #fighterFigures do -- 916
					local fighter = fighterFigures[i] -- 917
					_with_3:addChild((function() -- 918
						fighter.x = -500 + (i - 1) * 200 -- 919
						return fighter -- 918
					end)()) -- 918
				end -- 916
				_with_3:addChild((function() -- 920
					local _with_4 = CircleButton({ -- 921
						text = "开战！", -- 921
						y = -150, -- 922
						radius = 80, -- 923
						fontName = "sarasa-mono-sc-regular", -- 924
						fontSize = 48 -- 925
					}) -- 920
					local showItems -- 927
					showItems = function(show) -- 927
						for _index_0 = 1, #fighterFigures do -- 928
							local fighter = fighterFigures[_index_0] -- 928
							fighter.touchEnabled = not show -- 929
						end -- 928
						_with_4.visible = not show -- 930
					end -- 927
					_with_4:gslot("ShowFight", showItems) -- 931
					_with_4:gslot("ShowTraining", showItems) -- 932
					_with_4:slot("Tapped", function() -- 933
						if not _with_4.visible then -- 934
							return -- 934
						end -- 934
						for i = 1, #characters do -- 935
							Entity({ -- 937
								unitDef = "fighter", -- 937
								charSet = i, -- 938
								order = PlayerLayer, -- 939
								position = Vec2(-600 + (i - 1) * 200, 400), -- 940
								group = PlayerGroup, -- 941
								faceRight = true, -- 942
								decisionTree = "AI_Learned", -- 943
								player = true -- 944
							}) -- 936
						end -- 935
						Entity({ -- 946
							unitDef = "boss", -- 946
							order = EnemyLayer, -- 947
							position = Vec2(400, 400), -- 948
							group = EnemyGroup, -- 949
							faceRight = false, -- 950
							boss = true -- 951
						}) -- 945
						emit("ShowSetting", false) -- 952
						return emit("ShowFight", true) -- 953
					end) -- 933
					return _with_4 -- 920
				end)()) -- 920
				return _with_3 -- 905
			end)()) -- 905
			return _with_2 -- 862
		end)()) -- 862
		return _with_1 -- 860
	end)()) -- 860
	do -- 954
		local _exp_0 = App.platform -- 954
		if "iOS" == _exp_0 or "Android" == _exp_0 or "Web" == _exp_0 then -- 955
			_with_0:addChild((function() -- 956
				local _with_1 = AlignNode() -- 956
				_with_1:css("\n					width: auto;\n					height: 30%;\n					padding-bottom: 40;\n					margin: 0, 10, 0;\n					flex-direction: row;\n					justify-content: space-between\n				") -- 957
				_with_1:gslot("ShowTraining", function(show) -- 965
					_with_1.visible = show -- 965
				end) -- 965
				_with_1:addChild((function() -- 966
					local _with_2 = AlignNode() -- 966
					_with_2:css('height: 100%; width: 0') -- 967
					_with_2:addChild((function() -- 968
						local _with_3 = Menu() -- 968
						_with_3.anchor = Vec2.zero -- 969
						_with_3.size = Size(130, 60) -- 970
						_with_3:addChild((function() -- 971
							local _with_4 = CircleButton({ -- 972
								text = "左", -- 972
								radius = 60, -- 973
								fontSize = math.floor(36) -- 974
							}) -- 971
							_with_4.scaleX = 0.5 -- 976
							_with_4.scaleY = 0.5 -- 976
							_with_4.anchor = Vec2.zero -- 977
							_with_4:slot("TapBegan", function() -- 978
								return updatePlayerControl("keyLeft", true) -- 978
							end) -- 978
							_with_4:slot("TapEnded", function() -- 979
								return updatePlayerControl("keyLeft", false) -- 979
							end) -- 979
							return _with_4 -- 971
						end)()) -- 971
						_with_3:addChild((function() -- 980
							local _with_4 = CircleButton({ -- 981
								text = "右", -- 981
								x = 70, -- 982
								radius = 60, -- 983
								fontSize = math.floor(36) -- 984
							}) -- 980
							_with_4.scaleX = 0.5 -- 986
							_with_4.scaleY = 0.5 -- 986
							_with_4.anchor = Vec2.zero -- 987
							_with_4:slot("TapBegan", function() -- 988
								return updatePlayerControl("keyRight", true) -- 988
							end) -- 988
							_with_4:slot("TapEnded", function() -- 989
								return updatePlayerControl("keyRight", false) -- 989
							end) -- 989
							return _with_4 -- 980
						end)()) -- 980
						return _with_3 -- 968
					end)()) -- 968
					return _with_2 -- 966
				end)()) -- 966
				_with_1:addChild((function() -- 990
					local _with_2 = AlignNode() -- 990
					_with_2:css('height: 100%; width: 0') -- 991
					_with_2:addChild((function() -- 992
						local _with_3 = Menu() -- 992
						_with_3.anchor = Vec2(1, 0) -- 993
						_with_3.size = Size(200, 60) -- 994
						_with_3:addChild((function() -- 995
							local _with_4 = CircleButton({ -- 996
								text = "闪", -- 996
								radius = 60, -- 997
								fontSize = math.floor(36) -- 998
							}) -- 995
							_with_4.scaleX = 0.5 -- 1000
							_with_4.scaleY = 0.5 -- 1000
							_with_4.anchor = Vec2.zero -- 1001
							_with_4:slot("TapBegan", function() -- 1002
								return updatePlayerControl("keyE", true) -- 1002
							end) -- 1002
							_with_4:slot("TapEnded", function() -- 1003
								return updatePlayerControl("keyE", false) -- 1003
							end) -- 1003
							return _with_4 -- 995
						end)()) -- 995
						_with_3:addChild((function() -- 1004
							local _with_4 = CircleButton({ -- 1005
								text = "跳", -- 1005
								x = 70, -- 1006
								radius = 60, -- 1007
								fontSize = math.floor(36) -- 1008
							}) -- 1004
							_with_4.scaleX = 0.5 -- 1010
							_with_4.scaleY = 0.5 -- 1010
							_with_4.anchor = Vec2.zero -- 1011
							_with_4:slot("TapBegan", function() -- 1012
								return updatePlayerControl("keyUp", true) -- 1012
							end) -- 1012
							_with_4:slot("TapEnded", function() -- 1013
								return updatePlayerControl("keyUp", false) -- 1013
							end) -- 1013
							return _with_4 -- 1004
						end)()) -- 1004
						_with_3:addChild((function() -- 1014
							local _with_4 = CircleButton({ -- 1015
								text = "打", -- 1015
								x = 140, -- 1016
								radius = 60, -- 1017
								fontSize = math.floor(36) -- 1018
							}) -- 1014
							_with_4.scaleX = 0.5 -- 1020
							_with_4.scaleY = 0.5 -- 1020
							_with_4.anchor = Vec2.zero -- 1021
							_with_4:slot("TapBegan", function() -- 1022
								return updatePlayerControl("keyF", true) -- 1022
							end) -- 1022
							_with_4:slot("TapEnded", function() -- 1023
								return updatePlayerControl("keyF", false) -- 1023
							end) -- 1023
							return _with_4 -- 1014
						end)()) -- 1014
						return _with_3 -- 992
					end)()) -- 992
					return _with_2 -- 990
				end)()) -- 990
				return _with_1 -- 956
			end)()) -- 956
		end -- 954
	end -- 954
	if App.platform == "macOS" or App.platform == "Windows" or App.platform == "Linux" or App.platform == "Web" then -- 1024
		local _with_1 = Node() -- 1025
		_with_1:schedule(function() -- 1026
			updatePlayerControl("keyLeft", Keyboard:isKeyPressed("A"), "keyboard") -- 1027
			updatePlayerControl("keyRight", Keyboard:isKeyPressed("D"), "keyboard") -- 1028
			updatePlayerControl("keyUp", Keyboard:isKeyPressed("K"), "keyboard") -- 1029
			updatePlayerControl("keyF", Keyboard:isKeyPressed("J"), "keyboard") -- 1030
			return updatePlayerControl("keyE", Keyboard:isKeyPressed("E"), "keyboard") -- 1031
		end) -- 1026
	end -- 1024
	return _with_0 -- 847
end)()) -- 847
do -- 1033
	local _with_0 = Node() -- 1033
	_with_0:schedule(function() -- 1034
		local width, height -- 1035
		do -- 1035
			local _obj_0 = App.visualSize -- 1035
			width, height = _obj_0.width, _obj_0.height -- 1035
		end -- 1035
		for _index_0 = 1, #fighterPanels do -- 1036
			local panel = fighterPanels[_index_0] -- 1036
			panel() -- 1036
		end -- 1036
	end) -- 1034
end -- 1033
local rangeAttackEnd -- 1038
rangeAttackEnd = function(name, playable) -- 1038
	if name == "range" then -- 1039
		return playable.parent:stop() -- 1039
	end -- 1039
end -- 1038
UnitAction:add("range", { -- 1042
	priority = 3, -- 1042
	reaction = 10, -- 1043
	recovery = 0.1, -- 1044
	queued = true, -- 1045
	available = function() -- 1046
		return true -- 1046
	end, -- 1046
	create = function(self) -- 1047
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 1048
		do -- 1048
			local _obj_0 = self.entity -- 1053
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 1048
		end -- 1048
		do -- 1054
			local _with_0 = self.playable -- 1054
			_with_0.speed = attackSpeed -- 1055
			_with_0:play("range") -- 1056
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 1057
		end -- 1054
		return once(function(self) -- 1058
			local bulletDef = Store[self.unitDef.bulletType] -- 1059
			local onAttack -- 1060
			onAttack = function() -- 1060
				local _with_0 = Bullet(bulletDef, self) -- 1061
				_with_0.targetAllow = targetAllow -- 1062
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 1063
					do -- 1064
						local _with_1 = target.data -- 1064
						_with_1.hitPoint = pos -- 1065
						_with_1.hitPower = attackPower -- 1066
						_with_1.hitFromRight = bullet.velocityX < 0 -- 1067
					end -- 1064
					local entity = target.entity -- 1068
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 1069
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 1070
					entity.hp = entity.hp - damage -- 1071
					bullet.hitStop = true -- 1072
				end) -- 1063
				_with_0:addTo(self.world, self.order) -- 1073
				return _with_0 -- 1061
			end -- 1060
			sleep(0.5 * 28.0 / 30.0 / attackSpeed) -- 1074
			onAttack() -- 1075
			while true do -- 1076
				sleep() -- 1076
			end -- 1076
		end) -- 1058
	end, -- 1047
	stop = function(self) -- 1077
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 1078
	end -- 1077
}) -- 1041
local BigArrow -- 1080
do -- 1080
	local _with_0 = BulletDef() -- 1080
	_with_0.tag = "" -- 1081
	_with_0.endEffect = "" -- 1082
	_with_0.lifeTime = 5 -- 1083
	_with_0.damageRadius = 0 -- 1084
	_with_0.highSpeedFix = false -- 1085
	_with_0.gravity = Vec2(0, -10) -- 1086
	_with_0.face = Face("Model/patreon.clip|item_arrow", Vec2(-100, 0), 2) -- 1087
	_with_0:setAsCircle(10) -- 1088
	_with_0:setVelocity(25, 800) -- 1089
	BigArrow = _with_0 -- 1080
end -- 1080
UnitAction:add("multiArrow", { -- 1092
	priority = 3, -- 1092
	reaction = 10, -- 1093
	recovery = 0.1, -- 1094
	queued = true, -- 1095
	available = function() -- 1096
		return true -- 1096
	end, -- 1096
	create = function(self) -- 1097
		local attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor -- 1098
		do -- 1098
			local _obj_0 = self.entity -- 1103
			attackSpeed, targetAllow, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.targetAllow, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 1098
		end -- 1098
		do -- 1104
			local _with_0 = self.playable -- 1104
			_with_0.speed = attackSpeed -- 1105
			_with_0:play("range") -- 1106
			_with_0:slot("AnimationEnd", rangeAttackEnd) -- 1107
		end -- 1104
		return once(function(self) -- 1108
			local onAttack -- 1109
			onAttack = function(angle, speed) -- 1109
				BigArrow:setVelocity(angle, speed) -- 1110
				local _with_0 = Bullet(BigArrow, self) -- 1111
				_with_0.targetAllow = targetAllow -- 1112
				_with_0:slot("HitTarget", function(bullet, target, pos) -- 1113
					do -- 1114
						local _with_1 = target.data -- 1114
						_with_1.hitPoint = pos -- 1115
						_with_1.hitPower = attackPower -- 1116
						_with_1.hitFromRight = bullet.velocityX < 0 -- 1117
					end -- 1114
					local entity = target.entity -- 1118
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 1119
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 1120
					entity.hp = entity.hp - damage -- 1121
					bullet.hitStop = true -- 1122
				end) -- 1113
				_with_0:addTo(self.world, self.order) -- 1123
				return _with_0 -- 1111
			end -- 1109
			sleep(30.0 / 60.0 / attackSpeed) -- 1124
			onAttack(30, 1100) -- 1125
			onAttack(10, 1000) -- 1126
			onAttack(-10, 900) -- 1127
			onAttack(-30, 800) -- 1128
			onAttack(-50, 700) -- 1129
			while true do -- 1130
				sleep() -- 1130
			end -- 1130
		end) -- 1108
	end, -- 1097
	stop = function(self) -- 1131
		return self.playable:slot("AnimationEnd"):remove(rangeAttackEnd) -- 1132
	end -- 1131
}) -- 1091
UnitAction:add("fallOff", { -- 1135
	priority = 1, -- 1135
	reaction = 1, -- 1136
	recovery = 0, -- 1137
	available = function(self) -- 1138
		return not self.onSurface -- 1138
	end, -- 1138
	create = function(self) -- 1139
		if self.velocityY <= 0 then -- 1140
			self.data.fallDown = true -- 1141
			local _with_0 = self.playable -- 1142
			_with_0.speed = 2.5 -- 1143
			_with_0:play("idle") -- 1144
		else -- 1145
			self.data.fallDown = false -- 1145
		end -- 1140
		return function(self) -- 1146
			if self.onSurface then -- 1147
				return true -- 1147
			end -- 1147
			if not self.data.fallDown and self.velocityY <= 0 then -- 1148
				self.data.fallDown = true -- 1149
				local _with_0 = self.playable -- 1150
				_with_0.speed = 2.5 -- 1151
				_with_0:play("idle") -- 1152
			end -- 1148
			return false -- 1153
		end -- 1146
	end -- 1139
}) -- 1134
UnitAction:add("evade", { -- 1156
	priority = 10, -- 1156
	reaction = 10, -- 1157
	recovery = 0, -- 1158
	queued = true, -- 1159
	available = function() -- 1160
		return true -- 1160
	end, -- 1160
	create = function(self) -- 1161
		do -- 1162
			local _with_0 = self.playable -- 1162
			_with_0.speed = 1.0 -- 1163
			_with_0.recovery = 0.0 -- 1164
			_with_0:play("bevade") -- 1165
		end -- 1162
		return once(function(self) -- 1166
			local group = self.group -- 1167
			self.group = Data.groupHide -- 1168
			local dir = self.faceRight and -1 or 1 -- 1169
			cycle(0.2, function() -- 1170
				self.velocityX = 800 * dir -- 1170
			end) -- 1170
			self.group = group -- 1171
			do -- 1172
				local _with_0 = self.playable -- 1172
				_with_0.speed = 1.0 -- 1173
				_with_0:play("idle") -- 1174
			end -- 1172
			sleep(1) -- 1175
			return true -- 1176
		end) -- 1166
	end -- 1161
}) -- 1155
local spearAttackEnd -- 1178
spearAttackEnd = function(name, playable) -- 1178
	if name == "spear" then -- 1179
		return playable.parent:stop() -- 1179
	end -- 1179
end -- 1178
UnitAction:add("spearAttack", { -- 1182
	priority = 3, -- 1182
	reaction = 10, -- 1183
	recovery = 0.1, -- 1184
	queued = true, -- 1185
	available = function() -- 1186
		return true -- 1186
	end, -- 1186
	create = function(self) -- 1187
		local attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor -- 1188
		do -- 1188
			local _obj_0 = self.entity -- 1192
			attackSpeed, attackPower, damageType, attackBase, attackBonus, attackFactor = _obj_0.attackSpeed, _obj_0.attackPower, _obj_0.damageType, _obj_0.attackBase, _obj_0.attackBonus, _obj_0.attackFactor -- 1188
		end -- 1188
		do -- 1193
			local _with_0 = self.playable -- 1193
			_with_0.speed = attackSpeed -- 1194
			_with_0.recovery = 0.2 -- 1195
			_with_0:play("spear") -- 1196
			_with_0:slot("AnimationEnd", spearAttackEnd) -- 1197
		end -- 1193
		return once(function(self) -- 1198
			sleep(50.0 / 60.0) -- 1199
			local dir = self.faceRight and 0 or -900 -- 1200
			local origin = self.position - Vec2(0, 205) + Vec2(dir, 0) -- 1201
			local size = Size(900, 40) -- 1202
			world:query(Rect(origin, size), function(body) -- 1203
				local entity = body.entity -- 1204
				if entity and Data:isEnemy(body, self) then -- 1205
					do -- 1206
						local _with_0 = body.data -- 1206
						_with_0.hitPoint = body.position -- 1207
						_with_0.hitPower = attackPower -- 1208
						_with_0.hitFromRight = not self.faceRight -- 1209
					end -- 1206
					local factor = Data:getDamageFactor(damageType, entity.defenceType) -- 1210
					local damage = (attackBase + attackBonus) * (attackFactor + factor) -- 1211
					entity.hp = entity.hp - damage -- 1212
				end -- 1205
				return false -- 1213
			end) -- 1203
			while true do -- 1214
				sleep() -- 1214
			end -- 1214
		end) -- 1198
	end, -- 1187
	stop = function(self) -- 1215
		return self.playable:slot("AnimationEnd"):remove(spearAttackEnd) -- 1216
	end -- 1215
}) -- 1181
local mutables = { -- 1219
	"hp", -- 1219
	"moveSpeed", -- 1220
	"move", -- 1221
	"jump", -- 1222
	"targetAllow", -- 1223
	"attackBase", -- 1224
	"attackPower", -- 1225
	"attackSpeed", -- 1226
	"damageType", -- 1227
	"attackBonus", -- 1228
	"attackFactor", -- 1229
	"attackTarget", -- 1230
	"defenceType" -- 1231
} -- 1218
do -- 1234
	local _with_0 = Observer("Add", { -- 1234
		"unitDef", -- 1234
		"position", -- 1234
		"order", -- 1234
		"group", -- 1234
		"faceRight" -- 1234
	}) -- 1234
	_with_0:watch(function(self, unitDef, position, order, group) -- 1235
		local player, faceRight, charSet, decisionTree = self.player, self.faceRight, self.charSet, self.decisionTree -- 1236
		world = Store.world -- 1237
		local func = UnitDefFuncs[unitDef] -- 1238
		local def = func() -- 1239
		for _index_0 = 1, #mutables do -- 1240
			local var = mutables[_index_0] -- 1240
			self[var] = def[var] -- 1241
		end -- 1240
		if charSet then -- 1242
			local set = characters[charSet] -- 1243
			local actions = def.actions -- 1244
			local actionSet -- 1245
			do -- 1245
				local _tbl_0 = { } -- 1245
				for _index_0 = 1, #actions do -- 1245
					local a = actions[_index_0] -- 1245
					_tbl_0[a] = true -- 1245
				end -- 1245
				actionSet = _tbl_0 -- 1245
			end -- 1245
			for _index_0 = 1, #itemSlots do -- 1246
				local slot = itemSlots[_index_0] -- 1246
				local item = set[slot] -- 1247
				if not item then -- 1248
					goto _continue_0 -- 1248
				end -- 1248
				local skill = itemSettings[item].skill -- 1249
				if skill and not actionSet[skill] then -- 1250
					actions:add(skill) -- 1251
				end -- 1250
				local attackRange = itemSettings[item].attackRange -- 1252
				if attackRange then -- 1253
					def.attackRange = attackRange -- 1253
				end -- 1253
				::_continue_0:: -- 1247
			end -- 1246
		end -- 1242
		if decisionTree then -- 1254
			def.decisionTree = decisionTree -- 1254
		end -- 1254
		local unit -- 1255
		do -- 1255
			local _with_1 = Unit(def, world, self, position) -- 1255
			_with_1.group = group -- 1256
			_with_1.order = order -- 1257
			_with_1.faceRight = faceRight -- 1258
			_with_1:addTo(world) -- 1259
			unit = _with_1 -- 1255
		end -- 1255
		if charSet then -- 1260
			updateModel(unit.playable, characters[charSet]) -- 1260
		end -- 1260
		if player then -- 1261
			world.camera.followTarget = unit -- 1262
		end -- 1261
		return false -- 1235
	end) -- 1235
end -- 1234
local _with_0 = Observer("Change", { -- 1264
	"hp", -- 1264
	"unit" -- 1264
}) -- 1264
_with_0:watch(function(self, hp, unit) -- 1265
	local boss = self.boss -- 1266
	local lastHp = self.oldValues.hp -- 1267
	if hp < lastHp then -- 1268
		if not boss and unit:isDoing("hit") then -- 1269
			unit:start("cancel") -- 1269
		end -- 1269
		if boss then -- 1270
			local _with_1 = Visual("Particle/bloodp.par") -- 1271
			_with_1.position = unit.data.hitPoint -- 1272
			_with_1:addTo(world, unit.order) -- 1273
			_with_1:autoRemove() -- 1274
			_with_1:start() -- 1275
		end -- 1270
		if hp > 0 then -- 1276
			unit:start("hit") -- 1277
		else -- 1279
			unit:start("hit") -- 1279
			unit:start("fall") -- 1280
			unit.group = Data.groupHide -- 1281
			if self.player then -- 1282
				playerGroup:each(function(p) -- 1283
					if p and p.unit and p.hp > 0 then -- 1284
						world.camera.followTarget = p.unit -- 1285
						return true -- 1286
					else -- 1287
						return false -- 1287
					end -- 1284
				end) -- 1283
			end -- 1282
		end -- 1276
	end -- 1268
	return false -- 1265
end) -- 1265
return _with_0 -- 1264
