-- [ts]: BoardView.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
local ____FreshArt = require("Game.FreshArt") -- 1
local roundedRect = ____FreshArt.roundedRect -- 1
local ____Dora = require("Dora") -- 9
local Color = ____Dora.Color -- 9
local DrawNode = ____Dora.DrawNode -- 9
local Ease = ____Dora.Ease -- 9
local Label = ____Dora.Label -- 9
local Move = ____Dora.Move -- 9
local Node = ____Dora.Node -- 9
local Scale = ____Dora.Scale -- 9
local Sequence = ____Dora.Sequence -- 9
local Size = ____Dora.Size -- 9
local Vec2 = ____Dora.Vec2 -- 9
local ____Effects = require("Game.Effects") -- 10
local EffectsLayer = ____Effects.EffectsLayer -- 10
local ____FruitBoard = require("Game.FruitBoard") -- 11
local DIR_DOWN = ____FruitBoard.DIR_DOWN -- 11
local DIR_LEFT = ____FruitBoard.DIR_LEFT -- 11
local DIR_RIGHT = ____FruitBoard.DIR_RIGHT -- 11
local DIR_UP = ____FruitBoard.DIR_UP -- 11
local ____FruitArt = require("Game.FruitArt") -- 12
local drawFruit = ____FruitArt.drawFruit -- 12
local fruitOfTier = ____FruitArt.fruitOfTier -- 12
local tierOfValue = ____FruitArt.tierOfValue -- 12
local ____Theme = require("Game.Theme") -- 13
local CELL_GAP = ____Theme.CELL_GAP -- 14
local COLOR_ACCENT = ____Theme.COLOR_ACCENT -- 15
local COLOR_PANEL = ____Theme.COLOR_PANEL -- 16
local COLOR_SLOT = ____Theme.COLOR_SLOT -- 17
local FONT_NAME = ____Theme.FONT_NAME -- 18
local HUD_HEIGHT = ____Theme.HUD_HEIGHT -- 19
local SCREEN_MARGIN = ____Theme.SCREEN_MARGIN -- 20
local Z_PANEL = ____Theme.Z_PANEL -- 21
local Z_TILE = ____Theme.Z_TILE -- 23
--- 位移动画时长（秒）。
____exports.MOVE_DURATION = 0.12 -- 27
--- 小于该格子尺寸时隐藏果名文本，避免挤压。
local NAME_MIN_CELL = 56 -- 29
--- 果实上的数值字号。
local function numberFontSize(cell) -- 32
	local size = math.floor(cell * 0.24 + 0.5) -- 33
	if size < 12 then -- 33
		size = 12 -- 35
	end -- 35
	if size > 72 then -- 35
		size = 72 -- 38
	end -- 38
	return size -- 40
end -- 32
--- 果实下方的果名字号。
local function nameFontSize(cell) -- 44
	local size = math.floor(cell * 0.15 + 0.5) -- 45
	if size < 10 then -- 45
		size = 10 -- 47
	end -- 47
	if size > 40 then -- 47
		size = 40 -- 50
	end -- 50
	return size -- 52
end -- 44
--- 无方向时的待处理值。
____exports.NO_DIRECTION = -1 -- 55
--- 单个水果瓦片的视图。
____exports.TileView = __TS__Class() -- 58
local TileView = ____exports.TileView -- 58
TileView.name = "TileView" -- 58
function TileView.prototype.____constructor(self, node, canvas, value, row, col) -- 75
	self.node = node -- 76
	self.canvas = canvas -- 77
	self.numberLabel = nil -- 78
	self.numberSize = 0 -- 79
	self.nameLabel = nil -- 80
	self.nameSize = 0 -- 81
	self.value = value -- 82
	self.row = row -- 83
	self.col = col -- 84
	self.dying = false -- 85
end -- 75
--- 棋盘视图。
____exports.BoardView = __TS__Class() -- 90
local BoardView = ____exports.BoardView -- 90
BoardView.name = "BoardView" -- 90
function BoardView.prototype.____constructor(self, parent, rows, cols) -- 115
	self.rows = rows -- 116
	self.cols = cols -- 117
	self.cellSize = 60 -- 118
	self.boardSize = self.cellSize * cols -- 119
	self.tiles = {} -- 120
	self.pendingDir = ____exports.NO_DIRECTION -- 121
	self.pendingTap = false -- 122
	self.animating = false -- 123
	self.animTime = 0 -- 124
	self.touchActive = false -- 125
	self.touchStartX = 0 -- 126
	self.touchStartY = 0 -- 127
	self.swipeConsumed = false -- 128
	self.root = Node() -- 130
	self.root.size = Size(self.boardSize, self.boardSize) -- 131
	self.root:addTo(parent) -- 132
	self.panelCanvas = DrawNode() -- 134
	self.panelCanvas.order = Z_PANEL -- 135
	self.panelCanvas:addTo(self.root) -- 136
	self.tileLayer = Node() -- 138
	self.tileLayer.order = Z_TILE -- 139
	self.tileLayer:addTo(self.root) -- 140
	self.effects = __TS__New(EffectsLayer, self.root, parent) -- 142
	self:bindTouch() -- 143
