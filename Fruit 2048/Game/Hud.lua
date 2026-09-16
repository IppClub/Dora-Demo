-- [ts]: Hud.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 1
local DrawNode = ____Dora.DrawNode -- 1
local Label = ____Dora.Label -- 1
local Node = ____Dora.Node -- 1
local Size = ____Dora.Size -- 1
local Vec2 = ____Dora.Vec2 -- 1
local ____FreshArt = require("Game.FreshArt") -- 2
local roundedRect = ____FreshArt.roundedRect -- 2
local ____Theme = require("Game.Theme") -- 3
local COLOR_ACCENT = ____Theme.COLOR_ACCENT -- 4
local COLOR_TEXT = ____Theme.COLOR_TEXT -- 4
local COLOR_TEXT_MUTED = ____Theme.COLOR_TEXT_MUTED -- 4
local FONT_NAME = ____Theme.FONT_NAME -- 4
local HUD_LABEL_SIZE = ____Theme.HUD_LABEL_SIZE -- 5
local HUD_VALUE_SIZE = ____Theme.HUD_VALUE_SIZE -- 5
local SCREEN_MARGIN = ____Theme.SCREEN_MARGIN -- 5
local TITLE_SIZE = ____Theme.TITLE_SIZE -- 5
local Z_HUD = ____Theme.Z_HUD -- 5
--- Scene-owned controls work in the native player and Web exports.
____exports.Hud = __TS__Class() -- 9
local Hud = ____exports.Hud -- 9
Hud.name = "Hud" -- 9
function Hud.prototype.____constructor(self, parent) -- 22
	self.root = Node() -- 23
	self.root.order = Z_HUD -- 24
	self.root:addTo(parent) -- 25
	self.backdrop = DrawNode() -- 26
	self.backdrop.order = -1 -- 27
	self.backdrop:addTo(self.root) -- 28
	self.titleLabel = self:makeLabel( -- 29
		"水果 2048", -- 29
		TITLE_SIZE, -- 29
		COLOR_ACCENT, -- 29
		Vec2(0, 0.5) -- 29
	) -- 29
	self.goalLabel = self:makeLabel( -- 30
		"目标：合成大榴莲", -- 30
		HUD_LABEL_SIZE, -- 30
		COLOR_TEXT_MUTED, -- 30
		Vec2(0, 0.5) -- 30
	) -- 30
	self.scoreLabel = self:makeLabel( -- 31
		"分数", -- 31
		HUD_LABEL_SIZE, -- 31
		COLOR_TEXT_MUTED, -- 31
		Vec2(0.5, 0.5) -- 31
	) -- 31
	self.scoreValueLabel = self:makeLabel( -- 32
		"0", -- 32
		HUD_VALUE_SIZE, -- 32
		COLOR_TEXT, -- 32
		Vec2(0.5, 0.5) -- 32
	) -- 32
	self.bestLabel = self:makeLabel( -- 33
		"最高分", -- 33
		HUD_LABEL_SIZE, -- 33
		COLOR_TEXT_MUTED, -- 33
		Vec2(0.5, 0.5) -- 33
	) -- 33
	self.bestValueLabel = self:makeLabel( -- 34
		"0", -- 34
		HUD_VALUE_SIZE, -- 34
		COLOR_TEXT, -- 34
		Vec2(0.5, 0.5) -- 34
	) -- 34
	self.hintLabel = self:makeLabel( -- 35
		"滑动棋盘，合成水果", -- 35
		HUD_LABEL_SIZE, -- 35
		COLOR_TEXT_MUTED, -- 35
		Vec2(0.5, 0.5) -- 35
	) -- 35
	self.restartButton = Node() -- 36
	self.restartButton.size = Size(168, 44) -- 37
	self.restartButton.swallowTouches = true -- 38
	self.restartButton:addTo(self.root) -- 39
	local face = DrawNode() -- 40
	roundedRect( -- 41
		face, -- 41
		84, -- 41
		20, -- 41
		168, -- 41
		44, -- 41
		15, -- 41
		Color(55, 102, 78, 40) -- 41
	) -- 41
	roundedRect( -- 42
		face, -- 42
		84, -- 42
		22, -- 42
		168, -- 42
		44, -- 42
		15, -- 42
		Color(82, 135, 107, 255) -- 42
	) -- 42
	face:addTo(self.restartButton) -- 43
	local label = self:makeLabel( -- 44
		"重新开始", -- 44
		17, -- 44
		Color(255, 254, 245, 255), -- 44
		Vec2(0.5, 0.5) -- 44
	) -- 44
	if label then -- 44
		label:removeFromParent(false) -- 46
		label.position = Vec2(84, 22) -- 47
		label:addTo(self.restartButton) -- 48
	end -- 48
	self.restartButton:onTapped(function() -- 50
		if self.onRestart then -- 50
			self.onRestart() -- 50
		end -- 50
	end) -- 50
