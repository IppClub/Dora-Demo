-- [yue]: Dora-Demo/Loli War/Constant.yue
local _ENV = Dora(Dora.Platformer) -- 9
local Data <const> = Data -- 10
local _with_0 = Data.store -- 12
_with_0.GroupPlayer = 1 -- 13
_with_0.GroupPlayerBlock = 2 -- 14
_with_0.GroupPlayerPoke = 3 -- 15
_with_0.GroupEnemy = 4 -- 16
_with_0.GroupEnemyBlock = 5 -- 17
_with_0.GroupEnemyPoke = 6 -- 18
_with_0.GroupDisplay = 7 -- 19
_with_0.GroupTerrain = Data.groupTerrain -- 20
_with_0.GroupHide = Data.groupHide -- 21
_with_0.LayerBackground = 0 -- 23
_with_0.LayerBlock = 1 -- 24
_with_0.LayerSwitch = 2 -- 25
_with_0.LayerBunny = 3 -- 26
_with_0.LayerEnemyHero = 4 -- 27
_with_0.LayerPlayerHero = 5 -- 28
_with_0.LayerForeground = 6 -- 29
_with_0.LayerReadMe = 7 -- 30
_with_0.MaxBunnies = 6 -- 32
_with_0.MaxEP = 8.0 -- 33
_with_0.MaxHP = 8.0 -- 34
Data:setShouldContact(_with_0.GroupPlayerBlock, _with_0.GroupPlayerBlock, true) -- 36
Data:setShouldContact(_with_0.GroupEnemyBlock, _with_0.GroupEnemyBlock, true) -- 37
Data:setShouldContact(_with_0.GroupPlayerBlock, _with_0.GroupEnemyBlock, true) -- 38
Data:setShouldContact(_with_0.GroupEnemy, _with_0.GroupPlayerBlock, true) -- 40
Data:setShouldContact(_with_0.GroupPlayer, _with_0.GroupEnemyBlock, true) -- 41
Data:setShouldContact(_with_0.GroupPlayerPoke, _with_0.GroupEnemy, true) -- 43
Data:setShouldContact(_with_0.GroupPlayerPoke, _with_0.GroupEnemyBlock, true) -- 44
Data:setShouldContact(_with_0.GroupEnemyPoke, _with_0.GroupPlayer, true) -- 46
Data:setShouldContact(_with_0.GroupEnemyPoke, _with_0.GroupPlayerBlock, true) -- 47
Data:setShouldContact(_with_0.GroupEnemyPoke, _with_0.GroupPlayerPoke, true) -- 48
Data:setShouldContact(_with_0.GroupDisplay, _with_0.GroupDisplay, true) -- 50
Data:setRelation(_with_0.GroupPlayer, _with_0.GroupPlayerBlock, "Friend") -- 52
Data:setRelation(_with_0.GroupPlayer, _with_0.GroupPlayerPoke, "Friend") -- 53
Data:setRelation(_with_0.GroupEnemy, _with_0.GroupEnemyBlock, "Friend") -- 54
Data:setRelation(_with_0.GroupEnemy, _with_0.GroupEnemyPoke, "Friend") -- 55
Data:setRelation(_with_0.GroupPlayer, _with_0.GroupEnemy, "Enemy") -- 57
Data:setRelation(_with_0.GroupPlayer, _with_0.GroupEnemyBlock, "Enemy") -- 58
Data:setRelation(_with_0.GroupPlayer, _with_0.GroupEnemyPoke, "Enemy") -- 59
Data:setRelation(_with_0.GroupEnemy, _with_0.GroupPlayerBlock, "Enemy") -- 60
Data:setRelation(_with_0.GroupEnemy, _with_0.GroupPlayerPoke, "Enemy") -- 61
Data:setRelation(_with_0.GroupPlayerPoke, _with_0.GroupEnemyBlock, "Enemy") -- 63
Data:setRelation(_with_0.GroupEnemyPoke, _with_0.GroupPlayerBlock, "Enemy") -- 64
return _with_0 -- 12
