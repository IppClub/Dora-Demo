-- [yue]: init.yue
local _ENV = Dora -- 9
local Path <const> = Path -- 10
local Content <const> = Content -- 10
local require <const> = require -- 10
local scriptPath = Path:getScriptPath(...) -- 12
if scriptPath then -- 12
	Content:insertSearchPath(1, scriptPath) -- 13
	local _list_0 = { -- 15
		"Constant", -- 15
		"Bullet", -- 16
		"Unit", -- 17
		"AI", -- 18
		"Action", -- 19
		"Logic", -- 20
		"Control", -- 21
		"Scene" -- 22
	} -- 14
	for _index_0 = 1, #_list_0 do -- 14
		local mod = _list_0[_index_0] -- 14
		require(Path(scriptPath, mod)) -- 14
	end -- 14
end -- 12
