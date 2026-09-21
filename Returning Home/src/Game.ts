import {
	App,
	Audio,
	AxisName,
	Billboard,
	ButtonName,
	Camera3D,
	Color,
	Color3,
	Content,
	Controller,
	DirectionalLight3D,
	Director,
	DrawNode,
	json,
	Keyboard,
	KeyName,
	Label,
	Model3D,
	Node,
	Node3D,
	PointLight3D,
	Size,
	Sprite,
	Surface3D,
	TextAlign,
	Vec2,
	Vec3,
	View,
} from "Dora";
import {ChapterData, chapters, GuardData, Point, TILE_SIZE} from "src/Data";

type Phase = "menu" | "playing" | "paused" | "victory" | "defeat" | "ending";
type Mode = "story" | "daily" | "endurance" | "collector";
type Pickup = {kind: "seal" | "coin"; x: number; z: number; node: Model3D.Type; collected: boolean};
type SaveData = {unlocked: number; stars: number[]; best: number[]; sound: boolean};
type GuardState = "patrol" | "investigate" | "chase" | "search";

const MODEL = "Assets/Model/";
const UNITY = "Assets/Unity/Assets/ReturningHome30/";
const AUDIO = UNITY + "Audio/";
const FONT = UNITY + "Resources/ReturningHome30Chinese.ttf";
const FULL_FONT = FONT;
const SAVE_FILE = Content.writablePath + "/returning-home-30-save.json";
const PLAYER_RADIUS = 0.4;
// Unity Screen prefab: BoxCollider 1.6 x 1.7 x 0.22, uniformly scaled by
// 0.8 and rotated 90 degrees around Y.
const SCREEN_HALF_WIDTH = 0.22 * 0.8 * 0.5;
const SCREEN_HALF_LENGTH = 1.6 * 0.8 * 0.5;
const FAST_FOOTSTEP_INTERVAL = 0.5;
const FAST_HEARING_RADIUS = 5;
const QUIET_HEARING_RADIUS = 1.3;
const BELL_HEARING_RADIUS = 9.5;
const BELL_COOLDOWN = 10;

const clamp = (value: number, minimum: number, maximum: number) => math.max(minimum, math.min(maximum, value));
const distance = (a: Point, b: Point) => {
	const x = a.x - b.x;
	const z = a.z - b.z;
	return math.sqrt(x * x + z * z);
};
const normalize = (x: number, z: number): Point => {
	const length = math.sqrt(x * x + z * z);
	return length > 0.0001 ? {x: x / length, z: z / length} : {x: 0, z: 0};
};
const drawRing = (draw: DrawNode.Type, radius: number, width: number, color: Color.Type) => {
	const segments = 28;
	for (let index = 0; index < segments; index++) {
		const first = index * math.pi * 2 / segments;
		const second = (index + 1) * math.pi * 2 / segments;
		draw.drawSegment(Vec2(math.cos(first) * radius, math.sin(first) * radius), Vec2(math.cos(second) * radius, math.sin(second) * radius), width, color);
	}
};
const tileAt = (chapter: ChapterData, x: number, z: number) => {
	const row = math.floor(z / TILE_SIZE + 0.5);
	const column = math.floor(x / TILE_SIZE + 0.5);
	if (row < 0 || row >= chapter.map.length) return "#";
	if (column < 0 || column >= chapter.map[row].length) return "#";
	return string.sub(chapter.map[row], column + 1, column + 1);
};
const blocked = (chapter: ChapterData, x: number, z: number, padding = 0) => {
	if (tileAt(chapter, x, z) === "#") return true;
	const centerRow = math.floor(z / TILE_SIZE + 0.5);
	const centerColumn = math.floor(x / TILE_SIZE + 0.5);
	// Padding can extend the player's capsule just over a tile boundary, so
	// inspect neighbouring cells instead of relying on tileAt() alone.
	for (let row = centerRow - 1; row <= centerRow + 1; row++) {
		if (row < 0 || row >= chapter.map.length) continue;
		for (let column = centerColumn - 1; column <= centerColumn + 1; column++) {
			if (column < 0 || column >= chapter.map[row].length) continue;
			if (string.sub(chapter.map[row], column + 1, column + 1) !== "T") continue;
			if (
				math.abs(x - column * TILE_SIZE) <= SCREEN_HALF_WIDTH + padding &&
				math.abs(z - row * TILE_SIZE) <= SCREEN_HALF_LENGTH + padding
			) return true;
		}
	}
	return false;
};

export class Patrol {
	public suspicion = 0;
	public position: Point;
	public yaw = 0;
	public state: GuardState = "patrol";
	private waypoint = 1;
	private challengeSpeed = 1;
	private sealAlert = 0;
	private pause = 0;
	private investigatePoint: Point = {x: 0, z: 0};
	private investigateDeadline = 0;
	private investigateSearchDuration = 3.2;
	private lastSeen: Point;
	private pursuitUntil = 0;
	private searchUntil = 0;
	private searchTurnTimer = 0;
	private searchDirection = 1;
	private root: Node3D.Type;
	private markLabel: Label.Type | undefined;
	private mark: Surface3D.Type | undefined;
	private cone: Surface3D.Type | undefined;
	private coneDraw = DrawNode();

	public constructor(public readonly data: GuardData) {
		this.position = {x: data.route[0].x, z: data.route[0].z};
		this.lastSeen = {x: this.position.x, z: this.position.z};
		this.root = Node3D();
		this.root.position = Vec3(this.position.x, 0, this.position.z);
		const model = Model3D(MODEL + "guardian.glb");
		if (model !== undefined) {
			model.scale = Vec3(0.82, 0.82, 0.82);
			this.root.addChild(model);
		}

		const width = data.range * math.tan(data.halfAngle * math.pi / 180) * 2;
		this.cone = Surface3D(this.coneDraw, Size(width, data.range), Size(256, 256));
		if (this.cone !== undefined) {
			this.cone.position = Vec3(0, 0.035, data.range * 0.5);
			this.cone.angleX = -90;
			this.root.addChild(this.cone);
		}

		const alert = Label(FONT, 54, true);
		if (alert) {
			alert.text = "!";
			alert.color3 = Color3(0xffcf44);
			this.markLabel = alert;
			this.mark = Surface3D(alert, Size(0.5, 0.7), Size(96, 128));
			if (this.mark) {
				this.mark.position = Vec3(0, 2.1, 0);
				this.mark.billboard = Billboard.YAxis;
				this.mark.visible = false;
				this.root.addChild(this.mark);
			}
		}
		Director.entry.scene.addChild(this.root);
	}

	public hearFootstep(point: Point, elapsed: number) {
		if (this.state === "chase") return false;
		this.beginInvestigation(point, elapsed, 2.4, 2.2);
		this.suspicion = math.max(this.suspicion, 0.08);
		return true;
	}

	public hearBell(point: Point, elapsed: number) {
		// A guard that has positively identified the player cannot be reset or
		// redirected by a bell. The bell remains a preparation tool, not a panic
		// button that erases a failed stealth approach.
		if (this.state === "chase" || this.suspicion >= 0.6) return false;
		this.beginInvestigation(point, elapsed, 5.5, 3.6);
		this.suspicion = math.max(this.suspicion, 0.12);
		return true;
	}

	public hearDoor(point: Point, elapsed: number) {
		if (this.state === "chase") return false;
		this.beginInvestigation(point, elapsed, 7, 4.1);
		this.suspicion = math.max(this.suspicion, 0.18);
		return true;
	}

	private beginInvestigation(point: Point, elapsed: number, travelTime: number, searchDuration: number) {
		this.state = "investigate";
		this.investigatePoint = {x: point.x, z: point.z};
		this.investigateDeadline = elapsed + travelTime;
		this.investigateSearchDuration = searchDuration;
		this.pause = 0;
	}

	private beginSearch(elapsed: number, duration: number) {
		this.state = "search";
		this.searchUntil = elapsed + duration + this.sealAlert * 0.5;
		this.searchTurnTimer = 0.65;
		this.searchDirection = -this.searchDirection;
	}

