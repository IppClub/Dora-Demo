/**
 * 游戏装配与唯一状态机：把逻辑棋盘、棋盘视图、HUD、特效与存档串成完整流程。
 * 由外部唯一调度循环调用 update(dt) 推进；本类内部不挂调度。
 */

import { Color, DrawNode, Ease, KeyName, Label, Node, Scale, Vec2 } from 'Dora';
import { BoardView, NO_DIRECTION } from 'Game/BoardView';
import { DIR_DOWN, DIR_LEFT, DIR_RIGHT, DIR_UP, FruitBoard, MoveResult } from 'Game/FruitBoard';
import { Hud } from 'Game/Hud';
import { BestScoreStore } from 'Game/Save';
import {
	COLOR_ACCENT,
	COLOR_BG_BOTTOM,
	COLOR_BG_TOP,
	COLOR_TEXT,
	COLOR_TEXT_MUTED,
	FONT_NAME,
	HUD_LABEL_SIZE,
	Z_BACKGROUND,
	Z_OVERLAY,
} from 'Game/Theme';

/** 棋盘规格：4×4。 */
export const ROWS = 4;
export const COLS = 4;
/** 开局水果数量。 */
const INITIAL_TILES = 2;
/** 庆祝动画持续时长（秒）。 */
const CELEBRATE_TIME = 1.8;
/** 达成大榴莲的数值。 */
const DURIAN = 2048;

/** 一局完整的水果 2048 游戏。 */
export class FruitGame {
	parent: Node.Type;
	background: DrawNode.Type;
	board: FruitBoard;
	boardView: BoardView;
	hud: Hud;
	store: BestScoreStore;
	gameOverTitle: Label.Type | undefined;
	gameOverHint: Label.Type | undefined;
	winLabel: Label.Type | undefined;
	gameOver: boolean;
	celebrated: boolean;
	pendingResult: MoveResult | undefined;
	pendingMove: number;
	pendingCelebrate: boolean;
	winTimer: number;
	viewWidth: number;
	viewHeight: number;

	constructor(parent: Node.Type, scoreFileName?: string) {
		this.parent = parent;
		this.viewWidth = 0;
		this.viewHeight = 0;
		this.gameOver = false;
		this.celebrated = false;
		this.pendingResult = undefined;
		this.pendingMove = NO_DIRECTION;
		this.pendingCelebrate = false;
		this.winTimer = 0;

		this.background = DrawNode();
		this.background.order = Z_BACKGROUND;
		this.background.addTo(parent);

		this.board = new FruitBoard(ROWS, COLS);
		this.store = new BestScoreStore(scoreFileName);
		this.boardView = new BoardView(parent, ROWS, COLS);
		this.hud = new Hud(parent);
		this.hud.onRestart = () => this.startNewGame();

		this.gameOverTitle = this.makeOverlayLabel('无路可走', 34, COLOR_TEXT);
		this.gameOverHint = this.makeOverlayLabel('点击任意处或按空格重新开始', HUD_LABEL_SIZE + 2, COLOR_TEXT_MUTED);
		this.winLabel = this.makeOverlayLabel('大榴莲达成！', 40, COLOR_ACCENT);

		this.bindKeyboard();
		this.startNewGame();
	}

	/** 创建覆盖层文本（默认隐藏）。 */
	makeOverlayLabel(text: string, size: number, color: Color.Type): Label.Type | undefined {
		const label = Label(FONT_NAME, size);
		if (!label) {
			return undefined;
		}
		label.text = text;
		label.color = color;
		label.order = Z_OVERLAY + 1;
		label.visible = false;
		label.addTo(this.parent);
		return label;
	}

	/** 依视口尺寸重排背景、棋盘、HUD 与覆盖层文本。 */
	layout(viewWidth: number, viewHeight: number): void {
		this.viewWidth = viewWidth;
		this.viewHeight = viewHeight;
		const halfW = viewWidth / 2;
		const halfH = viewHeight / 2;
		this.background.clear();
		this.background.drawPolygon([
			Vec2(-halfW, -halfH),
			Vec2(halfW, -halfH),
			Vec2(halfW, halfH),
			Vec2(-halfW, halfH),
		], COLOR_BG_TOP);
		this.background.drawPolygon([
			Vec2(-halfW, -halfH),
			Vec2(halfW, -halfH),
			Vec2(halfW, 0),
			Vec2(-halfW, 0),
		], COLOR_BG_BOTTOM);
		this.boardView.layout(viewWidth, viewHeight);
		this.hud.layout(viewWidth, viewHeight, this.boardView.boardBottomY());
		const centerY = this.boardView.root.position.y;
		if (this.gameOverTitle) {
			this.gameOverTitle.position = Vec2(0, centerY + 8);
		}
		if (this.gameOverHint) {
			this.gameOverHint.position = Vec2(0, centerY - 34);
		}
		if (this.winLabel) {
			this.winLabel.position = Vec2(0, centerY + this.boardView.boardSize * 0.08);
		}
	}

	/** 开始新一局。 */
	startNewGame(): void {
		this.board.reset(INITIAL_TILES);
		this.boardView.buildFromBoard(this.board);
		this.hud.setScore(0);
		this.hud.setBest(this.store.best, this.store.persisted);
		this.hud.setHint('滑动棋盘，合成水果');
		this.boardView.effects.setScrimVisible(false);
		if (this.gameOverTitle) {
			this.gameOverTitle.visible = false;
		}
		if (this.gameOverHint) {
			this.gameOverHint.visible = false;
		}
		if (this.winLabel) {
			this.winLabel.visible = false;
		}
		this.gameOver = false;
		this.celebrated = false;
		this.pendingResult = undefined;
		this.pendingMove = NO_DIRECTION;
		this.pendingCelebrate = false;
		this.winTimer = 0;
	}

