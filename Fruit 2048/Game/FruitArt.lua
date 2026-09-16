-- [ts]: FruitArt.ts
local ____exports = {} -- 1
local ____FreshArt = require("Game.FreshArt") -- 1
local freshFruit = ____FreshArt.drawFruit -- 1
local ____Dora = require("Dora") -- 7
local Color = ____Dora.Color -- 7
local Vec2 = ____Dora.Vec2 -- 7
--- 装饰类型：叶子。
____exports.DECOR_LEAF = 0 -- 10
--- 装饰类型：梗。
____exports.DECOR_STEM = 1 -- 12
--- 装饰类型：圈纹。
____exports.DECOR_RING = 2 -- 14
--- 装饰类型：交叉纹（菠萝）。
____exports.DECOR_CROSS = 3 -- 16
--- 装饰类型：条纹（蜜瓜/西瓜）。
____exports.DECOR_STRIPE = 4 -- 18
--- 装饰类型：尖刺（榴莲）。
____exports.DECOR_SPIKE = 5 -- 20
--- 大榴莲所在层级。
____exports.DURIAN_TIER = 10 -- 34
--- 11 级水果外观表（tier 0 → 2 … tier 10 → 2048）。
____exports.FRUITS = { -- 37
	{ -- 38
		tier = 0, -- 38
		value = 2, -- 38
		name = "樱桃", -- 38
		body = Color(198, 42, 52, 255), -- 38
		edge = Color(132, 22, 32, 255), -- 38
		text = Color(255, 246, 242, 255), -- 38
		decor = ____exports.DECOR_LEAF -- 38
	}, -- 38
	{ -- 39
		tier = 1, -- 39
		value = 4, -- 39
		name = "草莓", -- 39
		body = Color(226, 72, 74, 255), -- 39
		edge = Color(154, 38, 44, 255), -- 39
		text = Color(255, 246, 242, 255), -- 39
		decor = ____exports.DECOR_LEAF -- 39
	}, -- 39
	{ -- 40
		tier = 2, -- 40
		value = 8, -- 40
		name = "葡萄", -- 40
		body = Color(126, 82, 200, 255), -- 40
		edge = Color(84, 48, 148, 255), -- 40
		text = Color(248, 244, 255, 255), -- 40
		decor = ____exports.DECOR_STEM -- 40
	}, -- 40
	{ -- 41
		tier = 3, -- 41
		value = 16, -- 41
		name = "柠檬", -- 41
		body = Color(236, 205, 58, 255), -- 41
		edge = Color(166, 138, 20, 255), -- 41
		text = Color(58, 46, 12, 255), -- 41
		decor = ____exports.DECOR_RING -- 41
	}, -- 41
	{ -- 42
		tier = 4, -- 42
		value = 32, -- 42
		name = "橙子", -- 42
		body = Color(240, 146, 58, 255), -- 42
		edge = Color(178, 98, 24, 255), -- 42
		text = Color(72, 40, 10, 255), -- 42
		decor = ____exports.DECOR_STEM -- 42
	}, -- 42
	{ -- 43
		tier = 5, -- 43
		value = 64, -- 43
		name = "苹果", -- 43
		body = Color(214, 62, 72, 255), -- 43
		edge = Color(146, 30, 42, 255), -- 43
		text = Color(255, 246, 242, 255), -- 43
		decor = ____exports.DECOR_LEAF -- 43
	}, -- 43
	{ -- 44
		tier = 6, -- 44
		value = 128, -- 44
		name = "桃子", -- 44
		body = Color(246, 158, 140, 255), -- 44
		edge = Color(190, 104, 92, 255), -- 44
		text = Color(92, 42, 38, 255), -- 44
		decor = ____exports.DECOR_LEAF -- 44
	}, -- 44
	{ -- 45
		tier = 7, -- 45
		value = 256, -- 45
		name = "菠萝", -- 45
		body = Color(232, 192, 60, 255), -- 45
		edge = Color(162, 126, 20, 255), -- 45
		text = Color(64, 48, 12, 255), -- 45
		decor = ____exports.DECOR_CROSS -- 45
	}, -- 45
	{ -- 46
		tier = 8, -- 46
		value = 512, -- 46
		name = "蜜瓜", -- 46
		body = Color(168, 201, 74, 255), -- 46
		edge = Color(114, 146, 38, 255), -- 46
		text = Color(44, 60, 16, 255), -- 46
		decor = ____exports.DECOR_STRIPE -- 46
	}, -- 46
	{ -- 47
		tier = 9, -- 47
		value = 1024, -- 47
		name = "西瓜", -- 47
		body = Color(60, 160, 92, 255), -- 47
		edge = Color(30, 106, 58, 255), -- 47
		text = Color(255, 246, 242, 255), -- 47
		decor = ____exports.DECOR_STRIPE -- 47
	}, -- 47
	{ -- 48
		tier = 10, -- 48
		value = 2048, -- 48
		name = "榴莲", -- 48
		body = Color(201, 162, 39, 255), -- 48
		edge = Color(130, 100, 14, 255), -- 48
		text = Color(52, 40, 8, 255), -- 48
		decor = ____exports.DECOR_SPIKE -- 48
	} -- 48
} -- 48
--- 取某层级的水果定义，越界时收敛到首尾项。
function ____exports.fruitOfTier(tier) -- 52
	local index = tier -- 53
	if index < 0 then -- 53
		index = 0 -- 55
	end -- 55
	if index > #____exports.FRUITS - 1 then -- 55
		index = #____exports.FRUITS - 1 -- 58
	end -- 58
	return ____exports.FRUITS[index + 1] -- 60