	public reset() {
		this.suspicion = 0;
		this.state = "patrol";
		this.investigateDeadline = 0;
		this.pursuitUntil = 0;
		this.searchUntil = 0;
		this.pause = 0;
	}

	public boostSpeed(multiplier: number) {
		this.challengeSpeed = multiplier;
	}

	public setSealAlert(sealCount: number) {
		this.sealAlert = math.max(0, sealCount - 1);
	}

	public update(dt: number, elapsed: number, player: Point, moving: boolean, quiet: boolean, protectedPlayer: boolean, chapter: ChapterData): boolean {
		const visible = !protectedPlayer && this.canSee(player, chapter);
		if (visible) {
			this.state = "chase";
			this.lastSeen = {x: player.x, z: player.z};
			this.pursuitUntil = elapsed + 3 + this.sealAlert * 0.5;
		} else if (this.state === "chase" && elapsed >= this.pursuitUntil) {
			this.beginSearch(elapsed, 3.2);
		} else if (this.state === "investigate" && elapsed >= this.investigateDeadline) {
			this.beginSearch(elapsed, this.investigateSearchDuration);
		} else if (this.state === "search" && elapsed >= this.searchUntil) {
			this.state = "patrol";
			this.pause = 0.35;
		}

		let target: Point | undefined;
		let turnRate = 105;
		let moveScale = 1;
		if (this.state === "chase") {
			target = this.lastSeen;
			turnRate = 145;
			moveScale = 1.28;
		} else if (this.state === "investigate") {
			target = this.investigatePoint;
			turnRate = 125;
			moveScale = 1.12;
		} else if (this.state === "search") {
			this.searchTurnTimer -= dt;
			if (this.searchTurnTimer <= 0) {
				this.searchTurnTimer += 0.75;
				this.searchDirection = -this.searchDirection;
			}
			this.yaw += this.searchDirection * 62 * dt;
		} else if (this.pause > 0) {
			this.pause -= dt;
		} else {
			target = this.data.route[this.waypoint];
		}

		if (target) {
			const direction = normalize(target.x - this.position.x, target.z - this.position.z);
			const desired = math.atan(direction.x, direction.z) * 180 / math.pi;
			let difference = (desired - this.yaw + 540) % 360 - 180;
			difference = clamp(difference, -turnRate * dt, turnRate * dt);
			this.yaw += difference;
			if (this.pause <= 0 && math.abs(difference) < 32) {
				const remaining = distance(this.position, target);
				const speed = this.data.speed * this.challengeSpeed * (1 + this.sealAlert * 0.06) * moveScale;
				const step = math.min(speed * dt, remaining);
				const nextX = this.position.x + direction.x * step;
				const nextZ = this.position.z + direction.z * step;
				if (!blocked(chapter, nextX, this.position.z, 0.28)) this.position.x = nextX;
				if (!blocked(chapter, this.position.x, nextZ, 0.28)) this.position.z = nextZ;
				if (distance(this.position, target) < 0.2) {
					if (this.state === "investigate") this.beginSearch(elapsed, this.investigateSearchDuration);
					else if (this.state === "chase" && !visible) this.beginSearch(elapsed, 3.2);
					else if (this.state === "patrol") {
					this.waypoint = (this.waypoint + 1) % this.data.route.length;
					this.pause = 0.65;
					}
				}
			}
		}

		const exposure = quiet ? 0.75 : moving ? 1.25 : 1;
		this.suspicion = clamp(this.suspicion + dt * (visible ? exposure / this.data.noticeSeconds : -0.35), 0, 1);
		this.root.position = Vec3(this.position.x, 0, this.position.z);
		this.root.angleY = this.yaw;
		this.updateCone(chapter);
		if (this.mark) {
			this.mark.visible = this.state !== "patrol" || this.suspicion > 0.05;
			this.mark.scale = Vec3(1 + this.suspicion * 0.35, 1 + this.suspicion * 0.35, 1);
		}
		if (this.markLabel) {
			this.markLabel.text = this.state === "chase" ? "!" : "?";
			this.markLabel.color3 = this.state === "chase" ? Color3(0xff493d) : Color3(0xffcf44);
		}
		return this.suspicion >= 1;
	}

	private updateCone(chapter: ChapterData) {
		const range = this.data.range;
		const fullWidth = this.data.range * math.tan(this.data.halfAngle * math.pi / 180) * 2;
		const points: Vec2.Type[] = [Vec2(0, 128)];
		const rayCount = 32;
		for (let index = 0; index <= rayCount; index++) {
			const relative = -this.data.halfAngle + this.data.halfAngle * 2 * index / rayCount;
			const relativeRadians = relative * math.pi / 180;
			const worldRadians = (this.yaw + relative) * math.pi / 180;
			const rayX = math.sin(worldRadians);
			const rayZ = math.cos(worldRadians);
			let clear = 0;
			let blockedAt = range;
			const step = TILE_SIZE / 16;
			for (let distanceAlongRay = step; distanceAlongRay <= range; distanceAlongRay += step) {
				if (blocked(chapter, this.position.x + rayX * distanceAlongRay, this.position.z + rayZ * distanceAlongRay)) {
					blockedAt = distanceAlongRay;
					break;
				}
				clear = distanceAlongRay;
			}
			if (blockedAt < range) {
				for (let refine = 0; refine < 5; refine++) {
					const middle = (clear + blockedAt) * 0.5;
					if (blocked(chapter, this.position.x + rayX * middle, this.position.z + rayZ * middle)) blockedAt = middle;
					else clear = middle;
				}
			} else clear = range;
			const localX = math.sin(relativeRadians) * clear;
			const localZ = math.cos(relativeRadians) * clear;
			points.push(Vec2(-localX / fullWidth * 256, 128 - localZ / this.data.range * 256));
		}
		this.coneDraw.clear();
		this.coneDraw.drawPolygon(points, Color(0x48f7b338));
	}

	private canSee(player: Point, chapter: ChapterData) {
		const dx = player.x - this.position.x;
		const dz = player.z - this.position.z;
		const range = this.data.range;
		const length = math.sqrt(dx * dx + dz * dz);
		if (length > range || length < 0.001) return false;
		const forwardX = math.sin(this.yaw * math.pi / 180);
		const forwardZ = math.cos(this.yaw * math.pi / 180);
		const cosine = (forwardX * dx + forwardZ * dz) / length;
		if (cosine < math.cos(this.data.halfAngle * math.pi / 180)) return false;
		const samples = math.max(2, math.ceil(length / 0.25));
		for (let i = 1; i < samples; i++) {
			const t = i / samples;
			if (blocked(chapter, this.position.x + dx * t, this.position.z + dz * t)) return false;
		}
		return true;
	}
}

export class ReturningHomeGame {
	private phase: Phase = "menu";
	private mode: Mode = "story";
	private chapterIndex = 0;
	private chapter = chapters[0];
	private elapsed = 0;
	private bellCooldown = 0;
	private footstepCooldown = 0;
	private safeUntil = 0;
	private lives = 3;
	private mistakes = 0;
	private sealCount = 0;
	private coinCount = 0;
	private alert = 0;
	private quiet = false;
	private sound = true;
	private player: Point = {x: 2, z: 2};
	private checkpoint: Point = {x: 2, z: 2};
	private inSanctuary = false;
	private playerRoot: Node3D.Type | undefined;
	private idleModel: Model3D.Type | undefined;
	private walkModel: Model3D.Type | undefined;
	private guards: Patrol[] = [];
	private pickups: Pickup[] = [];
	private exit: Point = {x: 0, z: 0};
	private camera = Camera3D();
	private ui = Node();
	private hud = Node();
	private overlay = Node();
	private minimap = DrawNode();
	private minimapOpen = false;
	private chrome = DrawNode();
	private alertMeter = DrawNode();
	private status = this.text("", 21);
	private objective = this.text("", 18);
	private hint = this.plainText("", 19);
	private alertText = this.text("", 18);
	private modeText = this.plainText("", 18);
	private hintText = "WASD / 方向移动 · Shift轻步 · Space响铃 · Esc暂停";
	private hintUntil = 0;
	private touchMove: Point = {x: 0, z: 0};
	private joystickKnob = DrawNode();
	private joystickCenter = Vec2.zero;
	private joystickActive = false;
	private playerYaw = 0;
	private quietButtonLabel: Label.Type | undefined;
	private bellButtonLabel: Label.Type | undefined;
	private lastWalking = false;
	private playerMoving = false;
	private footstepWaveDraw = DrawNode();
	private footstepWave: Surface3D.Type | undefined;
	private footstepWaveUntil = 0;
	private bellMarkerRoot: Node3D.Type | undefined;
	private bellMarkerDraw = DrawNode();
	private bellMarker: Surface3D.Type | undefined;
	private bellMarkerUntil = 0;
	private save: SaveData = {unlocked: 0, stars: [0, 0, 0], best: [0, 0, 0], sound: true};
	private ambience = 0;
	private challengeSeed = 0;
	private uiWidth = 1280;
	private uiHeight = 720;
	private uiCompact = false;
	private resultTitle = "";
	private resultBody = "";