end -- 115
function BoardView.prototype.bindTouch(self) -- 147
	self.root:onTapBegan(function(touch) -- 148
		self.touchActive = true -- 149
		self.touchStartX = touch.location.x -- 150
		self.touchStartY = touch.location.y -- 151
		self.swipeConsumed = false -- 152
		self.pendingTap = true -- 153
	end) -- 148
	self.root:onTapMoved(function(touch) -- 155
		if not self.touchActive or self.swipeConsumed then -- 155
			return -- 157
		end -- 157
		self:checkSwipe(touch.location.x - self.touchStartX, touch.location.y - self.touchStartY) -- 159
	end) -- 155
	self.root:onTapEnded(function(touch) -- 161
		if self.touchActive and not self.swipeConsumed then -- 161
			self:checkSwipe(touch.location.x - self.touchStartX, touch.location.y - self.touchStartY) -- 163
		end -- 163
		self.touchActive = false -- 165
		self.swipeConsumed = false -- 166
	end) -- 161
end -- 147
function BoardView.prototype.checkSwipe(self, dx, dy) -- 171
	local threshold = math.max(20, self.cellSize * 0.4) -- 172
	local absX = dx < 0 and -dx or dx -- 173
	local absY = dy < 0 and -dy or dy -- 174
	if absX < threshold and absY < threshold then -- 174
		return -- 176
	end -- 176
	if absX >= absY then -- 176
		self.pendingDir = dx > 0 and DIR_RIGHT or DIR_LEFT -- 179
	else -- 179
		self.pendingDir = dy > 0 and DIR_UP or DIR_DOWN -- 181
	end -- 181
	self.swipeConsumed = true -- 183
end -- 171
function BoardView.prototype.cellCenter(self, row, col) -- 187
	return Vec2(self.cellSize * (col + 0.5), self.cellSize * (row + 0.5)) -- 188
end -- 187
function BoardView.prototype.layout(self, viewWidth, viewHeight) -- 192
	local margin = SCREEN_MARGIN -- 193
	local availWidth = viewWidth - margin * 2 -- 194
	local availHeight = viewHeight - HUD_HEIGHT - margin * 2 -- 195
	local cell = math.floor(math.min(availWidth, availHeight) / self.cols) -- 196
	if cell < 24 then -- 196
		cell = 24 -- 198
	end -- 198
	self.cellSize = cell -- 200
	self.boardSize = cell * self.cols -- 201
	self.root.size = Size(self.boardSize, self.boardSize) -- 202
	self.root.position = Vec2(0, (margin - HUD_HEIGHT) / 2 + 40) -- 203
	self:redrawPanel() -- 204
	self.effects:layout(viewWidth, viewHeight) -- 205
	do -- 205
		local i = 0 -- 206
		while i < #self.tiles do -- 206
			self:refreshTile(self.tiles[i + 1]) -- 207
			self.tiles[i + 1].node.position = self:cellCenter(self.tiles[i + 1].row, self.tiles[i + 1].col) -- 208
			i = i + 1 -- 206
		end -- 206
	end -- 206
end -- 192
function BoardView.prototype.boardBottomY(self) -- 213
	return self.root.position.y - self.boardSize / 2 -- 214
end -- 213
function BoardView.prototype.redrawPanel(self) -- 218
	self.panelCanvas:clear() -- 219
	local size = self.boardSize -- 220
	roundedRect( -- 221
		self.panelCanvas, -- 221
		size / 2, -- 221
		size / 2 - 3, -- 221
		size + 8, -- 221
		size + 8, -- 221
		17, -- 221
		Color(183, 202, 173, 110) -- 221
	) -- 221
	roundedRect( -- 222
		self.panelCanvas, -- 222
		size / 2, -- 222
		size / 2, -- 222
		size + 8, -- 222
		size + 8, -- 222
		17, -- 222
		COLOR_PANEL -- 222
	) -- 222
	local half = self.cellSize / 2 - CELL_GAP -- 223
	do -- 223
		local row = 0 -- 224
		while row < self.rows do -- 224
			do -- 224
				local col = 0 -- 225
				while col < self.cols do -- 225
					local p = self:cellCenter(row, col) -- 226
					roundedRect( -- 227
						self.panelCanvas, -- 227
						p.x, -- 227
						p.y, -- 227
						half * 2, -- 227
						half * 2, -- 227
						10, -- 227
						COLOR_SLOT -- 227
					) -- 227
					col = col + 1 -- 225
				end -- 225
			end -- 225
			row = row + 1 -- 224
		end -- 224
	end -- 224
