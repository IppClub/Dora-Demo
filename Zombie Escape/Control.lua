-- [yue]: Dora-Demo/Zombie Escape/Control.yue
local _ENV = Dora(Dora.Platformer) -- 9
local CircleButton = require("UI.Control.Basic.CircleButton") -- 10
local Data <const> = Data -- 11
local Group <const> = Group -- 11
local AlignNode <const> = AlignNode -- 11
local Menu <const> = Menu -- 11
local Vec2 <const> = Vec2 -- 11
local Size <const> = Size -- 11
local math <const> = math -- 11
local Director <const> = Director -- 11
local Keyboard <const> = Keyboard -- 11
local Node <const> = Node -- 11
local Store = Data.store -- 13
Store.controlPlayer = "KidW" -- 15
local playerGroup = Group({ -- 16
	"player" -- 16
}) -- 16
local updatePlayerControl -- 17
updatePlayerControl = function(key, flag) -- 17
	local player = playerGroup:find(function(self) -- 18
		return self.unit.tag == Store.controlPlayer -- 18
	end) -- 18
	if player then -- 18
		player.unit.data[key] = flag -- 19
	end -- 18
end -- 17
do -- 21
	local _with_0 = AlignNode(true) -- 21
	_with_0:css('flex-direction: column-reverse') -- 22
	_with_0.visible = false -- 23
	_with_0:addChild((function() -- 24
		local _with_1 = AlignNode() -- 24
		_with_1:css("\n			width: auto;\n			height: 60;\n			margin: 0, 20, 40;\n			flex-direction: row;\n			justify-content: space-between\n		") -- 25
		_with_1:addChild((function() -- 32
			local _with_2 = AlignNode() -- 32
			_with_2:css('height: 60; width: 0') -- 33
			_with_2:addChild((function() -- 34
				local _with_3 = Menu() -- 34
				_with_3.anchor = Vec2.zero -- 35
				_with_3.size = Size(130, 60) -- 36
				_with_3:addChild((function() -- 37
					local _with_4 = CircleButton({ -- 38
						text = "Left", -- 38
						radius = 60, -- 39
						fontSize = math.floor(36) -- 40
					}) -- 37
					_with_4.scaleX = 0.5 -- 42
					_with_4.scaleY = 0.5 -- 42
					_with_4.anchor = Vec2.zero -- 43
					_with_4:slot("TapBegan", function() -- 44
						return updatePlayerControl("keyLeft", true) -- 44
					end) -- 44
					_with_4:slot("TapEnded", function() -- 45
						return updatePlayerControl("keyLeft", false) -- 45
					end) -- 45
					return _with_4 -- 37
				end)()) -- 37
				_with_3:addChild((function() -- 46
					local _with_4 = CircleButton({ -- 47
						text = "Right", -- 47
						x = 70, -- 48
						radius = 60, -- 49
						fontSize = math.floor(36) -- 50
					}) -- 46
					_with_4.scaleX = 0.5 -- 52
					_with_4.scaleY = 0.5 -- 52
					_with_4.anchor = Vec2.zero -- 53
					_with_4:slot("TapBegan", function() -- 54
						return updatePlayerControl("keyRight", true) -- 54
					end) -- 54
					_with_4:slot("TapEnded", function() -- 55
						return updatePlayerControl("keyRight", false) -- 55
					end) -- 55
					return _with_4 -- 46
				end)()) -- 46
				return _with_3 -- 34
			end)()) -- 34
			return _with_2 -- 32
		end)()) -- 32
		_with_1:addChild((function() -- 56
			local _with_2 = AlignNode() -- 56
			_with_2:css('height: 60; width: 0') -- 57
			_with_2:addChild((function() -- 58
				local _with_3 = Menu() -- 58
				_with_3.anchor = Vec2(1, 0) -- 59
				_with_3.size = Size(130, 60) -- 60
				_with_3:addChild((function() -- 61
					local _with_4 = CircleButton({ -- 62
						text = "Jump", -- 62
						radius = 60, -- 63
						fontSize = math.floor(36) -- 64
					}) -- 61
					_with_4.scaleX = 0.5 -- 66
					_with_4.scaleY = 0.5 -- 66
					_with_4.anchor = Vec2.zero -- 67
					_with_4:slot("TapBegan", function() -- 68
						return updatePlayerControl("keyUp", true) -- 68
					end) -- 68
					_with_4:slot("TapEnded", function() -- 69
						return updatePlayerControl("keyUp", false) -- 69
					end) -- 69
					return _with_4 -- 61
				end)()) -- 61
				_with_3:addChild((function() -- 70
					local _with_4 = CircleButton({ -- 71
						text = "Shoot", -- 71
						x = 70, -- 72
						radius = 60, -- 73
						fontSize = math.floor(36) -- 74
					}) -- 70
					_with_4.scaleX = 0.5 -- 76
					_with_4.scaleY = 0.5 -- 76
					_with_4.anchor = Vec2.zero -- 77
					_with_4:slot("TapBegan", function() -- 78
						return updatePlayerControl("keyShoot", true) -- 78
					end) -- 78
					_with_4:slot("TapEnded", function() -- 79
						return updatePlayerControl("keyShoot", false) -- 79
					end) -- 79
					return _with_4 -- 70
				end)()) -- 70
				return _with_3 -- 58
			end)()) -- 58
			return _with_2 -- 56
		end)()) -- 56
		return _with_1 -- 24
	end)()) -- 24
	_with_0:addTo((function() -- 80
		local _with_1 = Director.ui -- 80
		_with_1.renderGroup = true -- 81
		return _with_1 -- 80
	end)()) -- 80
end -- 21
Store.keyboardEnabled = false -- 83
local keyboardControl -- 84
keyboardControl = function() -- 84
	if not Store.keyboardEnabled then -- 85
		return -- 85
	end -- 85
	updatePlayerControl("keyLeft", Keyboard:isKeyPressed("A")) -- 86
	updatePlayerControl("keyRight", Keyboard:isKeyPressed("D")) -- 87
	updatePlayerControl("keyUp", Keyboard:isKeyPressed("K")) -- 88
	return updatePlayerControl("keyShoot", Keyboard:isKeyPressed("J")) -- 89
end -- 84
local _with_0 = Node() -- 91
_with_0:schedule(keyboardControl) -- 92
return _with_0 -- 91