	public constructor(previewChapter?: number) {
		this.loadSave();
		this.sound = this.save.sound;
		Director.clearCamera();
		Director.entry.scene.removeAllChildren();
		Director.ui.removeAllChildren();
		Director.clearColor = Color(0xff07110f);
		View.fieldOfView = 48;
		View.nearPlaneDistance = 0.1;
		View.farPlaneDistance = 150;
		Director.entry.shadowMapSize = 2048;
		Director.pushCamera(this.camera);
		Director.ui.addChild(this.ui);
		this.ui.addChild(this.hud);
		this.ui.addChild(this.overlay);
		this.rebuildHud();
		this.installInput();
		this.ui.onAppChange(setting => {
			if (setting !== "Size") return;
			this.rebuildHud();
			if (this.phase === "menu") this.renderMenu();
			else if (this.phase !== "playing") this.renderResult();
		});
		if (this.sound) this.ambience = Audio.play(AUDIO + "ambience.wav", true);
		this.showMenu();
		if (previewChapter !== undefined) {
			this.startChapter(previewChapter, "story");
		}
		this.ui.schedule(dt => {
			this.update(dt);
			return false;
		});
	}

	private text(value: string, size: number) {
		const label = Label(FONT, size, true);
		if (!label) throw new Error("归灯中文字体错误");
		label.text = value;
		label.color3 = Color3(0xfff6dc);
		label.outlineColor = Color(0xd0152018);
		label.outlineWidth = 0.18;
		return label;
	}

	private plainText(value: string, size: number) {
		const label = Label(FULL_FONT, size, true);
		if (!label) throw new Error("中文字体错误");
		label.text = value;
		label.color3 = Color3(0xfff6dc);
		label.outlineColor = Color(0xc0152018);
		label.outlineWidth = 0.12;
		return label;
	}

	private makeHud() {
		const width = this.uiWidth;
		const height = this.uiHeight;
		const compact = this.uiCompact;
		const edge = compact ? 16 : 24;
		const contentInset = compact ? 12 : 16;
		const rightWidth = compact ? 218 : 248;
		const leftWidth = width - rightWidth - edge * 2 - contentInset;
		const ink = Color(0xee0f2b24);
		const gold = Color(0xffd2b264);
		this.chrome.drawPolygon([Vec2(-width * 0.5 + edge, height * 0.5 - 138), Vec2(-width * 0.5 + edge, height * 0.5 - edge), Vec2(width * 0.5 - edge, height * 0.5 - edge), Vec2(width * 0.5 - edge, height * 0.5 - 138)], ink, 2, gold);
		this.chrome.drawPolygon([Vec2(-width * 0.5 + edge, height * 0.5 - 184), Vec2(-width * 0.5 + edge, height * 0.5 - 148), Vec2(width * 0.5 - edge, height * 0.5 - 148), Vec2(width * 0.5 - edge, height * 0.5 - 184)], ink, 1, Color(0xaa446b5d));
		this.hud.addChild(this.chrome);
		this.status.textWidth = math.max(220, math.min(310, leftWidth - 30));
		this.status.alignment = TextAlign.Left;
		this.status.lineGap = 4;
		this.status.position = Vec2(-width * 0.5 + edge + contentInset + this.status.textWidth * 0.5, height * 0.5 - 58);
		this.objective.textWidth = math.max(240, math.min(430, leftWidth - 30));
		this.objective.alignment = TextAlign.Left;
		this.objective.position = Vec2(-width * 0.5 + edge + contentInset + this.objective.textWidth * 0.5, height * 0.5 - 112);
		this.hint.position = Vec2(0, height * 0.5 - 210);
		this.alertText.position = Vec2(0, height * 0.5 - 168);
		// Keep gait/noise feedback between the left status block and the right
		// buttons so it remains readable at narrow window sizes.
		this.modeText.position = Vec2(compact ? -20 : 70, height * 0.5 - 72);
		this.alertMeter.position = Vec2(0, height * 0.5 - 168);
		this.hud.addChild(this.alertMeter);
		this.hud.addChild(this.status);
		this.hud.addChild(this.objective);
		this.hud.addChild(this.hint);
		this.hud.addChild(this.alertText);
		this.hud.addChild(this.modeText);
		// Keep the expanded map below the top controls and above the action
		// buttons, where neither UI group can cover it.
		this.minimap.position = Vec2(width * 0.5 - edge - 56, height * 0.5 - 230);
		this.minimap.scaleX = compact ? 0.62 : 0.72;
		this.minimap.scaleY = compact ? 0.62 : 0.72;
		this.minimap.visible = this.minimapOpen;
		this.hud.addChild(this.minimap);
	}

	private makeTouchControls() {
		const width = this.uiWidth;
		const height = this.uiHeight;
		const compact = this.uiCompact;
		const edge = compact ? 16 : 24;
		const contentInset = compact ? 12 : 16;
		const pad = Node();
		// Use a capture surface much larger than the visible pad and filter only
		// the initial press. Normal drags therefore cannot repeatedly leave and
		// re-enter the small visual pad and synthesize Ended/Began events.
		pad.size = Size(math.min(512, width * 0.55), math.min(512, height * 0.55));
		pad.anchor = Vec2.zero;
		// Keep the capture bounds wholly inside the window. A pointer leaving
		// the window must therefore leave this node first and emit TapEnded.
		pad.position = Vec2(-width * 0.5, -height * 0.5);
		pad.swallowTouches = true;
		const padCenter = Vec2(compact ? 96 : 108, compact ? 92 : 80);
		this.joystickCenter = padCenter;
		const base = DrawNode();
		base.drawPolygon([Vec2(0, 76), Vec2(76, 0), Vec2(0, -76), Vec2(-76, 0)], Color(0xd0274c41), 2, Color(0xffd2b264));
		base.position = padCenter;
		pad.addChild(base);
		this.joystickKnob.drawPolygon([Vec2(-28, -28), Vec2(-28, 28), Vec2(28, 28), Vec2(28, -28)], Color(0xffeee6c7));
		const moveLabel = this.text("移", 24);
		moveLabel.color3 = Color3(0x40534b);
		moveLabel.outlineWidth = 0;
		this.joystickKnob.addChild(moveLabel);
		this.joystickKnob.position = padCenter;
		pad.addChild(this.joystickKnob);
		pad.onTapFilter(touch => {
			const offset = touch.location.sub(padCenter);
			if (offset.length > 88) touch.enabled = false;
			else this.joystickActive = true;
		});
		pad.onTapBegan(touch => {
			if (this.joystickActive) this.updatePad(touch.location.sub(padCenter), padCenter);
		});
		pad.onTapMoved(touch => {
			if (this.joystickActive) this.updatePad(touch.location.sub(padCenter), padCenter);
		});
		pad.onTapEnded(() => {
			this.joystickActive = false;
			this.releasePad();
		});
		pad.onExit(() => {
			this.joystickActive = false;
			this.releasePad();
		});
		this.hud.addChild(pad);
		const actionWidth = compact ? 156 : 180;
		const actionX = width * 0.5 - edge - actionWidth * 0.5;
		this.quietButtonLabel = this.button("轻步：未开\n点击放轻", actionX, -height * 0.5 + 200, () => this.toggleQuiet(), actionWidth, 76, Color(0xee214c40));
		this.bellButtonLabel = this.button("响铃\n引开纸人", actionX, -height * 0.5 + 116, () => this.ringBell(), actionWidth, 76, Color(0xeea62c22));
		this.button("舆图", width * 0.5 - edge - contentInset - 164, height * 0.5 - 76, () => {
			this.minimapOpen = !this.minimapOpen;
			this.minimap.visible = this.minimapOpen;
		}, 104, 72, Color(0xdd173c33));
		this.button("暂停", width * 0.5 - edge - contentInset - 52, height * 0.5 - 76, () => this.pause(), 104, 72, Color(0xdd173c33));
		this.quietButtonLabel.text = this.quiet ? "轻步：已开\n点击恢复" : "轻步：未开\n点击放轻";
		this.bellButtonLabel.text = this.bellCooldown <= 0 ? "响铃\n引开纸人" : "响铃\n" + math.ceil(this.bellCooldown) + " 秒";
	}

