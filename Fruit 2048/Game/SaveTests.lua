-- [ts]: SaveTests.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 6
local Content = ____Dora.Content -- 6
local ____Save = require("Game.Save") -- 7
local BestScoreStore = ____Save.BestScoreStore -- 7
local joinPath = ____Save.joinPath -- 7
local parseScore = ____Save.parseScore -- 7
--- 探针文件名（测试结束后会删除）。
local PROBE_FILE = "fruit2048_save_test.txt" -- 10
function ____exports.runTests() -- 12
	local failures = {} -- 13
	local checks = 0 -- 14
	local function check(condition, message) -- 16
		checks = checks + 1 -- 17
		if not condition and #failures < 12 then -- 17
			failures[#failures + 1] = message -- 19
		end -- 19
	end -- 16
	check( -- 23
		parseScore("2048") == 2048, -- 23
		"S8 parseScore 应解析纯数字" -- 23
	) -- 23
	check( -- 24
		parseScore("") == 0, -- 24
		"S8 parseScore 空串应返回 0" -- 24
	) -- 24
	check( -- 25
		parseScore("oops") == 0, -- 25
		"S8 parseScore 非数字应返回 0" -- 25
	) -- 25
	check( -- 26
		parseScore("12345xyz") == 12345, -- 26
		"S8 parseScore 应在前缀数字后停止" -- 26
	) -- 26
	local probePath = joinPath(Content.writablePath, PROBE_FILE) -- 28
	if Content:exist(probePath) then -- 28
		Content:remove(probePath) -- 30
	end -- 30
	local store = __TS__New(BestScoreStore, PROBE_FILE) -- 33
	check(store.best == 0, "S8 无存档时最高分应为 0") -- 34
	check( -- 35
		store:submit(1234), -- 35
		"S8 首次提交应刷新最高分" -- 35
	) -- 35
	check(store.persisted, "S8 首次提交应写盘成功") -- 36
	local reloaded = __TS__New(BestScoreStore, PROBE_FILE) -- 38
	check(reloaded.best == 1234, "S8 重新读取应得到 1234") -- 39
	local lowered = __TS__New(BestScoreStore, PROBE_FILE) -- 41
	check( -- 42
		not lowered:submit(1000), -- 42
		"S8 更低分数不应刷新最高分" -- 42
	) -- 42
	check(lowered.best == 1234, "S8 更低分数不应覆盖磁盘值") -- 43
	local pathWithSlash = joinPath("a/b/", "c.txt") -- 45
	local pathWithoutSlash = joinPath("a/b", "c.txt") -- 46
	check(pathWithSlash == "a/b/c.txt", "S8 joinPath 应处理带分隔符的目录") -- 47
	check(pathWithoutSlash == "a/b/c.txt", "S8 joinPath 应自动补分隔符") -- 48
	if Content:exist(probePath) then -- 48
		Content:remove(probePath) -- 51
	end -- 51
	local cleaned = __TS__New(BestScoreStore, PROBE_FILE) -- 53
	check(cleaned.best == 0, "S8 删除存档后应回到 0") -- 54
	local lines = {} -- 56
	lines[#lines + 1] = #failures == 0 and "passed" or "failed" -- 57
	lines[#lines + 1] = (("checks=" .. tostring(checks)) .. " failures=") .. tostring(#failures) -- 58
	do -- 58
		local i = 0 -- 59
		while i < #failures do -- 59
			lines[#lines + 1] = "FAIL " .. failures[i + 1] -- 60
			i = i + 1 -- 59
		end -- 59
	end -- 59
	return table.concat(lines, "\n") -- 62
end -- 12
return ____exports -- 12