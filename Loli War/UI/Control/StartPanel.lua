-- [yue]: UI/Control/StartPanel.yue
local _module_0 = nil -- 1
local _ENV = Dora(Dora.Platformer) -- 9
local require <const> = require -- 10
local Class <const> = Class -- 10
local Audio <const> = Audio -- 10
local emit <const> = emit -- 10
local App <const> = App -- 10
local Mouse <const> = Mouse -- 10
local Vec2 <const> = Vec2 -- 10
local ipairs <const> = ipairs -- 10
local Rect <const> = Rect -- 10
local StartPanel = require("UI.View.StartPanel") -- 11
local _anon_func_0 = function(button, self) -- 21
	if self.fButton == button then -- 22
		return "Flandre" -- 22
	elseif self.vButton == button then -- 23
		return "Villy" -- 23
	elseif self.dButton == button then -- 24
		return "Dorothy" -- 24
	end -- 21
end -- 21
_module_0 = Class(StartPanel, { -- 14
	__init = function(self) -- 14
		local buttons = { -- 15
			self.fButton, -- 15
			self.vButton, -- 15
			self.dButton -- 15
		} -- 15
		for _index_0 = 1, #buttons do -- 16
			local button = buttons[_index_0] -- 16
			button:slot("Tapped", function() -- 17
				Audio:play("Audio/choose.wav") -- 18
				for _index_1 = 1, #buttons do -- 19
					local btn = buttons[_index_1] -- 19
					btn.touchEnabled = false -- 20
				end -- 19
				return emit("PlayerSelect", _anon_func_0(button, self)) -- 21
			end) -- 17
		end -- 16
		self:slot("Enter", function() -- 25
			return emit("InputManager.Select", true) -- 25
		end) -- 25
		self:slot("Exit", function() -- 26
			return emit("InputManager.Select", false) -- 26
		end) -- 26
		self.node:schedule(function() -- 27
			local bw, bh -- 28
			do -- 28
				local _obj_0 = App.bufferSize -- 28
				bw, bh = _obj_0.width, _obj_0.height -- 28
			end -- 28
			local vw = App.visualSize.width -- 29
			local pos = Mouse.position * (bw / vw) -- 30
			pos = Vec2(pos.x - bw / 2, bh / 2 - pos.y) -- 31
			for _, button in ipairs(buttons) do -- 32
				local localPos = button:convertToNodeSpace(pos) -- 33
				if Rect(Vec2.zero, button.size):containsPoint(localPos) then -- 34
					button:glow() -- 35
				else -- 37
					button:stopGlow() -- 37
				end -- 34
			end -- 32
		end) -- 27
		self.node:slot("PanelHide", function() -- 38
			return self:removeFromParent() -- 38
		end) -- 38
		self.node:gslot("Input.Flandre", function() -- 39
			if self.fButton.touchEnabled then -- 39
				return self.fButton:emit("Tapped") -- 39
			end -- 39
		end) -- 39
		self.node:gslot("Input.Dorothy", function() -- 40
			if self.dButton.touchEnabled then -- 40
				return self.dButton:emit("Tapped") -- 40
			end -- 40
		end) -- 40
		return self.node:gslot("Input.Villy", function() -- 41
			if self.vButton.touchEnabled then -- 41
				return self.vButton:emit("Tapped") -- 41
			end -- 41
		end) -- 41
	end -- 14
}) -- 13
return _module_0 -- 1