	private rebuildHud() {
		// A resize can replace the touch surface while a pointer is still held.
		// Reset the movement state first so orientation/window changes never leave
		// the player moving or the virtual stick displaced.
		this.joystickActive = false;
		this.touchMove = {x: 0, z: 0};
		const viewport = App.visualSize;
		const pixelWidth = viewport.width * App.devicePixelRatio;
		const pixelHeight = viewport.height * App.devicePixelRatio;
		const scale = clamp(math.min(pixelWidth / 1280, pixelHeight / 720), 0.6, 1);
		this.uiWidth = math.max(1, pixelWidth / scale);
		this.uiHeight = math.max(1, pixelHeight / scale);
		this.uiCompact = this.uiHeight > this.uiWidth * 1.05;
		this.hud.scaleX = scale;
		this.hud.scaleY = scale;
		this.overlay.scaleX = scale;
		this.overlay.scaleY = scale;
		this.hud.removeAllChildren();
		this.chrome = DrawNode();
		this.alertMeter = DrawNode();
		this.minimap = DrawNode();
		this.joystickKnob = DrawNode();
		this.status = this.text("", this.uiCompact ? 18 : 21);
		this.objective = this.text("", this.uiCompact ? 16 : 18);
		this.hint = this.plainText("", this.uiCompact ? 16 : 19);
		this.alertText = this.text("", this.uiCompact ? 16 : 18);
		this.modeText = this.plainText("", this.uiCompact ? 15 : 18);
		this.makeHud();
		this.makeTouchControls();
		this.hud.visible = this.phase === "playing";
		if (this.phase === "playing") this.refreshHud();
	}

	private updatePad(location: Vec2.Type, center = Vec2.zero) {
		const length = math.sqrt(location.x * location.x + location.y * location.y);
		const scale = length > 64 ? 64 / length : 1;
		const x = location.x * scale;
		const y = location.y * scale;
		this.touchMove = length < 8 ? {x: 0, z: 0} : {x: x / 64, z: y / 64};
		this.joystickKnob.position = Vec2(center.x + x, center.y + y);
	}

	private releasePad() {
		this.touchMove = {x: 0, z: 0};
		this.joystickKnob.position = this.joystickCenter;
	}

	private forcePlayerIdle() {
		this.joystickActive = false;
		this.releasePad();
		this.lastWalking = false;
		this.playerMoving = false;
		if (this.idleModel) this.idleModel.visible = true;
		if (this.walkModel) this.walkModel.visible = false;
	}

	private button(title: string, x: number, y: number, action: () => void, width = 92, height = 58, fill = Color(0xb02a5446)) {
		const node = Node();
		node.size = Size(width, height);
		node.anchor = Vec2.zero;
		node.position = Vec2(x - width * 0.5, y - height * 0.5);
		node.touchEnabled = true;
		node.swallowTouches = true;
		const center = Vec2(width * 0.5, height * 0.5);
		const shape = DrawNode();
		shape.drawPolygon([Vec2(-width * 0.5, -height * 0.5), Vec2(-width * 0.5, height * 0.5), Vec2(width * 0.5, height * 0.5), Vec2(width * 0.5, -height * 0.5)], fill, 2, Color(0xffd2b264));
		shape.position = center;
		node.addChild(shape);
		const label = this.text(title, 19);
		label.position = center;
		node.addChild(label);
		node.onTapped(action);
		this.hud.addChild(node);
		return label;
	}

	private overlayButton(title: string, x: number, y: number, action: () => void, width = 210, height = 56, fill = Color(0xdd173c33)) {
		const node = Node();
		node.size = Size(width, height);
		node.anchor = Vec2.zero;
		node.position = Vec2(x - width * 0.5, y - height * 0.5);
		node.touchEnabled = true;
		node.swallowTouches = true;
		const center = Vec2(width * 0.5, height * 0.5);
		const shape = DrawNode();
		shape.drawPolygon([Vec2(-width * 0.5, -height * 0.5), Vec2(-width * 0.5, height * 0.5), Vec2(width * 0.5, height * 0.5), Vec2(width * 0.5, -height * 0.5)], fill, 2, Color(0xffd2b264));
		shape.position = center;
		node.addChild(shape);
		const label = this.text(title, this.uiCompact ? 17 : 19);
		label.position = center;
		node.addChild(label);
		node.onTapped(action);
		this.overlay.addChild(node);
	}

	private installInput() {
		this.ui.onKeyDown(key => {
			if (key === KeyName.Escape) {
				if (this.phase === "playing") this.pause();
				else if (this.phase === "paused") this.resume();
				else if (this.phase !== "menu") this.showMenu();
				return;
			}
			if (this.phase === "menu") {
				if (key === KeyName.Num1) this.startChapter(0, "story");
				else if (key === KeyName.Num2) this.startChapter(1, "story");
				else if (key === KeyName.Num3) this.startChapter(2, "story");
				else if (key === KeyName.C) this.startChapter(this.save.unlocked, "story");
				else if (key === KeyName.D) this.startDaily();
				else if (key === KeyName.Num4) this.startChapter(this.save.unlocked, "endurance");
				else if (key === KeyName.Num5) this.startChapter(this.save.unlocked, "collector");
				return;
			}
			if (this.phase === "playing") {
				if (key === KeyName.LShift || key === KeyName.RShift) this.toggleQuiet();
				else if (key === KeyName.Space) this.ringBell();
				else if (key === KeyName.M) this.tell("右下角舆图：金=灯印/铜钱，青=安全灯，朱=出口", 4);
				else if (key === KeyName.O) this.toggleSound();
			} else if (this.phase === "victory") {
				if (key === KeyName.Return || key === KeyName.Space) this.nextChapter();
			} else if (this.phase === "defeat") {
				if (key === KeyName.Return || key === KeyName.Space) this.startChapter(this.chapterIndex, this.mode);
			} else if (this.phase === "ending") {
				if (key === KeyName.Return || key === KeyName.Space) this.showMenu();
			}
		});
		this.ui.onButtonDown((_controllerId, button) => {
			if (button === ButtonName.LeftShoulder) this.toggleQuiet();
			else if (button === ButtonName.A) this.ringBell();
			else if (button === ButtonName.Start) {
				if (this.phase === "playing") this.pause();
				else if (this.phase === "paused") this.resume();
			}
		});
	}

	private loadSave() {
		if (!Content.exist(SAVE_FILE)) return;
		const raw = Content.load(SAVE_FILE);
		const [value] = json.decode(raw);
		if (value === undefined || typeof value !== "object") return;
		const data = value as SaveData;
		this.save.unlocked = clamp(data.unlocked !== undefined ? data.unlocked : 0, 0, 2);
		this.save.stars = data.stars !== undefined ? data.stars : [0, 0, 0];
		this.save.best = data.best !== undefined ? data.best : [0, 0, 0];
		this.save.sound = data.sound !== false;
	}

	private saveProgress() {
		const [raw] = json.encode(this.save, true);
		if (raw !== undefined) Content.save(SAVE_FILE, raw);
	}

