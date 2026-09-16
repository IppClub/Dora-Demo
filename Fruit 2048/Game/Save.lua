-- [ts]: Save.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 5
local Content = ____Dora.Content -- 5
--- 默认存档文件名。
local BEST_FILE = "fruit2048_best.txt" -- 8
--- 拼接目录与文件名，兼容不同风格的路径分隔符。
function ____exports.joinPath(dir, name) -- 11
	if #dir == 0 then -- 11
		return name -- 13
	end -- 13
	local last = __TS__StringCharAt(dir, #dir - 1) -- 15
	if last == "/" or last == "\\" then -- 15
		return dir .. name -- 17
	end -- 17
	return (dir .. "/") .. name -- 19
end -- 11
--- 解析存档文本为分数，遇到非数字或过长内容时安全退出。
function ____exports.parseScore(text) -- 23
	local value = 0 -- 24
	local digits = 0 -- 25
	do -- 25
		local i = 0 -- 26
		while i < #text do -- 26
			local code = __TS__StringCharCodeAt(text, i) -- 27
			if code >= 48 and code <= 57 then -- 27
				value = value * 10 + (code - 48) -- 29
				digits = digits + 1 -- 30
				if digits > 9 then -- 30
					break -- 32
				end -- 32
			elseif digits > 0 then -- 32
				break -- 35
			end -- 35
			i = i + 1 -- 26
		end -- 26
	end -- 26
	return value -- 38
end -- 23
--- 最高分存储：优先落盘，失败时仅保留在内存。
____exports.BestScoreStore = __TS__Class() -- 42
local BestScoreStore = ____exports.BestScoreStore -- 42
BestScoreStore.name = "BestScoreStore" -- 42
function BestScoreStore.prototype.____constructor(self, fileName) -- 48
	local name = fileName and fileName or BEST_FILE -- 49
	self.path = ____exports.joinPath(Content.writablePath, name) -- 50
	self.best = 0 -- 51
	self.persisted = true -- 52
	self:load() -- 53
end -- 48
function BestScoreStore.prototype.load(self) -- 57
	if not Content:exist(self.path) then -- 57
		return self.best -- 59
	end -- 59
	local text = Content:load(self.path) -- 61
	if text == nil then -- 61
		return self.best -- 63
	end -- 63
	local value = ____exports.parseScore(text) -- 65
	if value > self.best then -- 65
		self.best = value -- 67
	end -- 67
	return self.best -- 69
end -- 57
function BestScoreStore.prototype.submit(self, score) -- 73
	if score <= self.best then -- 73
		return false -- 75
	end -- 75
	self.best = score -- 77
	self:save() -- 78
	return true -- 79
end -- 73
function BestScoreStore.prototype.save(self) -- 83
	local ok = Content:save( -- 84
		self.path, -- 84
		"" .. tostring(self.best) -- 84
	) -- 84
	if not ok then -- 84
		self.persisted = false -- 86
	end -- 86
	return ok -- 88
end -- 83
return ____exports -- 83