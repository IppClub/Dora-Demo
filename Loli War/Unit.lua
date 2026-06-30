-- [yue]: Unit.yue
local _ENV = Dora(Dora.Platformer) -- 9
local Data <const> = Data -- 10
local Dictionary <const> = Dictionary -- 10
local Vec2 <const> = Vec2 -- 10
local Size <const> = Size -- 10
local TargetAllow <const> = TargetAllow -- 10
local Array <const> = Array -- 10
local BodyDef <const> = BodyDef -- 10
local Store = Data.store -- 12
do -- 14
	local _with_0 = Dictionary() -- 14
	_with_0.linearAcceleration = Vec2(0, -10) -- 15
	_with_0.bodyType = "Dynamic" -- 16
	_with_0.scale = 2 -- 17
	_with_0.density = 1.0 -- 18
	_with_0.friction = 0.6 -- 19
	_with_0.restitution = 0.0 -- 20
	_with_0.playable = "model:Model/flandre" -- 21
	_with_0.size = Size(84, 186) -- 22
	_with_0.tag = "Hero" -- 23
	_with_0.sensity = 0 -- 24
	_with_0.move = 200 -- 25
	_with_0.jump = 780 -- 26
	_with_0.detectDistance = 300 -- 27
	_with_0.hp = 8.0 -- 28
	_with_0.attackBase = 1.0 -- 29
	_with_0.attackSpeed = 1.0 -- 30
	_with_0.attackDelay = 20.0 * 1.0 / 30.0 -- 31
	_with_0.attackEffectDelay = 0.0 -- 32
	_with_0.attackRange = Size(260 + 84 / 2, 200) -- 33
	_with_0.attackPower = Vec2(400, 400) -- 34
	_with_0.attackBonus = 0 -- 35
	_with_0.attackFactor = 1.0 -- 36
	_with_0.attackTarget = "Multi" -- 37
	do -- 38
		local conf -- 39
		do -- 39
			local _with_1 = TargetAllow() -- 39
			_with_1.terrainAllowed = false -- 40
			_with_1:allow("Enemy", true) -- 41
			conf = _with_1 -- 39
		end -- 39
		_with_0.targetAllow = conf:toValue() -- 42
	end -- 38
	_with_0.damageType = 0 -- 43
	_with_0.defenceType = 0 -- 44
	_with_0.bulletType = "" -- 45
	_with_0.attackEffect = "" -- 46
	_with_0.hitEffect = "Particle/blood.par" -- 47
	_with_0.sndAttack = "Audio/f_att.wav" -- 48
	_with_0.sndFallen = "" -- 49
	_with_0.decisionTree = "" -- 50
	_with_0.usePreciseHit = true -- 51
	_with_0.actions = Array({ -- 53
		"walk", -- 53
		"turn", -- 54
		"meleeAttack", -- 55
		"idle", -- 56
		"cancel", -- 57
		"jump", -- 58
		"hit", -- 59
		"fall", -- 60
		"fallOff", -- 61
		"pushSwitch", -- 62
		"strike", -- 63
		"wait" -- 64
	}) -- 52
	Store["Flandre"] = _with_0 -- 14