	private showMenu() {
		this.phase = "menu";
		this.resultTitle = "";
		this.resultBody = "";
		this.hud.visible = false;
		this.overlay.visible = true;
		this.renderMenu();
		Director.entry.scene.removeAllChildren();
		this.camera.lookAt(Vec3(0, 4, 8), Vec3(0, 0, 0));
	}

	private renderMenu() {
		this.overlay.removeAllChildren();
		const width = this.uiWidth;
		const height = this.uiHeight;
		const compact = this.uiCompact;
		const cover = Sprite(UNITY + "Resources/ReturningHome30Cover.png");
		if (cover !== undefined) {
			const coverScale = math.max(width / cover.width, height / cover.height);
			cover.scaleX = coverScale;
			cover.scaleY = coverScale;
			cover.opacity = 0.36;
			cover.color3 = Color3(0x85b8a2);
			this.overlay.addChild(cover);
		}
		const titleSize = compact ? 40 : 50;
		const subtitleSize = compact ? 18 : 22;
		const progressSize = compact ? 16 : 18;
		const infoSize = compact ? 14 : 17;
		const authorSize = compact ? 16 : 18;
		const columns = compact ? 2 : 4;
		const gap = compact ? 12 : 16;
		const buttonWidth = math.min(compact ? 250 : 230, (width - gap * (columns + 1)) / columns);
		const buttonHeight = compact ? 52 : 58;
		const rows = math.ceil(8 / columns);
		const baseTitleY = height * 0.5 - 72;
		const baseFirstY = height * 0.5 - 222;
		const baseInfoY = baseFirstY - rows * (buttonHeight + gap) - 8;
		const baseAuthorY = baseInfoY - (compact ? 34 : 30);
		const groupTop = baseTitleY + titleSize * 0.6;
		const groupBottom = baseAuthorY - authorSize * (compact ? 1.2 : 0.6);
		const centerOffsetY = -(groupTop + groupBottom) * 0.5;

		const title = this.text("古宅惊魂 · 归灯", titleSize);
		title.position = Vec2(0, baseTitleY + centerOffsetY);
		this.overlay.addChild(title);
		const subtitle = this.plainText("一位归家人，三枚灯印，九位巡夜纸人", subtitleSize);
		subtitle.position = Vec2(0, height * 0.5 - 118 + centerOffsetY);
		this.overlay.addChild(subtitle);
		const unlock = this.plainText("章节进度 " + (this.save.unlocked + 1) + "/3 · 已得星 " + (this.save.stars[0] + this.save.stars[1] + this.save.stars[2]) + "/9", progressSize);
		unlock.position = Vec2(0, height * 0.5 - 154 + centerOffsetY);
		this.overlay.addChild(unlock);

		const entries: Array<{title: string; action: () => void; fill?: Color.Type}> = [
			{title: "第一章 · 门庭夜雨", action: () => this.startChapter(0, "story")},
			{title: this.save.unlocked >= 1 ? "第二章 · 回廊迷灯" : "第二章 · 尚未解锁", action: () => { if (this.save.unlocked >= 1) this.startChapter(1, "story"); }},
			{title: this.save.unlocked >= 2 ? "第三章 · 归灯祠堂" : "第三章 · 尚未解锁", action: () => { if (this.save.unlocked >= 2) this.startChapter(2, "story"); }},
			{title: "继续章节", action: () => this.startChapter(this.save.unlocked, "story"), fill: Color(0xee214c40)},
			{title: "每日迷局", action: () => this.startDaily()},
			{title: "长夜守灯", action: () => this.startChapter(this.save.unlocked, "endurance")},
			{title: "搜寻旧物", action: () => this.startChapter(this.save.unlocked, "collector")},
			{title: this.sound ? "声音：开" : "声音：关", action: () => { this.toggleSound(); this.renderMenu(); }},
		];
		const firstY = baseFirstY + centerOffsetY;
		for (let index = 0; index < entries.length; index++) {
			const row = math.floor(index / columns);
			const column = index % columns;
			const count = math.min(columns, entries.length - row * columns);
			const rowWidth = count * buttonWidth + (count - 1) * gap;
			const x = -rowWidth * 0.5 + buttonWidth * 0.5 + column * (buttonWidth + gap);
			const y = firstY - row * (buttonHeight + gap);
			const entry = entries[index];
			this.overlayButton(entry.title, x, y, entry.action, buttonWidth, buttonHeight, entry.fill);
		}
		const info = this.plainText("点击按钮进入 · 游戏内左边摇杆移动，右边轻步与响铃", infoSize);
		info.position = Vec2(0, baseInfoY + centerOffsetY);
		this.overlay.addChild(info);
		let author = Label("sarasa-mono-sc-regular", authorSize, true);
		if (author === undefined) {
			author = this.plainText(compact ? "制作 dfer · https://www.dfer.site/\ndf_business[at]qq.com" : "制作 dfer · https://www.dfer.site/ · df_business[at]qq.com", authorSize);
		} else {
			author.text = compact ? "作者 dfer · https://www.dfer.site/\ndf_business@qq.com" : "作者 dfer · https://www.dfer.site/ · df_business@qq.com";
			author.color3 = Color3(0xfff6dc);
			author.outlineColor = Color(0xc0152018);
			author.outlineWidth = 0.12;
		}
		author.lineGap = 4;
		author.position = Vec2(0, baseAuthorY + centerOffsetY);
		this.overlay.addChild(author);
		const authorLink = Node();
		const authorWidth = math.min(width - 32, compact ? 430 : 620);
		const authorHeight = compact ? 48 : 34;
		authorLink.size = Size(authorWidth, authorHeight);
		authorLink.anchor = Vec2.zero;
		authorLink.position = Vec2(-authorWidth * 0.5, baseAuthorY + centerOffsetY - authorHeight * 0.5);
		authorLink.touchEnabled = true;
		authorLink.swallowTouches = true;
		authorLink.onTapped(() => App.openURL("https://www.dfer.site/"));
		this.overlay.addChild(authorLink);
	}

	private startDaily() {
		const day = tonumber(os.date("%Y%m%d")) || 1;
		this.challengeSeed = day;
		this.startChapter(day % chapters.length, "daily");
	}

	private startChapter(index: number, mode: Mode) {
		if (mode === "story" && index > this.save.unlocked) {
			this.tell("本章节尚未解锁，先完成前一章。", 3);
			return;
		}
		this.chapterIndex = clamp(index, 0, chapters.length - 1);
		this.chapter = chapters[this.chapterIndex];
		this.mode = mode;
		this.phase = "playing";
		this.elapsed = 0;
		this.bellCooldown = 0;
		this.footstepCooldown = 0;
		this.footstepWaveUntil = 0;
		this.bellMarkerUntil = 0;
		this.safeUntil = 2;
		this.lives = mode === "story" ? 3 : 2;
		this.mistakes = 0;
		this.sealCount = 0;
		this.coinCount = 0;
		this.alert = 0;
		this.quiet = false;
		this.minimapOpen = false;
		this.minimap.visible = false;
		if (this.quietButtonLabel) this.quietButtonLabel.text = "轻步：未开\n点击放轻";
		if (this.bellButtonLabel) this.bellButtonLabel.text = "响铃\n引开纸人";
		this.inSanctuary = false;
		this.player = {x: this.chapter.spawn.x, z: this.chapter.spawn.z};
		this.playerYaw = 0;
		this.checkpoint = {x: this.player.x, z: this.player.z};
		this.guards = [];
		this.pickups = [];
		this.overlay.visible = false;
		this.hud.visible = true;
		this.buildChapter();
		this.tell(this.chapter.introduction, 7);
		if (mode === "endurance") this.tell("长夜守灯：青灯暂歇，收齐灯印并坚持九十秒后逃离。", 9);
		if (mode === "collector") this.tell("搜寻旧物：铜钱和灯印全部寻回，才能打开朱门。", 9);
	}

