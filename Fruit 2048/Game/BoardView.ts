import { roundedRect } from 'Game/FreshArt';
/**
 * 棋盘视图与输入层：
 * - 有尺寸棋盘节点（子节点使用左下原点局部坐标），负责槽位底板与水果瓦片渲染；
 * - 触摸/鼠标滑动方向判定（只用位移差），键盘在外部绑定；
 * - 位移动画与合成弹跳、新果缩放的编排。
 */

import { Color, DrawNode, Ease, Label, Move, Node, Scale, Sequence, Size, Touch, Vec2 } from 'Dora';
import { EffectsLayer } from 'Game/Effects';
import { DIR_DOWN, DIR_LEFT, DIR_RIGHT, DIR_UP, FruitBoard, MoveResult } from 'Game/FruitBoard';
import { drawFruit, FruitDef, fruitOfTier, tierOfValue } from 'Game/FruitArt';
import {
	CELL_GAP,
	COLOR_ACCENT,
	COLOR_PANEL,
	COLOR_SLOT,
	FONT_NAME,
	HUD_HEIGHT,
	SCREEN_MARGIN,
	Z_PANEL,
	Z_SLOT,
	Z_TILE,
} from 'Game/Theme';

/** 位移动画时长（秒）。 */
export const MOVE_DURATION = 0.12;
/** 小于该格子尺寸时隐藏果名文本，避免挤压。 */
const NAME_MIN_CELL = 56;

/** 果实上的数值字号。 */
function numberFontSize(cell: number): number {
	let size = Math.round(cell * 0.24);
	if (size < 12) {
		size = 12;
	}
	if (size > 72) {
		size = 72;
	}
	return size;
}

/** 果实下方的果名字号。 */
function nameFontSize(cell: number): number {
	let size = Math.round(cell * 0.15);
	if (size < 10) {
		size = 10;
	}
	if (size > 40) {
		size = 40;
	}
	return size;
}
/** 无方向时的待处理值。 */
export const NO_DIRECTION = -1;

/** 单个水果瓦片的视图。 */
export class TileView {
	node: Node.Type;
	canvas: DrawNode.Type;
	/** 果实上的数值文本。 */
	numberLabel: Label.Type | undefined;
	/** 数值文本当前字号（格子尺寸变化时需重建）。 */
	numberSize: number;
	/** 果实下方的果名文本。 */
	nameLabel: Label.Type | undefined;
	/** 果名文本当前字号。 */
	nameSize: number;
	value: number;
	row: number;
	col: number;
	/** 被合并吞并：位移动画结束后移除。 */
	dying: boolean;

	constructor(node: Node.Type, canvas: DrawNode.Type, value: number, row: number, col: number) {
		this.node = node;
		this.canvas = canvas;
		this.numberLabel = undefined;
		this.numberSize = 0;
		this.nameLabel = undefined;
		this.nameSize = 0;
		this.value = value;
		this.row = row;
		this.col = col;
		this.dying = false;
	}
}

/** 棋盘视图。 */
export class BoardView {
	/** 有尺寸棋盘节点：同时是触摸输入节点。 */
	root: Node.Type;
	/** 底板与槽位。 */
	panelCanvas: DrawNode.Type;
	/** 瓦片层。 */
	tileLayer: Node.Type;
	/** 特效层。 */
	effects: EffectsLayer;
	rows: number;
	cols: number;
	cellSize: number;
	boardSize: number;
	tiles: TileView[];
	/** 待处理方向（由输入写入，调度循环消费），NO_DIRECTION 表示无。 */
	pendingDir: number;
	/** 是否发生了点击（用于终局重开）。 */
	pendingTap: boolean;
	animating: boolean;
	animTime: number;
	touchActive: boolean;
	touchStartX: number;
	touchStartY: number;
	swipeConsumed: boolean;

	constructor(parent: Node.Type, rows: number, cols: number) {
		this.rows = rows;
		this.cols = cols;
		this.cellSize = 60;
		this.boardSize = this.cellSize * cols;
		this.tiles = [];
		this.pendingDir = NO_DIRECTION;
		this.pendingTap = false;
		this.animating = false;
		this.animTime = 0;
		this.touchActive = false;
		this.touchStartX = 0;
		this.touchStartY = 0;
		this.swipeConsumed = false;

		this.root = Node();
		this.root.size = Size(this.boardSize, this.boardSize);
		this.root.addTo(parent);

		this.panelCanvas = DrawNode();
		this.panelCanvas.order = Z_PANEL;
		this.panelCanvas.addTo(this.root);

		this.tileLayer = Node();
		this.tileLayer.order = Z_TILE;
		this.tileLayer.addTo(this.root);

		this.effects = new EffectsLayer(this.root, parent);
		this.bindTouch();
	}

