-- [yue]: Constant.yue
local _ENV = Dora(Dora.Platformer) -- 9
local Data <const> = Data -- 10
local _with_0 = Data.store -- 12
_with_0.PlayerLayer = 2 -- 13
_with_0.ZombieLayer = 1 -- 14
_with_0.TerrainLayer = 0 -- 15
_with_0.PlayerGroup = 1 -- 17
_with_0.ZombieGroup = 2 -- 18
Data:setRelation(_with_0.PlayerGroup, _with_0.ZombieGroup, "Enemy") -- 20
_with_0.MaxZombies = 50 -- 22
_with_0.ZombieWaveDelay = 0 -- 23
return _with_0 -- 12