	/** 直接用给定数值表布置棋盘（测试与调试用）。 */
	setBoard(values: number[]): void {
		this.board.clearAll();
		this.board.load(values);
		this.boardView.buildFromBoard(this.board);
		this.hud.setScore(this.board.score);
	}

	/** 判定终局并显示遮罩。 */
	checkGameOver(): void {
		if (this.gameOver || !this.board.isGameOver()) {
			return;
		}
		this.gameOver = true;
		this.boardView.effects.setScrimVisible(true);
		if (this.gameOverTitle) {
			this.gameOverTitle.visible = true;
		}
		if (this.gameOverHint) {
			this.gameOverHint.visible = true;
		}
		this.hud.setHint('本局结束：点击任意处或按空格重新开始');
	}

	/** 达成大榴莲的庆祝表现。 */
	celebrate(): void {
		let durianRow = 0;
		let durianCol = 0;
		let found = false;
		for (let row = 0; row < this.board.rows; row++) {
			for (let col = 0; col < this.board.cols; col++) {
				if (this.board.get(row, col) >= DURIAN) {
					durianRow = row;
					durianCol = col;
					found = true;
				}
			}
		}
		const center = found
			? this.boardView.cellCenter(durianRow, durianCol)
			: Vec2(this.boardView.boardSize / 2, this.boardView.boardSize / 2);
		this.boardView.effects.flash(Color(255, 214, 140, 255));
		for (let i = 0; i < 4; i++) {
			this.boardView.effects.ringBurst(center, COLOR_ACCENT, 22);
		}
		this.boardView.effects.burst(center, Color(255, 255, 255, 255), 16);
		this.boardView.effects.floatText(center, '2048!', COLOR_ACCENT, 26);
		if (this.winLabel) {
			this.winLabel.visible = true;
			this.winLabel.scaleX = 0;
			this.winLabel.scaleY = 0;
			this.winLabel.runAction(Scale(0.3, 0, 1, Ease.OutBack));
		}
		this.winTimer = CELEBRATE_TIME;
		this.hud.setHint('达成大榴莲！继续合成或点击重开');
	}

	/** 执行一次方向移动（仅在动画空闲时调用）。 */
	executeMove(dir: number): void {
		const result = this.board.move(dir);
		if (!result.changed) {
			this.checkGameOver();
			return;
		}
		this.hud.setScore(this.board.score);
		if (this.board.score > this.store.best) {
			this.store.submit(this.board.score);
			this.hud.setBest(this.store.best, this.store.persisted);
		}
		if (this.board.reachedDurian && !this.celebrated) {
			this.celebrated = true;
			this.pendingCelebrate = true;
		}
		this.pendingResult = result;
		this.boardView.playMove(result);
	}

	/** 请求一次移动：动画期间只保留 1 个方向缓冲；终局时重开。 */
	requestMove(dir: number): void {
		if (this.gameOver) {
			this.startNewGame();
			return;
		}
		if (this.boardView.animating) {
			this.pendingMove = dir;
			return;
		}
		this.executeMove(dir);
	}

	/** 绑定键盘方向键、WASD 与空格/回车重开。 */
	bindKeyboard(): void {
		this.parent.onKeyDown((keyName) => {
			if (keyName === KeyName.Left || keyName === KeyName.A) {
				this.requestMove(DIR_LEFT);
			} else if (keyName === KeyName.Right || keyName === KeyName.D) {
				this.requestMove(DIR_RIGHT);
			} else if (keyName === KeyName.Up || keyName === KeyName.W) {
				this.requestMove(DIR_UP);
			} else if (keyName === KeyName.Down || keyName === KeyName.S) {
				this.requestMove(DIR_DOWN);
			} else if (keyName === KeyName.R) {
				this.startNewGame();
			} else if (keyName === KeyName.Space || keyName === KeyName.Return) {
				if (this.gameOver) {
					this.startNewGame();
				}
			}
		});
	}

	/** 单帧推进：重排 → 消费输入 → 动画收尾 → 判定终局 → 特效。 */
	update(dt: number): void {
		this.boardView.effects.update(dt);

		if (this.boardView.pendingTap) {
			this.boardView.pendingTap = false;
			if (this.gameOver) {
				this.startNewGame();
			}
		}

		if (this.boardView.pendingDir !== NO_DIRECTION) {
			const dir = this.boardView.pendingDir;
			this.boardView.pendingDir = NO_DIRECTION;
			this.requestMove(dir);
		}

		if (this.boardView.updateAnimation(dt)) {
			if (this.pendingResult) {
				this.boardView.finishMove(this.board, this.pendingResult);
				this.pendingResult = undefined;
			}
			if (this.pendingCelebrate) {
				this.pendingCelebrate = false;
				this.celebrate();
			}
			if (this.pendingMove !== NO_DIRECTION) {
				const next = this.pendingMove;
				this.pendingMove = NO_DIRECTION;
				this.executeMove(next);
			} else {
				this.checkGameOver();
			}
		}

		if (this.winTimer > 0) {
			this.winTimer -= dt;
			if (this.winTimer <= 0 && this.winLabel) {
				this.winLabel.visible = false;
			}
		}
	}

	/** 以固定步长推进若干秒（测试用，避免单帧超大 delta）。 */
	advance(seconds: number, stepSeconds?: number): void {
		const step = stepSeconds ? stepSeconds : 1 / 60;
		let remaining = seconds;
		while (remaining > 0) {
			const dt = remaining > step ? step : remaining;
			this.update(dt);
			remaining -= dt;
		}
	}
}