	/** 绑定滑动输入（触摸与鼠标拖拽都走 Tap 事件）。 */
	bindTouch(): void {
		this.root.onTapBegan((touch: Touch.Type): void => {
			this.touchActive = true;
			this.touchStartX = touch.location.x;
			this.touchStartY = touch.location.y;
			this.swipeConsumed = false;
			this.pendingTap = true;
		});
		this.root.onTapMoved((touch: Touch.Type): void => {
			if (!this.touchActive || this.swipeConsumed) {
				return;
			}
			this.checkSwipe(touch.location.x - this.touchStartX, touch.location.y - this.touchStartY);
		});
		this.root.onTapEnded((touch: Touch.Type): void => {
			if (this.touchActive && !this.swipeConsumed) {
				this.checkSwipe(touch.location.x - this.touchStartX, touch.location.y - this.touchStartY);
			}
			this.touchActive = false;
			this.swipeConsumed = false;
		});
	}

	/** 依据位移差判定滑动方向（只用位移差，不依赖局部坐标原点）。 */
	checkSwipe(dx: number, dy: number): void {
		const threshold = Math.max(20, this.cellSize * 0.4);
		const absX = dx < 0 ? -dx : dx;
		const absY = dy < 0 ? -dy : dy;
		if (absX < threshold && absY < threshold) {
			return;
		}
		if (absX >= absY) {
			this.pendingDir = dx > 0 ? DIR_RIGHT : DIR_LEFT;
		} else {
			this.pendingDir = dy > 0 ? DIR_UP : DIR_DOWN;
		}
		this.swipeConsumed = true;
	}

	/** 格子中心在棋盘局部坐标系（左下原点）中的位置。 */
	cellCenter(row: number, col: number): Vec2.Type {
		return Vec2(this.cellSize * (col + 0.5), this.cellSize * (row + 0.5));
	}

	/** 自适应布局：依视口尺寸确定格子大小、棋盘位置并重排。 */
	layout(viewWidth: number, viewHeight: number): void {
		const margin = SCREEN_MARGIN;
		const availWidth = viewWidth - margin * 2;
		const availHeight = viewHeight - HUD_HEIGHT - margin * 2;
		let cell = Math.floor(Math.min(availWidth, availHeight) / this.cols);
		const defaultCenterY = (margin - HUD_HEIGHT) / 2 + 40;
		const defaultBoardSize = cell * this.cols;
		const boardTopY = Math.min(
			defaultCenterY + defaultBoardSize / 2,
			viewHeight / 2 - margin - 144,
		);
		const footerTopY = -viewHeight / 2 + 88;
		cell = Math.min(cell, Math.floor((boardTopY - footerTopY) / this.cols));
		if (cell < 24) {
			cell = 24;
		}
		this.cellSize = cell;
		this.boardSize = cell * this.cols;
		this.root.size = Size(this.boardSize, this.boardSize);
		this.root.position = Vec2(0, boardTopY - this.boardSize / 2);
		this.redrawPanel();
		this.effects.layout(viewWidth, viewHeight);
		for (let i = 0; i < this.tiles.length; i++) {
			this.refreshTile(this.tiles[i]);
			this.tiles[i].node.position = this.cellCenter(this.tiles[i].row, this.tiles[i].col);
		}
	}

	/** 棋盘底边在屏幕中心坐标系中的 Y 值。 */
	boardBottomY(): number {
		return this.root.position.y - this.boardSize / 2;
	}

	/** 重绘底板与槽位。 */
	redrawPanel(): void {
		this.panelCanvas.clear();
		const size = this.boardSize;
		roundedRect(this.panelCanvas, size / 2, size / 2 - 3, size + 8, size + 8, 17, Color(183, 202, 173, 110));
		roundedRect(this.panelCanvas, size / 2, size / 2, size + 8, size + 8, 17, COLOR_PANEL);
		const half = this.cellSize / 2 - CELL_GAP;
		for (let row = 0; row < this.rows; row++) {
			for (let col = 0; col < this.cols; col++) {
				const p = this.cellCenter(row, col);
				roundedRect(this.panelCanvas, p.x, p.y, half * 2, half * 2, 10, COLOR_SLOT);
			}
		}
	}
	/** 创建瓦片视图。 */
	createTile(row: number, col: number, value: number): TileView {
		const node = Node();
		node.order = Z_TILE;
		node.position = this.cellCenter(row, col);
		node.addTo(this.tileLayer);

		const canvas = DrawNode();
		canvas.order = Z_TILE;
		canvas.addTo(node);

		const tile = new TileView(node, canvas, value, row, col);
		this.refreshTile(tile);
		return tile;
	}

	/** 刷新瓦片外观（果实绘制 + 数值 + 果名）。 */
	refreshTile(tile: TileView): void {
		let tier = tierOfValue(tile.value);
		if (tier < 0) {
			tier = 10;
		}
		const def = fruitOfTier(tier);
		tile.canvas.position = Vec2(0, this.cellSize * 0.10);
		drawFruit(tile.canvas, tier, this.cellSize * 0.29);
		this.refreshNumber(tile, def);

	}

