-- [yue]: Control.yue
local _ENV = Dora(Dora.Platformer) -- 9
local require <const> = require -- 10
local tostring <const> = tostring -- 10
local pairs <const> = pairs -- 10
local Data <const> = Data -- 10
local Group <const> = Group -- 10
local Director <const> = Director -- 10
local AlignNode <const> = AlignNode -- 10
local Vec2 <const> = Vec2 -- 10
local math <const> = math -- 10
local App <const> = App -- 10
local HPWheel = require("UI.Control.HPWheel") -- 11
local LeftTouchPad = require("UI.View.LeftTouchPad") -- 12
local RightTouchPad = require("UI.View.RightTouchPad") -- 13
local RestartPad = require("UI.View.RestartPad") -- 14
local StartPanel = require("UI.Control.StartPanel") -- 15
local InputManager = require("InputManager") -- 16
local Trigger = InputManager.Trigger -- 18
local KeyBtnDown -- 20
KeyBtnDown = function(buttonName, keyName) -- 20
	return Trigger.Selector({ -- 22
		Trigger.ButtonDown(buttonName), -- 22
		Trigger.KeyDown(keyName) -- 23
	}) -- 21
end -- 20
local KeyBtnDownUp -- 26
KeyBtnDownUp = function(name, buttonName, keyName) -- 26
	return { -- 27
		[tostring(name) .. "Down"] = Trigger.Selector({ -- 28
			Trigger.ButtonDown(buttonName), -- 28
			Trigger.KeyDown(keyName) -- 29
		}), -- 27
		[tostring(name) .. "Up"] = Trigger.Selector({ -- 32
			Trigger.ButtonUp(buttonName), -- 32
			Trigger.KeyUp(keyName) -- 33
		}) -- 31
	} -- 26
