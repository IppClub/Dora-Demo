-- [ts]: FruitGame.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 6
local Color = ____Dora.Color -- 6
local DrawNode = ____Dora.DrawNode -- 6
local Ease = ____Dora.Ease -- 6
local Label = ____Dora.Label -- 6
local Scale = ____Dora.Scale -- 6
local Vec2 = ____Dora.Vec2 -- 6
local ____BoardView = require("Game.BoardView") -- 7
local BoardView = ____BoardView.BoardView -- 7
local NO_DIRECTION = ____BoardView.NO_DIRECTION -- 7
local ____FruitBoard = require("Game.FruitBoard") -- 8
local DIR_DOWN = ____FruitBoard.DIR_DOWN -- 8
local DIR_LEFT = ____FruitBoard.DIR_LEFT -- 8
local DIR_RIGHT = ____FruitBoard.DIR_RIGHT -- 8
local DIR_UP = ____FruitBoard.DIR_UP -- 8
local FruitBoard = ____FruitBoard.FruitBoard -- 8
local ____Hud = require("Game.Hud") -- 9
local Hud = ____Hud.Hud -- 9
local ____Save = require("Game.Save") -- 10
local BestScoreStore = ____Save.BestScoreStore -- 10
local ____Theme = require("Game.Theme") -- 11
local COLOR_ACCENT = ____Theme.COLOR_ACCENT -- 12
local COLOR_BG_BOTTOM = ____Theme.COLOR_BG_BOTTOM -- 13
local COLOR_BG_TOP = ____Theme.COLOR_BG_TOP -- 14
local COLOR_TEXT = ____Theme.COLOR_TEXT -- 15
local COLOR_TEXT_MUTED = ____Theme.COLOR_TEXT_MUTED -- 16
local FONT_NAME = ____Theme.FONT_NAME -- 17
local HUD_LABEL_SIZE = ____Theme.HUD_LABEL_SIZE -- 18
local Z_BACKGROUND = ____Theme.Z_BACKGROUND -- 19
local Z_OVERLAY = ____Theme.Z_OVERLAY -- 20
--- 棋盘规格：4×4。
____exports.ROWS = 4 -- 24
____exports.COLS = 4 -- 25
--- 开局水果数量。
local INITIAL_TILES = 2 -- 27
--- 庆祝动画持续时长（秒）。
local CELEBRATE_TIME = 1.8 -- 29
--- 达成大榴莲的数值。
local DURIAN = 2048 -- 31
--- 一局完整的水果 2048 游戏。
____exports.FruitGame = __TS__Class() -- 34
local FruitGame = ____exports.FruitGame -- 34
FruitGame.name = "FruitGame" -- 34
function FruitGame.prototype.____constructor(self, parent, scoreFileName) -- 53
	self.parent = parent -- 54
	self.viewWidth = 0 -- 55
	self.viewHeight = 0 -- 56
	self.gameOver = false -- 57
	self.celebrated = false -- 58
	self.pendingResult = nil -- 59
	self.pendingMove = NO_DIRECTION -- 60
	self.pendingCelebrate = false -- 61
	self.winTimer = 0 -- 62
	self.background = DrawNode() -- 64
	self.background.order = Z_BACKGROUND -- 65
	self.background:addTo(parent) -- 66
	self.board = __TS__New(FruitBoard, ____exports.ROWS, ____exports.COLS) -- 68
	self.store = __TS__New(BestScoreStore, scoreFileName) -- 69
	self.boardView = __TS__New(BoardView, parent, ____exports.ROWS, ____exports.COLS) -- 70
	self.hud = __TS__New(Hud, parent) -- 71
	self.hud.onRestart = function() return self:startNewGame() end -- 72
	self.gameOverTitle = self:makeOverlayLabel("无路可走", 34, COLOR_TEXT) -- 74
	self.gameOverHint = self:makeOverlayLabel("点击任意处或按空格重新开始", HUD_LABEL_SIZE + 2, COLOR_TEXT_MUTED) -- 75
	self.winLabel = self:makeOverlayLabel("大榴莲达成！", 40, COLOR_ACCENT) -- 76
	self:bindKeyboard() -- 78
	self:startNewGame() -- 79
end -- 53
function FruitGame.prototype.makeOverlayLabel(self, text, size, color) -- 83
	local label = Label(FONT_NAME, size) -- 84
	if not label then -- 84
		return nil -- 86
	end -- 86
	label.text = text -- 88
	label.color = color -- 89
	label.order = Z_OVERLAY + 1 -- 90
	label.visible = false -- 91
	label:addTo(self.parent) -- 92
	return label -- 93
