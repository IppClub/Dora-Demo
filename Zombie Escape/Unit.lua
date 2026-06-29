-- [yue]: Dora-Demo/Zombie Escape/Unit.yue
local _ENV = Dora(Dora.Platformer) -- 9
local Data <const> = Data -- 10
local Dictionary <const> = Dictionary -- 10
local Vec2 <const> = Vec2 -- 10
local Size <const> = Size -- 10
local TargetAllow <const> = TargetAllow -- 10
local Array <const> = Array -- 10
local Store = Data.store -- 12
do -- 14
	local _with_0 = Dictionary() -- 14
	_with_0.linearAcceleration = Vec2(0, -10) -- 15
	_with_0.bodyType = "Dynamic" -- 16
	_with_0.scale = 5 -- 17
	_with_0.density = 1.0 -- 18
	_with_0.friction = 1.0 -- 19
	_with_0.restitution = 0.0 -- 20
	_with_0.playable = "model:Model/KidW" -- 21
	_with_0.size = Size(30, 110) -- 22
	_with_0.tag = "KidW" -- 23
	_with_0.sensity = 0.1 -- 24
	_with_0.move = 250 -- 25
	_with_0.moveSpeed = 1.0 -- 26
	_with_0.jump = 500 -- 27
	_with_0.detectDistance = 350 -- 28
	_with_0.hp = 5.0 -- 29
	_with_0.attackBase = 2.5 -- 30
	_with_0.attackDelay = 0.1 -- 31
	_with_0.attackEffectDelay = 0.1 -- 32
	_with_0.attackRange = Size(350, 150) -- 33
	_with_0.attackPower = Vec2(100, 100) -- 34
	_with_0.attackTarget = "Single" -- 35
	do -- 36
		local conf -- 37
		do -- 37
			local _with_1 = TargetAllow() -- 37
			_with_1.terrainAllowed = true -- 38
			_with_1:allow("Enemy", true) -- 39
			conf = _with_1 -- 37
		end -- 37
		_with_0.targetAllow = conf:toValue() -- 40
	end -- 36
	_with_0.damageType = 0 -- 41
	_with_0.defenceType = 0 -- 42
	_with_0.bulletType = "Bullet_KidW" -- 43
	_with_0.attackEffect = "" -- 44
	_with_0.hitEffect = "" -- 45
	_with_0.sndAttack = "" -- 46
	_with_0.sndFallen = "" -- 47
	_with_0.decisionTree = "AI_KidSearch" -- 48
	_with_0.usePreciseHit = false -- 49
	_with_0.actions = Array({ -- 51
		"walk", -- 51
		"turn", -- 52
		"rangeAttack", -- 53
		"idle", -- 54
		"cancel", -- 55
		"jump", -- 56
		"hit", -- 57
		"fall", -- 58
		"fallOff" -- 59
	}) -- 50
	Store["Unit_KidW"] = _with_0 -- 14
end -- 14
do -- 61
	local _with_0 = Dictionary() -- 61
	_with_0.linearAcceleration = Vec2(0, -10) -- 62
	_with_0.bodyType = "Dynamic" -- 63
	_with_0.scale = 5 -- 64
	_with_0.density = 1.0 -- 65
	_with_0.friction = 1.0 -- 66
	_with_0.restitution = 0.0 -- 67
	_with_0.playable = "model:Model/KidM" -- 68
	_with_0.size = Size(30, 110) -- 69
	_with_0.tag = "KidM" -- 70
	_with_0.sensity = 0.1 -- 71
	_with_0.move = 250 -- 72
	_with_0.moveSpeed = 1.0 -- 73
	_with_0.jump = 500 -- 74
	_with_0.detectDistance = 500 -- 75
	_with_0.hp = 5.0 -- 76
	_with_0.attackBase = 1.0 -- 77
	_with_0.attackDelay = 0.1 -- 78
	_with_0.attackEffectDelay = 0.1 -- 79
	_with_0.attackRange = Size(400, 100) -- 80
	_with_0.attackPower = Vec2(100, 0) -- 81
	_with_0.attackTarget = "Single" -- 82
	do -- 83
		local conf -- 84
		do -- 84
			local _with_1 = TargetAllow() -- 84
			_with_1.terrainAllowed = true -- 85
			_with_1:allow("Enemy", true) -- 86
			conf = _with_1 -- 84
		end -- 84
		_with_0.targetAllow = conf:toValue() -- 87
	end -- 83
	_with_0.damageType = 0 -- 88
	_with_0.defenceType = 0 -- 89
	_with_0.bulletType = "Bullet_KidM" -- 90
	_with_0.attackEffect = "" -- 91
	_with_0.hitEffect = "" -- 92
	_with_0.sndAttack = "" -- 93
	_with_0.sndFallen = "" -- 94
	_with_0.decisionTree = "AI_KidFollow" -- 95
	_with_0.usePreciseHit = false -- 96
	_with_0.actions = Array({ -- 98
		"walk", -- 98
		"turn", -- 99
		"rangeAttack", -- 100
		"idle", -- 101
		"cancel", -- 102
		"jump", -- 103
		"hit", -- 104
		"fall", -- 105
		"fallOff" -- 106
	}) -- 97
	Store["Unit_KidM"] = _with_0 -- 61
