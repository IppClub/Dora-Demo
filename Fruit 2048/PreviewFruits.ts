// @preview-file on clear
/**
 * 开发预览入口（不是正式游戏入口）：正式入口请运行 `init.ts`。
 *
 * 用途：在无法注入真实触摸/键盘事件时做视觉验收。
 * 它会先把棋盘预设为覆盖多个等级的水果，再在 0.7 秒时自动向左移动一次，
 * 让相邻的两个 1024 合成大榴莲，从而一次性看到各等级果实外观、果名、HUD 与庆祝效果。
 */

import { Director, Node, View } from 'Dora';
import { DIR_LEFT } from 'Game/FruitBoard';
import { COLS, FruitGame, ROWS } from 'Game/FruitGame';

const game = new FruitGame(Director.entry);
game.layout(View.size.width, View.size.height);

const values: number[] = [];
for (let i = 0; i < ROWS * COLS; i++) {
	values.push(0);
}
values[0 * COLS + 0] = 2;
values[0 * COLS + 1] = 4;
values[0 * COLS + 2] = 8;
values[0 * COLS + 3] = 16;
values[1 * COLS + 0] = 32;
values[1 * COLS + 1] = 64;
values[1 * COLS + 2] = 128;
values[1 * COLS + 3] = 256;
values[2 * COLS + 0] = 512;
values[2 * COLS + 1] = 1024;
values[2 * COLS + 2] = 1024;
values[3 * COLS + 0] = 2;
values[3 * COLS + 1] = 4;
game.setBoard(values);

let elapsed = 0;
let moved = false;
const loop = Node();
loop.addTo(Director.entry);
loop.schedule((dt: number): boolean => {
	elapsed += dt;
	const size = View.size;
	if (size.width !== game.viewWidth || size.height !== game.viewHeight) {
		game.layout(size.width, size.height);
	}
	game.update(dt);
	if (!moved && elapsed > 0.7) {
		moved = true;
		game.requestMove(DIR_LEFT);
	}
	return false;
});