end -- 14
do -- 67
	local _with_0 = Dictionary() -- 67
	_with_0.linearAcceleration = Vec2(0, -10) -- 68
	_with_0.bodyType = "Dynamic" -- 69
	_with_0.scale = 2 -- 70
	_with_0.density = 1.0 -- 71
	_with_0.friction = 0.4 -- 72
	_with_0.restitution = 0.0 -- 73
	_with_0.playable = "model:Model/dorothy" -- 74
	_with_0.size = Size(84, 170) -- 75
	_with_0.tag = "Hero" -- 76
	_with_0.sensity = 0 -- 77
	_with_0.move = 150 -- 78
	_with_0.jump = 600 -- 79
	_with_0.detectDistance = 300 -- 80
	_with_0.hp = 8.0 -- 81
	_with_0.attackBase = 2.0 -- 82
	_with_0.attackSpeed = 1.0 -- 83
	_with_0.attackDelay = 18.0 * 1.0 / 30.0 -- 84
	_with_0.attackEffectDelay = 0.0 -- 85
	_with_0.attackRange = Size(500 + 84 / 2, 100) -- 86
	_with_0.attackPower = Vec2(300, 300) -- 87
	_with_0.attackBonus = 0 -- 88
	_with_0.attackFactor = 1.0 -- 89
	_with_0.attackTarget = "Single" -- 90
	do -- 91
		local conf -- 92
		do -- 92
			local _with_1 = TargetAllow() -- 92
			_with_1.terrainAllowed = true -- 93
			_with_1:allow("Enemy", true) -- 94
			conf = _with_1 -- 92
		end -- 92
		_with_0.targetAllow = conf:toValue() -- 95
	end -- 91
	_with_0.damageType = 0 -- 96
	_with_0.defenceType = 0 -- 97
	_with_0.bulletType = "Arrow" -- 98
	_with_0.attackEffect = "" -- 99
	_with_0.hitEffect = "Particle/blood.par" -- 100
	_with_0.sndAttack = "Audio/d_att.wav" -- 101
	_with_0.sndFallen = "" -- 102
	_with_0.decisionTree = "HeroAI" -- 103
	_with_0.usePreciseHit = true -- 104
	_with_0.actions = Array({ -- 106
		"walk", -- 106
		"turn", -- 107
		"rangeAttack", -- 108
		"idle", -- 109
		"cancel", -- 110
		"jump", -- 111
		"hit", -- 112
		"fall", -- 113
		"fallOff", -- 114
		"pushSwitch", -- 115
		"strike", -- 116
		"wait" -- 117
	}) -- 105
	Store["Dorothy"] = _with_0 -- 67
end -- 67
do -- 120
	local _with_0 = Dictionary() -- 120
	_with_0.linearAcceleration = Vec2(0, -10) -- 121
	_with_0.bodyType = "Dynamic" -- 122
	_with_0.scale = 2 -- 123
	_with_0.density = 1.0 -- 124
	_with_0.friction = 0.4 -- 125
	_with_0.restitution = 0.0 -- 126
	_with_0.playable = "model:Model/villy" -- 127
	_with_0.size = Size(84, 186) -- 128
	_with_0.tag = "Hero" -- 129
	_with_0.sensity = 0 -- 130
	_with_0.move = 240 -- 131
	_with_0.jump = 600 -- 132
	_with_0.detectDistance = 300 -- 133
	_with_0.hp = 8.0 -- 134
	_with_0.attackBase = 1.0 -- 135
	_with_0.attackSpeed = 1.0 -- 136
	_with_0.attackDelay = 0.0 -- 137
	_with_0.attackEffectDelay = 0.0 -- 138
	_with_0.attackRange = Size(300 + 84 / 2, 100) -- 139
	_with_0.attackPower = Vec2(200, 300) -- 140
	_with_0.attackBonus = 0 -- 141
	_with_0.attackFactor = 1.0 -- 142
	_with_0.attackTarget = "Single" -- 143
	do -- 144
		local conf -- 145
		do -- 145
			local _with_1 = TargetAllow() -- 145
			_with_1.terrainAllowed = true -- 146
			_with_1:allow("Enemy", true) -- 147
			conf = _with_1 -- 145
		end -- 145
		_with_0.targetAllow = conf:toValue() -- 148
	end -- 144
	_with_0.damageType = 0 -- 149
	_with_0.defenceType = 0 -- 150
	_with_0.bulletType = "Bubble" -- 151
	_with_0.attackEffect = "" -- 152
	_with_0.hitEffect = "Particle/blood.par" -- 153
	_with_0.sndAttack = "Audio/v_att.wav" -- 154
	_with_0.sndFallen = "" -- 155
	_with_0.decisionTree = "" -- 156
	_with_0.usePreciseHit = true -- 157
	_with_0.actions = Array({ -- 159
		"walk", -- 159
		"turn", -- 160
		"villyAttack", -- 161
		"idle", -- 162
		"cancel", -- 163
		"jump", -- 164
		"hit", -- 165
		"fall", -- 166
		"fallOff", -- 167
		"pushSwitch", -- 168
		"strike", -- 169
		"wait" -- 170
	}) -- 158
	Store["Villy"] = _with_0 -- 120