end -- 61
do -- 108
	local _with_0 = Dictionary() -- 108
	_with_0.linearAcceleration = Vec2(0, -10) -- 109
	_with_0.bodyType = "Dynamic" -- 110
	_with_0.scale = 5 -- 111
	_with_0.density = 1.0 -- 112
	_with_0.friction = 1.0 -- 113
	_with_0.restitution = 0.0 -- 114
	_with_0.playable = "model:Model/Zombie1" -- 115
	_with_0.size = Size(40, 110) -- 116
	_with_0.tag = "Zombie1" -- 117
	_with_0.sensity = 0.2 -- 118
	_with_0.move = 120 -- 119
	_with_0.moveSpeed = 1.0 -- 120
	_with_0.jump = 600 -- 121
	_with_0.detectDistance = 600 -- 122
	_with_0.hp = 5.0 -- 123
	_with_0.attackBase = 1 -- 124
	_with_0.attackDelay = 0.25 -- 125
	_with_0.attackEffectDelay = 0.1 -- 126
	_with_0.attackRange = Size(80, 50) -- 127
	_with_0.attackPower = Vec2(150, 100) -- 128
	_with_0.attackTarget = "Single" -- 129
	do -- 130
		local conf -- 131
		do -- 131
			local _with_1 = TargetAllow() -- 131
			_with_1.terrainAllowed = true -- 132
			_with_1:allow("Enemy", true) -- 133
			conf = _with_1 -- 131
		end -- 131
		_with_0.targetAllow = conf:toValue() -- 134
	end -- 130
	_with_0.damageType = 0 -- 135
	_with_0.defenceType = 0 -- 136
	_with_0.bulletType = "" -- 137
	_with_0.attackEffect = "" -- 138
	_with_0.hitEffect = "" -- 139
	_with_0.sndAttack = "" -- 140
	_with_0.sndFallen = "" -- 141
	_with_0.decisionTree = "AI_Zombie" -- 142
	_with_0.usePreciseHit = false -- 143
	_with_0.actions = Array({ -- 145
		"walk", -- 145
		"turn", -- 146
		"meleeAttack", -- 147
		"idle", -- 148
		"cancel", -- 149
		"jump", -- 150
		"hit", -- 151
		"fall", -- 152
		"groundEntrance", -- 153
		"fallOff" -- 154
	}) -- 144
	Store["Unit_Zombie1"] = _with_0 -- 108
end -- 108
local _with_0 = Dictionary() -- 156
_with_0.linearAcceleration = Vec2(0, -10) -- 157
_with_0.bodyType = "Dynamic" -- 158
_with_0.scale = 5 -- 159
_with_0.density = 1.0 -- 160
_with_0.friction = 1.0 -- 161
_with_0.restitution = 0.0 -- 162
_with_0.playable = "model:Model/Zombie2" -- 163
_with_0.size = Size(40, 110) -- 164
_with_0.tag = "Zombie2" -- 165
_with_0.sensity = 0.2 -- 166
_with_0.move = 60 -- 167
_with_0.moveSpeed = 1.0 -- 168
_with_0.jump = 500 -- 169
_with_0.detectDistance = 600 -- 170
_with_0.hp = 5.0 -- 171
_with_0.attackBase = 1 -- 172
_with_0.attackDelay = 0.4 -- 173
_with_0.attackEffectDelay = 0.1 -- 174
_with_0.attackRange = Size(150, 80) -- 175
_with_0.attackPower = Vec2(150, 100) -- 176
_with_0.attackTarget = "Multi" -- 177
do -- 178
	local conf -- 179
	do -- 179
		local _with_1 = TargetAllow() -- 179
		_with_1.terrainAllowed = true -- 180
		_with_1:allow("Enemy", true) -- 181
		conf = _with_1 -- 179
	end -- 179
	_with_0.targetAllow = conf:toValue() -- 182
end -- 178
_with_0.damageType = 0 -- 183
_with_0.defenceType = 0 -- 184
_with_0.bulletType = "" -- 185
_with_0.attackEffect = "" -- 186
_with_0.hitEffect = "" -- 187
_with_0.sndAttack = "" -- 188
_with_0.sndFallen = "" -- 189
_with_0.decisionTree = "AI_Zombie" -- 190
_with_0.usePreciseHit = false -- 191
_with_0.actions = Array({ -- 193
	"walk", -- 193
	"turn", -- 194
	"meleeAttack", -- 195
	"idle", -- 196
	"cancel", -- 197
	"jump", -- 198
	"hit", -- 199
	"fall", -- 200
	"groundEntrance", -- 201
	"fallOff" -- 202
}) -- 192
Store["Unit_Zombie2"] = _with_0 -- 156
