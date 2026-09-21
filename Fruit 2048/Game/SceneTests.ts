/**
 * 场景级自动化测试：在真实 Dora 节点树上驱动 FruitGame，
 * 验证「输入 → 逻辑变化 → 位移动画 → 新果生成 → 终局/重开」的完整链路。
 * 时间推进使用固定步长，不依赖真实帧。
 */

import { Content, Director, Node } from 'Dora';
import { joinPath } from 'Game/Save';
import { DIR_LEFT, DIR_UP } from 'Game/FruitBoard';
import { COLS, FruitGame, ROWS } from 'Game/FruitGame';
import { SCREEN_MARGIN } from 'Game/Theme';

/** 生成全空棋盘数值表。 */
function emptyValues(): number[] {
	const values: number[] = [];
	for (let i = 0; i < ROWS * COLS; i++) {
		values.push(0);
	}
	return values;
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

	const host = Node();
	host.addTo(Director.entry);
	const scoreFileName = 'fruit2048_scene_test.txt';
	const scorePath = joinPath(Content.writablePath, scoreFileName);
	if (Content.exist(scorePath)) Content.remove(scorePath);
	const game = new FruitGame(host, scoreFileName);
	game.layout(360, 640);
	check(game.hud.hintLabel !== undefined && game.hud.hintLabel.text.length > 0, '场景：操作提示应可见');
	check(game.hud.restartButton.width === 168, '场景：重开按钮应可点击');
	game.layout(783, 639);
	check(
		game.hud.hintLabel !== undefined
			&& game.hud.restartButton.position.x === 0
			&& game.hud.hintLabel.position.x === 0
			&& game.hud.restartButton.position.y > game.hud.hintLabel.position.y,
		'场景：短横屏下重开按钮应居中且提示位于下方',
	);
	check(game.boardView.boardBottomY() >= game.hud.restartButton.position.y + 22, '场景：重开按钮不应遮挡棋盘');
	const scoreCardsBottomY = 639 / 2 - SCREEN_MARGIN - 132;
	check(game.boardView.root.position.y + game.boardView.boardSize / 2 <= scoreCardsBottomY - 12, '场景：评分卡片不应遮挡棋盘');
	game.layout(360, 640);
	check(ROWS === 4 && COLS === 4, '场景：棋盘规格应为 4×4');
	check(game.board.rows === 4 && game.board.cols === 4, '场景：逻辑棋盘应为 4×4');
	check(game.boardView.tiles.length === 2, '场景：开局应有 2 个水果瓦片');
	check(game.boardView.cellSize > 24, '场景：布局应给出可用格子尺寸');

	// 合成链路：同一行的两个 2
	const mergeValues = emptyValues();
	mergeValues[0] = 2;
	mergeValues[1] = 2;
	game.setBoard(mergeValues);
	check(game.boardView.tiles.length === 2, '场景：布置后应有两个瓦片');

	game.requestMove(DIR_LEFT);
	check(game.boardView.animating, '场景：请求移动后应进入位移动画');
	check(game.board.get(0, 0) === 4, '场景：向左合成后 (0,0) 应为 4');
	check(game.board.score === 4, '场景：合成后得分应为 4');

	game.advance(0.3);
	check(!game.boardView.animating, '场景：推进时间后位移动画应结束');
	check(game.boardView.tiles.length === 2, '场景：合成后应有目标瓦片与新水果共 2 个');
	let hasFour = false;
	for (let i = 0; i < game.boardView.tiles.length; i++) {
		if (game.boardView.tiles[i].value === 4) {
			hasFour = true;
		}
	}
	check(hasFour, '场景：合成后应存在数值为 4 的瓦片');

	// 每个瓦片都应有与数值一致的文本（果实上的数字）
	let numbersOk = true;
	for (let i = 0; i < game.boardView.tiles.length; i++) {
		const tile = game.boardView.tiles[i];
		if (!tile.numberLabel || tile.numberLabel.text !== '' + tile.value) {
			numbersOk = false;
		}
	}
	check(numbersOk, '场景：每个瓦片应显示与其数值一致的文本');
	check(game.hud !== undefined, '场景：HUD 应已创建');

	// 无效方向不生成新水果
	const singleValues = emptyValues();
	singleValues[3 * COLS] = 8;
	game.setBoard(singleValues);
	game.requestMove(DIR_LEFT);
	check(!game.boardView.animating, '场景：已贴边的瓦片不应触发动画');
	check(game.board.tileCount() === 1, '场景：无效方向不应生成新水果');
	check(game.boardView.tiles.length === 1, '场景：无效方向后瓦片数不变');

	// 终局：棋盘填满且无相邻同值
	const fullValues = emptyValues();
	for (let row = 0; row < ROWS; row++) {
		for (let col = 0; col < COLS; col++) {
			fullValues[row * COLS + col] = (row + col) % 2 === 0 ? 2 : 4;
		}
	}
	game.setBoard(fullValues);
	game.requestMove(DIR_LEFT);
	check(game.gameOver, '场景：无路可走时应进入终局状态');
	check(game.gameOverTitle !== undefined && game.gameOverTitle.visible, '场景：终局文本应可见');
	check(game.boardView.effects.scrim.visible, '场景：终局遮罩应可见');

	// 终局后请求移动 → 重开
	game.requestMove(DIR_UP);
	check(!game.gameOver, '场景：终局后请求移动应重开新局');
	check(game.board.tileCount() === 2, '场景：重开后应有 2 个水果');
	check(!game.boardView.effects.scrim.visible, '场景：重开后遮罩应隐藏');

	game.setBoard(mergeValues);
	if (game.hud.onRestart) game.hud.onRestart();
	check(game.board.tileCount() === 2 && game.board.score === 0, '场景：HUD 重开应恢复初始棋盘');
	host.removeFromParent();
	if (Content.exist(scorePath)) Content.remove(scorePath);

	const lines: string[] = [];
	lines.push(failures.length === 0 ? 'passed' : 'failed');
	lines.push('checks=' + checks + ' failures=' + failures.length);
	for (let i = 0; i < failures.length; i++) {
		lines.push('FAIL ' + failures[i]);
	}
	return lines.join('\n');
}