end -- 83
function FruitGame.prototype.layout(self, viewWidth, viewHeight) -- 97
	self.viewWidth = viewWidth -- 98
	self.viewHeight = viewHeight -- 99
	local halfW = viewWidth / 2 -- 100
	local halfH = viewHeight / 2 -- 101
	self.background:clear() -- 102
	self.background:drawPolygon( -- 103
		{ -- 103
			Vec2(-halfW, -halfH), -- 104
			Vec2(halfW, -halfH), -- 105
			Vec2(halfW, halfH), -- 106
			Vec2(-halfW, halfH) -- 107
		}, -- 107
		COLOR_BG_TOP -- 108
	) -- 108
	self.background:drawPolygon( -- 109
		{ -- 109
			Vec2(-halfW, -halfH), -- 110
			Vec2(halfW, -halfH), -- 111
			Vec2(halfW, 0), -- 112
			Vec2(-halfW, 0) -- 113
		}, -- 113
		COLOR_BG_BOTTOM -- 114
	) -- 114
	self.boardView:layout(viewWidth, viewHeight) -- 115
	self.hud:layout( -- 116
		viewWidth, -- 116
		viewHeight, -- 116
		self.boardView:boardBottomY() -- 116
	) -- 116
	local centerY = self.boardView.root.position.y -- 117
	if self.gameOverTitle then -- 117
		self.gameOverTitle.position = Vec2(0, centerY + 8) -- 119
	end -- 119
	if self.gameOverHint then -- 119
		self.gameOverHint.position = Vec2(0, centerY - 34) -- 122
	end -- 122
	if self.winLabel then -- 122
		self.winLabel.position = Vec2(0, centerY + self.boardView.boardSize * 0.08) -- 125
	end -- 125
end -- 97
function FruitGame.prototype.startNewGame(self) -- 130
	self.board:reset(INITIAL_TILES) -- 131
	self.boardView:buildFromBoard(self.board) -- 132
	self.hud:setScore(0) -- 133
	self.hud:setBest(self.store.best, self.store.persisted) -- 134
	self.hud:setHint("滑动棋盘，合成水果") -- 135
	self.boardView.effects:setScrimVisible(false) -- 136
	if self.gameOverTitle then -- 136
		self.gameOverTitle.visible = false -- 138
	end -- 138
	if self.gameOverHint then -- 138
		self.gameOverHint.visible = false -- 141
	end -- 141
	if self.winLabel then -- 141
		self.winLabel.visible = false -- 144
	end -- 144
	self.gameOver = false -- 146
	self.celebrated = false -- 147
	self.pendingResult = nil -- 148
	self.pendingMove = NO_DIRECTION -- 149
	self.pendingCelebrate = false -- 150
	self.winTimer = 0 -- 151
end -- 130
function FruitGame.prototype.setBoard(self, values) -- 155
	self.board:clearAll() -- 156
	self.board:load(values) -- 157
	self.boardView:buildFromBoard(self.board) -- 158
	self.hud:setScore(self.board.score) -- 159
end -- 155
function FruitGame.prototype.checkGameOver(self) -- 163
	if self.gameOver or not self.board:isGameOver() then -- 163
		return -- 165
	end -- 165
	self.gameOver = true -- 167
	self.boardView.effects:setScrimVisible(true) -- 168
	if self.gameOverTitle then -- 168
		self.gameOverTitle.visible = true -- 170
	end -- 170
	if self.gameOverHint then -- 170
		self.gameOverHint.visible = true -- 173
	end -- 173
	self.hud:setHint("本局结束：点击任意处或按空格重新开始") -- 175
end -- 163
function FruitGame.prototype.celebrate(self) -- 179
	local durianRow = 0 -- 180
	local durianCol = 0 -- 181
	local found = false -- 182
	do -- 182
		local row = 0 -- 183
		while row < self.board.rows do -- 183
			do -- 183
				local col = 0 -- 184
				while col < self.board.cols do -- 184
					if self.board:get(row, col) >= DURIAN then -- 184
						durianRow = row -- 186
						durianCol = col -- 187
						found = true -- 188
					end -- 188
					col = col + 1 -- 184
				end -- 184
			end -- 184
			row = row + 1 -- 183
		end -- 183
	end -- 183
	local center = found and self.boardView:cellCenter(durianRow, durianCol) or Vec2(self.boardView.boardSize / 2, self.boardView.boardSize / 2) -- 192
	self.boardView.effects:flash(Color(255, 214, 140, 255)) -- 195
	do -- 195
		local i = 0 -- 196
		while i < 4 do -- 196
			self.boardView.effects:ringBurst(center, COLOR_ACCENT, 22) -- 197
			i = i + 1 -- 196
		end -- 196
	end -- 196
	self.boardView.effects:burst( -- 199
		center, -- 199
		Color(255, 255, 255, 255), -- 199
		16 -- 199
	) -- 199
	self.boardView.effects:floatText(center, "2048!", COLOR_ACCENT, 26) -- 200
	if self.winLabel then -- 200
		self.winLabel.visible = true -- 202
		self.winLabel.scaleX = 0 -- 203
		self.winLabel.scaleY = 0 -- 204
		self.winLabel:runAction(Scale(0.3, 0, 1, Ease.OutBack)) -- 205
	end -- 205
	self.winTimer = CELEBRATE_TIME -- 207
	self.hud:setHint("达成大榴莲！继续合成或点击重开") -- 208
