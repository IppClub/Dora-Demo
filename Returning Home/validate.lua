-- [ts]: validate.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Director = ____Dora.Director -- 1
local ____Data = require("src.Data") -- 2
local chapters = ____Data.chapters -- 2
local TILE_SIZE = ____Data.TILE_SIZE -- 2
local ____Game = require("src.Game") -- 3
local Patrol = ____Game.Patrol -- 3
local function count(chapter, token) -- 5
	local total = 0 -- 6
	for ____, row in ipairs(chapter.map) do -- 7
		do -- 7
			local i = 1 -- 8
			while i <= #row do -- 8
				if string.sub(row, i, i) == token then -- 8
					total = total + 1 -- 9
				end -- 9
				i = i + 1 -- 8
			end -- 8
		end -- 8
	end -- 8
	return total -- 12
end -- 5
local expectedSizes = {13, 15, 17} -- 15
local expectedGuards = {2, 3, 4} -- 16
local failures = 0 -- 17
do -- 17
	local i = 0 -- 18
	while i < #chapters do -- 18
		local chapter = chapters[i + 1] -- 19
		local size = expectedSizes[i + 1] -- 20
		local checks = { -- 21
			#chapter.map == size, -- 22
			__TS__ArrayEvery( -- 23
				chapter.map, -- 23
				function(____, row) return #row == size end -- 23
			), -- 23
			#chapter.guards == expectedGuards[i + 1], -- 24
			__TS__ArrayEvery( -- 25
				chapter.guards, -- 25
				function(____, guard) return #guard.route == 4 end -- 25
			), -- 25
			count(chapter, "S") == 1, -- 26
			count(chapter, "H") == 1, -- 27
			count(chapter, "E") == 1, -- 28
			count(chapter, "K") == 3, -- 29
			count(chapter, "C") == 3 -- 30
		} -- 30
		if not __TS__ArrayEvery( -- 30
			checks, -- 32
			function(____, value) return value end -- 32
		) then -- 32
			failures = failures + 1 -- 33
			print("VALIDATION_FAIL", i + 1, chapter.title) -- 34
		else -- 34
			print( -- 35
				"VALIDATION_OK", -- 35
				i + 1, -- 35
				chapter.title, -- 35
				(tostring(size) .. "x") .. tostring(size), -- 35
				tostring(expectedGuards[i + 1]) .. " guards" -- 35
			) -- 35
		end -- 35
		i = i + 1 -- 18
	end -- 18
end -- 18
print(failures == 0 and TILE_SIZE == 2 and "RETURNING_HOME_VALID" or "RETURNING_HOME_INVALID", failures) -- 37
local testChapter = { -- 39
	title = "stealth-test", -- 40
	introduction = "", -- 41
	spawn = {x = 4, z = 4}, -- 42
	map = { -- 43
		"#######", -- 44
		"#.....#", -- 45
		"#.....#", -- 46
		"#.....#", -- 47
		"#.....#", -- 48
		"#.....#", -- 49
		"#######" -- 50
	}, -- 50
	guards = {} -- 52
} -- 52
local guardData = { -- 54
	route = {{x = 4, z = 4}, {x = 6, z = 4}, {x = 6, z = 6}, {x = 4, z = 6}}, -- 55
	speed = 1, -- 56
	range = 5, -- 57
	halfAngle = 36, -- 58
	noticeSeconds = 1 -- 59
} -- 59
local function check(condition, name) -- 61
	if condition then -- 61
		print("STEALTH_OK", name) -- 62
	else -- 62
		failures = failures + 1 -- 64
		print("STEALTH_FAIL", name) -- 65
	end -- 65
end -- 61
local fastGuard = __TS__New(Patrol, guardData) -- 69
local quietGuard = __TS__New(Patrol, guardData) -- 70
fastGuard:update( -- 71
	0.2, -- 71
	0.2, -- 71
	{x = 4, z = 6}, -- 71
	true, -- 71
	false, -- 71
	false, -- 71
	testChapter -- 71
) -- 71
quietGuard:update( -- 72
	0.2, -- 72
	0.2, -- 72
	{x = 4, z = 6}, -- 72
	true, -- 72
	true, -- 72
	false, -- 72
	testChapter -- 72
) -- 72
check(fastGuard.state == "chase" and quietGuard.state == "chase", "quiet-keeps-real-vision-range") -- 73
check(fastGuard.suspicion > quietGuard.suspicion, "fast-exposure-exceeds-quiet") -- 74
local bellGuard = __TS__New(Patrol, guardData) -- 76
bellGuard.suspicion = 0.4 -- 77
check( -- 78
	bellGuard:hearBell({x = 8, z = 4}, 0) and bellGuard.suspicion >= 0.4, -- 78
	"bell-preserves-suspicion" -- 78
) -- 78
do -- 78
	local step = 1 -- 79
	while step <= 25 do -- 79
		bellGuard:update( -- 79
			0.1, -- 79
			step * 0.1, -- 79
			{x = 0, z = 0}, -- 79
			false, -- 79
			false, -- 79
			true, -- 79
			testChapter -- 79
		) -- 79
		step = step + 1 -- 79
	end -- 79
