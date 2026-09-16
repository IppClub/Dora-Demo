-- [ts]: Effects.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 6
local Color = ____Dora.Color -- 6
local DrawNode = ____Dora.DrawNode -- 6
local Ease = ____Dora.Ease -- 6
local Label = ____Dora.Label -- 6
local Move = ____Dora.Move -- 6
local Node = ____Dora.Node -- 6
local Opacity = ____Dora.Opacity -- 6
local Sequence = ____Dora.Sequence -- 6
local Spawn = ____Dora.Spawn -- 6
local Vec2 = ____Dora.Vec2 -- 6
local ____Theme = require("Game.Theme") -- 7
local COLOR_SCRIM = ____Theme.COLOR_SCRIM -- 7
local FONT_NAME = ____Theme.FONT_NAME -- 7
local Z_EFFECT = ____Theme.Z_EFFECT -- 7
local Z_OVERLAY = ____Theme.Z_OVERLAY -- 7
--- 粒子数量上限：超出后丢弃新粒子，保证帧率与画面可读性。
local MAX_PARTICLES = 240 -- 30
--- 自绘特效层。
____exports.EffectsLayer = __TS__Class() -- 33
local EffectsLayer = ____exports.EffectsLayer -- 33
EffectsLayer.name = "EffectsLayer" -- 33
function EffectsLayer.prototype.____constructor(self, localParent, overlayParent) -- 51
	self.root = Node() -- 52
	self.root.order = Z_EFFECT -- 53
	self.root:addTo(localParent) -- 54
	self.canvas = DrawNode() -- 56
	self.canvas.order = Z_EFFECT -- 57
	self.canvas:addTo(self.root) -- 58
	self.overlay = Node() -- 60
	self.overlay.order = Z_OVERLAY -- 61
	self.overlay:addTo(overlayParent) -- 62
	self.scrim = DrawNode() -- 64
	self.scrim.visible = false -- 65
	self.scrim:addTo(self.overlay) -- 66
	self.flashNode = DrawNode() -- 68
	self.flashNode.opacity = 0 -- 69
	self.flashNode:addTo(self.overlay) -- 70
	self.particles = {} -- 72
	self.transients = {} -- 73
	self.viewWidth = 0 -- 74
	self.viewHeight = 0 -- 75
	self.particleDirty = true -- 76
	self.jitterSeed = 9781 -- 77
end -- 51
function EffectsLayer.prototype.drawFullRect(self, node, color) -- 81
	node:clear() -- 82
	local halfW = self.viewWidth / 2 -- 83
	local halfH = self.viewHeight / 2 -- 84
	node:drawPolygon( -- 85
		{ -- 85
			Vec2(-halfW, -halfH), -- 86
			Vec2(halfW, -halfH), -- 87
			Vec2(halfW, halfH), -- 88
			Vec2(-halfW, halfH) -- 89
		}, -- 89
		color -- 90
	) -- 90
end -- 81
function EffectsLayer.prototype.layout(self, viewWidth, viewHeight) -- 94
	self.viewWidth = viewWidth -- 95
	self.viewHeight = viewHeight -- 96
	self:drawFullRect(self.scrim, COLOR_SCRIM) -- 97
	self:drawFullRect( -- 98
		self.flashNode, -- 98
		Color(255, 212, 138, 255) -- 98
	) -- 98
end -- 94
function EffectsLayer.prototype.nextJitter(self) -- 102
	self.jitterSeed = self.jitterSeed * 16807 % 2147483647 -- 103
	return (self.jitterSeed % 1000 / 1000 - 0.5) * 0.5 -- 104
