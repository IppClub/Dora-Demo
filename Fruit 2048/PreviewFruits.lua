-- [ts]: PreviewFruits.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 10
local Director = ____Dora.Director -- 10
local Node = ____Dora.Node -- 10
local View = ____Dora.View -- 10
local ____FruitBoard = require("Game.FruitBoard") -- 11
local DIR_LEFT = ____FruitBoard.DIR_LEFT -- 11
local ____FruitGame = require("Game.FruitGame") -- 12
local COLS = ____FruitGame.COLS -- 12
local FruitGame = ____FruitGame.FruitGame -- 12
local ROWS = ____FruitGame.ROWS -- 12
local game = __TS__New(FruitGame, Director.entry) -- 14
game:layout(View.size.width, View.size.height) -- 15
local values = {} -- 17
do -- 17
	local i = 0 -- 18
	while i < ROWS * COLS do -- 18
		values[#values + 1] = 0 -- 19
		i = i + 1 -- 18
	end -- 18
end -- 18
values[0 * COLS + 0 + 1] = 2 -- 21
values[0 * COLS + 1 + 1] = 4 -- 22
values[0 * COLS + 2 + 1] = 8 -- 23
values[0 * COLS + 3 + 1] = 16 -- 24
values[1 * COLS + 0 + 1] = 32 -- 25
values[1 * COLS + 1 + 1] = 64 -- 26
values[1 * COLS + 2 + 1] = 128 -- 27
values[1 * COLS + 3 + 1] = 256 -- 28
values[2 * COLS + 0 + 1] = 512 -- 29
values[2 * COLS + 1 + 1] = 1024 -- 30
values[2 * COLS + 2 + 1] = 1024 -- 31
values[3 * COLS + 0 + 1] = 2 -- 32
values[3 * COLS + 1 + 1] = 4 -- 33
game:setBoard(values) -- 34
local elapsed = 0 -- 36
local moved = false -- 37
local loop = Node() -- 38
loop:addTo(Director.entry) -- 39
loop:schedule(function(dt) -- 40
	elapsed = elapsed + dt -- 41
	local size = View.size -- 42
	if size.width ~= game.viewWidth or size.height ~= game.viewHeight then -- 42
		game:layout(size.width, size.height) -- 44
	end -- 44
	game:update(dt) -- 46
	if not moved and elapsed > 0.7 then -- 46
		moved = true -- 48
		game:requestMove(DIR_LEFT) -- 49
	end -- 49
	return false -- 51
end) -- 40
return ____exports -- 40