end -- 218
function BoardView.prototype.createTile(self, row, col, value) -- 232
	local node = Node() -- 233
	node.order = Z_TILE -- 234
	node.position = self:cellCenter(row, col) -- 235
	node:addTo(self.tileLayer) -- 236
	local canvas = DrawNode() -- 238
	canvas.order = Z_TILE -- 239
	canvas:addTo(node) -- 240
	local tile = __TS__New( -- 242
		____exports.TileView, -- 242
		node, -- 242
		canvas, -- 242
		value, -- 242
		row, -- 242
		col -- 242
	) -- 242
	self:refreshTile(tile) -- 243
	return tile -- 244
end -- 232
function BoardView.prototype.refreshTile(self, tile) -- 248
	local tier = tierOfValue(tile.value) -- 249
	if tier < 0 then -- 249
		tier = 10 -- 251
	end -- 251
	local def = fruitOfTier(tier) -- 253
	tile.canvas.position = Vec2(0, self.cellSize * 0.1) -- 254
	drawFruit(tile.canvas, tier, self.cellSize * 0.29) -- 255
	self:refreshNumber(tile, def) -- 256
end -- 248
function BoardView.prototype.refreshNumber(self, tile, def) -- 261
	local size = numberFontSize(self.cellSize) -- 262
	if tile.numberLabel and tile.numberSize ~= size then -- 262
		tile.numberLabel:removeFromParent() -- 264
		tile.numberLabel = nil -- 265
	end -- 265
	if not tile.numberLabel then -- 265
		local created = Label(FONT_NAME, size * 3, false) -- 268
		if not created then -- 268
			return -- 270
		end -- 270
		local ____temp_0 = 1 / 3 -- 272
		created.scaleY = ____temp_0 -- 272
		created.scaleX = ____temp_0 -- 272
		created.order = Z_TILE + 1 -- 273
		created:addTo(tile.node) -- 274
		tile.numberLabel = created -- 275
		tile.numberSize = size -- 276
	end -- 276
	tile.numberLabel.text = "" .. tostring(tile.value) -- 278
	tile.numberLabel.color = Color(67, 91, 66, 255) -- 279
	tile.numberLabel.position = Vec2(0, -self.cellSize * 0.29) -- 280
end -- 261
function BoardView.prototype.refreshName(self, tile, def) -- 284
	if self.cellSize < NAME_MIN_CELL then -- 284
		if tile.nameLabel then -- 284
			tile.nameLabel:removeFromParent() -- 287
			tile.nameLabel = nil -- 288
			tile.nameSize = 0 -- 289
		end -- 289
		return -- 291
	end -- 291
	local size = nameFontSize(self.cellSize) -- 293
	if tile.nameLabel and tile.nameSize ~= size then -- 293
		tile.nameLabel:removeFromParent() -- 295
		tile.nameLabel = nil -- 296
	end -- 296
	if not tile.nameLabel then -- 296
		local created = Label(FONT_NAME, size) -- 299
		if not created then -- 299
			return -- 301
		end -- 301
		local ____temp_1 = 1 / 3 -- 303
		created.scaleY = ____temp_1 -- 303
		created.scaleX = ____temp_1 -- 303
		created.order = Z_TILE + 1 -- 304
		created:addTo(tile.node) -- 305
		tile.nameLabel = created -- 306
		tile.nameSize = size -- 307
	end -- 307
	tile.nameLabel.text = def.name -- 309
	tile.nameLabel.color = def.text -- 310
	tile.nameLabel.position = Vec2(0, -self.cellSize * 0.38) -- 311
end -- 284
function BoardView.prototype.findTile(self, row, col) -- 315
	do -- 315
		local i = 0 -- 316
		while i < #self.tiles do -- 316
			local tile = self.tiles[i + 1] -- 317
			if not tile.dying and tile.row == row and tile.col == col then -- 317
				return tile -- 319
			end -- 319
			i = i + 1 -- 316
		end -- 316
	end -- 316
	return nil -- 322
