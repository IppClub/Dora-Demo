-- [yue]: Dora-Demo/Zombie Escape/init.yue
local _ENV = Dora -- 11
local Path <const> = Path -- 12
local Content <const> = Content -- 12
local require <const> = require -- 12
local scriptPath = Path:getScriptPath(...) -- 14
if scriptPath then -- 14
	Content:insertSearchPath(1, scriptPath) -- 15
	local _list_0 = { -- 17
		"Constant", -- 17
		"Unit", -- 18
		"Body", -- 19
		"Bullet", -- 20
		"Action", -- 21
		"AI", -- 22
		"Logic", -- 23
		"Control", -- 24
		"Scene", -- 25
		"Debug" -- 26
	} -- 16
	for _index_0 = 1, #_list_0 do -- 16
		local mod = _list_0[_index_0] -- 16
		require(Path(scriptPath, mod)) -- 16
	end -- 16
end -- 14