end -- 52
--- 由数值反查层级，未知数值返回 -1。
function ____exports.tierOfValue(value) -- 64
	do -- 64
		local i = 0 -- 65
		while i < #____exports.FRUITS do -- 65
			if ____exports.FRUITS[i + 1].value == value then -- 65
				return i -- 67
			end -- 67
			i = i + 1 -- 65
		end -- 65
	end -- 65
	return -1 -- 70
end -- 64
--- 水果中文名（未知数值返回数值文本）。
function ____exports.fruitName(value) -- 74
	local tier = ____exports.tierOfValue(value) -- 75
	if tier < 0 then -- 75
		return "" .. tostring(value) -- 77
	end -- 77
	return ____exports.FRUITS[tier + 1].name -- 79
end -- 74
--- 绘制圆环（用折线近似）。
local function drawRing(node, center, radius, thickness, color, segments) -- 83
	local prevX = center.x + radius -- 84
	local prevY = center.y -- 85
	do -- 85
		local i = 1 -- 86
		while i <= segments do -- 86
			local angle = i / segments * math.pi * 2 -- 87
			local x = center.x + math.cos(angle) * radius -- 88
			local y = center.y + math.sin(angle) * radius -- 89
			node:drawSegment( -- 90
				Vec2(prevX, prevY), -- 90
				Vec2(x, y), -- 90
				thickness, -- 90
				color -- 90
			) -- 90
			prevX = x -- 91
			prevY = y -- 92
			i = i + 1 -- 86
		end -- 86
	end -- 86
end -- 83
--- 绘制叶子：朝右上的一片小叶子。
local function drawLeaf(node, radius) -- 97
	local leaf = Color(86, 168, 78, 255) -- 98
	local stem = Color(70, 112, 46, 255) -- 99
	local baseX = radius * 0.18 -- 100
	local baseY = radius * 0.92 -- 101
	node:drawSegment( -- 102
		Vec2(0, radius * 0.86), -- 102
		Vec2(baseX, baseY), -- 102
		radius * 0.08, -- 102
		stem -- 102
	) -- 102
	node:drawPolygon( -- 103
		{ -- 103
			Vec2(baseX, baseY), -- 104
			Vec2(radius * 0.66, radius * 1.06), -- 105
			Vec2(radius * 1.02, radius * 0.82), -- 106
			Vec2(radius * 0.52, radius * 0.74) -- 107
		}, -- 107
		leaf -- 108
	) -- 108
end -- 97
--- 绘制梗：果实顶部一小段短梗。
local function drawStem(node, radius) -- 112
	local stem = Color(96, 72, 40, 255) -- 113
	node:drawSegment( -- 114
		Vec2(0, radius * 0.9), -- 114
		Vec2(radius * 0.08, radius * 1.28), -- 114
		radius * 0.11, -- 114
		stem -- 114
	) -- 114
	node:drawDot( -- 115
		Vec2(radius * 0.08, radius * 1.28), -- 115
		radius * 0.1, -- 115
		Color(126, 96, 54, 255) -- 115
	) -- 115
end -- 112
--- 绘制菠萝交叉纹。
local function drawCross(node, radius, color) -- 119
	do -- 119
		local i = 0 -- 120
		while i < 3 do -- 120
			local offset = (i - 1) * radius * 0.42 -- 121
			node:drawSegment( -- 122
				Vec2(offset - radius * 0.42, radius * 0.42), -- 122
				Vec2(offset + radius * 0.42, -radius * 0.42), -- 122
				radius * 0.05, -- 122
				color -- 122
			) -- 122
			node:drawSegment( -- 123
				Vec2(offset - radius * 0.42, -radius * 0.42), -- 123
				Vec2(offset + radius * 0.42, radius * 0.42), -- 123
				radius * 0.05, -- 123
				color -- 123
			) -- 123
			i = i + 1 -- 120
		end -- 120
	end -- 120
end -- 119
--- 绘制蜜瓜/西瓜条纹。
local function drawStripe(node, radius, color) -- 128
	do -- 128
		local i = -2 -- 129
		while i <= 2 do -- 129
			local x = i * radius * 0.34 -- 130
			node:drawSegment( -- 131
				Vec2(x, -radius * 0.78), -- 131
				Vec2(x * 0.5, radius * 0.78), -- 131
				radius * 0.06, -- 131
				color -- 131
			) -- 131
			i = i + 1 -- 129
		end -- 129
	end -- 129
end -- 128
--- 绘制榴莲尖刺：沿外圈放射的短刺。
local function drawSpike(node, radius, color) -- 136
	local count = 14 -- 137
	do -- 137
		local i = 0 -- 138
		while i < count do -- 138
			local angle = i / count * math.pi * 2 -- 139
			local cos = math.cos(angle) -- 140
			local sin = math.sin(angle) -- 141
			local innerX = cos * radius * 0.86 -- 142
			local innerY = sin * radius * 0.86 -- 143
			local outerX = cos * radius * 1.18 -- 144
			local outerY = sin * radius * 1.18 -- 145
			node:drawSegment( -- 146
				Vec2(innerX, innerY), -- 146
				Vec2(outerX, outerY), -- 146
				radius * 0.09, -- 146
				color -- 146
			) -- 146
			i = i + 1 -- 138
		end -- 138
	end -- 138
end -- 136
--- 在指定 DrawNode 上绘制对应层级的水果（以节点局部原点为果实中心）。
function ____exports.drawFruit(node, tier, radius) -- 151
	freshFruit(node, tier, radius) -- 151
end -- 151
return ____exports -- 151