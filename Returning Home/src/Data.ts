export type Point = {x: number; z: number};

export const TILE_SIZE = 2;

export type GuardData = {
	route: Point[];
	speed: number;
	range: number;
	halfAngle: number;
	noticeSeconds: number;
};

export type ChapterData = {
	title: string;
	introduction: string;
	map: string[];
	spawn: Point;
	guards: GuardData[];
};

export const chapters: ChapterData[] = [
	{
		title: "门庭夜雨",
		introduction: "先拾起近处的灯印。避开金色灯光，寻回三枚灯印后离开朱门。",
		spawn: {x: 2, z: 2},
		map: [
			"#############",
			"#S..#.......#",
			"#.K.#.C.....#",
			"#...#.....K.#",
			"#.......#...#",
			"###.#####.###",
			"#...#...#...#",
			"#.T.#.H.#...#",
			"#.........K.#",
			"#...#...#...#",
			"#.C.#.T...C.#",
			"#...#...#.E.#",
			"#############",
		],
		guards: [
			{route: [{x: 18, z: 12}, {x: 22, z: 12}, {x: 22, z: 20}, {x: 18, z: 20}], speed: 1, range: 4.6, halfAngle: 36, noticeSeconds: 1.35},
			{route: [{x: 12, z: 2}, {x: 20, z: 2}, {x: 20, z: 6}, {x: 12, z: 6}], speed: 1, range: 4.6, halfAngle: 36, noticeSeconds: 1.35},
		],
	},
	{
		title: "回廊迷灯",
		introduction: "纸人的巡逻路线交错。轻步时视野更短，响铃可以将目光引向远处。",
		spawn: {x: 4, z: 2},
		map: [
			"###############",
			"#.S..#...#....#",
			"#....#...#..C.#",
			"#....#........#",
			"#.K......#..T.#",
			"#....#.K.#....#",
			"##.####.####.##",
			"#....#........#",
			"#.T....H.#.T..#",
			"#....#.C.#....#",
			"###.###.###.###",
			"#....#........#",
			"#.C......#..K.#",
			"#....#...#..E.#",
			"###############",
		],
		guards: [
			{route: [{x: 12, z: 4}, {x: 16, z: 4}, {x: 16, z: 10}, {x: 12, z: 10}], speed: 1.12, range: 4.85, halfAngle: 36, noticeSeconds: 1.25},
			{route: [{x: 20, z: 22}, {x: 26, z: 22}, {x: 26, z: 26}, {x: 20, z: 26}], speed: 1.12, range: 4.85, halfAngle: 36, noticeSeconds: 1.25},
			{route: [{x: 2, z: 4}, {x: 6, z: 4}, {x: 6, z: 8}, {x: 2, z: 8}], speed: 1.12, range: 4.85, halfAngle: 36, noticeSeconds: 1.25},
		],
	},
	{
		title: "归灯祠堂",
		introduction: "三枚灯印落在祠堂各处。青灯记住脚步，铜钱能提高评分。",
		spawn: {x: 4, z: 4},
		map: [
			"#################",
			"#....#.....#....#",
			"#.S..#.....#..C.#",
			"#.......K..#....#",
			"#....#..........#",
			"##.#####.#####.##",
			"#....#..T..#....#",
			"#....#.....#.T..#",
			"#..T....H.....K.#",
			"#....#.....#....#",
			"#....#.....#....#",
			"###.####.####.###",
			"#....#.T........#",
			"#..........#....#",
			"#.C..#..K..#..C.#",
			"#....#.....#..E.#",
			"#################",
		],
		guards: [
			{route: [{x: 2, z: 6}, {x: 6, z: 6}, {x: 6, z: 8}, {x: 2, z: 8}], speed: 1.24, range: 5.1, halfAngle: 36, noticeSeconds: 1.15},
			{route: [{x: 12, z: 24}, {x: 20, z: 24}, {x: 20, z: 30}, {x: 12, z: 30}], speed: 1.24, range: 5.1, halfAngle: 36, noticeSeconds: 1.15},
			{route: [{x: 24, z: 12}, {x: 30, z: 12}, {x: 30, z: 18}, {x: 24, z: 18}], speed: 1.24, range: 5.1, halfAngle: 36, noticeSeconds: 1.15},
			{route: [{x: 14, z: 2}, {x: 18, z: 2}, {x: 18, z: 8}, {x: 14, z: 8}], speed: 1.24, range: 5.1, halfAngle: 36, noticeSeconds: 1.15},
		],
	},
];