end -- 179
function FruitGame.prototype.executeMove(self, dir) -- 212
	local result = self.board:move(dir) -- 213
	if not result.changed then -- 213
		self:checkGameOver() -- 215
		return -- 216
	end -- 216
	self.hud:setScore(self.board.score) -- 218
	if self.board.score > self.store.best then -- 218
		self.store:submit(self.board.score) -- 220
		self.hud:setBest(self.store.best, self.store.persisted) -- 221
	end -- 221
	if self.board.reachedDurian and not self.celebrated then -- 221
		self.celebrated = true -- 224
		self.pendingCelebrate = true -- 225
	end -- 225
	self.pendingResult = result -- 227
	self.boardView:playMove(result) -- 228
end -- 212
function FruitGame.prototype.requestMove(self, dir) -- 232
	if self.gameOver then -- 232
		self:startNewGame() -- 234
		return -- 235
	end -- 235
	if self.boardView.animating then -- 235
		self.pendingMove = dir -- 238
		return -- 239
	end -- 239
	self:executeMove(dir) -- 241
end -- 232
function FruitGame.prototype.bindKeyboard(self) -- 245
	self.parent:onKeyDown(function(keyName) -- 246
		if keyName == "Left" or keyName == "A" then -- 246
			self:requestMove(DIR_LEFT) -- 248
		elseif keyName == "Right" or keyName == "D" then -- 248
			self:requestMove(DIR_RIGHT) -- 250
		elseif keyName == "Up" or keyName == "W" then -- 250
			self:requestMove(DIR_UP) -- 252
		elseif keyName == "Down" or keyName == "S" then -- 252
			self:requestMove(DIR_DOWN) -- 254
		elseif keyName == "R" then -- 254
			self:startNewGame() -- 256
		elseif keyName == "Space" or keyName == "Return" then -- 256
			if self.gameOver then -- 256
				self:startNewGame() -- 259
			end -- 259
		end -- 259
	end) -- 246
end -- 245
function FruitGame.prototype.update(self, dt) -- 266
	self.boardView.effects:update(dt) -- 267
	if self.boardView.pendingTap then -- 267
		self.boardView.pendingTap = false -- 270
		if self.gameOver then -- 270
			self:startNewGame() -- 272
		end -- 272
	end -- 272
	if self.boardView.pendingDir ~= NO_DIRECTION then -- 272
		local dir = self.boardView.pendingDir -- 277
		self.boardView.pendingDir = NO_DIRECTION -- 278
		self:requestMove(dir) -- 279
	end -- 279
	if self.boardView:updateAnimation(dt) then -- 279
		if self.pendingResult then -- 279
			self.boardView:finishMove(self.board, self.pendingResult) -- 284
			self.pendingResult = nil -- 285
		end -- 285
		if self.pendingCelebrate then -- 285
			self.pendingCelebrate = false -- 288
			self:celebrate() -- 289
		end -- 289
		if self.pendingMove ~= NO_DIRECTION then -- 289
			local next = self.pendingMove -- 292
			self.pendingMove = NO_DIRECTION -- 293
			self:executeMove(next) -- 294
		else -- 294
			self:checkGameOver() -- 296
		end -- 296
	end -- 296
	if self.winTimer > 0 then -- 296
		self.winTimer = self.winTimer - dt -- 301
		if self.winTimer <= 0 and self.winLabel then -- 301
			self.winLabel.visible = false -- 303
		end -- 303
	end -- 303
end -- 266
function FruitGame.prototype.advance(self, seconds, stepSeconds) -- 309
	local step = stepSeconds and stepSeconds or 1 / 60 -- 310
	local remaining = seconds -- 311
	while remaining > 0 do -- 311
		local dt = remaining > step and step or remaining -- 313
		self:update(dt) -- 314
		remaining = remaining - dt -- 315
	end -- 315
end -- 309
return ____exports -- 309