end -- 79
check(bellGuard.position.x > 4.2, "bell-causes-real-investigation-movement") -- 80
bellGuard.state = "chase" -- 81
check( -- 82
	not bellGuard:hearBell({x = 2, z = 2}, 3), -- 82
	"bell-cannot-break-active-chase" -- 82
) -- 82
local footstepGuard = __TS__New(Patrol, guardData) -- 84
check( -- 85
	footstepGuard:hearFootstep({x = 6, z = 4}, 0) and footstepGuard.state == "investigate", -- 85
	"footstep-starts-investigation" -- 85
) -- 85
do -- 85
	local step = 1 -- 86
	while step <= 30 do -- 86
		footstepGuard:update( -- 86
			0.1, -- 86
			step * 0.1, -- 86
			{x = 0, z = 0}, -- 86
			false, -- 86
			false, -- 86
			true, -- 86
			testChapter -- 86
		) -- 86
		step = step + 1 -- 86
	end -- 86
end -- 86
check(footstepGuard.state == "search", "investigation-transitions-to-search") -- 87
do -- 87
	local step = 31 -- 88
	while step <= 60 do -- 88
		footstepGuard:update( -- 88
			0.1, -- 88
			step * 0.1, -- 88
			{x = 0, z = 0}, -- 88
			false, -- 88
			false, -- 88
			true, -- 88
			testChapter -- 88
		) -- 88
		step = step + 1 -- 88
	end -- 88
end -- 88
check(footstepGuard.state == "patrol", "search-returns-to-patrol") -- 89
local pursuitGuard = __TS__New(Patrol, guardData) -- 91
pursuitGuard:update( -- 92
	0.1, -- 92
	0.1, -- 92
	{x = 4, z = 6}, -- 92
	true, -- 92
	false, -- 92
	false, -- 92
	testChapter -- 92
) -- 92
do -- 92
	local step = 2 -- 93
	while step <= 34 do -- 93
		pursuitGuard:update( -- 93
			0.1, -- 93
			step * 0.1, -- 93
			{x = 10, z = 10}, -- 93
			false, -- 93
			false, -- 93
			true, -- 93
			testChapter -- 93
		) -- 93
		step = step + 1 -- 93
	end -- 93
end -- 93
check(pursuitGuard.state == "search", "lost-sight-pursuit-keeps-last-seen-point") -- 94
local decayGuard = __TS__New(Patrol, guardData) -- 96
decayGuard.suspicion = 0.5 -- 97
decayGuard:update( -- 98
	0.2, -- 98
	0.2, -- 98
	{x = 0, z = 0}, -- 98
	false, -- 98
	false, -- 98
	true, -- 98
	testChapter -- 98
) -- 98
check( -- 99
	math.abs(decayGuard.suspicion - 0.43) < 0.001, -- 99
	"hidden-suspicion-decays-at-0.35-per-second" -- 99
) -- 99
local baseAlertGuard = __TS__New(Patrol, guardData) -- 101
local raisedAlertGuard = __TS__New(Patrol, guardData) -- 102
raisedAlertGuard:setSealAlert(2) -- 103
baseAlertGuard:hearBell({x = 8, z = 4}, 0) -- 104
raisedAlertGuard:hearBell({x = 8, z = 4}, 0) -- 105
do -- 105
	local step = 1 -- 106
	while step <= 18 do -- 106
		baseAlertGuard:update( -- 107
			0.1, -- 107
			step * 0.1, -- 107
			{x = 0, z = 0}, -- 107
			false, -- 107
			false, -- 107
			true, -- 107
			testChapter -- 107
		) -- 107
		raisedAlertGuard:update( -- 108
			0.1, -- 108
			step * 0.1, -- 108
			{x = 0, z = 0}, -- 108
			false, -- 108
			false, -- 108
			true, -- 108
			testChapter -- 108
		) -- 108
		step = step + 1 -- 106
	end -- 106
end -- 106
check(raisedAlertGuard.position.x > baseAlertGuard.position.x, "second-seal-raises-guard-speed") -- 110
check( -- 111
	raisedAlertGuard:hearDoor({x = 6, z = 6}, 2) and raisedAlertGuard.state == "investigate", -- 111
	"door-sound-starts-investigation" -- 111
) -- 111
local baseSearchGuard = __TS__New(Patrol, guardData) -- 113
local raisedSearchGuard = __TS__New(Patrol, guardData) -- 114
raisedSearchGuard:setSealAlert(2) -- 115
baseSearchGuard:hearFootstep({x = 4, z = 4}, 0) -- 116
raisedSearchGuard:hearFootstep({x = 4, z = 4}, 0) -- 117
do -- 117
	local step = 1 -- 118
	while step <= 25 do -- 118
		baseSearchGuard:update( -- 119
			0.1, -- 119
			step * 0.1, -- 119
			{x = 0, z = 0}, -- 119
			false, -- 119
			false, -- 119
			true, -- 119
			testChapter -- 119
		) -- 119
		raisedSearchGuard:update( -- 120
			0.1, -- 120
			step * 0.1, -- 120
			{x = 0, z = 0}, -- 120
			false, -- 120
			false, -- 120
			true, -- 120
			testChapter -- 120
		) -- 120
		step = step + 1 -- 118
	end -- 118
end -- 118
check(baseSearchGuard.state == "patrol" and raisedSearchGuard.state == "search", "second-seal-extends-search-time") -- 122
Director.entry.scene:removeAllChildren() -- 124
print(failures == 0 and "STEALTH_LOOP_VALID" or "STEALTH_LOOP_INVALID", failures) -- 125
return ____exports -- 125