end -- 102
function EffectsLayer.prototype.addParticle(self, particle) -- 107
	if #self.particles >= MAX_PARTICLES then -- 107
		return -- 109
	end -- 109
	local ____self_particles_0 = self.particles -- 109
	____self_particles_0[#____self_particles_0 + 1] = particle -- 111
	self.particleDirty = true -- 112
end -- 107
function EffectsLayer.prototype.burst(self, at, color, count) -- 116
	do -- 116
		local i = 0 -- 117
		while i < count do -- 117
			local angle = i / count * math.pi * 2 + self:nextJitter() -- 118
			local speed = 110 + i % 4 * 26 -- 119
			self:addParticle({ -- 120
				x = at.x, -- 121
				y = at.y, -- 122
				vx = math.cos(angle) * speed, -- 123
				vy = math.sin(angle) * speed * 0.9, -- 124
				life = 0.42, -- 125
				maxLife = 0.42, -- 126
				size = 3 + i % 3, -- 127
				gravity = 240, -- 128
				drag = 1.8, -- 129
				color = color -- 130
			}) -- 130
			i = i + 1 -- 117
		end -- 117
	end -- 117
end -- 116
function EffectsLayer.prototype.ringBurst(self, at, color, count) -- 136
	do -- 136
		local i = 0 -- 137
		while i < count do -- 137
			local angle = i / count * math.pi * 2 + self:nextJitter() * 0.6 -- 138
			local speed = 250 + i % 6 * 45 -- 139
			self:addParticle({ -- 140
				x = at.x, -- 141
				y = at.y, -- 142
				vx = math.cos(angle) * speed, -- 143
				vy = math.sin(angle) * speed, -- 144
				life = 0.9, -- 145
				maxLife = 0.9, -- 146
				size = 4 + i % 3, -- 147
				gravity = 150, -- 148
				drag = 0.9, -- 149
				color = color -- 150
			}) -- 150
			i = i + 1 -- 137
		end -- 137
	end -- 137
end -- 136
function EffectsLayer.prototype.floatText(self, at, text, color, size) -- 156
	local label = Label(FONT_NAME, size) -- 157
	if not label then -- 157
		return -- 159
	end -- 159
	label.text = text -- 161
	label.color = color -- 162
	label.order = Z_EFFECT -- 163
	label.position = Vec2(at.x, at.y) -- 164
	label:addTo(self.root) -- 165
	label:runAction(Spawn( -- 166
		Move( -- 167
			0.55, -- 167
			Vec2(at.x, at.y), -- 167
			Vec2(at.x, at.y + 44), -- 167
			Ease.OutCubic -- 167
		), -- 167
		Opacity(0.55, 1, 0) -- 168
	)) -- 168
	local ____self_transients_1 = self.transients -- 168
	____self_transients_1[#____self_transients_1 + 1] = {node = label, ttl = 0.6} -- 170
end -- 156
function EffectsLayer.prototype.flash(self, color) -- 174
	self:drawFullRect(self.flashNode, color) -- 175
	self.flashNode:runAction(Sequence( -- 176
		Opacity(0.12, 0, 0.72, Ease.OutQuad), -- 177
		Opacity(0.55, 0.72, 0, Ease.InQuad) -- 178
	)) -- 178
end -- 174
function EffectsLayer.prototype.setScrimVisible(self, visible) -- 183
	self.scrim.visible = visible -- 184
end -- 183
function EffectsLayer.prototype.redrawParticles(self) -- 188
	self.canvas:clear() -- 189
	do -- 189
		local i = 0 -- 190
		while i < #self.particles do -- 190
			local particle = self.particles[i + 1] -- 191
			local t = particle.life / particle.maxLife -- 192
			local radius = particle.size * (0.45 + t * 0.75) -- 193
			local alpha = math.floor(255 * t) -- 194
			local color = Color(particle.color.r, particle.color.g, particle.color.b, alpha) -- 195
			self.canvas:drawDot( -- 196
				Vec2(particle.x, particle.y), -- 196
				radius, -- 196
				color -- 196
			) -- 196
			i = i + 1 -- 190
		end -- 190
	end -- 190
	self.particleDirty = false -- 198
end -- 188
function EffectsLayer.prototype.update(self, dt) -- 202
	local active = false -- 203
	do -- 203
		local i = #self.particles - 1 -- 204
		while i >= 0 do -- 204
			do -- 204
				local particle = self.particles[i + 1] -- 205
				particle.life = particle.life - dt -- 206
				if particle.life <= 0 then -- 206
					__TS__ArraySplice(self.particles, i, 1) -- 208
					self.particleDirty = true -- 209
					goto __continue23 -- 210
				end -- 210
				local drag = 1 - particle.drag * dt -- 212
				particle.vx = particle.vx * drag -- 213
				particle.vy = particle.vy * drag -- 214
				particle.vy = particle.vy - particle.gravity * dt -- 215
				particle.x = particle.x + particle.vx * dt -- 216
				particle.y = particle.y + particle.vy * dt -- 217
				active = true -- 218
			end -- 218
			::__continue23:: -- 218
			i = i - 1 -- 204
		end -- 204
	end -- 204
	if #self.particles > 0 or self.particleDirty then -- 204
		self:redrawParticles() -- 221
	end -- 221
	do -- 221
		local i = #self.transients - 1 -- 223
		while i >= 0 do -- 223
			local transient = self.transients[i + 1] -- 224
			transient.ttl = transient.ttl - dt -- 225
			if transient.ttl <= 0 then -- 225
				transient.node:removeFromParent() -- 227
				__TS__ArraySplice(self.transients, i, 1) -- 228
			else -- 228
				active = true -- 230
			end -- 230
			i = i - 1 -- 223
		end -- 223
	end -- 223
	return active -- 233
end -- 202
return ____exports -- 202