end -- 120
do -- 173
	local _with_0 = Dictionary() -- 173
	_with_0.linearAcceleration = Vec2(0, -10) -- 174
	_with_0.bodyType = "Dynamic" -- 175
	_with_0.scale = 2 -- 176
	_with_0.density = 1.0 -- 177
	_with_0.friction = 0.4 -- 178
	_with_0.restitution = 0.0 -- 179
	_with_0.playable = "model:Model/bunnyp" -- 180
	_with_0.size = Size(132, 128) -- 181
	_with_0.tag = "Bunny" -- 182
	_with_0.sensity = 0 -- 183
	_with_0.move = 150 -- 184
	_with_0.jump = 600 -- 185
	_with_0.detectDistance = 0 -- 186
	_with_0.hp = 3.0 -- 187
	_with_0.attackBase = 1.0 -- 188
	_with_0.attackSpeed = 1.0 -- 189
	_with_0.attackDelay = 20.0 * 1.0 / 60.0 -- 190
	_with_0.attackEffectDelay = 0.0 -- 191
	_with_0.attackRange = Size(60 + 132 / 2, 80) -- 192
	_with_0.attackPower = Vec2(400, 400) -- 193
	_with_0.attackBonus = 0 -- 194
	_with_0.attackFactor = 1.0 -- 195
	_with_0.attackTarget = "Single" -- 196
	do -- 197
		local conf -- 198
		do -- 198
			local _with_1 = TargetAllow() -- 198
			_with_1.terrainAllowed = false -- 199
			_with_1:allow("Enemy", true) -- 200
			conf = _with_1 -- 198
		end -- 198
		_with_0.targetAllow = conf:toValue() -- 201
	end -- 197
	_with_0.damageType = 0 -- 202
	_with_0.defenceType = 0 -- 203
	_with_0.bulletType = "" -- 204
	_with_0.attackEffect = "" -- 205
	_with_0.hitEffect = "Particle/blood.par" -- 206
	_with_0.sndAttack = "Audio/b_att.wav" -- 207
	_with_0.sndFallen = "" -- 208
	_with_0.decisionTree = "" -- 209
	_with_0.usePreciseHit = true -- 210
	_with_0.actions = Array({ -- 212
		"walk", -- 212
		"turn", -- 213
		"meleeAttack", -- 214
		"idle", -- 215
		"cancel", -- 216
		"jump", -- 217
		"hit", -- 218
		"fall", -- 219
		"fallOff", -- 220
		"pushSwitch", -- 221
		"strike", -- 222
		"wait" -- 223
	}) -- 211
	Store["BunnyP"] = _with_0 -- 173
end -- 173
do -- 226
	local _with_0 = Dictionary() -- 226
	_with_0.linearAcceleration = Vec2(0, -10) -- 227
	_with_0.bodyType = "Dynamic" -- 228
	_with_0.scale = 2 -- 229
	_with_0.density = 1.0 -- 230
	_with_0.friction = 0.4 -- 231
	_with_0.restitution = 0.0 -- 232
	_with_0.playable = "model:Model/bunnyg" -- 233
	_with_0.size = Size(132, 128) -- 234
	_with_0.tag = "Bunny" -- 235
	_with_0.sensity = 0 -- 236
	_with_0.move = 150 -- 237
	_with_0.jump = 600 -- 238
	_with_0.detectDistance = 0 -- 239
	_with_0.hp = 3.0 -- 240
	_with_0.attackBase = 1.0 -- 241
	_with_0.attackSpeed = 1.0 -- 242
	_with_0.attackDelay = 20.0 * 1.0 / 60.0 -- 243
	_with_0.attackEffectDelay = 0.0 -- 244
	_with_0.attackRange = Size(60 + 132 / 2, 80) -- 245
	_with_0.attackPower = Vec2(400, 400) -- 246
	_with_0.attackBonus = 0 -- 247
	_with_0.attackFactor = 1.0 -- 248
	_with_0.attackTarget = "Single" -- 249
	do -- 250
		local conf -- 251
		do -- 251
			local _with_1 = TargetAllow() -- 251
			_with_1.terrainAllowed = false -- 252
			_with_1:allow("Enemy", true) -- 253
			conf = _with_1 -- 251
		end -- 251
		_with_0.targetAllow = conf:toValue() -- 254
	end -- 250
	_with_0.damageType = 0 -- 255
	_with_0.defenceType = 0 -- 256
	_with_0.bulletType = "" -- 257
	_with_0.attackEffect = "" -- 258
	_with_0.hitEffect = "Particle/blood.par" -- 259
	_with_0.sndAttack = "Audio/b_att.wav" -- 260
	_with_0.sndFallen = "" -- 261
	_with_0.decisionTree = "" -- 262
	_with_0.usePreciseHit = true -- 263
	_with_0.actions = Array({ -- 265
		"walk", -- 265
		"turn", -- 266
		"meleeAttack", -- 267
		"idle", -- 268
		"cancel", -- 269
		"jump", -- 270
		"hit", -- 271
		"fall", -- 272
		"fallOff", -- 273
		"pushSwitch", -- 274
		"strike", -- 275
		"wait" -- 276
	}) -- 264
	Store["BunnyG"] = _with_0 -- 226
