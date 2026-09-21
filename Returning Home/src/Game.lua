local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__New = ____lualib.__TS__New
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local ____exports = {}
local ____Dora = require("Dora")
local App = ____Dora.App
local Audio = ____Dora.Audio
local Camera3D = ____Dora.Camera3D
local Color = ____Dora.Color
local Color3 = ____Dora.Color3
local Content = ____Dora.Content
local Controller = ____Dora.Controller
local DirectionalLight3D = ____Dora.DirectionalLight3D
local Director = ____Dora.Director
local DrawNode = ____Dora.DrawNode
local json = ____Dora.json
local Keyboard = ____Dora.Keyboard
local Label = ____Dora.Label
local Model3D = ____Dora.Model3D
local Node = ____Dora.Node
local Node3D = ____Dora.Node3D
local PointLight3D = ____Dora.PointLight3D
local Size = ____Dora.Size
local Sprite = ____Dora.Sprite
local Surface3D = ____Dora.Surface3D
local Vec2 = ____Dora.Vec2
local Vec3 = ____Dora.Vec3
local View = ____Dora.View
local ____Data = require("src.Data")
local chapters = ____Data.chapters
local TILE_SIZE = ____Data.TILE_SIZE
local MODEL = "Assets/Model/"
local UNITY = "Assets/Unity/Assets/ReturningHome30/"
local AUDIO = UNITY .. "Audio/"
local FONT = UNITY .. "Resources/ReturningHome30Chinese.ttf"
local FULL_FONT = FONT
local SAVE_FILE = Content.writablePath .. "/returning-home-30-save.json"
local PLAYER_RADIUS = 0.4
local SCREEN_HALF_WIDTH = 0.22 * 0.8 * 0.5
local SCREEN_HALF_LENGTH = 1.6 * 0.8 * 0.5
local FAST_FOOTSTEP_INTERVAL = 0.5
local FAST_HEARING_RADIUS = 5
local QUIET_HEARING_RADIUS = 1.3
local BELL_HEARING_RADIUS = 9.5
local BELL_COOLDOWN = 10
local function clamp(value, minimum, maximum)
	return math.max(
		minimum,
		math.min(maximum, value)
	)
end
local function distance(a, b)
	local x = a.x - b.x
	local z = a.z - b.z
	return math.sqrt(x * x + z * z)
end
local function normalize(x, z)
	local length = math.sqrt(x * x + z * z)
	return length > 0.0001 and ({x = x / length, z = z / length}) or ({x = 0, z = 0})
end
local function drawRing(draw, radius, width, color)
	local segments = 28
	do
		local index = 0
		while index < segments do
			local first = index * math.pi * 2 / segments
			local second = (index + 1) * math.pi * 2 / segments
			draw:drawSegment(
				Vec2(
					math.cos(first) * radius,
					math.sin(first) * radius
				),
				Vec2(
					math.cos(second) * radius,
					math.sin(second) * radius
				),
				width,
				color
			)
			index = index + 1
		end
	end
end
local function tileAt(chapter, x, z)
	local row = math.floor(z / TILE_SIZE + 0.5)
	local column = math.floor(x / TILE_SIZE + 0.5)
	if row < 0 or row >= #chapter.map then
		return "#"
	end
	if column < 0 or column >= #chapter.map[row + 1] then
		return "#"
	end
	return string.sub(chapter.map[row + 1], column + 1, column + 1)
end
local function blocked(chapter, x, z, padding)
	if padding == nil then
		padding = 0
	end
	if tileAt(chapter, x, z) == "#" then
		return true
	end
	local centerRow = math.floor(z / TILE_SIZE + 0.5)
	local centerColumn = math.floor(x / TILE_SIZE + 0.5)
	do
		local row = centerRow - 1
		while row <= centerRow + 1 do
			do
				if row < 0 or row >= #chapter.map then
					goto __continue14
				end
				do
					local column = centerColumn - 1
					while column <= centerColumn + 1 do
						do
							if column < 0 or column >= #chapter.map[row + 1] then
								goto __continue17
							end
							if string.sub(chapter.map[row + 1], column + 1, column + 1) ~= "T" then
								goto __continue17
							end
							if math.abs(x - column * TILE_SIZE) <= SCREEN_HALF_WIDTH + padding and math.abs(z - row * TILE_SIZE) <= SCREEN_HALF_LENGTH + padding then
								return true
							end
						end
						::__continue17::
						column = column + 1
					end
				end
			end
			::__continue14::
			row = row + 1
		end
	end
	return false
end
____exports.Patrol = __TS__Class()
local Patrol = ____exports.Patrol
Patrol.name = "Patrol"
function Patrol.prototype.____constructor(self, data)
	self.data = data
	self.suspicion = 0
	self.yaw = 0
	self.state = "patrol"
	self.waypoint = 1
	self.challengeSpeed = 1
	self.sealAlert = 0
	self.pause = 0
	self.investigatePoint = {x = 0, z = 0}
	self.investigateDeadline = 0
	self.investigateSearchDuration = 3.2
	self.pursuitUntil = 0
	self.searchUntil = 0
	self.searchTurnTimer = 0
	self.searchDirection = 1
	self.coneDraw = DrawNode()
	self.position = {x = data.route[1].x, z = data.route[1].z}
	self.lastSeen = {x = self.position.x, z = self.position.z}
	self.root = Node3D()
	self.root.position = Vec3(self.position.x, 0, self.position.z)
	local model = Model3D(MODEL .. "guardian.glb")
	if model ~= nil then
		model.scale = Vec3(0.82, 0.82, 0.82)
		self.root:addChild(model)
	end
	local width = data.range * math.tan(data.halfAngle * math.pi / 180) * 2
	self.cone = Surface3D(
		self.coneDraw,
		Size(width, data.range),
		Size(256, 256)
	)
	if self.cone ~= nil then
		self.cone.position = Vec3(0, 0.035, data.range * 0.5)
		self.cone.angleX = -90
		self.root:addChild(self.cone)
	end
	local alert = Label(FONT, 54, true)
	if alert then
		alert.text = "!"
		alert.color3 = Color3(16764740)
		self.markLabel = alert
		self.mark = Surface3D(
			alert,
			Size(0.5, 0.7),
			Size(96, 128)
		)
		if self.mark then
			self.mark.position = Vec3(0, 2.1, 0)
			self.mark.billboard = "YAxis"
			self.mark.visible = false
			self.root:addChild(self.mark)
		end
	end
	Director.entry.scene:addChild(self.root)
end
function Patrol.prototype.hearFootstep(self, point, elapsed)
	if self.state == "chase" then
		return false
	end
	self:beginInvestigation(point, elapsed, 2.4, 2.2)
	self.suspicion = math.max(self.suspicion, 0.08)
	return true
end
function Patrol.prototype.hearBell(self, point, elapsed)
	if self.state == "chase" or self.suspicion >= 0.6 then
		return false
	end
	self:beginInvestigation(point, elapsed, 5.5, 3.6)
	self.suspicion = math.max(self.suspicion, 0.12)
	return true
end
function Patrol.prototype.hearDoor(self, point, elapsed)
	if self.state == "chase" then
		return false
	end
	self:beginInvestigation(point, elapsed, 7, 4.1)
	self.suspicion = math.max(self.suspicion, 0.18)
	return true
end
function Patrol.prototype.beginInvestigation(self, point, elapsed, travelTime, searchDuration)
	self.state = "investigate"
	self.investigatePoint = {x = point.x, z = point.z}
	self.investigateDeadline = elapsed + travelTime
	self.investigateSearchDuration = searchDuration
	self.pause = 0
end
function Patrol.prototype.beginSearch(self, elapsed, duration)
	self.state = "search"
	self.searchUntil = elapsed + duration + self.sealAlert * 0.5
	self.searchTurnTimer = 0.65
	self.searchDirection = -self.searchDirection
end
function Patrol.prototype.reset(self)
	self.suspicion = 0
	self.state = "patrol"
	self.investigateDeadline = 0
	self.pursuitUntil = 0
	self.searchUntil = 0
	self.pause = 0
end
function Patrol.prototype.boostSpeed(self, multiplier)
	self.challengeSpeed = multiplier
end
function Patrol.prototype.setSealAlert(self, sealCount)
	self.sealAlert = math.max(0, sealCount - 1)