end -- 26
local inputManager = InputManager.CreateManager({ -- 37
	Select = { -- 38
		Flandre = KeyBtnDown("dpleft", "A"), -- 38
		Villy = KeyBtnDown("dpdown", "S"), -- 39
		Dorothy = KeyBtnDown("dpright", "D") -- 40
	}, -- 37
	Control = (function() -- 42
		local _tab_0 = { -- 42
			Restart = KeyBtnDown("back", "Q") -- 42
		} -- 43
		local _obj_0 = KeyBtnDownUp("Left", "dpleft", "A") -- 43
		local _idx_0 = 1 -- 43
		for _key_0, _value_0 in pairs(_obj_0) do -- 43
			if _idx_0 == _key_0 then -- 43
				_tab_0[#_tab_0 + 1] = _value_0 -- 43
				_idx_0 = _idx_0 + 1 -- 43
			else -- 43
				_tab_0[_key_0] = _value_0 -- 43
			end -- 43
		end -- 43
		local _obj_1 = KeyBtnDownUp("Right", "dpright", "D") -- 44
		local _idx_1 = 1 -- 44
		for _key_0, _value_0 in pairs(_obj_1) do -- 44
			if _idx_1 == _key_0 then -- 44
				_tab_0[#_tab_0 + 1] = _value_0 -- 44
				_idx_1 = _idx_1 + 1 -- 44
			else -- 44
				_tab_0[_key_0] = _value_0 -- 44
			end -- 44
		end -- 44
		local _obj_2 = KeyBtnDownUp("Jump", "a", "K") -- 45
		local _idx_2 = 1 -- 45
		for _key_0, _value_0 in pairs(_obj_2) do -- 45
			if _idx_2 == _key_0 then -- 45
				_tab_0[#_tab_0 + 1] = _value_0 -- 45
				_idx_2 = _idx_2 + 1 -- 45
			else -- 45
				_tab_0[_key_0] = _value_0 -- 45
			end -- 45
		end -- 45
		local _obj_3 = KeyBtnDownUp("Attack", "b", "J") -- 46
		local _idx_3 = 1 -- 46
		for _key_0, _value_0 in pairs(_obj_3) do -- 46
			if _idx_3 == _key_0 then -- 46
				_tab_0[#_tab_0 + 1] = _value_0 -- 46
				_idx_3 = _idx_3 + 1 -- 46
			else -- 46
				_tab_0[_key_0] = _value_0 -- 46
			end -- 46
		end -- 46
		return _tab_0 -- 42
	end)() -- 41
}) -- 36
inputManager:pushContext("Control") -- 49
local Store = Data.store -- 51
local GroupPlayer = Store.GroupPlayer -- 52
local playerGroup = Group({ -- 54
	"hero", -- 54
	"unit" -- 54
}) -- 54
local updatePlayerControl -- 55
updatePlayerControl = function(key, flag) -- 55
	return playerGroup:each(function(self) -- 56
		if self.group == GroupPlayer then -- 56
			self.unit.data[key] = flag -- 56
		end -- 56
	end) -- 56
end -- 55
local showStartPanel -- 58
showStartPanel = function() -- 58
	return Director.ui:addChild((function() -- 59
		local _with_0 = AlignNode(true) -- 59
		_with_0:css('align-items: center; justify-content: center') -- 60
		_with_0:addChild((function() -- 61
			local align = AlignNode() -- 61
			align:css('width: 80%; height: 80%') -- 62
			align:addChild((function() -- 63
				local _with_1 = StartPanel() -- 63
				align:slot("AlignLayout", function(w, h) -- 64
					_with_1.position = Vec2(w / 2, h / 2) -- 65
					do -- 66
						local _tmp_0 = math.min(w / _with_1.node.width, h / _with_1.node.height) -- 66
						_with_1.scaleX = _tmp_0 -- 66
						_with_1.scaleY = _tmp_0 -- 66
					end -- 66
				end) -- 64
				return _with_1 -- 63
			end)()) -- 63
			return align -- 61
		end)()) -- 61
		return _with_0 -- 59
	end)()) -- 59
end -- 58
local inputNode -- 68
do -- 68
	local _with_0 = inputManager:getNode() -- 68
	_with_0:gslot("Input.LeftDown", function() -- 69
		return updatePlayerControl("keyLeft", true) -- 69
	end) -- 69
	_with_0:gslot("Input.LeftUp", function() -- 70
		return updatePlayerControl("keyLeft", false) -- 70
	end) -- 70
	_with_0:gslot("Input.RightDown", function() -- 71
		return updatePlayerControl("keyRight", true) -- 71
	end) -- 71
	_with_0:gslot("Input.RightUp", function() -- 72
		return updatePlayerControl("keyRight", false) -- 72
	end) -- 72
	_with_0:gslot("Input.JumpDown", function() -- 73
		return updatePlayerControl("keyUp", true) -- 73
	end) -- 73
	_with_0:gslot("Input.JumpUp", function() -- 74
		return updatePlayerControl("keyUp", false) -- 74
	end) -- 74
	_with_0:gslot("Input.AttackDown", function() -- 75
		return updatePlayerControl("keyF", true) -- 75
	end) -- 75
	_with_0:gslot("Input.AttackUp", function() -- 76
		return updatePlayerControl("keyF", false) -- 76
	end) -- 76
	_with_0:gslot("Input.Restart", function() -- 77
		Store.winner = -1 -- 78
		return showStartPanel() -- 79
	end) -- 77
	_with_0:gslot("InputManager.Select", function(on) -- 80
		if on then -- 80
			return inputManager:pushContext("Select") -- 81
		else -- 83
			return inputManager:popContext() -- 83
		end -- 80
	end) -- 80
	inputNode = _with_0 -- 68
end -- 68
local root = AlignNode(true) -- 85
root:css('flex-direction: column; justify-content: space-between') -- 86
root:addChild((function() -- 87
	local _with_0 = AlignNode() -- 87
	_with_0:css('width: 10; height: 10; margin-top: 50; margin-left: 60') -- 88
	_with_0:addChild(HPWheel()) -- 89
	return _with_0 -- 87
end)()) -- 87
root:addChild((function() -- 90
	local _with_0 = AlignNode() -- 90
	_with_0:css('margin: 0, 10, 40; height: 104; flex-direction: row; justify-content: space-between') -- 91
	local _exp_0 = App.platform -- 92
	if "iOS" == _exp_0 or "Android" == _exp_0 then -- 93
		_with_0:addChild((function() -- 94
			local _with_1 = AlignNode() -- 94
			_with_1:css('height: 104; width: 0') -- 95
			_with_1:addChild((function() -- 96
				local _with_2 = LeftTouchPad() -- 96
				_with_2:slot("KeyLeftUp", function() -- 97
					return inputManager:emitKeyUp("A") -- 97
				end) -- 97
				_with_2:slot("KeyLeftDown", function() -- 98
					return inputManager:emitKeyDown("A") -- 98
				end) -- 98
				_with_2:slot("KeyRightUp", function() -- 99
					return inputManager:emitKeyUp("D") -- 99
				end) -- 99
				_with_2:slot("KeyRightDown", function() -- 100
					return inputManager:emitKeyDown("D") -- 100
				end) -- 100
				return _with_2 -- 96
			end)()) -- 96
			return _with_1 -- 94
		end)()) -- 94
		_with_0:addChild((function() -- 101
			local _with_1 = AlignNode() -- 101
			_with_1:css('height: 104; width: 0') -- 102
			_with_1:addChild((function() -- 103
				local _with_2 = RightTouchPad() -- 103
				_with_2:slot("KeyFUp", function() -- 104
					return inputManager:emitKeyUp("J") -- 104
				end) -- 104
				_with_2:slot("KeyFDown", function() -- 105
					return inputManager:emitKeyDown("J") -- 105
				end) -- 105
				_with_2:slot("KeyUpUp", function() -- 106
					return inputManager:emitKeyUp("K") -- 106
				end) -- 106
				_with_2:slot("KeyUpDown", function() -- 107
					return inputManager:emitKeyDown("K") -- 107
				end) -- 107
				return _with_2 -- 103
			end)()) -- 103
			return _with_1 -- 101
		end)()) -- 101
	end -- 92
	return _with_0 -- 90
end)()) -- 90
root:addChild((function() -- 108
	local _with_0 = RestartPad() -- 108
	root:slot("AlignLayout", function(w, h) -- 109
		_with_0.position = Vec2(w - 10, h - 10) -- 110
	end) -- 109
	_with_0:slot("Tapped", function() -- 111
		Store.winner = -1 -- 112
		return showStartPanel() -- 113
	end) -- 111
	return _with_0 -- 108
end)()) -- 108
root:addTo(Director.ui) -- 114
showStartPanel() -- 115
return root -- 85