end -- 226
do -- 279
	local _with_0 = Dictionary() -- 279
	_with_0.scale = 2 -- 280
	_with_0.playable = "model:Model/block1" -- 281
	do -- 282
		local _with_1 = BodyDef() -- 282
		_with_1.linearAcceleration = Vec2(0, -10) -- 283
		_with_1.type = "Dynamic" -- 284
		_with_1:attachPolygon(90, 90, 1.0, 0.4, 0.0) -- 285
		_with_0.bodyDef = _with_1 -- 282
	end -- 282
	_with_0.tag = "Block" -- 286
	_with_0.hp = 2.0 -- 287
	_with_0.hitEffect = "Particle/heart.par" -- 288
	_with_0.actions = Array({ -- 289
		"hit" -- 289
	}) -- 289
	Store["BlockA"] = _with_0 -- 279
end -- 279
do -- 291
	local _with_0 = Dictionary() -- 291
	_with_0.scale = 2 -- 292
	_with_0.playable = "model:Model/block2" -- 293
	do -- 294
		local _with_1 = BodyDef() -- 294
		_with_1.linearAcceleration = Vec2(0, -10) -- 295
		_with_1.type = "Dynamic" -- 296
		_with_1:attachPolygon(90, 210, 0.5, 0.4, 0.0) -- 297
		_with_0.bodyDef = _with_1 -- 294
	end -- 294
	_with_0.tag = "Block" -- 298
	_with_0.hp = 3.0 -- 299
	_with_0.hitEffect = "Particle/heart.par" -- 300
	_with_0.actions = Array({ -- 301
		"hit" -- 301
	}) -- 301
	Store["BlockB"] = _with_0 -- 291
end -- 291
do -- 303
	local _with_0 = Dictionary() -- 303
	_with_0.scale = 2 -- 304
	_with_0.playable = "model:Model/block3" -- 305
	do -- 306
		local _with_1 = BodyDef() -- 306
		_with_1.linearAcceleration = Vec2(0, -10) -- 307
		_with_1.type = "Dynamic" -- 308
		_with_1:attachPolygon(450, 90, 0.5, 0.4, 0.0) -- 309
		_with_0.bodyDef = _with_1 -- 306
	end -- 306
	_with_0.tag = "Block" -- 310
	_with_0.hp = 4.0 -- 311
	_with_0.hitEffect = "Particle/heart.par" -- 312
	_with_0.actions = Array({ -- 313
		"hit" -- 313
	}) -- 313
	Store["BlockC"] = _with_0 -- 303
end -- 303
do -- 315
	local _with_0 = Dictionary() -- 315
	_with_0.bodyType = "Static" -- 316
	_with_0.playable = "model:Model/switch" -- 317
	_with_0.attackRange = Size(80, 126) -- 318
	_with_0.tag = "Switch" -- 319
	_with_0.decisionTree = "SwitchAI" -- 320
	_with_0.actions = Array({ -- 321
		"waitUser", -- 321
		"pushed" -- 321
	}) -- 321
	Store["Switch"] = _with_0 -- 315
end -- 315
local _with_0 = Dictionary() -- 323
_with_0.bodyType = "Static" -- 324
_with_0.playable = "model:Model/switch" -- 325
_with_0.attackRange = Size(80, 126) -- 326
_with_0.tag = "Switch" -- 327
_with_0.decisionTree = "SwitchAI" -- 328
_with_0.actions = Array({ -- 329
	"waitUser", -- 329
	"pushed" -- 329
}) -- 329
Store["SwitchG"] = _with_0 -- 323
