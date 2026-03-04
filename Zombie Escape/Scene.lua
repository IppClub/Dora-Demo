-- [yue]: Scene.yue
local _ENV = Dora(Dora.Platformer) -- 9
local Rectangle = require("UI.View.Shape.Rectangle") -- 10
local Data <const> = Data -- 11
local PlatformWorld <const> = PlatformWorld -- 11
local Vec2 <const> = Vec2 -- 11
local View <const> = View -- 11
local BodyDef <const> = BodyDef -- 11
local Color <const> = Color -- 11
local App <const> = App -- 11
local Body <const> = Body -- 11
local Entity <const> = Entity -- 11
local Size <const> = Size -- 11
local Store = Data.store -- 13
local PlayerLayer, PlayerGroup, ZombieLayer, TerrainLayer = Store.PlayerLayer, Store.PlayerGroup, Store.ZombieLayer, Store.TerrainLayer -- 14
local DesignWidth <const> = 1280 -- 21
local world -- 23
do -- 23
	local _with_0 = PlatformWorld() -- 23
	_with_0:getLayer(PlayerLayer).renderGroup = true -- 24
	_with_0:getLayer(ZombieLayer).renderGroup = true -- 25
	_with_0:getLayer(TerrainLayer).renderGroup = true -- 26
	_with_0.camera.followRatio = Vec2(0.01, 0.01) -- 27
	_with_0.camera.zoom = View.size.width / DesignWidth -- 28
	_with_0:onAppChange(function(settingName) -- 29
		if settingName == "Size" then -- 29
			_with_0.camera.zoom = View.size.width / DesignWidth -- 30
		end -- 29
	end) -- 29
	world = _with_0 -- 23
end -- 23
Store.world = world -- 31
local terrainDef -- 33
do -- 33
	local _with_0 = BodyDef() -- 33
	_with_0.type = "Static" -- 34
	_with_0:attachPolygon(Vec2(0, -500), 2500, 10, 0, 1, 1, 0) -- 35
	_with_0:attachPolygon(Vec2(0, 500), 2500, 10, 0, 1, 1, 0) -- 36
	_with_0:attachPolygon(Vec2(1250, 0), 10, 1000, 0, 1, 1, 0) -- 37
	_with_0:attachPolygon(Vec2(-1250, 0), 10, 1000, 0, 1, 1, 0) -- 38
	terrainDef = _with_0 -- 33
end -- 33
local fillColor = Color(App.themeColor:toColor3(), 0x66):toARGB() -- 40
local borderColor = App.themeColor:toARGB() -- 41
do -- 43
	local _with_0 = Body(terrainDef, world, Vec2.zero) -- 43
	_with_0.order = TerrainLayer -- 44
	_with_0.group = Data.groupTerrain -- 45
	_with_0:addChild(Rectangle({ -- 47
		y = -500, -- 47
		width = 2500, -- 48
		height = 10, -- 49
		fillColor = fillColor, -- 50
		borderColor = borderColor, -- 51
		fillOrder = 1, -- 52
		lineOrder = 2 -- 53
	})) -- 46
	_with_0:addChild(Rectangle({ -- 56
		x = 1250, -- 56
		y = 0, -- 57
		width = 10, -- 58
		height = 1000, -- 59
		fillColor = fillColor, -- 60
		borderColor = borderColor, -- 61
		fillOrder = 1, -- 62
		lineOrder = 2 -- 63
	})) -- 55
	_with_0:addChild(Rectangle({ -- 66
		x = -1250, -- 66
		y = 0, -- 67
		width = 10, -- 68
		height = 1000, -- 69
		fillColor = fillColor, -- 70
		borderColor = borderColor, -- 71
		fillOrder = 1, -- 72
		lineOrder = 2 -- 73
	})) -- 65
	_with_0:addTo(world) -- 75
end -- 43
Entity({ -- 78
	obstacleDef = "Body_ObstacleS", -- 78
	size = Size(100, 60), -- 79
	position = Vec2(100, -464), -- 80
	color = borderColor -- 81
}) -- 77
Entity({ -- 84
	obstacleDef = "Body_ObstacleM", -- 84
	size = Size(260, 60), -- 85
	position = Vec2(-400, -464), -- 86
	color = borderColor -- 87
}) -- 83
Entity({ -- 90
	obstacleDef = "Body_ObstacleS", -- 90
	size = Size(100, 60), -- 91
	position = Vec2(-400, -404), -- 92
	color = borderColor -- 93
}) -- 89
Entity({ -- 96
	obstacleDef = "Body_ObstacleC", -- 96
	size = 40, -- 97
	position = Vec2(400, -464), -- 98
	color = 0xff6666 -- 99
}) -- 95
Entity({ -- 102
	unitDef = "Unit_KidM", -- 102
	order = PlayerLayer, -- 103
	position = Vec2(-50, -430), -- 104
	group = PlayerGroup, -- 105
	faceRight = false, -- 106
	player = true -- 107
}) -- 101
return Entity({ -- 110
	unitDef = "Unit_KidW", -- 110
	order = PlayerLayer, -- 111
	position = Vec2(0, -430), -- 112
	group = PlayerGroup, -- 113
	faceRight = true, -- 114
	player = true -- 115
}) -- 109