	/** 刷新果实上的数值文本（字号随格子尺寸变化时重建）。 */
	refreshNumber(tile: TileView, def: FruitDef): void {
		const size = numberFontSize(this.cellSize);
		if (tile.numberLabel && tile.numberSize !== size) {
			tile.numberLabel.removeFromParent();
			tile.numberLabel = undefined;
		}
		if (!tile.numberLabel) {
			const created = Label(FONT_NAME, size * 3, false);
			if (!created) {
				return;
			}
			created.scaleX = created.scaleY = 1 / 3;
			created.order = Z_TILE + 1;
			created.addTo(tile.node);
			tile.numberLabel = created;
			tile.numberSize = size;
		}
		tile.numberLabel.text = '' + tile.value;
		tile.numberLabel.color = Color(67,91,66,255);
		tile.numberLabel.position = Vec2(0, -this.cellSize * 0.29);
	}

	/** 刷新果实下方的果名文本，格子过小时隐藏。 */
	refreshName(tile: TileView, def: FruitDef): void {
		if (this.cellSize < NAME_MIN_CELL) {
			if (tile.nameLabel) {
				tile.nameLabel.removeFromParent();
				tile.nameLabel = undefined;
				tile.nameSize = 0;
			}
			return;
		}
		const size = nameFontSize(this.cellSize);
		if (tile.nameLabel && tile.nameSize !== size) {
			tile.nameLabel.removeFromParent();
			tile.nameLabel = undefined;
		}
		if (!tile.nameLabel) {
			const created = Label(FONT_NAME, size);
			if (!created) {
				return;
			}
			created.scaleX = created.scaleY = 1/3;
created.order = Z_TILE + 1;
			created.addTo(tile.node);
			tile.nameLabel = created;
			tile.nameSize = size;
		}
		tile.nameLabel.text = def.name;
		tile.nameLabel.color = def.text;
		tile.nameLabel.position = Vec2(0, -this.cellSize * 0.38);
	}

	/** 查找某格上的瓦片。 */
	findTile(row: number, col: number): TileView | undefined {
		for (let i = 0; i < this.tiles.length; i++) {
			const tile = this.tiles[i];
			if (!tile.dying && tile.row === row && tile.col === col) {
				return tile;
			}
		}
		return undefined;
	}

	/** 清空全部瓦片。 */
	clearTiles(): void {
		for (let i = 0; i < this.tiles.length; i++) {
			this.tiles[i].node.removeFromParent();
		}
		this.tiles = [];
	}

	/** 依据棋盘状态重建全部瓦片（无动画）。 */
	buildFromBoard(board: FruitBoard): void {
		this.clearTiles();
		for (let row = 0; row < this.rows; row++) {
			for (let col = 0; col < this.cols; col++) {
				const value = board.get(row, col);
				if (value > 0) {
					this.tiles.push(this.createTile(row, col, value));
				}
			}
		}
	}

	/** 播放一次移动：先位移，稍后由 finishMove 收尾。 */
	playMove(result: MoveResult): void {
		for (let i = 0; i < result.moves.length; i++) {
			const move = result.moves[i];
			const tile = this.findTile(move.fromRow, move.fromCol);
			if (!tile) {
				continue;
			}
			const target = this.cellCenter(move.toRow, move.toCol);
			tile.node.runAction(Move(MOVE_DURATION, tile.node.position, target, Ease.OutQuad));
			if (move.merged) {
				tile.dying = true;
			} else {
				tile.row = move.toRow;
				tile.col = move.toCol;
			}
		}
		this.animating = true;
		this.animTime = MOVE_DURATION;
	}

	/** 位移结束后：移除被吞瓦片、合成弹跳、新果缩放出现。 */
	finishMove(board: FruitBoard, result: MoveResult): void {
		for (let i = this.tiles.length - 1; i >= 0; i--) {
			if (this.tiles[i].dying) {
				this.tiles[i].node.removeFromParent();
				this.tiles.splice(i, 1);
			}
		}
		for (let i = 0; i < result.mergedCells.length; i++) {
			const pos = result.mergedCells[i];
			const tile = this.createTile(pos.row, pos.col, board.get(pos.row, pos.col));
			this.tiles.push(tile);
			tile.node.runAction(Sequence(
				Scale(0.08, 1, 1.18, Ease.OutQuad),
				Scale(0.09, 1.18, 1, Ease.InQuad),
			));
			this.effects.burst(this.cellCenter(pos.row, pos.col), COLOR_ACCENT, 8);
		}
		if (result.spawnedRow >= 0) {
			const spawned = this.createTile(result.spawnedRow, result.spawnedCol, board.get(result.spawnedRow, result.spawnedCol));
			this.tiles.push(spawned);
			spawned.node.scaleX = 0;
			spawned.node.scaleY = 0;
			spawned.node.runAction(Scale(0.16, 0, 1, Ease.OutBack));
		}
		this.animating = false;
		this.animTime = 0;
	}

	/** 推进位移动画计时，返回是否刚好结束。 */
	updateAnimation(dt: number): boolean {
		if (!this.animating) {
			return false;
		}
		this.animTime -= dt;
		if (this.animTime <= 0) {
			return true;
		}
		return false;
	}
}