end -- 315
function BoardView.prototype.clearTiles(self) -- 326
	do -- 326
		local i = 0 -- 327
		while i < #self.tiles do -- 327
			self.tiles[i + 1].node:removeFromParent() -- 328
			i = i + 1 -- 327
		end -- 327
	end -- 327
	self.tiles = {} -- 330
end -- 326
function BoardView.prototype.buildFromBoard(self, board) -- 334
	self:clearTiles() -- 335
	do -- 335
		local row = 0 -- 336
		while row < self.rows do -- 336
			do -- 336
				local col = 0 -- 337
				while col < self.cols do -- 337
					local value = board:get(row, col) -- 338
					if value > 0 then -- 338
						local ____self_tiles_2 = self.tiles -- 338
						____self_tiles_2[#____self_tiles_2 + 1] = self:createTile(row, col, value) -- 340
					end -- 340
					col = col + 1 -- 337
				end -- 337
			end -- 337
			row = row + 1 -- 336
		end -- 336
	end -- 336
end -- 334
function BoardView.prototype.playMove(self, result) -- 347
	do -- 347
		local i = 0 -- 348
		while i < #result.moves do -- 348
			do -- 348
				local move = result.moves[i + 1] -- 349
				local tile = self:findTile(move.fromRow, move.fromCol) -- 350
				if not tile then -- 350
					goto __continue59 -- 352
				end -- 352
				local target = self:cellCenter(move.toRow, move.toCol) -- 354
				tile.node:runAction(Move(____exports.MOVE_DURATION, tile.node.position, target, Ease.OutQuad)) -- 355
				if move.merged then -- 355
					tile.dying = true -- 357
				else -- 357
					tile.row = move.toRow -- 359
					tile.col = move.toCol -- 360
				end -- 360
			end -- 360
			::__continue59:: -- 360
			i = i + 1 -- 348
		end -- 348
	end -- 348
	self.animating = true -- 363
	self.animTime = ____exports.MOVE_DURATION -- 364
end -- 347
function BoardView.prototype.finishMove(self, board, result) -- 368
	do -- 368
		local i = #self.tiles - 1 -- 369
		while i >= 0 do -- 369
			if self.tiles[i + 1].dying then -- 369
				self.tiles[i + 1].node:removeFromParent() -- 371
				__TS__ArraySplice(self.tiles, i, 1) -- 372
			end -- 372
			i = i - 1 -- 369
		end -- 369
	end -- 369
	do -- 369
		local i = 0 -- 375
		while i < #result.mergedCells do -- 375
			local pos = result.mergedCells[i + 1] -- 376
			local tile = self:createTile( -- 377
				pos.row, -- 377
				pos.col, -- 377
				board:get(pos.row, pos.col) -- 377
			) -- 377
			local ____self_tiles_3 = self.tiles -- 377
			____self_tiles_3[#____self_tiles_3 + 1] = tile -- 378
			tile.node:runAction(Sequence( -- 379
				Scale(0.08, 1, 1.18, Ease.OutQuad), -- 380
				Scale(0.09, 1.18, 1, Ease.InQuad) -- 381
			)) -- 381
			self.effects:burst( -- 383
				self:cellCenter(pos.row, pos.col), -- 383
				COLOR_ACCENT, -- 383
				8 -- 383
			) -- 383
			i = i + 1 -- 375
		end -- 375
	end -- 375
	if result.spawnedRow >= 0 then -- 375
		local spawned = self:createTile( -- 386
			result.spawnedRow, -- 386
			result.spawnedCol, -- 386
			board:get(result.spawnedRow, result.spawnedCol) -- 386
		) -- 386
		local ____self_tiles_4 = self.tiles -- 386
		____self_tiles_4[#____self_tiles_4 + 1] = spawned -- 387
		spawned.node.scaleX = 0 -- 388
		spawned.node.scaleY = 0 -- 389
		spawned.node:runAction(Scale(0.16, 0, 1, Ease.OutBack)) -- 390
	end -- 390
	self.animating = false -- 392
	self.animTime = 0 -- 393
end -- 368
function BoardView.prototype.updateAnimation(self, dt) -- 397
	if not self.animating then -- 397
		return false -- 399
	end -- 399
	self.animTime = self.animTime - dt -- 401
	if self.animTime <= 0 then -- 401
		return true -- 403
	end -- 403
	return false -- 405
end -- 397
return ____exports -- 397