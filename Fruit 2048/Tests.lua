-- Run with this project as the search path: dora cli run -p "Fruit 2048" --entry Tests.lua
local suites = {"Game.GameTests", "Game.SaveTests", "Game.SceneTests"}
for _, name in ipairs(suites) do
	local report = require(name).runTests()
	print(name .. "\n" .. report)
	assert(report:match("^passed"), name .. " failed")
end
print("FRUIT_2048_TESTS_PASSED")
