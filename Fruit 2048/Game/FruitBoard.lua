-- [ts]: FruitBoard.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
--- 方向常量：向上（行号增大）。
____exports.DIR_UP = 0 -- 7
--- 方向常量：向右（列号增大）。
____exports.DIR_RIGHT = 1 -- 9
--- 方向常量：向下（行号减小）。
____exports.DIR_DOWN = 2 -- 11
--- 方向常量：向左（列号减小）。
____exports.DIR_LEFT = 3 -- 13
--- 11 级水果数值：tier 0 → 2，tier 10 → 2048。
____exports.TILE_VALUES = { -- 16
	2, -- 16
	4, -- 16
	8, -- 16
	16, -- 16
	32, -- 16
	64, -- 16
	128, -- 16
	256, -- 16
	512, -- 16
	1024, -- 16
	2048 -- 16
} -- 16
--- 达成「大榴莲」所需数值。
____exports.DURIAN_VALUE = 2048 -- 19
--- 棋盘状态与规则实现。
____exports.FruitBoard = __TS__Class() -- 55
local FruitBoard = ____exports.FruitBoard -- 55
FruitBoard.name = "FruitBoard" -- 55
function FruitBoard.prototype.____constructor(self, rows, cols, seed) -- 69
	self.rows = rows -- 70
	self.cols = cols -- 71
	self.score = 0 -- 72
	self.reachedDurian = false -- 73
	self.cells = {} -- 74
	local total = rows * cols -- 75
	do -- 75
		local i = 0 -- 76
		while i < total do -- 76
			local ____self_cells_0 = self.cells -- 76
			____self_cells_0[#____self_cells_0 + 1] = 0 -- 77
			i = i + 1 -- 76
		end -- 76
	end -- 76
	self.rngState = seed and seed or 20480816 -- 79
end -- 69
function FruitBoard.prototype.nextRandom(self) -- 83
	local state = self.rngState * 16807 % 2147483647 -- 84
	if state <= 0 then -- 84
		state = state + 2147483646 -- 86
	end -- 86
	self.rngState = state -- 88
	return (state - 1) / 2147483646 -- 89
end -- 83
function FruitBoard.prototype.load(self, values) -- 93
	local total = self.rows * self.cols -- 94
	do -- 94
		local i = 0 -- 95
		while i < total do -- 95
			self.cells[i + 1] = i < #values and values[i + 1] or 0 -- 96
			i = i + 1 -- 95
		end -- 95
	end -- 95
end -- 93
function FruitBoard.prototype.clearAll(self) -- 101
	local total = self.rows * self.cols -- 102
	do -- 102
		local i = 0 -- 103
		while i < total do -- 103
			self.cells[i + 1] = 0 -- 104
			i = i + 1 -- 103
		end -- 103
	end -- 103
	self.score = 0 -- 106
	self.reachedDurian = false -- 107
end -- 101
function FruitBoard.prototype.reset(self, initialTiles) -- 111
	self:clearAll() -- 112
	do -- 112
		local i = 0 -- 113
		while i < initialTiles do -- 113
			self:spawnTile() -- 114
			i = i + 1 -- 113
		end -- 113
	end -- 113
end -- 111
function FruitBoard.prototype.get(self, row, col) -- 118
	return self.cells[row * self.cols + col + 1] -- 119
end -- 118
function FruitBoard.prototype.set(self, row, col, value) -- 122
	self.cells[row * self.cols + col + 1] = value -- 123
end -- 122
function FruitBoard.prototype.isInside(self, row, col) -- 126
	return row >= 0 and row < self.rows and col >= 0 and col < self.cols -- 127
end -- 126
function FruitBoard.prototype.emptyPositions(self) -- 131
	local result = {} -- 132
	do -- 132
		local row = 0 -- 133
		while row < self.rows do -- 133
			do -- 133
				local col = 0 -- 134
				while col < self.cols do -- 134
					if self:get(row, col) == 0 then -- 134
						result[#result + 1] = {row = row, col = col} -- 136
					end -- 136
					col = col + 1 -- 134
				end -- 134
			end -- 134
			row = row + 1 -- 133
		end -- 133
	end -- 133
	return result -- 140
end -- 131
function FruitBoard.prototype.emptyCount(self) -- 143
	local count = 0 -- 144
	do -- 144
		local i = 0 -- 145
		while i < #self.cells do -- 145
			if self.cells[i + 1] == 0 then -- 145
				count = count + 1 -- 147
			end -- 147
			i = i + 1 -- 145
		end -- 145
	end -- 145
	return count -- 150
end -- 143
function FruitBoard.prototype.tileCount(self) -- 153
	return self.rows * self.cols - self:emptyCount() -- 154
end -- 153
function FruitBoard.prototype.maxValue(self) -- 157
	local best = 0 -- 158
	do -- 158
		local i = 0 -- 159
		while i < #self.cells do -- 159
			if self.cells[i + 1] > best then -- 159
				best = self.cells[i + 1] -- 161
			end -- 161
			i = i + 1 -- 159
		end -- 159
	end -- 159
	return best -- 164
end -- 157
function FruitBoard.prototype.spawnTile(self) -- 168
	local empties = self:emptyPositions() -- 169
	if #empties == 0 then -- 169
		return false -- 171
	end -- 171
	local picked = self:pickIndex(#empties) -- 173
	local value = self:nextRandom() < 0.9 and 2 or 4 -- 174
	self:set(empties[picked + 1].row, empties[picked + 1].col, value) -- 175
	return true -- 176
end -- 168
function FruitBoard.prototype.pickIndex(self, count) -- 180
	local index = math.floor(self:nextRandom() * count) -- 181
	if index < 0 then -- 181
		index = 0 -- 183
	end -- 183
	if index > count - 1 then -- 183
		index = count - 1 -- 186
	end -- 186
	return index -- 188
end -- 180
function FruitBoard.prototype.lineCell(self, dir, line, step) -- 192
	if dir == ____exports.DIR_LEFT then -- 192
		return {row = line, col = step} -- 194
	end -- 194
	if dir == ____exports.DIR_RIGHT then -- 194
		return {row = line, col = self.cols - 1 - step} -- 197
	end -- 197
	if dir == ____exports.DIR_DOWN then -- 197
		return {row = step, col = line} -- 200
	end -- 200
	return {row = self.rows - 1 - step, col = line} -- 202
end -- 192
function FruitBoard.prototype.move(self, dir) -- 206
	local result = { -- 207
		changed = false, -- 208
		moves = {}, -- 209
		mergedCells = {}, -- 210
		gainedScore = 0, -- 211
		spawnedRow = -1, -- 212
		spawnedCol = -1, -- 213
		spawnedValue = 0 -- 214
	} -- 214
	local total = self.rows * self.cols -- 216
	local next = {} -- 217
	do -- 217
		local i = 0 -- 218
		while i < total do -- 218
			next[#next + 1] = 0 -- 219
			i = i + 1 -- 218
		end -- 218
	end -- 218
	local horizontal = dir == ____exports.DIR_LEFT or dir == ____exports.DIR_RIGHT -- 222
	local lineCount = horizontal and self.rows or self.cols -- 223
	local lineSize = horizontal and self.cols or self.rows -- 224
	do -- 224
		local line = 0 -- 226
		while line < lineCount do -- 226
			local srcRows = {} -- 227
			local srcCols = {} -- 228
			local srcValues = {} -- 229
			do -- 229
				local step = 0 -- 230
				while step < lineSize do -- 230
					local pos = self:lineCell(dir, line, step) -- 231
					local value = self:get(pos.row, pos.col) -- 232
					if value ~= 0 then -- 232
						srcRows[#srcRows + 1] = pos.row -- 234
						srcCols[#srcCols + 1] = pos.col -- 235
						srcValues[#srcValues + 1] = value -- 236
					end -- 236
					step = step + 1 -- 230
				end -- 230
			end -- 230
			local outStep = 0 -- 239
			local i = 0 -- 240
			while i < #srcValues do -- 240
				local target = self:lineCell(dir, line, outStep) -- 242
				local sameNext = i + 1 < #srcValues and srcValues[i + 1] == srcValues[i + 1 + 1] -- 243
				if sameNext then -- 243
					local merged = srcValues[i + 1] * 2 -- 245
					next[target.row * self.cols + target.col + 1] = merged -- 246
					local ____result_moves_1 = result.moves -- 246
					____result_moves_1[#____result_moves_1 + 1] = { -- 247
						fromRow = srcRows[i + 1], -- 248
						fromCol = srcCols[i + 1], -- 249
						toRow = target.row, -- 250
						toCol = target.col, -- 251
						value = srcValues[i + 1], -- 252
						merged = true -- 253
					} -- 253
					local ____result_moves_2 = result.moves -- 253
					____result_moves_2[#____result_moves_2 + 1] = { -- 255
						fromRow = srcRows[i + 1 + 1], -- 256
						fromCol = srcCols[i + 1 + 1], -- 257
						toRow = target.row, -- 258
						toCol = target.col, -- 259
						value = srcValues[i + 1 + 1], -- 260
						merged = true -- 261
					} -- 261
					local ____result_mergedCells_3 = result.mergedCells -- 261
					____result_mergedCells_3[#____result_mergedCells_3 + 1] = {row = target.row, col = target.col} -- 263
					result.gainedScore = result.gainedScore + merged -- 264
					i = i + 2 -- 265
				else -- 265
					next[target.row * self.cols + target.col + 1] = srcValues[i + 1] -- 267
					local ____result_moves_4 = result.moves -- 267
					____result_moves_4[#____result_moves_4 + 1] = { -- 268
						fromRow = srcRows[i + 1], -- 269
						fromCol = srcCols[i + 1], -- 270
						toRow = target.row, -- 271
						toCol = target.col, -- 272
						value = srcValues[i + 1], -- 273
						merged = false -- 274
					} -- 274
					i = i + 1 -- 276
				end -- 276
				outStep = outStep + 1 -- 278
			end -- 278
			line = line + 1 -- 226
		end -- 226
	end -- 226
	do -- 226
		local i = 0 -- 282
		while i < total do -- 282
			if next[i + 1] ~= self.cells[i + 1] then -- 282
				result.changed = true -- 284
				break -- 285
			end -- 285
			i = i + 1 -- 282
		end -- 282
	end -- 282
	if not result.changed then -- 282
		result.moves = {} -- 289
		result.mergedCells = {} -- 290
		result.gainedScore = 0 -- 291
		return result -- 292
	end -- 292
	do -- 292
		local i = 0 -- 295
		while i < total do -- 295
			self.cells[i + 1] = next[i + 1] -- 296
			i = i + 1 -- 295
		end -- 295
	end -- 295
	self.score = self.score + result.gainedScore -- 298
	local empties = self:emptyPositions() -- 300
	if #empties > 0 then -- 300
		local picked = self:pickIndex(#empties) -- 302
		local value = self:nextRandom() < 0.9 and 2 or 4 -- 303
		local pos = empties[picked + 1] -- 304
		self:set(pos.row, pos.col, value) -- 305
		result.spawnedRow = pos.row -- 306
		result.spawnedCol = pos.col -- 307
		result.spawnedValue = value -- 308
	end -- 308
	if not self.reachedDurian and self:maxValue() >= ____exports.DURIAN_VALUE then -- 308
		self.reachedDurian = true -- 312
	end -- 312
	return result -- 314
end -- 206
function FruitBoard.prototype.hasMoves(self) -- 318
	if self:emptyCount() > 0 then -- 318
		return true -- 320
	end -- 320
	do -- 320
		local row = 0 -- 322
		while row < self.rows do -- 322
			do -- 322
				local col = 0 -- 323
				while col < self.cols do -- 323
					local value = self:get(row, col) -- 324
					if col + 1 < self.cols and self:get(row, col + 1) == value then -- 324
						return true -- 326
					end -- 326
					if row + 1 < self.rows and self:get(row + 1, col) == value then -- 326
						return true -- 329
					end -- 329
					col = col + 1 -- 323
				end -- 323
			end -- 323
			row = row + 1 -- 322
		end -- 322
	end -- 322
	return false -- 333
end -- 318
function FruitBoard.prototype.isGameOver(self) -- 337
	return not self:hasMoves() -- 338
end -- 337
function FruitBoard.prototype.toFlatString(self) -- 342
	local text = "" -- 343
	do -- 343
		local i = 0 -- 344
		while i < #self.cells do -- 344
			if i > 0 then -- 344
				text = text .. "," -- 346
			end -- 346
			text = text .. tostring(self.cells[i + 1]) -- 348
			i = i + 1 -- 344
		end -- 344
	end -- 344
	return text -- 350
end -- 342
return ____exports -- 342