	private buildBackdrop() {
		Director.entry.scene.removeAllChildren();
		const light = DirectionalLight3D();
		light.color = Color3(0xffd9a8);
		light.intensity = 2.3;
		light.angleX = -55;
		light.angleY = 25;
		light.castShadow = true;
		light.shadowSoftness = 2.4;
		Director.entry.scene.addChild(light);
		const floor = Model3D(MODEL + "floor.glb");
		if (floor !== undefined) {
			floor.scale = Vec3(7, 1, 7);
			Director.entry.scene.addChild(floor);
		}
		const lantern = Model3D(MODEL + "lantern.glb");
		if (lantern !== undefined) {
			lantern.position = Vec3(0, 0, 0);
			Director.entry.scene.addChild(lantern);
		}
		this.camera.lookAt(Vec3(8.5, 8.5, 10.5), Vec3(0, 0.8, 0));
	}

	private buildChapter() {
		Director.entry.scene.removeAllChildren();
		const light = DirectionalLight3D();
		light.color = Color3(0xffe0ad);
		light.intensity = 0.72;
		light.angleX = -52;
		light.angleY = 28;
		light.castShadow = true;
		light.shadowBias = 0.0015;
		light.shadowNormalBias = 0.025;
		light.shadowSoftness = 2.2;
		Director.entry.scene.addChild(light);
		const architecture = Model3D(MODEL + "chapter-" + this.chapterIndex + ".glb");
		if (architecture !== undefined) Director.entry.scene.addChild(architecture);

		for (let z = 0; z < this.chapter.map.length; z++) {
			const row = this.chapter.map[z];
			for (let x = 0; x < row.length; x++) {
				const tile = string.sub(row, x + 1, x + 1);
				const worldX = x * TILE_SIZE;
				const worldZ = z * TILE_SIZE;
				if (tile === "K" || tile === "C") {
					const kind = tile === "K" ? "seal" : "coin";
					const model = Model3D(MODEL + kind + ".glb");
					if (model !== undefined) {
						model.position = Vec3(worldX, 0.68, worldZ);
						Director.entry.scene.addChild(model);
						this.pickups.push({kind, x: worldX, z: worldZ, node: model, collected: false});
					}
				}
				if (tile === "H") this.addSanctuary(worldX, worldZ);
				if (tile === "E") {
					this.exit = {x: worldX, z: worldZ};
					const gate = Model3D(MODEL + "gate.glb");
					if (gate !== undefined) {
						gate.position = Vec3(worldX, 0, worldZ);
						Director.entry.scene.addChild(gate);
					}
				}
			}
		}

		this.playerRoot = Node3D();
		this.idleModel = Model3D(MODEL + "cat-idle.glb");
		this.walkModel = Model3D(MODEL + "cat-walk.glb");
		if (this.idleModel !== undefined) {
			this.idleModel.scale = Vec3(0.78, 0.78, 0.78);
			this.idleModel.play("idle", true);
			this.playerRoot.addChild(this.idleModel);
		}
		if (this.walkModel !== undefined) {
			this.walkModel.scale = Vec3(0.78, 0.78, 0.78);
			this.walkModel.play("walk", true);
			this.walkModel.visible = false;
			this.playerRoot.addChild(this.walkModel);
		}
		this.footstepWaveDraw = DrawNode();
		this.footstepWave = Surface3D(this.footstepWaveDraw, Size(2.8, 2.8), Size(128, 128));
		if (this.footstepWave !== undefined) {
			this.footstepWave.position = Vec3(0, 0.04, 0);
			this.footstepWave.angleX = -90;
			this.footstepWave.visible = false;
			this.playerRoot.addChild(this.footstepWave);
		}
		this.playerRoot.position = Vec3(this.player.x, 0, this.player.z);
		Director.entry.scene.addChild(this.playerRoot);

		this.bellMarkerRoot = Node3D();
		this.bellMarkerDraw = DrawNode();
		this.bellMarker = Surface3D(this.bellMarkerDraw, Size(3.2, 3.2), Size(128, 128));
		if (this.bellMarker !== undefined) {
			this.bellMarker.position = Vec3(0, 0.045, 0);
			this.bellMarker.angleX = -90;
			this.bellMarker.visible = false;
			this.bellMarkerRoot.addChild(this.bellMarker);
		}
		Director.entry.scene.addChild(this.bellMarkerRoot);

		for (const data of this.chapter.guards) this.guards.push(new Patrol(data));
		if (this.mode !== "story") this.applyChallenge();
		this.updateCamera();
	}

	private addSanctuary(x: number, z: number) {
		if (this.mode === "endurance") return;
		const lantern = Model3D(MODEL + "lantern.glb");
		if (lantern !== undefined) {
			lantern.position = Vec3(x + 0.6, 0.18, z + 0.6);
			lantern.scale = Vec3(0.55, 0.55, 0.55);
			Director.entry.scene.addChild(lantern);
		}
		const glow = PointLight3D();
		glow.position = Vec3(x + 0.6, 0.8, z + 0.6);
		glow.color = Color3(0x66ffd5);
		glow.intensity = 18;
		glow.range = 4.5;
		Director.entry.scene.addChild(glow);
	}

	private applyChallenge() {
		let seed = this.challengeSeed !== 0 ? this.challengeSeed : math.floor(App.rand % 2147483647);
		const cells: Point[] = [];
		for (let z = 1; z < this.chapter.map.length - 1; z++) {
			for (let x = 1; x < this.chapter.map[z].length - 1; x++) {
				const tile = string.sub(this.chapter.map[z], x + 1, x + 1);
				if (tile === "." && distance({x: x * TILE_SIZE, z: z * TILE_SIZE}, this.chapter.spawn) > 4) cells.push({x: x * TILE_SIZE, z: z * TILE_SIZE});
			}
		}
		for (const pickup of this.pickups) {
			seed = (seed * 1103515245 + 12345) % 2147483647;
			const index = math.floor(seed % cells.length);
			const cell = cells[index];
			if (cell !== undefined) {
				pickup.x = cell.x;
				pickup.z = cell.z;
				pickup.node.position = Vec3(cell.x, 0.05, cell.z);
				cells.splice(index, 1);
			}
		}
		for (const guard of this.guards) guard.boostSpeed(1.15);
	}

	private update(dt: number) {
		if (this.phase !== "playing") {
			this.forcePlayerIdle();
			this.refreshHud();
			return;
		}
		this.elapsed += dt;
		this.bellCooldown = math.max(0, this.bellCooldown - dt);
		this.footstepCooldown = math.max(0, this.footstepCooldown - dt);

		// The imported Unity scene's X axis is mirrored in Dora screen space.
		// Keep all input sources in screen-space semantics: left stays left.
		let x = -this.touchMove.x;
		let z = this.touchMove.z;
		if (Keyboard.isKeyPressed(KeyName.A) || Keyboard.isKeyPressed(KeyName.Left)) x += 1;
		if (Keyboard.isKeyPressed(KeyName.D) || Keyboard.isKeyPressed(KeyName.Right)) x -= 1;
		if (Keyboard.isKeyPressed(KeyName.S) || Keyboard.isKeyPressed(KeyName.Down)) z -= 1;
		if (Keyboard.isKeyPressed(KeyName.W) || Keyboard.isKeyPressed(KeyName.Up)) z += 1;
		x -= Controller.getAxis(0, AxisName.LeftX);
		z -= Controller.getAxis(0, AxisName.LeftY);
		const direction = normalize(x, z);
		const moving = math.abs(direction.x) + math.abs(direction.z) > 0.05;
		this.playerMoving = moving;
		if (moving) {
			const speed = this.quiet ? 1.55 : 2.8;
			const nextX = this.player.x + direction.x * speed * dt;
			const nextZ = this.player.z + direction.z * speed * dt;
			if (!blocked(this.chapter, nextX, this.player.z, PLAYER_RADIUS)) this.player.x = nextX;
			if (!blocked(this.chapter, this.player.x, nextZ, PLAYER_RADIUS)) this.player.z = nextZ;
			if (this.playerRoot) {
				const targetYaw = math.atan(direction.x, direction.z) * 180 / math.pi;
				let deltaYaw = targetYaw - this.playerYaw;
				// Unwrap atan's -180/180 seam. Without this, tiny joystick noise
				// around straight-back movement flips the model by almost 360 degrees.
				while (deltaYaw > 180) deltaYaw -= 360;
				while (deltaYaw < -180) deltaYaw += 360;
				this.playerYaw += deltaYaw;
				this.playerRoot.angleY = this.playerYaw;
			}
		}
		if (this.idleModel) this.idleModel.visible = !moving;
		if (this.walkModel) {
			this.walkModel.visible = moving;
			this.walkModel.speed = this.quiet ? 0.65 : 1;
		}
		const protectedPlayer = this.elapsed < this.safeUntil || this.inSanctuary;
		if (moving && this.footstepCooldown <= 0 && !protectedPlayer) {
			this.emitFootstep();
			this.footstepCooldown = this.quiet ? 0.7 : FAST_FOOTSTEP_INTERVAL;
		}
		this.lastWalking = moving;
		if (this.playerRoot) {
			this.playerRoot.position = Vec3(this.player.x, 0, this.player.z);
		}

		this.alert = 0;
		for (const guard of this.guards) {
			if (guard.update(dt, this.elapsed, this.player, moving, this.quiet, protectedPlayer, this.chapter)) {
				this.caught();
				break;
			}
			this.alert = math.max(this.alert, guard.suspicion);
		}

		for (const pickup of this.pickups) {
			if (pickup.collected) continue;
			pickup.node.angleY += 55 * dt;
			pickup.node.y = 0.68 + math.sin(this.elapsed * 2.4 + pickup.x) * 0.075;
			if (distance(this.player, pickup) < 0.8) this.collect(pickup);
		}

		const onSanctuary = tileAt(this.chapter, this.player.x, this.player.z) === "H" && this.mode !== "endurance";
		if (onSanctuary && !this.inSanctuary) {
			this.inSanctuary = true;
			this.checkpoint = {x: this.player.x, z: this.player.z};
			for (const guard of this.guards) guard.reset();
			this.tell("青灯记住了你的脚步 · 这里可以安心停留", 3);
		} else if (!onSanctuary) this.inSanctuary = false;

		if (distance(this.player, this.exit) < 1) this.tryExit();
		this.updateNoiseFeedback();
		this.updateCamera();
		this.refreshHud();
	}

