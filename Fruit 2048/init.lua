-- [ts]: init.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Director = ____Dora.Director -- 1
local Node = ____Dora.Node -- 1
local View = ____Dora.View -- 1
local tolua = ____Dora.tolua -- 1
local ____FruitGame = require("Game.FruitGame") -- 2
local FruitGame = ____FruitGame.FruitGame -- 2
local game = __TS__New(FruitGame, Director.entry) -- 4
local lastWidth = 0 -- 5
local lastHeight = 0 -- 6
local function layout() -- 9
	local size = View.size -- 10
	local scale = math.min(size.width / 360, size.height / 640) -- 11
	local camera = tolua.cast(Director.currentCamera, "Camera2D") -- 12
	if camera then -- 12
		camera.zoom = scale -- 13
	end -- 13
	game:layout(size.width / scale, size.height / scale) -- 14
	lastWidth = size.width -- 15
	lastHeight = size.height -- 16
end -- 9
layout() -- 19
local loop = Node() -- 20
loop:addTo(Director.entry) -- 21
loop:schedule(function(dt) -- 22
	if View.size.width ~= lastWidth or View.size.height ~= lastHeight then -- 22
		layout() -- 23
	end -- 23
	game:update(dt) -- 24
	return false -- 25
end) -- 22
return ____exports -- 22