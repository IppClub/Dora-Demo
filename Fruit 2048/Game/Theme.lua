-- [ts]: Theme.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 1
--- 全局字体：引擎内置更纱黑体（含中文字形）。
____exports.FONT_NAME = "sarasa-mono-sc-regular" -- 4
--- 屏幕边距（像素）。
____exports.SCREEN_MARGIN = 16 -- 7
--- 顶部 HUD 预留高度（像素）。
____exports.HUD_HEIGHT = 180 -- 9
--- 棋盘格子之间的缝隙（像素）。
____exports.CELL_GAP = 6 -- 11
--- 棋盘外框内边距（像素）。
____exports.PANEL_PADDING = 10 -- 13
--- 层级：背景。
____exports.Z_BACKGROUND = 0 -- 16
--- 层级：棋盘底板。
____exports.Z_PANEL = 10 -- 18
--- 层级：格子槽位。
____exports.Z_SLOT = 20 -- 20
--- 层级：水果瓦片。
____exports.Z_TILE = 30 -- 22
--- 层级：粒子/飘分等特效。
____exports.Z_EFFECT = 40 -- 24
--- 层级：HUD 文本与分数。
____exports.Z_HUD = 50 -- 26
--- 层级：终局遮罩与庆祝。
____exports.Z_OVERLAY = 60 -- 28
--- 主色：柔和的叶绿色。
____exports.COLOR_ACCENT = Color(68, 125, 91, 255) -- 31
--- 背景顶部色。
____exports.COLOR_BG_TOP = Color(248, 249, 239, 255) -- 33
--- 背景底部色。
____exports.COLOR_BG_BOTTOM = Color(248, 249, 239, 255) -- 35
--- 棋盘底板色。
____exports.COLOR_PANEL = Color(218, 231, 213, 255) -- 37
--- 格子槽位色。
____exports.COLOR_SLOT = Color(233, 240, 225, 255) -- 39
--- 主文本色。
____exports.COLOR_TEXT = Color(53, 82, 61, 255) -- 41
--- 次文本色。
____exports.COLOR_TEXT_MUTED = Color(126, 146, 123, 255) -- 43
--- 遮罩色（半透明黑）。
____exports.COLOR_SCRIM = Color(0, 0, 0, 170) -- 45
--- 标题字号。
____exports.TITLE_SIZE = 28 -- 48
--- HUD 小标签字号。
____exports.HUD_LABEL_SIZE = 14 -- 50
--- HUD 数值字号。
____exports.HUD_VALUE_SIZE = 30 -- 52
return ____exports -- 52