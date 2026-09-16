/**
 * 纯逻辑自动化测试：导出 runTests()，报告首行为 passed / failed。
 * 不依赖 Dora API 与渲染，可由运行时 requireProjectModule("Game.GameTests") 调用。
 */

import {
	DIR_DOWN,
	DIR_LEFT,
	DIR_RIGHT,
	DIR_UP,
	FruitBoard,
	TILE_VALUES,
} from 'Game/FruitBoard';

/** 允许出现在棋盘上的数值（0 表示空）。 */
function isAllowedValue(value: number): boolean {
	if (value === 0) {
		return true;
	}
	for (let i = 0; i < TILE_VALUES.length; i++) {
		if (TILE_VALUES[i] === value) {
			return true;
		}
	}
	return false;
}

export function runTests(): string {
	const failures: string[] = [];
	let checks = 0;

	const check = (condition: boolean, message: string): void => {
		checks += 1;
		if (!condition && failures.length < 12) {
			failures.push(message);
		}
	};

	const board4 = (values: number[]): FruitBoard => {
		const board = new FruitBoard(4, 4, 12345);
		board.load(values);
		return board;
	};

	// T1 无合成时仅压缩
	const compact = board4([0, 0, 2, 0]);
	const compactResult = compact.move(DIR_LEFT);
	check(compact.get(0, 0) === 2, 'T1 向左压缩后瓦片应在 (0,0)');
	check(compactResult.gainedScore === 0, 'T1 无合成时不应得分');
	check(compactResult.changed, 'T1 瓦片发生位移时应判定为变化');
	check(compact.tileCount() === 2, 'T1 有效移动后应生成 1 个新水果');

	// T2 相邻同值合成
	const merged = board4([2, 2, 0, 0]);
	const mergedResult = merged.move(DIR_LEFT);
	check(merged.get(0, 0) === 4, 'T2 2+2 应合成为 4');
	check(mergedResult.gainedScore === 4, 'T2 合成 4 应得 4 分');

	// T3 单步最多合成一次：[2,2,4] → [4,4]
	const once = board4([2, 2, 4, 0]);
	once.move(DIR_LEFT);
	check(once.get(0, 0) === 4 && once.get(0, 1) === 4, 'T3 [2,2,4] 向左应得到 [4,4]');
	check(once.get(0, 2) === 0, 'T3 不应产生第二级合成');

	// T4 四连相同：[2,2,2,2] → [4,4]
	const quad = board4([2, 2, 2, 2]);
	const quadResult = quad.move(DIR_LEFT);
	check(quad.get(0, 0) === 4 && quad.get(0, 1) === 4, 'T4 [2,2,2,2] 向左应得到 [4,4]');
	check(quadResult.gainedScore === 8, 'T4 应获得 8 分');
	check(quadResult.mergedCells.length === 2, 'T4 应记录 2 个合成格');

	// T5 跳过不可合成的间隙：[4,2,2] → [4,4]
	const gap = board4([4, 2, 2, 0]);
	const gapResult = gap.move(DIR_LEFT);
	check(gap.get(0, 0) === 4 && gap.get(0, 1) === 4, 'T5 [4,2,2] 向左应得到 [4,4]');
	check(gapResult.gainedScore === 4, 'T5 仅合成中间的两个 2');

	// T6 无变化时不生成新水果
	const stuck = new FruitBoard(4, 4, 11);
	stuck.set(0, 0, 2);
	const stuckResult = stuck.move(DIR_LEFT);
	check(!stuckResult.changed, 'T6 已贴边的瓦片不应判定为变化');
	check(stuckResult.spawnedRow === -1, 'T6 无变化时不应生成新水果');
	check(stuck.tileCount() === 1, 'T6 无变化时格子数不应增加');

	// T7 四方向正确性
	const singleTile = (dir: number, row: number, col: number): FruitBoard => {
		const board = new FruitBoard(4, 4, 2024);
		board.clearAll();
		board.set(row, col, 8);
		board.move(dir);
		return board;
	};
	check(singleTile(DIR_UP, 1, 1).get(3, 1) === 8, 'T7 向上应移动到顶行');
	check(singleTile(DIR_DOWN, 1, 1).get(0, 1) === 8, 'T7 向下应移动到底行');
	check(singleTile(DIR_LEFT, 1, 1).get(1, 0) === 8, 'T7 向左应移动到最左列');
	check(singleTile(DIR_RIGHT, 1, 1).get(1, 3) === 8, 'T7 向右应移动到最右列');

	// T8 生成数量的精确校验（4×4）
	const spawnBoard = new FruitBoard(4, 4, 31);
	spawnBoard.set(0, 3, 4);
	const spawnResult = spawnBoard.move(DIR_LEFT);
	check(spawnBoard.get(0, 0) === 4, 'T8 瓦片应移动到最左列');
	check(spawnResult.spawnedRow >= 0 && spawnResult.spawnedCol >= 0, 'T8 应生成新水果');
	check(spawnBoard.tileCount() === 2, 'T8 有效移动后格子数应为 2');

	// T9 得分累加
	const scored = board4([2, 2, 4, 4]);
	scored.move(DIR_LEFT);
	check(scored.get(0, 0) === 4 && scored.get(0, 1) === 8, 'T9 应得到 [4,8]');
	check(scored.score === 12, 'T9 累计得分应为 12');

	// T10 棋盘填满且无相邻同值 → 无路可走
	const full = new FruitBoard(4, 4, 7);
	const checker: number[] = [];
	for (let row = 0; row < 4; row++) {
		for (let col = 0; col < 4; col++) {
			checker.push((row + col) % 2 === 0 ? 2 : 4);
		}
	}
	full.load(checker);
	check(full.emptyCount() === 0, 'T10 棋盘应无空格');
	check(full.isGameOver(), 'T10 应判定无路可走');
	check(!full.move(DIR_LEFT).changed, 'T10 无路可走时移动不应产生变化');

	// T11 达成大榴莲
	const durian = board4([1024, 1024, 0, 0]);
	const durianResult = durian.move(DIR_LEFT);
	check(durian.get(0, 0) === 2048, 'T11 两个 1024 应合成为 2048');
	check(durian.reachedDurian, 'T11 出现 2048 后应置达成标记');
	check(durianResult.gainedScore === 2048, 'T11 合成 2048 应获得 2048 分');

	// T12 4×4 边界与随机对局安全性
	check(TILE_VALUES.length === 11 && TILE_VALUES[10] === 2048, 'T12 水果链条应为 11 级且终点为 2048');
	const corner = new FruitBoard(4, 4, 5);
	corner.set(3, 3, 4);
	const cornerResult = corner.move(DIR_RIGHT);
	check(corner.get(3, 3) === 4, 'T12 右下角瓦片向右移动后仍留在 (3,3)');
	check(!cornerResult.changed, 'T12 角落瓦片向右移动不应判定为变化');
	const randomBoard = new FruitBoard(4, 4, 99);
	randomBoard.reset(2);
	for (let step = 0; step < 60; step++) {
		if (randomBoard.isGameOver()) {
			break;
		}
		randomBoard.move(step % 4);
	}
	check(randomBoard.cells.length === 16, 'T12 4×4 棋盘应始终保留 16 格');
	let legal = true;
	for (let i = 0; i < randomBoard.cells.length; i++) {
		if (!isAllowedValue(randomBoard.cells[i])) {
			legal = false;
		}
	}
	check(legal, 'T12 连续随机移动后不应出现非法数值');

	const lines: string[] = [];
	lines.push(failures.length === 0 ? 'passed' : 'failed');
	lines.push('checks=' + checks + ' failures=' + failures.length);
	for (let i = 0; i < failures.length; i++) {
		lines.push('FAIL ' + failures[i]);
	}
	return lines.join('\n');
}
