import {Director} from "Dora";
import {ChapterData, chapters, GuardData, TILE_SIZE} from "src/Data";
import {Patrol} from "src/Game";

function count(chapter: typeof chapters[number], token: string) {
	let total = 0;
	for (const row of chapter.map) {
		for (let i = 1; i <= row.length; i++) {
			if (string.sub(row, i, i) === token) total++;
		}
	}
	return total;
}

const expectedSizes = [13, 15, 17];
const expectedGuards = [2, 3, 4];
let failures = 0;
for (let i = 0; i < chapters.length; i++) {
	const chapter = chapters[i];
	const size = expectedSizes[i];
	const checks = [
		chapter.map.length === size,
		chapter.map.every(row => row.length === size),
		chapter.guards.length === expectedGuards[i],
		chapter.guards.every(guard => guard.route.length === 4),
		count(chapter, "S") === 1,
		count(chapter, "H") === 1,
		count(chapter, "E") === 1,
		count(chapter, "K") === 3,
		count(chapter, "C") === 3,
	];
	if (!checks.every(value => value)) {
		failures++;
		print("VALIDATION_FAIL", i + 1, chapter.title);
	} else print("VALIDATION_OK", i + 1, chapter.title, size + "x" + size, expectedGuards[i] + " guards");
}
print(failures === 0 && TILE_SIZE === 2 ? "RETURNING_HOME_VALID" : "RETURNING_HOME_INVALID", failures);

const testChapter: ChapterData = {
	title: "stealth-test",
	introduction: "",
	spawn: {x: 4, z: 4},
	map: [
		"#######",
		"#.....#",
		"#.....#",
		"#.....#",
		"#.....#",
		"#.....#",
		"#######",
	],
	guards: [],
};
const guardData: GuardData = {
	route: [{x: 4, z: 4}, {x: 6, z: 4}, {x: 6, z: 6}, {x: 4, z: 6}],
	speed: 1,
	range: 5,
	halfAngle: 36,
	noticeSeconds: 1,
};
const check = (condition: boolean, name: string) => {
	if (condition) print("STEALTH_OK", name);
	else {
		failures++;
		print("STEALTH_FAIL", name);
	}
};

const fastGuard = new Patrol(guardData);
const quietGuard = new Patrol(guardData);
fastGuard.update(0.2, 0.2, {x: 4, z: 6}, true, false, false, testChapter);
quietGuard.update(0.2, 0.2, {x: 4, z: 6}, true, true, false, testChapter);
check(fastGuard.state === "chase" && quietGuard.state === "chase", "quiet-keeps-real-vision-range");
check(fastGuard.suspicion > quietGuard.suspicion, "fast-exposure-exceeds-quiet");

const bellGuard = new Patrol(guardData);
bellGuard.suspicion = 0.4;
check(bellGuard.hearBell({x: 8, z: 4}, 0) && bellGuard.suspicion >= 0.4, "bell-preserves-suspicion");
for (let step = 1; step <= 25; step++) bellGuard.update(0.1, step * 0.1, {x: 0, z: 0}, false, false, true, testChapter);
check(bellGuard.position.x > 4.2, "bell-causes-real-investigation-movement");
bellGuard.state = "chase";
check(!bellGuard.hearBell({x: 2, z: 2}, 3), "bell-cannot-break-active-chase");

const footstepGuard = new Patrol(guardData);
check(footstepGuard.hearFootstep({x: 6, z: 4}, 0) && footstepGuard.state === "investigate", "footstep-starts-investigation");
for (let step = 1; step <= 30; step++) footstepGuard.update(0.1, step * 0.1, {x: 0, z: 0}, false, false, true, testChapter);
check(footstepGuard.state === "search", "investigation-transitions-to-search");
for (let step = 31; step <= 60; step++) footstepGuard.update(0.1, step * 0.1, {x: 0, z: 0}, false, false, true, testChapter);
check(footstepGuard.state === "patrol", "search-returns-to-patrol");

const pursuitGuard = new Patrol(guardData);
pursuitGuard.update(0.1, 0.1, {x: 4, z: 6}, true, false, false, testChapter);
for (let step = 2; step <= 34; step++) pursuitGuard.update(0.1, step * 0.1, {x: 10, z: 10}, false, false, true, testChapter);
check(pursuitGuard.state === "search", "lost-sight-pursuit-keeps-last-seen-point");

const decayGuard = new Patrol(guardData);
decayGuard.suspicion = 0.5;
decayGuard.update(0.2, 0.2, {x: 0, z: 0}, false, false, true, testChapter);
check(math.abs(decayGuard.suspicion - 0.43) < 0.001, "hidden-suspicion-decays-at-0.35-per-second");

const baseAlertGuard = new Patrol(guardData);
const raisedAlertGuard = new Patrol(guardData);
raisedAlertGuard.setSealAlert(2);
baseAlertGuard.hearBell({x: 8, z: 4}, 0);
raisedAlertGuard.hearBell({x: 8, z: 4}, 0);
for (let step = 1; step <= 18; step++) {
	baseAlertGuard.update(0.1, step * 0.1, {x: 0, z: 0}, false, false, true, testChapter);
	raisedAlertGuard.update(0.1, step * 0.1, {x: 0, z: 0}, false, false, true, testChapter);
}
check(raisedAlertGuard.position.x > baseAlertGuard.position.x, "second-seal-raises-guard-speed");
check(raisedAlertGuard.hearDoor({x: 6, z: 6}, 2) && raisedAlertGuard.state === "investigate", "door-sound-starts-investigation");

const baseSearchGuard = new Patrol(guardData);
const raisedSearchGuard = new Patrol(guardData);
raisedSearchGuard.setSealAlert(2);
baseSearchGuard.hearFootstep({x: 4, z: 4}, 0);
raisedSearchGuard.hearFootstep({x: 4, z: 4}, 0);
for (let step = 1; step <= 25; step++) {
	baseSearchGuard.update(0.1, step * 0.1, {x: 0, z: 0}, false, false, true, testChapter);
	raisedSearchGuard.update(0.1, step * 0.1, {x: 0, z: 0}, false, false, true, testChapter);
}
check(baseSearchGuard.state === "patrol" && raisedSearchGuard.state === "search", "second-seal-extends-search-time");

Director.entry.scene.removeAllChildren();
print(failures === 0 ? "STEALTH_LOOP_VALID" : "STEALTH_LOOP_INVALID", failures);
