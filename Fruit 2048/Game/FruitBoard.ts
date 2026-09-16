/**
 * 纯逻辑层：水果 2048 棋盘规则。
 * 本文件不依赖任何 Dora API，可独立于引擎运行（供 GameTests 调用）。
 */

/** 方向常量：向上（行号增大）。 */
export const DIR_UP = 0;
/** 方向常量：向右（列号增大）。 */
export const DIR_RIGHT = 1;
/** 方向常量：向下（行号减小）。 */
export const DIR_DOWN = 2;
/** 方向常量：向左（列号减小）。 */
export const DIR_LEFT = 3;

/** 11 级水果数值：tier 0 → 2，tier 10 → 2048。 */
export const TILE_VALUES: number[] = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048];

/** 达成「大榴莲」所需数值。 */
export const DURIAN_VALUE = 2048;

/** 棋盘坐标。 */
export interface GridPos {
	row: number;
	col: number;
}

/** 单个瓦片的移动记录，供渲染层播放位移动画。 */
export interface TileMove {
	fromRow: number;
	fromCol: number;
	toRow: number;
	toCol: number;
	/** 移动前该瓦片的数值。 */
	value: number;
	/** true 表示该瓦片被合并进目标格（自身消失）。 */
	merged: boolean;
}

/** 一次移动的完整结果。 */
export interface MoveResult {
	/** 该方向上棋盘是否发生变化；false 时不生成新水果、不计分。 */
	changed: boolean;
	moves: TileMove[];
	/** 发生合成的目标格，需要播放弹跳动画。 */
	mergedCells: GridPos[];
	/** 本次合成获得的分数。 */
	gainedScore: number;
	/** 新生成水果的位置，未生成时为 -1。 */
	spawnedRow: number;
	spawnedCol: number;
	spawnedValue: number;
}

/** 棋盘状态与规则实现。 */
export class FruitBoard {
	/** 行数，row 0 位于底部。 */
	rows: number;
	/** 列数。 */
	cols: number;
	/** 当前得分。 */
	score: number;
	/** 是否已出现过 2048（一次性标记）。 */
	reachedDurian: boolean;
	/** 扁平存储的格子数值：index = row * cols + col，0 表示空。 */
	cells: number[];
	/** 线性同余随机状态，可按固定种子构造以便测试复现。 */
	rngState: number;

	constructor(rows: number, cols: number, seed?: number) {
		this.rows = rows;
		this.cols = cols;
		this.score = 0;
		this.reachedDurian = false;
		this.cells = [];
		const total = rows * cols;
		for (let i = 0; i < total; i++) {
			this.cells.push(0);
		}
		this.rngState = seed ? seed : 20480816;
	}

	/** 生成 [0, 1) 区间伪随机数（状态与乘数均在 double 精度安全范围内）。 */
	nextRandom(): number {
		let state = (this.rngState * 16807) % 2147483647;
		if (state <= 0) {
			state += 2147483646;
		}
		this.rngState = state;
		return (state - 1) / 2147483646;
	}

	/** 用扁平数值表覆盖棋盘内容（长度不足处按 0 处理）。 */
	load(values: number[]): void {
		const total = this.rows * this.cols;
		for (let i = 0; i < total; i++) {
			this.cells[i] = i < values.length ? values[i] : 0;
		}
	}

	/** 清空棋盘、分数与达成标记。 */
	clearAll(): void {
		const total = this.rows * this.cols;
		for (let i = 0; i < total; i++) {
			this.cells[i] = 0;
		}
		this.score = 0;
		this.reachedDurian = false;
	}

	/** 重置并放置指定数量的初始水果。 */
	reset(initialTiles: number): void {
		this.clearAll();
		for (let i = 0; i < initialTiles; i++) {
			this.spawnTile();
		}
	}

	get(row: number, col: number): number {
		return this.cells[row * this.cols + col];
	}

	set(row: number, col: number, value: number): void {
		this.cells[row * this.cols + col] = value;
	}

	isInside(row: number, col: number): boolean {
		return row >= 0 && row < this.rows && col >= 0 && col < this.cols;
	}

	/** 空格列表。 */
	emptyPositions(): GridPos[] {
		const result: GridPos[] = [];
		for (let row = 0; row < this.rows; row++) {
			for (let col = 0; col < this.cols; col++) {
				if (this.get(row, col) === 0) {
					result.push({ row: row, col: col });
				}
			}
		}
		return result;
	}

	emptyCount(): number {
		let count = 0;
		for (let i = 0; i < this.cells.length; i++) {
			if (this.cells[i] === 0) {
				count += 1;
			}
		}
		return count;
	}

	tileCount(): number {
		return this.rows * this.cols - this.emptyCount();
	}

	maxValue(): number {
		let best = 0;
		for (let i = 0; i < this.cells.length; i++) {
			if (this.cells[i] > best) {
				best = this.cells[i];
			}
		}
		return best;
	}

	/** 在随机空格生成一个水果（90% 为 2，10% 为 4）。 */
	spawnTile(): boolean {
		const empties = this.emptyPositions();
		if (empties.length === 0) {
			return false;
		}
		const picked = this.pickIndex(empties.length);
		const value = this.nextRandom() < 0.9 ? 2 : 4;
		this.set(empties[picked].row, empties[picked].col, value);
		return true;
	}