end
function Patrol.prototype.update(self, dt, elapsed, player, moving, quiet, protectedPlayer, chapter)
	local visible = not protectedPlayer and self:canSee(player, chapter)
	if visible then
		self.state = "chase"
		self.lastSeen = {x = player.x, z = player.z}
		self.pursuitUntil = elapsed + 3 + self.sealAlert * 0.5
	elseif self.state == "chase" and elapsed >= self.pursuitUntil then
		self:beginSearch(elapsed, 3.2)
	elseif self.state == "investigate" and elapsed >= self.investigateDeadline then
		self:beginSearch(elapsed, self.investigateSearchDuration)
	elseif self.state == "search" and elapsed >= self.searchUntil then
		self.state = "patrol"
		self.pause = 0.35
	end
	local target
	local turnRate = 105
	local moveScale = 1
	if self.state == "chase" then
		target = self.lastSeen
		turnRate = 145
		moveScale = 1.28
	elseif self.state == "investigate" then
		target = self.investigatePoint
		turnRate = 125
		moveScale = 1.12
	elseif self.state == "search" then
		self.searchTurnTimer = self.searchTurnTimer - dt
		if self.searchTurnTimer <= 0 then
			self.searchTurnTimer = self.searchTurnTimer + 0.75
			self.searchDirection = -self.searchDirection
		end
		self.yaw = self.yaw + self.searchDirection * 62 * dt
	elseif self.pause > 0 then
		self.pause = self.pause - dt
	else
		target = self.data.route[self.waypoint + 1]
	end
	if target then
		local direction = normalize(target.x - self.position.x, target.z - self.position.z)
		local desired = math.atan(direction.x, direction.z) * 180 / math.pi
		local difference = (desired - self.yaw + 540) % 360 - 180
		difference = clamp(difference, -turnRate * dt, turnRate * dt)
		self.yaw = self.yaw + difference
		if self.pause <= 0 and math.abs(difference) < 32 then
			local remaining = distance(self.position, target)
			local speed = self.data.speed * self.challengeSpeed * (1 + self.sealAlert * 0.06) * moveScale
			local step = math.min(speed * dt, remaining)
			local nextX = self.position.x + direction.x * step
			local nextZ = self.position.z + direction.z * step
			if not blocked(chapter, nextX, self.position.z, 0.28) then
				self.position.x = nextX
			end
			if not blocked(chapter, self.position.x, nextZ, 0.28) then
				self.position.z = nextZ
			end
			if distance(self.position, target) < 0.2 then
				if self.state == "investigate" then
					self:beginSearch(elapsed, self.investigateSearchDuration)
				elseif self.state == "chase" and not visible then
					self:beginSearch(elapsed, 3.2)
				elseif self.state == "patrol" then
					self.waypoint = (self.waypoint + 1) % #self.data.route
					self.pause = 0.65
				end
			end
		end
	end
	local exposure = quiet and 0.75 or (moving and 1.25 or 1)
	self.suspicion = clamp(self.suspicion + dt * (visible and exposure / self.data.noticeSeconds or -0.35), 0, 1)
	self.root.position = Vec3(self.position.x, 0, self.position.z)
	self.root.angleY = self.yaw
	self:updateCone(chapter)
	if self.mark then
		self.mark.visible = self.state ~= "patrol" or self.suspicion > 0.05
		self.mark.scale = Vec3(1 + self.suspicion * 0.35, 1 + self.suspicion * 0.35, 1)
	end
	if self.markLabel then
		self.markLabel.text = self.state == "chase" and "!" or "?"
		self.markLabel.color3 = self.state == "chase" and Color3(16730429) or Color3(16764740)
	end
	return self.suspicion >= 1