end -- 22
function Hud.prototype.makeLabel(self, text, size, color, anchor) -- 53
	local label = Label(FONT_NAME, size * 3, false) -- 54
	if not label then -- 54
		return nil -- 55
	end -- 55
	local ____temp_0 = 1 / 3 -- 56
	label.scaleY = ____temp_0 -- 56
	label.scaleX = ____temp_0 -- 56
	label.text = text -- 57
	label.color = color -- 58
	label.anchor = anchor -- 59
	label.order = Z_HUD -- 60
	label:addTo(self.root) -- 61
	return label -- 62
end -- 53
function Hud.prototype.layout(self, viewWidth, viewHeight, boardBottomY) -- 65
	local halfWidth = viewWidth / 2 -- 66
	local halfHeight = viewHeight / 2 -- 67
	local topY = halfHeight - SCREEN_MARGIN -- 68
	if self.titleLabel then -- 68
		self.titleLabel.position = Vec2(-halfWidth + SCREEN_MARGIN, topY - TITLE_SIZE * 0.6) -- 69
	end -- 69
	if self.goalLabel then -- 69
		self.goalLabel.position = Vec2(-halfWidth + SCREEN_MARGIN, topY - TITLE_SIZE * 1.5) -- 70
	end -- 70
	local chipWidth = 144 -- 71
	local chipHeight = 56 -- 72
	local centerY = topY - 76 - chipHeight / 2 -- 73
	self.backdrop:clear() -- 74
	for ____, centerX in ipairs({-78, 78}) do -- 75
		roundedRect( -- 76
			self.backdrop, -- 76
			centerX, -- 76
			centerY - 2, -- 76
			chipWidth, -- 76
			chipHeight, -- 76
			12, -- 76
			Color(174, 197, 166, 65) -- 76
		) -- 76
		roundedRect( -- 77
			self.backdrop, -- 77
			centerX, -- 77
			centerY, -- 77
			chipWidth, -- 77
			chipHeight, -- 77
			12, -- 77
			Color(255, 253, 247, 255) -- 77
		) -- 77
	end -- 77
	if self.scoreLabel then -- 77
		self.scoreLabel.position = Vec2(-78, centerY + 13) -- 79
	end -- 79
	if self.scoreValueLabel then -- 79
		self.scoreValueLabel.position = Vec2(-78, centerY - 11) -- 80
	end -- 80
	if self.bestLabel then -- 80
		self.bestLabel.position = Vec2(78, centerY + 13) -- 81
	end -- 81
	if self.bestValueLabel then -- 81
		self.bestValueLabel.position = Vec2(78, centerY - 11) -- 82
	end -- 82
	if self.hintLabel then -- 82
		self.hintLabel.position = Vec2(0, boardBottomY - 16) -- 83
	end -- 83
	self.restartButton.position = Vec2(0, -halfHeight + 50) -- 84
end -- 65
function Hud.prototype.setScore(self, score) -- 87
	if self.scoreValueLabel then -- 87
		self.scoreValueLabel.text = "" .. tostring(score) -- 88
	end -- 88
end -- 87
function Hud.prototype.setBest(self, best, persisted) -- 91
	if self.bestValueLabel then -- 91
		self.bestValueLabel.text = persisted and "" .. tostring(best) or tostring(best) .. "*" -- 92
	end -- 92
end -- 91
function Hud.prototype.setHint(self, text) -- 95
	if self.hintLabel then -- 95
		self.hintLabel.text = text -- 96
	end -- 96
end -- 95
return ____exports -- 95