	/** 取 [0, count) 内的随机下标，并做边界保护。 */
	pickIndex(count: number): number {
		let index = Math.floor(this.nextRandom() * count);
		if (index < 0) {
			index = 0;
		}
		if (index > count - 1) {
			index = count - 1;
		}
		return index;
	}

	/** 按方向取该线上第 step 个格子（step 0 为移动方向的最前方）。 */
	lineCell(dir: number, line: number, step: number): GridPos {
		if (dir === DIR_LEFT) {
			return { row: line, col: step };
		}
		if (dir === DIR_RIGHT) {
			return { row: line, col: this.cols - 1 - step };
		}
		if (dir === DIR_DOWN) {
			return { row: step, col: line };
		}
		return { row: this.rows - 1 - step, col: line };
	}

	/** 执行一次移动；无变化时 changed 为 false。 */
	move(dir: number): MoveResult {
		const result: MoveResult = {
			changed: false,
			moves: [],
			mergedCells: [],
			gainedScore: 0,
			spawnedRow: -1,
			spawnedCol: -1,
			spawnedValue: 0,
		};
		const total = this.rows * this.cols;
		const next: number[] = [];
		for (let i = 0; i < total; i++) {
			next.push(0);
		}

		const horizontal = dir === DIR_LEFT || dir === DIR_RIGHT;
		const lineCount = horizontal ? this.rows : this.cols;
		const lineSize = horizontal ? this.cols : this.rows;

		for (let line = 0; line < lineCount; line++) {
			const srcRows: number[] = [];
			const srcCols: number[] = [];
			const srcValues: number[] = [];
			for (let step = 0; step < lineSize; step++) {
				const pos = this.lineCell(dir, line, step);
				const value = this.get(pos.row, pos.col);
				if (value !== 0) {
					srcRows.push(pos.row);
					srcCols.push(pos.col);
					srcValues.push(value);
				}
			}
			let outStep = 0;
			let i = 0;
			while (i < srcValues.length) {
				const target = this.lineCell(dir, line, outStep);
				const sameNext = i + 1 < srcValues.length && srcValues[i] === srcValues[i + 1];
				if (sameNext) {
					const merged = srcValues[i] * 2;
					next[target.row * this.cols + target.col] = merged;
					result.moves.push({
						fromRow: srcRows[i],
						fromCol: srcCols[i],
						toRow: target.row,
						toCol: target.col,
						value: srcValues[i],
						merged: true,
					});
					result.moves.push({
						fromRow: srcRows[i + 1],
						fromCol: srcCols[i + 1],
						toRow: target.row,
						toCol: target.col,
						value: srcValues[i + 1],
						merged: true,
					});
					result.mergedCells.push({ row: target.row, col: target.col });
					result.gainedScore += merged;
					i += 2;
				} else {
					next[target.row * this.cols + target.col] = srcValues[i];
					result.moves.push({
						fromRow: srcRows[i],
						fromCol: srcCols[i],
						toRow: target.row,
						toCol: target.col,
						value: srcValues[i],
						merged: false,
					});
					i += 1;
				}
				outStep += 1;
			}
		}

		for (let i = 0; i < total; i++) {
			if (next[i] !== this.cells[i]) {
				result.changed = true;
				break;
			}
		}
		if (!result.changed) {
			result.moves = [];
			result.mergedCells = [];
			result.gainedScore = 0;
			return result;
		}

		for (let i = 0; i < total; i++) {
			this.cells[i] = next[i];
		}
		this.score += result.gainedScore;

		const empties = this.emptyPositions();
		if (empties.length > 0) {
			const picked = this.pickIndex(empties.length);
			const value = this.nextRandom() < 0.9 ? 2 : 4;
			const pos = empties[picked];
			this.set(pos.row, pos.col, value);
			result.spawnedRow = pos.row;
			result.spawnedCol = pos.col;
			result.spawnedValue = value;
		}

		if (!this.reachedDurian && this.maxValue() >= DURIAN_VALUE) {
			this.reachedDurian = true;
		}
		return result;
	}

	/** 是否还存在可行操作（空格或可合成的相邻同值）。 */
	hasMoves(): boolean {
		if (this.emptyCount() > 0) {
			return true;
		}
		for (let row = 0; row < this.rows; row++) {
			for (let col = 0; col < this.cols; col++) {
				const value = this.get(row, col);
				if (col + 1 < this.cols && this.get(row, col + 1) === value) {
					return true;
				}
				if (row + 1 < this.rows && this.get(row + 1, col) === value) {
					return true;
				}
			}
		}
		return false;
	}

	/** 无路可走（棋盘无空格且无相邻同值）。 */
	isGameOver(): boolean {
		return !this.hasMoves();
	}

	/** 扁平数值文本，便于测试断言。 */
	toFlatString(): string {
		let text = '';
		for (let i = 0; i < this.cells.length; i++) {
			if (i > 0) {
				text += ',';
			}
			text += this.cells[i];
		}
		return text;
	}
}
