-- [ts]: GameTests.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____FruitBoard = require("Game.FruitBoard") -- 6
local DIR_DOWN = ____FruitBoard.DIR_DOWN -- 7
local DIR_LEFT = ____FruitBoard.DIR_LEFT -- 8
local DIR_RIGHT = ____FruitBoard.DIR_RIGHT -- 9
local DIR_UP = ____FruitBoard.DIR_UP -- 10
local FruitBoard = ____FruitBoard.FruitBoard -- 11
local TILE_VALUES = ____FruitBoard.TILE_VALUES -- 12
--- 允许出现在棋盘上的数值（0 表示空）。
local function isAllowedValue(value) -- 16
	if value == 0 then -- 16
		return true -- 18
	end -- 18
	do -- 18
		local i = 0 -- 20
		while i < #TILE_VALUES do -- 20
			if TILE_VALUES[i + 1] == value then -- 20
				return true -- 22
			end -- 22
			i = i + 1 -- 20
		end -- 20
	end -- 20
	return false -- 25
end -- 16
function ____exports.runTests() -- 28
	local failures = {} -- 29
	local checks = 0 -- 30
	local function check(condition, message) -- 32
		checks = checks + 1 -- 33
		if not condition and #failures < 12 then -- 33
			failures[#failures + 1] = message -- 35
		end -- 35
	end -- 32
	local function board4(values) -- 39
		local board = __TS__New(FruitBoard, 4, 4, 12345) -- 40
		board:load(values) -- 41
		return board -- 42
	end -- 39
	local compact = board4({0, 0, 2, 0}) -- 46
	local compactResult = compact:move(DIR_LEFT) -- 47
	check( -- 48
		compact:get(0, 0) == 2, -- 48
		"T1 向左压缩后瓦片应在 (0,0)" -- 48
	) -- 48
	check(compactResult.gainedScore == 0, "T1 无合成时不应得分") -- 49
	check(compactResult.changed, "T1 瓦片发生位移时应判定为变化") -- 50
	check( -- 51
		compact:tileCount() == 2, -- 51
		"T1 有效移动后应生成 1 个新水果" -- 51
	) -- 51
	local merged = board4({2, 2, 0, 0}) -- 54
	local mergedResult = merged:move(DIR_LEFT) -- 55
	check( -- 56
		merged:get(0, 0) == 4, -- 56
		"T2 2+2 应合成为 4" -- 56
	) -- 56
	check(mergedResult.gainedScore == 4, "T2 合成 4 应得 4 分") -- 57
	local once = board4({2, 2, 4, 0}) -- 60
	once:move(DIR_LEFT) -- 61
	check( -- 62
		once:get(0, 0) == 4 and once:get(0, 1) == 4, -- 62
		"T3 [2,2,4] 向左应得到 [4,4]" -- 62
	) -- 62
	check( -- 63
		once:get(0, 2) == 0, -- 63
		"T3 不应产生第二级合成" -- 63
	) -- 63
	local quad = board4({2, 2, 2, 2}) -- 66
	local quadResult = quad:move(DIR_LEFT) -- 67
	check( -- 68
		quad:get(0, 0) == 4 and quad:get(0, 1) == 4, -- 68
		"T4 [2,2,2,2] 向左应得到 [4,4]" -- 68
	) -- 68
	check(quadResult.gainedScore == 8, "T4 应获得 8 分") -- 69
	check(#quadResult.mergedCells == 2, "T4 应记录 2 个合成格") -- 70
	local gap = board4({4, 2, 2, 0}) -- 73
	local gapResult = gap:move(DIR_LEFT) -- 74
	check( -- 75
		gap:get(0, 0) == 4 and gap:get(0, 1) == 4, -- 75
		"T5 [4,2,2] 向左应得到 [4,4]" -- 75
	) -- 75
	check(gapResult.gainedScore == 4, "T5 仅合成中间的两个 2") -- 76
	local stuck = __TS__New(FruitBoard, 4, 4, 11) -- 79
	stuck:set(0, 0, 2) -- 80
	local stuckResult = stuck:move(DIR_LEFT) -- 81
	check(not stuckResult.changed, "T6 已贴边的瓦片不应判定为变化") -- 82
	check(stuckResult.spawnedRow == -1, "T6 无变化时不应生成新水果") -- 83
	check( -- 84
		stuck:tileCount() == 1, -- 84
		"T6 无变化时格子数不应增加" -- 84
	) -- 84
	local function singleTile(dir, row, col) -- 87
		local board = __TS__New(FruitBoard, 4, 4, 2024) -- 88
		board:clearAll() -- 89
		board:set(row, col, 8) -- 90
		board:move(dir) -- 91
		return board -- 92
	end -- 87
	check( -- 94
		singleTile(DIR_UP, 1, 1):get(3, 1) == 8, -- 94
		"T7 向上应移动到顶行" -- 94
	) -- 94
	check( -- 95
		singleTile(DIR_DOWN, 1, 1):get(0, 1) == 8, -- 95
		"T7 向下应移动到底行" -- 95
	) -- 95
	check( -- 96
		singleTile(DIR_LEFT, 1, 1):get(1, 0) == 8, -- 96
		"T7 向左应移动到最左列" -- 96
	) -- 96
	check( -- 97
		singleTile(DIR_RIGHT, 1, 1):get(1, 3) == 8, -- 97
		"T7 向右应移动到最右列" -- 97
	) -- 97
	local spawnBoard = __TS__New(FruitBoard, 4, 4, 31) -- 100
	spawnBoard:set(0, 3, 4) -- 101
	local spawnResult = spawnBoard:move(DIR_LEFT) -- 102
	check( -- 103
		spawnBoard:get(0, 0) == 4, -- 103
		"T8 瓦片应移动到最左列" -- 103
	) -- 103
	check(spawnResult.spawnedRow >= 0 and spawnResult.spawnedCol >= 0, "T8 应生成新水果") -- 104
	check( -- 105
		spawnBoard:tileCount() == 2, -- 105
		"T8 有效移动后格子数应为 2" -- 105
	) -- 105
	local scored = board4({2, 2, 4, 4}) -- 108
	scored:move(DIR_LEFT) -- 109
	check( -- 110
		scored:get(0, 0) == 4 and scored:get(0, 1) == 8, -- 110
		"T9 应得到 [4,8]" -- 110
	) -- 110
	check(scored.score == 12, "T9 累计得分应为 12") -- 111
	local full = __TS__New(FruitBoard, 4, 4, 7) -- 114
	local checker = {} -- 115
	do -- 115
		local row = 0 -- 116
		while row < 4 do -- 116
			do -- 116
				local col = 0 -- 117
				while col < 4 do -- 117
					checker[#checker + 1] = (row + col) % 2 == 0 and 2 or 4 -- 118
					col = col + 1 -- 117
				end -- 117
			end -- 117
			row = row + 1 -- 116
		end -- 116
	end -- 116
	full:load(checker) -- 121
	check( -- 122
		full:emptyCount() == 0, -- 122
		"T10 棋盘应无空格" -- 122
	) -- 122
	check( -- 123
		full:isGameOver(), -- 123
		"T10 应判定无路可走" -- 123
	) -- 123
	check( -- 124
		not full:move(DIR_LEFT).changed, -- 124
		"T10 无路可走时移动不应产生变化" -- 124
	) -- 124
	local durian = board4({1024, 1024, 0, 0}) -- 127
	local durianResult = durian:move(DIR_LEFT) -- 128
	check( -- 129
		durian:get(0, 0) == 2048, -- 129
		"T11 两个 1024 应合成为 2048" -- 129
	) -- 129
	check(durian.reachedDurian, "T11 出现 2048 后应置达成标记") -- 130
	check(durianResult.gainedScore == 2048, "T11 合成 2048 应获得 2048 分") -- 131
	check(#TILE_VALUES == 11 and TILE_VALUES[11] == 2048, "T12 水果链条应为 11 级且终点为 2048") -- 134
	local corner = __TS__New(FruitBoard, 4, 4, 5) -- 135
	corner:set(3, 3, 4) -- 136
	local cornerResult = corner:move(DIR_RIGHT) -- 137
	check( -- 138
		corner:get(3, 3) == 4, -- 138
		"T12 右下角瓦片向右移动后仍留在 (3,3)" -- 138
	) -- 138
	check(not cornerResult.changed, "T12 角落瓦片向右移动不应判定为变化") -- 139
	local randomBoard = __TS__New(FruitBoard, 4, 4, 99) -- 140
	randomBoard:reset(2) -- 141
	do -- 141
		local step = 0 -- 142
		while step < 60 do -- 142
			if randomBoard:isGameOver() then -- 142
				break -- 144
			end -- 144
			randomBoard:move(step % 4) -- 146
			step = step + 1 -- 142
		end -- 142
	end -- 142
	check(#randomBoard.cells == 16, "T12 4×4 棋盘应始终保留 16 格") -- 148
	local legal = true -- 149
	do -- 149
		local i = 0 -- 150
		while i < #randomBoard.cells do -- 150
			if not isAllowedValue(randomBoard.cells[i + 1]) then -- 150
				legal = false -- 152
			end -- 152
			i = i + 1 -- 150
		end -- 150
	end -- 150
	check(legal, "T12 连续随机移动后不应出现非法数值") -- 155
	local lines = {} -- 157
	lines[#lines + 1] = #failures == 0 and "passed" or "failed" -- 158
	lines[#lines + 1] = (("checks=" .. tostring(checks)) .. " failures=") .. tostring(#failures) -- 159
	do -- 159
		local i = 0 -- 160
		while i < #failures do -- 160
			lines[#lines + 1] = "FAIL " .. failures[i + 1] -- 161
			i = i + 1 -- 160
		end -- 160
	end -- 160
	return table.concat(lines, "\n") -- 163
end -- 28
return ____exports -- 28