-- [ts]: SceneTests.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 7
local Content = ____Dora.Content -- 7
local Director = ____Dora.Director -- 7
local Node = ____Dora.Node -- 7
local ____Save = require("Game.Save") -- 8
local joinPath = ____Save.joinPath -- 8
local ____FruitBoard = require("Game.FruitBoard") -- 9
local DIR_LEFT = ____FruitBoard.DIR_LEFT -- 9
local DIR_UP = ____FruitBoard.DIR_UP -- 9
local ____FruitGame = require("Game.FruitGame") -- 10
local COLS = ____FruitGame.COLS -- 10
local FruitGame = ____FruitGame.FruitGame -- 10
local ROWS = ____FruitGame.ROWS -- 10
local ____Theme = require("Game.Theme")
local SCREEN_MARGIN = ____Theme.SCREEN_MARGIN
--- 生成全空棋盘数值表。
local function emptyValues() -- 13
	local values = {} -- 14
	do -- 14
		local i = 0 -- 15
		while i < ROWS * COLS do -- 15
			values[#values + 1] = 0 -- 16
			i = i + 1 -- 15
		end -- 15
	end -- 15
	return values -- 18
end -- 13
function ____exports.runTests() -- 21
	local failures = {} -- 22
	local checks = 0 -- 23
	local function check(condition, message) -- 25
		checks = checks + 1 -- 26
		if not condition and #failures < 12 then -- 26
			failures[#failures + 1] = message -- 28
		end -- 28
	end -- 25
	local host = Node() -- 32
	host:addTo(Director.entry) -- 33
	local scoreFileName = "fruit2048_scene_test.txt" -- 34
	local scorePath = joinPath(Content.writablePath, scoreFileName) -- 35
	if Content:exist(scorePath) then -- 35
		Content:remove(scorePath) -- 36
	end -- 36
	local game = __TS__New(FruitGame, host, scoreFileName) -- 37
	game:layout(360, 640) -- 38
	check(game.hud.hintLabel ~= nil and #game.hud.hintLabel.text > 0, "场景：操作提示应可见") -- 39
	check(game.hud.restartButton.width == 168, "场景：重开按钮应可点击") -- 40
	game:layout(783, 639) -- 41
	check( -- 42
		game.hud.hintLabel ~= nil and game.hud.restartButton.position.x == 0 and game.hud.hintLabel.position.x == 0 and game.hud.restartButton.position.y > game.hud.hintLabel.position.y, -- 42
		"场景：短横屏下重开按钮应居中且提示位于下方" -- 42
	) -- 42
	check(game.boardView:boardBottomY() >= game.hud.restartButton.position.y + 22, "场景：重开按钮不应遮挡棋盘") -- 43
	local scoreCardsBottomY = 639 / 2 - SCREEN_MARGIN - 132 -- 44
	check(game.boardView.root.position.y + game.boardView.boardSize / 2 <= scoreCardsBottomY - 12, "场景：评分卡片不应遮挡棋盘") -- 45
	game:layout(360, 640) -- 43
	check(ROWS == 4 and COLS == 4, "场景：棋盘规格应为 4×4") -- 41
	check(game.board.rows == 4 and game.board.cols == 4, "场景：逻辑棋盘应为 4×4") -- 42
	check(#game.boardView.tiles == 2, "场景：开局应有 2 个水果瓦片") -- 43
	check(game.boardView.cellSize > 24, "场景：布局应给出可用格子尺寸") -- 44
	local mergeValues = emptyValues() -- 47
	mergeValues[1] = 2 -- 48
	mergeValues[2] = 2 -- 49
	game:setBoard(mergeValues) -- 50
	check(#game.boardView.tiles == 2, "场景：布置后应有两个瓦片") -- 51
	game:requestMove(DIR_LEFT) -- 53
	check(game.boardView.animating, "场景：请求移动后应进入位移动画") -- 54
	check( -- 55
		game.board:get(0, 0) == 4, -- 55
		"场景：向左合成后 (0,0) 应为 4" -- 55
	) -- 55
	check(game.board.score == 4, "场景：合成后得分应为 4") -- 56
	game:advance(0.3) -- 58
	check(not game.boardView.animating, "场景：推进时间后位移动画应结束") -- 59
	check(#game.boardView.tiles == 2, "场景：合成后应有目标瓦片与新水果共 2 个") -- 60
	local hasFour = false -- 61
	do -- 61
		local i = 0 -- 62
		while i < #game.boardView.tiles do -- 62
			if game.boardView.tiles[i + 1].value == 4 then -- 62
				hasFour = true -- 64
			end -- 64
			i = i + 1 -- 62
		end -- 62
	end -- 62
	check(hasFour, "场景：合成后应存在数值为 4 的瓦片") -- 67
	local numbersOk = true -- 70
	do -- 70
		local i = 0 -- 71
		while i < #game.boardView.tiles do -- 71
			local tile = game.boardView.tiles[i + 1] -- 72
			if not tile.numberLabel or tile.numberLabel.text ~= "" .. tostring(tile.value) then -- 72
				numbersOk = false -- 74
			end -- 74
			i = i + 1 -- 71
		end -- 71
	end -- 71
	check(numbersOk, "场景：每个瓦片应显示与其数值一致的文本") -- 77
	check(game.hud ~= nil, "场景：HUD 应已创建") -- 78
	local singleValues = emptyValues() -- 81
	singleValues[3 * COLS + 1] = 8 -- 82
	game:setBoard(singleValues) -- 83
	game:requestMove(DIR_LEFT) -- 84
	check(not game.boardView.animating, "场景：已贴边的瓦片不应触发动画") -- 85
	check( -- 86
		game.board:tileCount() == 1, -- 86
		"场景：无效方向不应生成新水果" -- 86
	) -- 86
	check(#game.boardView.tiles == 1, "场景：无效方向后瓦片数不变") -- 87
	local fullValues = emptyValues() -- 90
	do -- 90
		local row = 0 -- 91
		while row < ROWS do -- 91
			do -- 91
				local col = 0 -- 92
				while col < COLS do -- 92
					fullValues[row * COLS + col + 1] = (row + col) % 2 == 0 and 2 or 4 -- 93
					col = col + 1 -- 92
				end -- 92
			end -- 92
			row = row + 1 -- 91
		end -- 91
	end -- 91
	game:setBoard(fullValues) -- 96
	game:requestMove(DIR_LEFT) -- 97
	check(game.gameOver, "场景：无路可走时应进入终局状态") -- 98
	check(game.gameOverTitle ~= nil and game.gameOverTitle.visible, "场景：终局文本应可见") -- 99
	check(game.boardView.effects.scrim.visible, "场景：终局遮罩应可见") -- 100
	game:requestMove(DIR_UP) -- 103
	check(not game.gameOver, "场景：终局后请求移动应重开新局") -- 104
	check( -- 105
		game.board:tileCount() == 2, -- 105
		"场景：重开后应有 2 个水果" -- 105
	) -- 105
	check(not game.boardView.effects.scrim.visible, "场景：重开后遮罩应隐藏") -- 106
	game:setBoard(mergeValues) -- 108
	if game.hud.onRestart then -- 108
		game.hud.onRestart() -- 109
	end -- 109
	check( -- 110
		game.board:tileCount() == 2 and game.board.score == 0, -- 110
		"场景：HUD 重开应恢复初始棋盘" -- 110
	) -- 110
	host:removeFromParent() -- 111
	if Content:exist(scorePath) then -- 111
		Content:remove(scorePath) -- 112
	end -- 112
	local lines = {} -- 114
	lines[#lines + 1] = #failures == 0 and "passed" or "failed" -- 115
	lines[#lines + 1] = (("checks=" .. tostring(checks)) .. " failures=") .. tostring(#failures) -- 116
	do -- 116
		local i = 0 -- 117
		while i < #failures do -- 117
			lines[#lines + 1] = "FAIL " .. failures[i + 1] -- 118
			i = i + 1 -- 117
		end -- 117
	end -- 117
	return table.concat(lines, "\n") -- 120
end -- 21
return ____exports -- 21