	private updateCamera() {
		const maxX = (this.chapter.map[0].length - 1) * TILE_SIZE;
		const maxZ = (this.chapter.map.length - 1) * TILE_SIZE;
		const focusX = clamp(this.player.x, 4, maxX - 4);
		const focusZ = clamp(this.player.z + 1.2, 4, maxZ - 4);
		this.camera.lookAt(Vec3(focusX, 10.5, focusZ - 8.8), Vec3(focusX, 0, focusZ));
	}

	private collect(pickup: Pickup) {
		pickup.collected = true;
		pickup.node.visible = false;
		if (pickup.kind === "seal") {
			this.sealCount++;
			for (const guard of this.guards) guard.setSealAlert(this.sealCount);
			this.play("seal");
			if (this.sealCount === 3) {
				for (const guard of this.guards) guard.hearDoor(this.exit, this.elapsed);
				this.showBellMarker(this.exit, 4.8);
				this.tell("三枚灯印已齐！朱门开启的声响惊动了全部纸人", 4);
			} else if (this.sealCount === 2) this.tell("第二枚灯印已得 · 纸人的巡查更快了", 3);
			else this.tell("寻回第一枚灯印 · 纸人的巡查仍很慢", 3);
		} else {
			this.coinCount++;
			this.play("bell");
			this.tell("拾到铜钱 · " + this.coinCount + " / 3", 2);
		}
	}

	private toggleQuiet() {
		if (this.phase !== "playing") return;
		this.quiet = !this.quiet;
		if (this.quietButtonLabel !== undefined) this.quietButtonLabel.text = this.quiet ? "轻步：已开\n点击恢复" : "轻步：未开\n点击放轻";
		this.play("seal");
		this.tell(this.quiet ? "轻步中 · 脚步很静，暴露速度更慢" : "恢复快走 · 速度更快，近处纸人能听见脚步", 2);
	}

	private ringBell() {
		if (this.phase !== "playing" || this.bellCooldown > 0) return;
		this.bellCooldown = BELL_COOLDOWN;
		this.play("bell");
		const bellPoint = {x: this.player.x, z: this.player.z};
		let listeners = 0;
		for (const guard of this.guards) {
			if (distance(guard.position, bellPoint) <= BELL_HEARING_RADIUS && guard.hearBell(bellPoint, this.elapsed)) listeners++;
		}
		this.showBellMarker(bellPoint, 4.2);
		this.tell(listeners > 0 ? "纸人正往铃声处移动 · 快走离开，再躲好切回轻步" : "铃声未引来纸人 · 等纸人走近后再试", 3.5);
	}

	private emitFootstep() {
		const hearingRadius = this.quiet ? QUIET_HEARING_RADIUS : FAST_HEARING_RADIUS;
		for (const guard of this.guards) {
			if (distance(guard.position, this.player) <= hearingRadius) guard.hearFootstep(this.player, this.elapsed);
		}
		if (!this.quiet) {
			this.play("step");
			this.footstepWaveUntil = this.elapsed + 0.42;
		}
	}

	private showBellMarker(point: Point, duration: number) {
		this.bellMarkerUntil = this.elapsed + duration;
		if (this.bellMarkerRoot) this.bellMarkerRoot.position = Vec3(point.x, 0, point.z);
	}

	private updateNoiseFeedback() {
		if (this.footstepWave) {
			const remaining = this.footstepWaveUntil - this.elapsed;
			this.footstepWave.visible = remaining > 0;
			if (remaining > 0) {
				const progress = 1 - remaining / 0.42;
				this.footstepWaveDraw.clear();
				drawRing(this.footstepWaveDraw, 22 + progress * 28, 2.2, Color(0x90f0d176));
			}
		}
		if (this.bellMarker) {
			const remaining = this.bellMarkerUntil - this.elapsed;
			this.bellMarker.visible = remaining > 0;
			if (remaining > 0) {
				const pulse = (math.sin(this.elapsed * 8) + 1) * 0.5;
				this.bellMarkerDraw.clear();
				drawRing(this.bellMarkerDraw, 30 + pulse * 8, 2.6, Color(0xc0ffd166));
				drawRing(this.bellMarkerDraw, 48 + pulse * 6, 1.5, Color(0x70ffd166));
			}
		}
	}

	private toggleSound() {
		this.sound = !this.sound;
		this.save.sound = this.sound;
		if (this.sound) this.ambience = Audio.play(AUDIO + "ambience.wav", true);
		else Audio.stopAll(0.15);
		this.saveProgress();
		this.tell(this.sound ? "声音已开启" : "声音已关闭", 2);
	}

	private caught() {
		if (this.elapsed < this.safeUntil || this.inSanctuary || this.phase !== "playing") return;
		this.lives--;
		this.mistakes++;
		this.alert = 0;
		this.play("caught");
		for (const guard of this.guards) guard.reset();
		if (this.lives <= 0) {
			this.phase = "defeat";
		this.showResult("灯火已熄", "纸人发现了你三次\n请重新挑战，或返回开场");
			return;
		}
		this.player = {x: this.checkpoint.x, z: this.checkpoint.z};
		this.safeUntil = this.elapsed + 2.5;
		this.inSanctuary = false;
		this.tell("青灯护住了你 · 灯印保留，换条路再试试", 4);
	}

	private tryExit() {
		if (this.phase !== "playing") return;
		if (this.mode === "endurance" && this.elapsed < 90) {
			this.tell("灯火尚未稳住，再坚持 " + math.ceil(90 - this.elapsed) + " 秒", 2);
			return;
		}
		if (this.mode === "collector" && this.coinCount < 3) {
			this.tell("还有 " + (3 - this.coinCount) + " 枚旧铜钱遗落在宅中", 2);
			return;
		}
		if (this.sealCount < 3) {
			this.tell("还差 " + (3 - this.sealCount) + " 枚灯印，朱门尚未开启", 2);
			return;
		}
		this.phase = "victory";
		this.play("win");
		const stars = 1 + (this.coinCount >= 3 ? 1 : 0) + (this.mistakes === 0 ? 1 : 0);
		const score = math.max(0, 3000 + this.coinCount * 600 - this.mistakes * 700 - math.floor(this.elapsed * 8));
		if (this.mode === "story") {
			this.save.unlocked = math.max(this.save.unlocked, math.min(2, this.chapterIndex + 1));
			this.save.stars[this.chapterIndex] = math.max(this.save.stars[this.chapterIndex] !== undefined ? this.save.stars[this.chapterIndex] : 0, stars);
			this.save.best[this.chapterIndex] = math.max(this.save.best[this.chapterIndex] !== undefined ? this.save.best[this.chapterIndex] : 0, score);
			this.saveProgress();
		}
		this.showResult("归灯已明", "评分 " + "★".repeat(stars) + "☆".repeat(3 - stars) + "\n得分 " + score + " · 用时 " + math.floor(this.elapsed) + " 秒");
	}

