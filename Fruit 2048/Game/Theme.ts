import { Color } from 'Dora';

/** 全局字体：引擎内置更纱黑体（含中文字形）。 */
export const FONT_NAME = 'sarasa-mono-sc-regular';

/** 屏幕边距（像素）。 */
export const SCREEN_MARGIN = 16;
/** 顶部 HUD 预留高度（像素）。 */
export const HUD_HEIGHT = 180;
/** 棋盘格子之间的缝隙（像素）。 */
export const CELL_GAP = 6;
/** 棋盘外框内边距（像素）。 */
export const PANEL_PADDING = 10;

/** 层级：背景。 */
export const Z_BACKGROUND = 0;
/** 层级：棋盘底板。 */
export const Z_PANEL = 10;
/** 层级：格子槽位。 */
export const Z_SLOT = 20;
/** 层级：水果瓦片。 */
export const Z_TILE = 30;
/** 层级：粒子/飘分等特效。 */
export const Z_EFFECT = 40;
/** 层级：HUD 文本与分数。 */
export const Z_HUD = 50;
/** 层级：终局遮罩与庆祝。 */
export const Z_OVERLAY = 60;

/** 主色：柔和的叶绿色。 */
export const COLOR_ACCENT = Color(68, 125, 91, 255);
/** 背景顶部色。 */
export const COLOR_BG_TOP = Color(248, 249, 239, 255);
/** 背景底部色。 */
export const COLOR_BG_BOTTOM = Color(248, 249, 239, 255);
/** 棋盘底板色。 */
export const COLOR_PANEL = Color(218, 231, 213, 255);
/** 格子槽位色。 */
export const COLOR_SLOT = Color(233, 240, 225, 255);
/** 主文本色。 */
export const COLOR_TEXT = Color(53, 82, 61, 255);
/** 次文本色。 */
export const COLOR_TEXT_MUTED = Color(126, 146, 123, 255);
/** 遮罩色（半透明黑）。 */
export const COLOR_SCRIM = Color(0, 0, 0, 170);

/** 标题字号。 */
export const TITLE_SIZE = 28;
/** HUD 小标签字号。 */
export const HUD_LABEL_SIZE = 14;
/** HUD 数值字号。 */
export const HUD_VALUE_SIZE = 30;