end
function Patrol.prototype.updateCone(self, chapter)
	local range = self.data.range
	local fullWidth = self.data.range * math.tan(self.data.halfAngle * math.pi / 180) * 2
	local points = {Vec2(0, 128)}
	local rayCount = 32
	do
		local index = 0
		while index <= rayCount do
			local relative = -self.data.halfAngle + self.data.halfAngle * 2 * index / rayCount
			local relativeRadians = relative * math.pi / 180
			local worldRadians = (self.yaw + relative) * math.pi / 180
			local rayX = math.sin(worldRadians)
			local rayZ = math.cos(worldRadians)
			local clear = 0
			local blockedAt = range
			local step = TILE_SIZE / 16
			do
				local distanceAlongRay = step
				while distanceAlongRay <= range do
					if blocked(chapter, self.position.x + rayX * distanceAlongRay, self.position.z + rayZ * distanceAlongRay) then
						blockedAt = distanceAlongRay
						break
					end
					clear = distanceAlongRay
					distanceAlongRay = distanceAlongRay + step
				end
			end
			if blockedAt < range then
				do
					local refine = 0
					while refine < 5 do
						local middle = (clear + blockedAt) * 0.5
						if blocked(chapter, self.position.x + rayX * middle, self.position.z + rayZ * middle) then
							blockedAt = middle
						else
							clear = middle
						end
						refine = refine + 1
					end
				end
			else
				clear = range
			end
			local localX = math.sin(relativeRadians) * clear
			local localZ = math.cos(relativeRadians) * clear
			points[#points + 1] = Vec2(-localX / fullWidth * 256, 128 - localZ / self.data.range * 256)
			index = index + 1
		end
	end
	self.coneDraw:clear()
	self.coneDraw:drawPolygon(
		points,
		Color(1224192824)
	)
end
function Patrol.prototype.canSee(self, player, chapter)
	local dx = player.x - self.position.x
	local dz = player.z - self.position.z
	local range = self.data.range
	local length = math.sqrt(dx * dx + dz * dz)
	if length > range or length < 0.001 then
		return false
	end
	local forwardX = math.sin(self.yaw * math.pi / 180)
	local forwardZ = math.cos(self.yaw * math.pi / 180)
	local cosine = (forwardX * dx + forwardZ * dz) / length
	if cosine < math.cos(self.data.halfAngle * math.pi / 180) then
		return false
	end
	local samples = math.max(
		2,
		math.ceil(length / 0.25)
	)
	do
		local i = 1
		while i < samples do
			local t = i / samples
			if blocked(chapter, self.position.x + dx * t, self.position.z + dz * t) then
				return false
			end
			i = i + 1
		end
	end
	return true
end
____exports.ReturningHomeGame = __TS__Class()
local ReturningHomeGame = ____exports.ReturningHomeGame
ReturningHomeGame.name = "ReturningHomeGame"
function ReturningHomeGame.prototype.____constructor(self, previewChapter)
	self.phase = "menu"
	self.mode = "story"
	self.chapterIndex = 0
	self.chapter = chapters[1]
	self.elapsed = 0
	self.bellCooldown = 0
	self.footstepCooldown = 0
	self.safeUntil = 0
	self.lives = 3
	self.mistakes = 0
	self.sealCount = 0
	self.coinCount = 0
	self.alert = 0
	self.quiet = false
	self.sound = true
	self.player = {x = 2, z = 2}
	self.checkpoint = {x = 2, z = 2}
	self.inSanctuary = false
	self.guards = {}
	self.pickups = {}
	self.exit = {x = 0, z = 0}
	self.camera = Camera3D()
	self.ui = Node()
	self.hud = Node()
	self.overlay = Node()
	self.minimap = DrawNode()
	self.minimapOpen = false
	self.chrome = DrawNode()
	self.alertMeter = DrawNode()
	self.status = self:text("", 21)
	self.objective = self:text("", 18)
	self.hint = self:plainText("", 19)
	self.alertText = self:text("", 18)
	self.modeText = self:plainText("", 18)
	self.hintText = "WASD / 方向移动 · Shift轻步 · Space响铃 · Esc暂停"
	self.hintUntil = 0
	self.touchMove = {x = 0, z = 0}
	self.joystickKnob = DrawNode()
	self.joystickCenter = Vec2.zero
	self.joystickActive = false
	self.playerYaw = 0
	self.lastWalking = false
	self.playerMoving = false
	self.footstepWaveDraw = DrawNode()
	self.footstepWaveUntil = 0
	self.bellMarkerDraw = DrawNode()
	self.bellMarkerUntil = 0
	self.save = {unlocked = 0, stars = {0, 0, 0}, best = {0, 0, 0}, sound = true}
	self.ambience = 0
	self.challengeSeed = 0
	self.uiWidth = 1280
	self.uiHeight = 720
	self.uiCompact = false
	self.resultTitle = ""
	self.resultBody = ""
	self:loadSave()
	self.sound = self.save.sound
	Director:clearCamera()
	Director.entry.scene:removeAllChildren()
	Director.ui:removeAllChildren()
	Director.clearColor = Color(4278653199)
	View.fieldOfView = 48
	View.nearPlaneDistance = 0.1
	View.farPlaneDistance = 150
	Director.entry.shadowMapSize = 2048
	Director:pushCamera(self.camera)
	Director.ui:addChild(self.ui)
	self.ui:addChild(self.hud)
	self.ui:addChild(self.overlay)
	self:rebuildHud()
	self:installInput()
	self.ui:onAppChange(function(setting)
		if setting ~= "Size" then
			return
		end
		self:rebuildHud()
		if self.phase == "menu" then
			self:renderMenu()
		elseif self.phase ~= "playing" then
			self:renderResult()
		end
	end)
	if self.sound then
		self.ambience = Audio:play(AUDIO .. "ambience.wav", true)
	end
	self:showMenu()
	if previewChapter ~= nil then
		self:startChapter(previewChapter, "story")
	end
	self.ui:schedule(function(dt)
		self:update(dt)
		return false
	end)
end
function ReturningHomeGame.prototype.text(self, value, size)
	local label = Label(FONT, size, true)
	if not label then
		error(
			__TS__New(Error, "归灯中文字体错误"),
			0
		)
	end
	label.text = value
	label.color3 = Color3(16774876)
	label.outlineColor = Color(3491045400)
	label.outlineWidth = 0.18
	return label
end
function ReturningHomeGame.prototype.plainText(self, value, size)
	local label = Label(FULL_FONT, size, true)
	if not label then
		error(
			__TS__New(Error, "中文字体错误"),
			0
		)
	end
	label.text = value
	label.color3 = Color3(16774876)
	label.outlineColor = Color(3222609944)
	label.outlineWidth = 0.12
	return label
end
function ReturningHomeGame.prototype.makeHud(self)
	local width = self.uiWidth
	local height = self.uiHeight
	local compact = self.uiCompact
	local edge = compact and 16 or 24
	local contentInset = compact and 12 or 16
	local rightWidth = compact and 218 or 248
	local leftWidth = width - rightWidth - edge * 2 - contentInset
	local ink = Color(3993971492)
	local gold = Color(4291998308)
	self.chrome:drawPolygon(
		{
			Vec2(-width * 0.5 + edge, height * 0.5 - 138),
			Vec2(-width * 0.5 + edge, height * 0.5 - edge),
			Vec2(width * 0.5 - edge, height * 0.5 - edge),
			Vec2(width * 0.5 - edge, height * 0.5 - 138)
		},
		ink,
		2,
		gold
	)
	self.chrome:drawPolygon(
		{
			Vec2(-width * 0.5 + edge, height * 0.5 - 184),
			Vec2(-width * 0.5 + edge, height * 0.5 - 148),
			Vec2(width * 0.5 - edge, height * 0.5 - 148),
			Vec2(width * 0.5 - edge, height * 0.5 - 184)
		},
		ink,
		1,
		Color(2856610653)
	)
	self.hud:addChild(self.chrome)
	self.status.textWidth = math.max(
		220,
		math.min(310, leftWidth - 30)
	)
	self.status.alignment = "Left"
	self.status.lineGap = 4
	self.status.position = Vec2(-width * 0.5 + edge + contentInset + self.status.textWidth * 0.5, height * 0.5 - 58)
	self.objective.textWidth = math.max(
		240,
		math.min(430, leftWidth - 30)
	)
	self.objective.alignment = "Left"
	self.objective.position = Vec2(-width * 0.5 + edge + contentInset + self.objective.textWidth * 0.5, height * 0.5 - 112)
	self.hint.position = Vec2(0, height * 0.5 - 210)
	self.alertText.position = Vec2(0, height * 0.5 - 168)
	self.modeText.position = Vec2(compact and -20 or 70, height * 0.5 - 72)
	self.alertMeter.position = Vec2(0, height * 0.5 - 168)
	self.hud:addChild(self.alertMeter)
	self.hud:addChild(self.status)
	self.hud:addChild(self.objective)
	self.hud:addChild(self.hint)
	self.hud:addChild(self.alertText)
	self.hud:addChild(self.modeText)
	self.minimap.position = Vec2(width * 0.5 - edge - 56, height * 0.5 - 230)
	self.minimap.scaleX = compact and 0.62 or 0.72
	self.minimap.scaleY = compact and 0.62 or 0.72
	self.minimap.visible = self.minimapOpen
	self.hud:addChild(self.minimap)
end
function ReturningHomeGame.prototype.makeTouchControls(self)
	local width = self.uiWidth
	local height = self.uiHeight
	local compact = self.uiCompact
	local edge = compact and 16 or 24
	local contentInset = compact and 12 or 16
	local pad = Node()
	pad.size = Size(
		math.min(512, width * 0.55),
		math.min(512, height * 0.55)
	)
	pad.anchor = Vec2.zero
	pad.position = Vec2(-width * 0.5, -height * 0.5)
	pad.swallowTouches = true
	local padCenter = Vec2(compact and 96 or 108, compact and 92 or 80)
	self.joystickCenter = padCenter
	local base = DrawNode()
	base:drawPolygon(
		{
			Vec2(0, 76),
			Vec2(76, 0),
			Vec2(0, -76),
			Vec2(-76, 0)
		},
		Color(3492236353),
		2,
		Color(4291998308)
	)
	base.position = padCenter
	pad:addChild(base)
	self.joystickKnob:drawPolygon(
		{
			Vec2(-28, -28),
			Vec2(-28, 28),
			Vec2(28, 28),
			Vec2(28, -28)
		},
		Color(4293846727)
	)
	local moveLabel = self:text("移", 24)
	moveLabel.color3 = Color3(4215627)
	moveLabel.outlineWidth = 0
	self.joystickKnob:addChild(moveLabel)
	self.joystickKnob.position = padCenter
	pad:addChild(self.joystickKnob)
	pad:onTapFilter(function(touch)
		local offset = touch.location:sub(padCenter)
		if offset.length > 88 then
			touch.enabled = false
		else
			self.joystickActive = true
		end
	end)
	pad:onTapBegan(function(touch)
		if self.joystickActive then
			self:updatePad(
				touch.location:sub(padCenter),
				padCenter
			)
		end
	end)
	pad:onTapMoved(function(touch)
		if self.joystickActive then
			self:updatePad(
				touch.location:sub(padCenter),
				padCenter
			)
		end
	end)
	pad:onTapEnded(function()
		self.joystickActive = false
		self:releasePad()
	end)
	pad:onExit(function()
		self.joystickActive = false
		self:releasePad()
	end)
	self.hud:addChild(pad)
	local actionWidth = compact and 156 or 180
	local actionX = width * 0.5 - edge - actionWidth * 0.5
	self.quietButtonLabel = self:button(
		"轻步：未开\n点击放轻",
		actionX,
		-height * 0.5 + 200,
		function() return self:toggleQuiet() end,
		actionWidth,
		76,
		Color(3995159616)
	)
	self.bellButtonLabel = self:button(
		"响铃\n引开纸人",
		actionX,
		-height * 0.5 + 116,
		function() return self:ringBell() end,
		actionWidth,
		76,
		Color(4003867682)
	)
	self:button(
		"舆图",
		width * 0.5 - edge - contentInset - 164,
		height * 0.5 - 76,
		function()
			self.minimapOpen = not self.minimapOpen
			self.minimap.visible = self.minimapOpen
		end,
		104,
		72,
		Color(3709287475)
	)
	self:button(
		"暂停",
		width * 0.5 - edge - contentInset - 52,
		height * 0.5 - 76,
		function() return self:pause() end,
		104,
		72,
		Color(3709287475)
	)
	self.quietButtonLabel.text = self.quiet and "轻步：已开\n点击恢复" or "轻步：未开\n点击放轻"
	self.bellButtonLabel.text = self.bellCooldown <= 0 and "响铃\n引开纸人" or ("响铃\n" .. tostring(math.ceil(self.bellCooldown))) .. " 秒"
end
function ReturningHomeGame.prototype.rebuildHud(self)
	self.joystickActive = false
	self.touchMove = {x = 0, z = 0}
	local viewport = App.visualSize
	local pixelWidth = viewport.width * App.devicePixelRatio
	local pixelHeight = viewport.height * App.devicePixelRatio
	local scale = clamp(
		math.min(pixelWidth / 1280, pixelHeight / 720),
		0.6,
		1
	)
	self.uiWidth = math.max(1, pixelWidth / scale)
	self.uiHeight = math.max(1, pixelHeight / scale)
	self.uiCompact = self.uiHeight > self.uiWidth * 1.05
	self.hud.scaleX = scale
	self.hud.scaleY = scale
	self.overlay.scaleX = scale
	self.overlay.scaleY = scale
	self.hud:removeAllChildren()
	self.chrome = DrawNode()
	self.alertMeter = DrawNode()
	self.minimap = DrawNode()
	self.joystickKnob = DrawNode()
	self.status = self:text("", self.uiCompact and 18 or 21)
	self.objective = self:text("", self.uiCompact and 16 or 18)
	self.hint = self:plainText("", self.uiCompact and 16 or 19)
	self.alertText = self:text("", self.uiCompact and 16 or 18)
	self.modeText = self:plainText("", self.uiCompact and 15 or 18)
	self:makeHud()
	self:makeTouchControls()
	self.hud.visible = self.phase == "playing"
	if self.phase == "playing" then
		self:refreshHud()
	end
end
function ReturningHomeGame.prototype.updatePad(self, location, center)
	if center == nil then
		center = Vec2.zero
	end
	local length = math.sqrt(location.x * location.x + location.y * location.y)
	local scale = length > 64 and 64 / length or 1
	local x = location.x * scale
	local y = location.y * scale
	self.touchMove = length < 8 and ({x = 0, z = 0}) or ({x = x / 64, z = y / 64})
	self.joystickKnob.position = Vec2(center.x + x, center.y + y)
end
function ReturningHomeGame.prototype.releasePad(self)
	self.touchMove = {x = 0, z = 0}
	self.joystickKnob.position = self.joystickCenter
end
function ReturningHomeGame.prototype.forcePlayerIdle(self)
	self.joystickActive = false
	self:releasePad()
	self.lastWalking = false
	self.playerMoving = false
	if self.idleModel then
		self.idleModel.visible = true
	end
	if self.walkModel then
		self.walkModel.visible = false
	end
end
function ReturningHomeGame.prototype.button(self, title, x, y, action, width, height, fill)
	if width == nil then
		width = 92
	end
	if height == nil then
		height = 58
	end
	if fill == nil then
		fill = Color(2955564102)
	end
	local node = Node()
	node.size = Size(width, height)
	node.anchor = Vec2.zero
	node.position = Vec2(x - width * 0.5, y - height * 0.5)
	node.touchEnabled = true
	node.swallowTouches = true
	local center = Vec2(width * 0.5, height * 0.5)
	local shape = DrawNode()
	shape:drawPolygon(
		{
			Vec2(-width * 0.5, -height * 0.5),
			Vec2(-width * 0.5, height * 0.5),
			Vec2(width * 0.5, height * 0.5),
			Vec2(width * 0.5, -height * 0.5)
		},
		fill,
		2,
		Color(4291998308)
	)
	shape.position = center
	node:addChild(shape)
	local label = self:text(title, 19)
	label.position = center
	node:addChild(label)
	node:onTapped(action)
	self.hud:addChild(node)
	return label
end
function ReturningHomeGame.prototype.overlayButton(self, title, x, y, action, width, height, fill)
	if width == nil then
		width = 210
	end
	if height == nil then
		height = 56
	end
	if fill == nil then
		fill = Color(3709287475)
	end
	local node = Node()
	node.size = Size(width, height)
	node.anchor = Vec2.zero
	node.position = Vec2(x - width * 0.5, y - height * 0.5)
	node.touchEnabled = true
	node.swallowTouches = true
	local center = Vec2(width * 0.5, height * 0.5)
	local shape = DrawNode()
	shape:drawPolygon(
		{
			Vec2(-width * 0.5, -height * 0.5),
			Vec2(-width * 0.5, height * 0.5),
			Vec2(width * 0.5, height * 0.5),
			Vec2(width * 0.5, -height * 0.5)
		},
		fill,
		2,
		Color(4291998308)
	)
	shape.position = center
	node:addChild(shape)
	local label = self:text(title, self.uiCompact and 17 or 19)
	label.position = center
	node:addChild(label)
	node:onTapped(action)
	self.overlay:addChild(node)
end
function ReturningHomeGame.prototype.installInput(self)
	self.ui:onKeyDown(function(key)
		if key == "Escape" then
			if self.phase == "playing" then
				self:pause()
			elseif self.phase == "paused" then
				self:resume()
			elseif self.phase ~= "menu" then
				self:showMenu()
			end
			return
		end
		if self.phase == "menu" then
			if key == "1" then
				self:startChapter(0, "story")
			elseif key == "2" then
				self:startChapter(1, "story")
			elseif key == "3" then
				self:startChapter(2, "story")
			elseif key == "C" then
				self:startChapter(self.save.unlocked, "story")
			elseif key == "D" then
				self:startDaily()
			elseif key == "4" then
				self:startChapter(self.save.unlocked, "endurance")
			elseif key == "5" then
				self:startChapter(self.save.unlocked, "collector")
			end
			return
		end
		if self.phase == "playing" then
			if key == "LShift" or key == "RShift" then
				self:toggleQuiet()
			elseif key == "Space" then
				self:ringBell()
			elseif key == "M" then
				self:tell("右下角舆图：金=灯印/铜钱，青=安全灯，朱=出口", 4)
			elseif key == "O" then
				self:toggleSound()
			end
		elseif self.phase == "victory" then
			if key == "Return" or key == "Space" then
				self:nextChapter()
			end
		elseif self.phase == "defeat" then
			if key == "Return" or key == "Space" then
				self:startChapter(self.chapterIndex, self.mode)
			end
		elseif self.phase == "ending" then
			if key == "Return" or key == "Space" then
				self:showMenu()
			end
		end
	end)
	self.ui:onButtonDown(function(_controllerId, button)
		if button == "leftshoulder" then
			self:toggleQuiet()
		elseif button == "a" then
			self:ringBell()
		elseif button == "start" then
			if self.phase == "playing" then
				self:pause()
			elseif self.phase == "paused" then
				self:resume()
			end
		end
	end)
end
function ReturningHomeGame.prototype.loadSave(self)
	if not Content:exist(SAVE_FILE) then
		return
	end
	local raw = Content:load(SAVE_FILE)
	local value = json.decode(raw)
	if value == nil or type(value) ~= "table" then
		return
	end
	local data = value
	self.save.unlocked = clamp(data.unlocked ~= nil and data.unlocked or 0, 0, 2)
	self.save.stars = data.stars ~= nil and data.stars or ({0, 0, 0})
	self.save.best = data.best ~= nil and data.best or ({0, 0, 0})
	self.save.sound = data.sound ~= false
end
function ReturningHomeGame.prototype.saveProgress(self)
	local raw = json.encode(self.save, true)
	if raw ~= nil then
		Content:save(SAVE_FILE, raw)
	end
end
function ReturningHomeGame.prototype.showMenu(self)
	self.phase = "menu"
	self.resultTitle = ""
	self.resultBody = ""
	self.hud.visible = false
	self.overlay.visible = true
	self:renderMenu()
	Director.entry.scene:removeAllChildren()
	self.camera:lookAt(
		Vec3(0, 4, 8),
		Vec3(0, 0, 0)
	)
end
function ReturningHomeGame.prototype.renderMenu(self)
	self.overlay:removeAllChildren()
	local width = self.uiWidth
	local height = self.uiHeight
	local compact = self.uiCompact
	local cover = Sprite(UNITY .. "Resources/ReturningHome30Cover.png")
	if cover ~= nil then
		local coverScale = math.max(width / cover.width, height / cover.height)
		cover.scaleX = coverScale
		cover.scaleY = coverScale
		cover.opacity = 0.36
		cover.color3 = Color3(8763554)
		self.overlay:addChild(cover)
	end
	local titleSize = compact and 40 or 50
	local subtitleSize = compact and 18 or 22
	local progressSize = compact and 16 or 18
	local infoSize = compact and 14 or 17
	local authorSize = compact and 16 or 18
	local columns = compact and 2 or 4
	local gap = compact and 12 or 16
	local buttonWidth = math.min(compact and 250 or 230, (width - gap * (columns + 1)) / columns)
	local buttonHeight = compact and 52 or 58
	local rows = math.ceil(8 / columns)
	local baseTitleY = height * 0.5 - 72
	local baseFirstY = height * 0.5 - 222
	local baseInfoY = baseFirstY - rows * (buttonHeight + gap) - 8
	local baseAuthorY = baseInfoY - (compact and 34 or 30)
	local groupTop = baseTitleY + titleSize * 0.6
	local groupBottom = baseAuthorY - authorSize * (compact and 1.2 or 0.6)
	local centerOffsetY = -(groupTop + groupBottom) * 0.5
	local title = self:text("古宅惊魂 · 归灯", titleSize)
	title.position = Vec2(0, baseTitleY + centerOffsetY)
	self.overlay:addChild(title)
	local subtitle = self:plainText("一位归家人，三枚灯印，九位巡夜纸人", subtitleSize)
	subtitle.position = Vec2(0, height * 0.5 - 118 + centerOffsetY)
	self.overlay:addChild(subtitle)
	local unlock = self:plainText(
		((("章节进度 " .. tostring(self.save.unlocked + 1)) .. "/3 · 已得星 ") .. tostring(self.save.stars[1] + self.save.stars[2] + self.save.stars[3])) .. "/9",
		progressSize
	)
	unlock.position = Vec2(0, height * 0.5 - 154 + centerOffsetY)
	self.overlay:addChild(unlock)
	local entries = {
		{
			title = "第一章 · 门庭夜雨",
			action = function() return self:startChapter(0, "story") end
		},
		{
			title = self.save.unlocked >= 1 and "第二章 · 回廊迷灯" or "第二章 · 尚未解锁",
			action = function()
				if self.save.unlocked >= 1 then
					self:startChapter(1, "story")
				end
			end
		},
		{
			title = self.save.unlocked >= 2 and "第三章 · 归灯祠堂" or "第三章 · 尚未解锁",
			action = function()
				if self.save.unlocked >= 2 then
					self:startChapter(2, "story")
				end
			end
		},
		{
			title = "继续章节",
			action = function() return self:startChapter(self.save.unlocked, "story") end,
			fill = Color(3995159616)
		},
		{
			title = "每日迷局",
			action = function() return self:startDaily() end
		},
		{
			title = "长夜守灯",
			action = function() return self:startChapter(self.save.unlocked, "endurance") end
		},
		{
			title = "搜寻旧物",
			action = function() return self:startChapter(self.save.unlocked, "collector") end
		},
		{
			title = self.sound and "声音：开" or "声音：关",
			action = function()
				self:toggleSound()
				self:renderMenu()
			end
		}
	}
	local firstY = baseFirstY + centerOffsetY
	do
		local index = 0
		while index < #entries do
			local row = math.floor(index / columns)
			local column = index % columns
			local count = math.min(columns, #entries - row * columns)
			local rowWidth = count * buttonWidth + (count - 1) * gap
			local x = -rowWidth * 0.5 + buttonWidth * 0.5 + column * (buttonWidth + gap)
			local y = firstY - row * (buttonHeight + gap)
			local entry = entries[index + 1]
			self:overlayButton(
				entry.title,
				x,
				y,
				entry.action,
				buttonWidth,
				buttonHeight,
				entry.fill
			)
			index = index + 1
		end
	end
	local info = self:plainText("点击按钮进入 · 游戏内左边摇杆移动，右边轻步与响铃", infoSize)
	info.position = Vec2(0, baseInfoY + centerOffsetY)
	self.overlay:addChild(info)
	local author = Label("sarasa-mono-sc-regular", authorSize, true)
	if author == nil then
		author = self:plainText(compact and "制作 dfer · https://www.dfer.site/\ndf_business[at]qq.com" or "制作 dfer · https://www.dfer.site/ · df_business[at]qq.com", authorSize)
	else
		author.text = compact and "作者 dfer · https://www.dfer.site/\ndf_business@qq.com" or "作者 dfer · https://www.dfer.site/ · df_business@qq.com"
		author.color3 = Color3(16774876)
		author.outlineColor = Color(3222609944)
		author.outlineWidth = 0.12
	end
	author.lineGap = 4
	author.position = Vec2(0, baseAuthorY + centerOffsetY)
	self.overlay:addChild(author)
	local authorLink = Node()
	local authorWidth = math.min(width - 32, compact and 430 or 620)
	local authorHeight = compact and 48 or 34
	authorLink.size = Size(authorWidth, authorHeight)
	authorLink.anchor = Vec2.zero
	authorLink.position = Vec2(-authorWidth * 0.5, baseAuthorY + centerOffsetY - authorHeight * 0.5)
	authorLink.touchEnabled = true
	authorLink.swallowTouches = true
	authorLink:onTapped(function() return App:openURL("https://www.dfer.site/") end)
	self.overlay:addChild(authorLink)
end
function ReturningHomeGame.prototype.startDaily(self)
	local day = tonumber(os.date("%Y%m%d")) or 1
	self.challengeSeed = day
	self:startChapter(day % #chapters, "daily")
end
function ReturningHomeGame.prototype.startChapter(self, index, mode)
	if mode == "story" and index > self.save.unlocked then
		self:tell("本章节尚未解锁，先完成前一章。", 3)
		return
	end
	self.chapterIndex = clamp(index, 0, #chapters - 1)
	self.chapter = chapters[self.chapterIndex + 1]
	self.mode = mode
	self.phase = "playing"
	self.elapsed = 0
	self.bellCooldown = 0
	self.footstepCooldown = 0
	self.footstepWaveUntil = 0
	self.bellMarkerUntil = 0
	self.safeUntil = 2
	self.lives = mode == "story" and 3 or 2
	self.mistakes = 0
	self.sealCount = 0
	self.coinCount = 0
	self.alert = 0
	self.quiet = false
	self.minimapOpen = false
	self.minimap.visible = false
	if self.quietButtonLabel then
		self.quietButtonLabel.text = "轻步：未开\n点击放轻"
	end
	if self.bellButtonLabel then
		self.bellButtonLabel.text = "响铃\n引开纸人"
	end
	self.inSanctuary = false
	self.player = {x = self.chapter.spawn.x, z = self.chapter.spawn.z}
	self.playerYaw = 0
	self.checkpoint = {x = self.player.x, z = self.player.z}
	self.guards = {}
	self.pickups = {}
	self.overlay.visible = false
	self.hud.visible = true
	self:buildChapter()
	self:tell(self.chapter.introduction, 7)
	if mode == "endurance" then
		self:tell("长夜守灯：青灯暂歇，收齐灯印并坚持九十秒后逃离。", 9)
	end
	if mode == "collector" then
		self:tell("搜寻旧物：铜钱和灯印全部寻回，才能打开朱门。", 9)
	end
end
function ReturningHomeGame.prototype.buildBackdrop(self)
	Director.entry.scene:removeAllChildren()
	local light = DirectionalLight3D()
	light.color = Color3(16767400)
	light.intensity = 2.3
	light.angleX = -55
	light.angleY = 25
	light.castShadow = true
	light.shadowSoftness = 2.4
	Director.entry.scene:addChild(light)
	local floor = Model3D(MODEL .. "floor.glb")
	if floor ~= nil then
		floor.scale = Vec3(7, 1, 7)
		Director.entry.scene:addChild(floor)
	end
	local lantern = Model3D(MODEL .. "lantern.glb")
	if lantern ~= nil then
		lantern.position = Vec3(0, 0, 0)
		Director.entry.scene:addChild(lantern)
	end
	self.camera:lookAt(
		Vec3(8.5, 8.5, 10.5),
		Vec3(0, 0.8, 0)
	)
end
function ReturningHomeGame.prototype.buildChapter(self)
	Director.entry.scene:removeAllChildren()
	local light = DirectionalLight3D()
	light.color = Color3(16769197)
	light.intensity = 0.72
	light.angleX = -52
	light.angleY = 28
	light.castShadow = true
	light.shadowBias = 0.0015
	light.shadowNormalBias = 0.025
	light.shadowSoftness = 2.2
	Director.entry.scene:addChild(light)
	local architecture = Model3D(((MODEL .. "chapter-") .. tostring(self.chapterIndex)) .. ".glb")
	if architecture ~= nil then
		Director.entry.scene:addChild(architecture)
	end
	do
		local z = 0
		while z < #self.chapter.map do
			local row = self.chapter.map[z + 1]
			do
				local x = 0
				while x < #row do
					local tile = string.sub(row, x + 1, x + 1)
					local worldX = x * TILE_SIZE
					local worldZ = z * TILE_SIZE
					if tile == "K" or tile == "C" then
						local kind = tile == "K" and "seal" or "coin"
						local model = Model3D((MODEL .. kind) .. ".glb")
						if model ~= nil then
							model.position = Vec3(worldX, 0.68, worldZ)
							Director.entry.scene:addChild(model)
							local ____self_pickups_0 = self.pickups
							____self_pickups_0[#____self_pickups_0 + 1] = {
								kind = kind,
								x = worldX,
								z = worldZ,
								node = model,
								collected = false
							}
						end
					end
					if tile == "H" then
						self:addSanctuary(worldX, worldZ)
					end
					if tile == "E" then
						self.exit = {x = worldX, z = worldZ}
						local gate = Model3D(MODEL .. "gate.glb")
						if gate ~= nil then
							gate.position = Vec3(worldX, 0, worldZ)
							Director.entry.scene:addChild(gate)
						end
					end
					x = x + 1
				end
			end
			z = z + 1
		end
	end
	self.playerRoot = Node3D()
	self.idleModel = Model3D(MODEL .. "cat-idle.glb")
	self.walkModel = Model3D(MODEL .. "cat-walk.glb")
	if self.idleModel ~= nil then
		self.idleModel.scale = Vec3(0.78, 0.78, 0.78)
		self.idleModel:play("idle", true)
		self.playerRoot:addChild(self.idleModel)
	end
	if self.walkModel ~= nil then
		self.walkModel.scale = Vec3(0.78, 0.78, 0.78)
		self.walkModel:play("walk", true)
		self.walkModel.visible = false
		self.playerRoot:addChild(self.walkModel)
	end
	self.footstepWaveDraw = DrawNode()
	self.footstepWave = Surface3D(
		self.footstepWaveDraw,
		Size(2.8, 2.8),
		Size(128, 128)
	)
	if self.footstepWave ~= nil then
		self.footstepWave.position = Vec3(0, 0.04, 0)
		self.footstepWave.angleX = -90
		self.footstepWave.visible = false
		self.playerRoot:addChild(self.footstepWave)
	end
	self.playerRoot.position = Vec3(self.player.x, 0, self.player.z)
	Director.entry.scene:addChild(self.playerRoot)
	self.bellMarkerRoot = Node3D()
	self.bellMarkerDraw = DrawNode()
	self.bellMarker = Surface3D(
		self.bellMarkerDraw,
		Size(3.2, 3.2),
		Size(128, 128)
	)
	if self.bellMarker ~= nil then
		self.bellMarker.position = Vec3(0, 0.045, 0)
		self.bellMarker.angleX = -90
		self.bellMarker.visible = false
		self.bellMarkerRoot:addChild(self.bellMarker)
	end
	Director.entry.scene:addChild(self.bellMarkerRoot)
	for ____, data in ipairs(self.chapter.guards) do
		local ____self_guards_1 = self.guards
		____self_guards_1[#____self_guards_1 + 1] = __TS__New(____exports.Patrol, data)
	end
	if self.mode ~= "story" then
		self:applyChallenge()
	end
	self:updateCamera()
end
function ReturningHomeGame.prototype.addSanctuary(self, x, z)
	if self.mode == "endurance" then
		return
	end
	local lantern = Model3D(MODEL .. "lantern.glb")
	if lantern ~= nil then
		lantern.position = Vec3(x + 0.6, 0.18, z + 0.6)
		lantern.scale = Vec3(0.55, 0.55, 0.55)
		Director.entry.scene:addChild(lantern)
	end
	local glow = PointLight3D()
	glow.position = Vec3(x + 0.6, 0.8, z + 0.6)
	glow.color = Color3(6750165)
	glow.intensity = 18
	glow.range = 4.5
	Director.entry.scene:addChild(glow)
end
function ReturningHomeGame.prototype.applyChallenge(self)
	local seed = self.challengeSeed ~= 0 and self.challengeSeed or math.floor(App.rand % 2147483647)
	local cells = {}
	do
		local z = 1
		while z < #self.chapter.map - 1 do
			do
				local x = 1
				while x < #self.chapter.map[z + 1] - 1 do
					local tile = string.sub(self.chapter.map[z + 1], x + 1, x + 1)
					if tile == "." and distance({x = x * TILE_SIZE, z = z * TILE_SIZE}, self.chapter.spawn) > 4 then
						cells[#cells + 1] = {x = x * TILE_SIZE, z = z * TILE_SIZE}
					end
					x = x + 1
				end
			end
			z = z + 1
		end
	end
	for ____, pickup in ipairs(self.pickups) do
		seed = (seed * 1103515245 + 12345) % 2147483647
		local index = math.floor(seed % #cells)
		local cell = cells[index + 1]
		if cell ~= nil then
			pickup.x = cell.x
			pickup.z = cell.z
			pickup.node.position = Vec3(cell.x, 0.05, cell.z)
			__TS__ArraySplice(cells, index, 1)
		end
	end
	for ____, guard in ipairs(self.guards) do
		guard:boostSpeed(1.15)
	end
end
function ReturningHomeGame.prototype.update(self, dt)
	if self.phase ~= "playing" then
		self:forcePlayerIdle()
		self:refreshHud()
		return
	end
	self.elapsed = self.elapsed + dt
	self.bellCooldown = math.max(0, self.bellCooldown - dt)
	self.footstepCooldown = math.max(0, self.footstepCooldown - dt)
	local x = -self.touchMove.x
	local z = self.touchMove.z
	if Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") then
		x = x + 1
	end
	if Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") then
		x = x - 1
	end
	if Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") then
		z = z - 1
	end
	if Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") then
		z = z + 1
	end
	x = x - Controller:getAxis(0, "leftx")
	z = z - Controller:getAxis(0, "lefty")
	local direction = normalize(x, z)
	local moving = math.abs(direction.x) + math.abs(direction.z) > 0.05
	self.playerMoving = moving
	if moving then
		local speed = self.quiet and 1.55 or 2.8
		local nextX = self.player.x + direction.x * speed * dt
		local nextZ = self.player.z + direction.z * speed * dt
		if not blocked(self.chapter, nextX, self.player.z, PLAYER_RADIUS) then
			self.player.x = nextX
		end
		if not blocked(self.chapter, self.player.x, nextZ, PLAYER_RADIUS) then
			self.player.z = nextZ
		end
		if self.playerRoot then
			local targetYaw = math.atan(direction.x, direction.z) * 180 / math.pi
			local deltaYaw = targetYaw - self.playerYaw
			while deltaYaw > 180 do
				deltaYaw = deltaYaw - 360
			end
			while deltaYaw < -180 do
				deltaYaw = deltaYaw + 360
			end
			self.playerYaw = self.playerYaw + deltaYaw
			self.playerRoot.angleY = self.playerYaw
		end
	end
	if self.idleModel then
		self.idleModel.visible = not moving
	end
	if self.walkModel then
		self.walkModel.visible = moving
		self.walkModel.speed = self.quiet and 0.65 or 1
	end
	local protectedPlayer = self.elapsed < self.safeUntil or self.inSanctuary
	if moving and self.footstepCooldown <= 0 and not protectedPlayer then
		self:emitFootstep()
		self.footstepCooldown = self.quiet and 0.7 or FAST_FOOTSTEP_INTERVAL
	end
	self.lastWalking = moving
	if self.playerRoot then
		self.playerRoot.position = Vec3(self.player.x, 0, self.player.z)
	end
	self.alert = 0
	for ____, guard in ipairs(self.guards) do
		if guard:update(
			dt,
			self.elapsed,
			self.player,
			moving,
			self.quiet,
			protectedPlayer,
			self.chapter
		) then
			self:caught()
			break
		end
		self.alert = math.max(self.alert, guard.suspicion)
	end
	for ____, pickup in ipairs(self.pickups) do
		do
			if pickup.collected then
				goto __continue227
			end
			local ____pickup_node_2, ____angleY_3 = pickup.node, "angleY"
			____pickup_node_2[____angleY_3] = ____pickup_node_2[____angleY_3] + 55 * dt
			pickup.node.y = 0.68 + math.sin(self.elapsed * 2.4 + pickup.x) * 0.075
			if distance(self.player, pickup) < 0.8 then
				self:collect(pickup)
			end
		end
		::__continue227::
	end
	local onSanctuary = tileAt(self.chapter, self.player.x, self.player.z) == "H" and self.mode ~= "endurance"
	if onSanctuary and not self.inSanctuary then
		self.inSanctuary = true
		self.checkpoint = {x = self.player.x, z = self.player.z}
		for ____, guard in ipairs(self.guards) do
			guard:reset()
		end
		self:tell("青灯记住了你的脚步 · 这里可以安心停留", 3)
	elseif not onSanctuary then
		self.inSanctuary = false
	end
	if distance(self.player, self.exit) < 1 then
		self:tryExit()
	end
	self:updateNoiseFeedback()
	self:updateCamera()
	self:refreshHud()
end
function ReturningHomeGame.prototype.updateCamera(self)
	local maxX = (#self.chapter.map[1] - 1) * TILE_SIZE
	local maxZ = (#self.chapter.map - 1) * TILE_SIZE
	local focusX = clamp(self.player.x, 4, maxX - 4)
	local focusZ = clamp(self.player.z + 1.2, 4, maxZ - 4)
	self.camera:lookAt(
		Vec3(focusX, 10.5, focusZ - 8.8),
		Vec3(focusX, 0, focusZ)
	)
end
function ReturningHomeGame.prototype.collect(self, pickup)
	pickup.collected = true
	pickup.node.visible = false
	if pickup.kind == "seal" then
		self.sealCount = self.sealCount + 1
		for ____, guard in ipairs(self.guards) do
			guard:setSealAlert(self.sealCount)
		end
		self:play("seal")
		if self.sealCount == 3 then
			for ____, guard in ipairs(self.guards) do
				guard:hearDoor(self.exit, self.elapsed)
			end
			self:showBellMarker(self.exit, 4.8)
			self:tell("三枚灯印已齐！朱门开启的声响惊动了全部纸人", 4)
		elseif self.sealCount == 2 then
			self:tell("第二枚灯印已得 · 纸人的巡查更快了", 3)
		else
			self:tell("寻回第一枚灯印 · 纸人的巡查仍很慢", 3)
		end
	else
		self.coinCount = self.coinCount + 1
		self:play("bell")
		self:tell(
			("拾到铜钱 · " .. tostring(self.coinCount)) .. " / 3",
			2
		)
	end
end
function ReturningHomeGame.prototype.toggleQuiet(self)
	if self.phase ~= "playing" then
		return
	end
	self.quiet = not self.quiet
	if self.quietButtonLabel ~= nil then
		self.quietButtonLabel.text = self.quiet and "轻步：已开\n点击恢复" or "轻步：未开\n点击放轻"
	end
	self:play("seal")
	self:tell(self.quiet and "轻步中 · 脚步很静，暴露速度更慢" or "恢复快走 · 速度更快，近处纸人能听见脚步", 2)
end
function ReturningHomeGame.prototype.ringBell(self)
	if self.phase ~= "playing" or self.bellCooldown > 0 then
		return
	end
	self.bellCooldown = BELL_COOLDOWN
	self:play("bell")
	local bellPoint = {x = self.player.x, z = self.player.z}
	local listeners = 0
	for ____, guard in ipairs(self.guards) do
		if distance(guard.position, bellPoint) <= BELL_HEARING_RADIUS and guard:hearBell(bellPoint, self.elapsed) then
			listeners = listeners + 1
		end
	end
	self:showBellMarker(bellPoint, 4.2)
	self:tell(listeners > 0 and "纸人正往铃声处移动 · 快走离开，再躲好切回轻步" or "铃声未引来纸人 · 等纸人走近后再试", 3.5)
end
function ReturningHomeGame.prototype.emitFootstep(self)
	local hearingRadius = self.quiet and QUIET_HEARING_RADIUS or FAST_HEARING_RADIUS
	for ____, guard in ipairs(self.guards) do
		if distance(guard.position, self.player) <= hearingRadius then
			guard:hearFootstep(self.player, self.elapsed)
		end
	end
	if not self.quiet then
		self:play("step")
		self.footstepWaveUntil = self.elapsed + 0.42
	end
end
function ReturningHomeGame.prototype.showBellMarker(self, point, duration)
	self.bellMarkerUntil = self.elapsed + duration
	if self.bellMarkerRoot then
		self.bellMarkerRoot.position = Vec3(point.x, 0, point.z)
	end
end
function ReturningHomeGame.prototype.updateNoiseFeedback(self)
	if self.footstepWave then
		local remaining = self.footstepWaveUntil - self.elapsed
		self.footstepWave.visible = remaining > 0
		if remaining > 0 then
			local progress = 1 - remaining / 0.42
			self.footstepWaveDraw:clear()
			drawRing(
				self.footstepWaveDraw,
				22 + progress * 28,
				2.2,
				Color(2431701366)
			)
		end
	end
	if self.bellMarker then
		local remaining = self.bellMarkerUntil - self.elapsed
		self.bellMarker.visible = remaining > 0
		if remaining > 0 then
			local pulse = (math.sin(self.elapsed * 8) + 1) * 0.5
			self.bellMarkerDraw:clear()
			drawRing(
				self.bellMarkerDraw,
				30 + pulse * 8,
				2.6,
				Color(3237990758)
			)
			drawRing(
				self.bellMarkerDraw,
				48 + pulse * 6,
				1.5,
				Color(1895813478)
			)
		end
	end
end
function ReturningHomeGame.prototype.toggleSound(self)
	self.sound = not self.sound
	self.save.sound = self.sound
	if self.sound then
		self.ambience = Audio:play(AUDIO .. "ambience.wav", true)
	else
		Audio:stopAll(0.15)
	end
	self:saveProgress()
	self:tell(self.sound and "声音已开启" or "声音已关闭", 2)
end
function ReturningHomeGame.prototype.caught(self)
	if self.elapsed < self.safeUntil or self.inSanctuary or self.phase ~= "playing" then
		return
	end
	self.lives = self.lives - 1
	self.mistakes = self.mistakes + 1
	self.alert = 0
	self:play("caught")
	for ____, guard in ipairs(self.guards) do
		guard:reset()
	end
	if self.lives <= 0 then
		self.phase = "defeat"
		self:showResult("灯火已熄", "纸人发现了你三次\n请重新挑战，或返回开场")
		return
	end
	self.player = {x = self.checkpoint.x, z = self.checkpoint.z}
	self.safeUntil = self.elapsed + 2.5
	self.inSanctuary = false
	self:tell("青灯护住了你 · 灯印保留，换条路再试试", 4)
end
function ReturningHomeGame.prototype.tryExit(self)
	if self.phase ~= "playing" then
		return
	end
	if self.mode == "endurance" and self.elapsed < 90 then
		self:tell(
			("灯火尚未稳住，再坚持 " .. tostring(math.ceil(90 - self.elapsed))) .. " 秒",
			2
		)
		return
	end
	if self.mode == "collector" and self.coinCount < 3 then
		self:tell(
			("还有 " .. tostring(3 - self.coinCount)) .. " 枚旧铜钱遗落在宅中",
			2
		)
		return
	end
	if self.sealCount < 3 then
		self:tell(
			("还差 " .. tostring(3 - self.sealCount)) .. " 枚灯印，朱门尚未开启",
			2
		)
		return
	end
	self.phase = "victory"
	self:play("win")
	local stars = 1 + (self.coinCount >= 3 and 1 or 0) + (self.mistakes == 0 and 1 or 0)
	local score = math.max(
		0,
		3000 + self.coinCount * 600 - self.mistakes * 700 - math.floor(self.elapsed * 8)
	)
	if self.mode == "story" then
		self.save.unlocked = math.max(
			self.save.unlocked,
			math.min(2, self.chapterIndex + 1)
		)
		self.save.stars[self.chapterIndex + 1] = math.max(self.save.stars[self.chapterIndex + 1] ~= nil and self.save.stars[self.chapterIndex + 1] or 0, stars)
		self.save.best[self.chapterIndex + 1] = math.max(self.save.best[self.chapterIndex + 1] ~= nil and self.save.best[self.chapterIndex + 1] or 0, score)
		self:saveProgress()
	end
	self:showResult(
		"归灯已明",
		(((((("评分 " .. string.rep(
			"★",
			math.floor(stars)
		)) .. string.rep(
			"☆",
			math.floor(3 - stars)
		)) .. "\n得分 ") .. tostring(score)) .. " · 用时 ") .. tostring(math.floor(self.elapsed))) .. " 秒"
	)
end
function ReturningHomeGame.prototype.nextChapter(self)
	if self.mode ~= "story" then
		self:showMenu()
		return
	end
	if self.chapterIndex >= #chapters - 1 then
		self.phase = "ending"
		self:showResult("尾声 · 灯归家中", "雨声渐远，旧宅里的每一盏灯都记住了归家人的脚步。\n九枚星愿点亮新的归途。")
	else
		self:startChapter(self.chapterIndex + 1, "story")
	end
end
function ReturningHomeGame.prototype.pause(self)
	self.phase = "paused"
	self:showResult("暂歇廊下", "灯印与青灯位置已保留")
end
function ReturningHomeGame.prototype.resume(self)
	self.phase = "playing"
	self.overlay.visible = false
	self.hud.visible = true
end
function ReturningHomeGame.prototype.showResult(self, titleText, bodyText)
	self:forcePlayerIdle()
	self.hud.visible = false
	self.overlay.visible = true
	self.resultTitle = titleText
	self.resultBody = bodyText
	self:renderResult()
end
function ReturningHomeGame.prototype.renderResult(self)
	self.overlay:removeAllChildren()
	local compact = self.uiCompact
	local title = self:text(self.resultTitle, compact and 38 or 46)
	title.position = Vec2(0, 100)
	self.overlay:addChild(title)
	local body = self:text(self.resultBody, compact and 18 or 22)
	body.lineGap = 10
	body.position = Vec2(0, 20)
	self.overlay:addChild(body)
	local gap = 18
	local buttonWidth = compact and 190 or 220
	local actions = {}
	if self.phase == "paused" then
		actions[#actions + 1] = {
			title = "继续游戏",
			action = function() return self:resume() end,
			fill = Color(3995159616)
		}
	elseif self.phase == "defeat" then
		actions[#actions + 1] = {
			title = "重新挑战",
			action = function() return self:startChapter(self.chapterIndex, self.mode) end,
			fill = Color(4003867682)
		}
	elseif self.phase == "victory" then
		actions[#actions + 1] = {
			title = "继续",
			action = function() return self:nextChapter() end,
			fill = Color(3995159616)
		}
	end
	if self.phase == "paused" or self.phase == "defeat" or self.phase == "victory" or self.phase == "ending" then
		actions[#actions + 1] = {
			title = "返回开场",
			action = function() return self:showMenu() end
		}
	end
	local totalWidth = #actions * buttonWidth + math.max(0, #actions - 1) * gap
	do
		local index = 0
		while index < #actions do
			local action = actions[index + 1]
			local x = -totalWidth * 0.5 + buttonWidth * 0.5 + index * (buttonWidth + gap)
			self:overlayButton(
				action.title,
				x,
				-105,
				action.action,
				buttonWidth,
				58,
				action.fill
			)
			index = index + 1
		end
	end
end
function ReturningHomeGame.prototype.tell(self, message, seconds)
	self.hintText = message
	self.hintUntil = App.totalTime + seconds
end
function ReturningHomeGame.prototype.play(self, cue)
	if not self.sound then
		return
	end
	local file = cue
	if cue == "coin" then
		file = "bell"
	end
	Audio:play((AUDIO .. file) .. ".wav")
end
function ReturningHomeGame.prototype.refreshHud(self)
	if self.phase ~= "playing" then
		return
	end
	self.status.text = ((((("灯印 " .. tostring(self.sealCount)) .. " / 三    铜钱 ") .. tostring(self.coinCount)) .. " / 三\n生命 ") .. tostring(self.lives)) .. " 条"
	local mission = self.sealCount >= 3 and "灯印已齐 · 前往朱门" or "寻回灯印，点亮回家的路"
	if self.mode == "endurance" and self.elapsed < 90 then
		mission = ("长夜守灯 · " .. tostring(math.ceil(90 - self.elapsed))) .. "秒"
	elseif self.mode == "collector" and self.coinCount < 3 then
		mission = ("搜寻旧物 · 铜钱 " .. tostring(self.coinCount)) .. "/3"
	end
	self.objective.text = (self.chapter.title .. "\n") .. mission
	self.alertText.text = ("暴露  " .. tostring(math.floor(self.alert * 100))) .. "%"
	self.alertText.color3 = self.alert > 0.66 and Color3(16730429) or (self.alert > 0.2 and Color3(16763477) or Color3(8644540))
	local footstepState = not self.playerMoving and "脚步：静止" or (self.quiet and "脚步：安静" or "脚步：有脚步声")
	local bellState = self.bellCooldown <= 0 and "铃：可用" or ("铃：" .. tostring(math.ceil(self.bellCooldown))) .. "秒"
	self.modeText.text = (footstepState .. "  ·  ") .. bellState
	if self.bellButtonLabel then
		self.bellButtonLabel.text = self.bellCooldown <= 0 and "响铃\n引开纸人" or ("响铃\n" .. tostring(math.ceil(self.bellCooldown))) .. " 秒"
	end
	self.alertMeter:clear()
	local meterWidth = self.uiWidth - 52
	if self.alert > 0 then
		self.alertMeter:drawPolygon(
			{
				Vec2(-meterWidth * 0.5, -16),
				Vec2(-meterWidth * 0.5, 16),
				Vec2(-meterWidth * 0.5 + meterWidth * self.alert, 16),
				Vec2(-meterWidth * 0.5 + meterWidth * self.alert, -16)
			},
			Color(self.alert > 0.66 and 2863476774 or 2862250284)
		)
	end
	self.hint.text = App.totalTime < self.hintUntil and self.hintText or (self.inSanctuary and "青灯下很安全，观察纸人的巡逻再出发" or (self.quiet and "轻步中 · 更安静，也更难被远处发现" or "灯光中会逐渐暴露，躲到墙或屏风后"))
	self:drawMap()
end
function ReturningHomeGame.prototype.drawMap(self)
	self.minimap:clear()
	local scale = 7
	local mapWidth = #self.chapter.map[1]
	local width = mapWidth * scale
	local height = #self.chapter.map * scale
	local function projectX(tileX)
		return -(tileX - mapWidth / 2 + 0.5) * scale
	end
	self.minimap:drawPolygon(
		{
			Vec2(-width / 2 - 5, -height / 2 - 5),
			Vec2(-width / 2 - 5, height / 2 + 5),
			Vec2(width / 2 + 5, height / 2 + 5),
			Vec2(width / 2 + 5, -height / 2 - 5)
		},
		Color(3222415650),
		2,
		Color(2966927210)
	)
	do
		local z = 0
		while z < #self.chapter.map do
			local row = self.chapter.map[z + 1]
			do
				local x = 0
				while x < #row do
					local tile = string.sub(row, x + 1, x + 1)
					if tile == "#" or tile == "T" then
						local px = projectX(x)
						local py = (z - #self.chapter.map / 2 + 0.5) * scale
						self.minimap:drawPolygon(
							{
								Vec2(px - 3, py - 3),
								Vec2(px - 3, py + 3),
								Vec2(px + 3, py + 3),
								Vec2(px + 3, py - 3)
							},
							Color(tile == "#" and 4284314466 or 4282224504)
						)
					end
					x = x + 1
				end
			end
			z = z + 1
		end
	end
	local function project(point)
		return Vec2(
			projectX(point.x / TILE_SIZE),
			(point.z / TILE_SIZE - #self.chapter.map / 2 + 0.5) * scale
		)
	end
	for ____, pickup in ipairs(self.pickups) do
		if not pickup.collected then
			self.minimap:drawDot(
				project(pickup),
				2.5,
				Color(4294954850)
			)
		end
	end
	for ____, guard in ipairs(self.guards) do
		self.minimap:drawDot(
			project(guard.position),
			2.8,
			Color(4294928722)
		)
	end
	self.minimap:drawDot(
		project(self.exit),
		3.2,
		Color(4293873474)
	)
	self.minimap:drawDot(
		project(self.player),
		3.5,
		Color(4294967295)
	)
end
return ____exports