	private nextChapter() {
		if (this.mode !== "story") {
			this.showMenu();
			return;
		}
		if (this.chapterIndex >= chapters.length - 1) {
			this.phase = "ending";
			this.showResult("尾声 · 灯归家中", "雨声渐远，旧宅里的每一盏灯都记住了归家人的脚步。\n九枚星愿点亮新的归途。");
		} else this.startChapter(this.chapterIndex + 1, "story");
	}

	private pause() {
		this.phase = "paused";
		this.showResult("暂歇廊下", "灯印与青灯位置已保留");
	}

	private resume() {
		this.phase = "playing";
		this.overlay.visible = false;
		this.hud.visible = true;
	}

	private showResult(titleText: string, bodyText: string) {
		// Phase changes happen during the playing update, so switch animation in
		// the same call instead of leaving the last walking pose for one frame.
		this.forcePlayerIdle();
		this.hud.visible = false;
		this.overlay.visible = true;
		this.resultTitle = titleText;
		this.resultBody = bodyText;
		this.renderResult();
	}

	private renderResult() {
		this.overlay.removeAllChildren();
		const compact = this.uiCompact;
		const title = this.text(this.resultTitle, compact ? 38 : 46);
		title.position = Vec2(0, 100);
		this.overlay.addChild(title);
		const body = this.text(this.resultBody, compact ? 18 : 22);
		body.lineGap = 10;
		body.position = Vec2(0, 20);
		this.overlay.addChild(body);
		const gap = 18;
		const buttonWidth = compact ? 190 : 220;
		const actions: Array<{title: string; action: () => void; fill?: Color.Type}> = [];
		if (this.phase === "paused") actions.push({title: "继续游戏", action: () => this.resume(), fill: Color(0xee214c40)});
		else if (this.phase === "defeat") actions.push({title: "重新挑战", action: () => this.startChapter(this.chapterIndex, this.mode), fill: Color(0xeea62c22)});
		else if (this.phase === "victory") actions.push({title: "继续", action: () => this.nextChapter(), fill: Color(0xee214c40)});
		if (this.phase === "paused" || this.phase === "defeat" || this.phase === "victory" || this.phase === "ending") actions.push({title: "返回开场", action: () => this.showMenu()});
		const totalWidth = actions.length * buttonWidth + math.max(0, actions.length - 1) * gap;
		for (let index = 0; index < actions.length; index++) {
			const action = actions[index];
			const x = -totalWidth * 0.5 + buttonWidth * 0.5 + index * (buttonWidth + gap);
			this.overlayButton(action.title, x, -105, action.action, buttonWidth, 58, action.fill);
		}
	}

	private tell(message: string, seconds: number) {
		this.hintText = message;
		this.hintUntil = App.totalTime + seconds;
	}

	private play(cue: string) {
		if (!this.sound) return;
		let file = cue;
		if (cue === "coin") file = "bell";
		Audio.play(AUDIO + file + ".wav");
	}

	private refreshHud() {
		if (this.phase !== "playing") return;
		this.status.text = "灯印 " + this.sealCount + " / 三    铜钱 " + this.coinCount + " / 三\n生命 " + this.lives + " 条";
		let mission = this.sealCount >= 3 ? "灯印已齐 · 前往朱门" : "寻回灯印，点亮回家的路";
		if (this.mode === "endurance" && this.elapsed < 90) mission = "长夜守灯 · " + math.ceil(90 - this.elapsed) + "秒";
		else if (this.mode === "collector" && this.coinCount < 3) mission = "搜寻旧物 · 铜钱 " + this.coinCount + "/3";
		this.objective.text = this.chapter.title + "\n" + mission;
		this.alertText.text = "暴露  " + math.floor(this.alert * 100) + "%";
		this.alertText.color3 = this.alert > 0.66 ? Color3(0xff493d) : this.alert > 0.2 ? Color3(0xffca55) : Color3(0x83e7bc);
		const footstepState = !this.playerMoving ? "脚步：静止" : this.quiet ? "脚步：安静" : "脚步：有脚步声";
		const bellState = this.bellCooldown <= 0 ? "铃：可用" : "铃：" + math.ceil(this.bellCooldown) + "秒";
		this.modeText.text = footstepState + "  ·  " + bellState;
		if (this.bellButtonLabel) this.bellButtonLabel.text = this.bellCooldown <= 0 ? "响铃\n引开纸人" : "响铃\n" + math.ceil(this.bellCooldown) + " 秒";
		this.alertMeter.clear();
		const meterWidth = this.uiWidth - 52;
		if (this.alert > 0) this.alertMeter.drawPolygon([Vec2(-meterWidth * 0.5, -16), Vec2(-meterWidth * 0.5, 16), Vec2(-meterWidth * 0.5 + meterWidth * this.alert, 16), Vec2(-meterWidth * 0.5 + meterWidth * this.alert, -16)], Color(this.alert > 0.66 ? 0xaaad3026 : 0xaa9a792c));
		this.hint.text = App.totalTime < this.hintUntil ? this.hintText : (this.inSanctuary ? "青灯下很安全，观察纸人的巡逻再出发" : this.quiet ? "轻步中 · 更安静，也更难被远处发现" : "灯光中会逐渐暴露，躲到墙或屏风后");
		this.drawMap();
	}

	private drawMap() {
		this.minimap.clear();
		const scale = 7;
		const mapWidth = this.chapter.map[0].length;
		const width = mapWidth * scale;
		const height = this.chapter.map.length * scale;
		// The imported Unity world is mirrored on Dora's screen X axis. Project
		// both the map cells and live markers through that same transform so the
		// minimap's left/right directions match what the player sees.
		const projectX = (tileX: number) => -(tileX - mapWidth / 2 + 0.5) * scale;
		this.minimap.drawPolygon([Vec2(-width / 2 - 5, -height / 2 - 5), Vec2(-width / 2 - 5, height / 2 + 5), Vec2(width / 2 + 5, height / 2 + 5), Vec2(width / 2 + 5, -height / 2 - 5)], Color(0xc0122922), 2, Color(0xb0d7b76a));
		for (let z = 0; z < this.chapter.map.length; z++) {
			const row = this.chapter.map[z];
			for (let x = 0; x < row.length; x++) {
				const tile = string.sub(row, x + 1, x + 1);
				if (tile === "#" || tile === "T") {
					const px = projectX(x);
					const py = (z - this.chapter.map.length / 2 + 0.5) * scale;
					this.minimap.drawPolygon([Vec2(px - 3, py - 3), Vec2(px - 3, py + 3), Vec2(px + 3, py + 3), Vec2(px + 3, py - 3)], Color(tile === "#" ? 0xff5d7362 : 0xff3d8f78));
				}
			}
		}
		const project = (point: Point) => Vec2(projectX(point.x / TILE_SIZE), (point.z / TILE_SIZE - this.chapter.map.length / 2 + 0.5) * scale);
		for (const pickup of this.pickups) if (!pickup.collected) this.minimap.drawDot(project(pickup), 2.5, Color(0xffffcf62));
		for (const guard of this.guards) this.minimap.drawDot(project(guard.position), 2.8, Color(0xffff6952));
		this.minimap.drawDot(project(this.exit), 3.2, Color(0xffef4f42));
		this.minimap.drawDot(project(this.player), 3.5, Color(0xffffffff));
	}
}
