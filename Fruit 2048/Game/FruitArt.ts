import {drawFruit as freshFruit} from 'Game/FreshArt';
/**
 * 水果外观定义与程序化绘制（无图片素材）。
 * 每级水果 = 底色果实 + 描边 + 高光 + 特征装饰（叶子/梗/圈纹/交叉纹/条纹/尖刺）。
 */

import { Color, DrawNode, Vec2 } from 'Dora';

/** 装饰类型：叶子。 */
export const DECOR_LEAF = 0;
/** 装饰类型：梗。 */
export const DECOR_STEM = 1;
/** 装饰类型：圈纹。 */
export const DECOR_RING = 2;
/** 装饰类型：交叉纹（菠萝）。 */
export const DECOR_CROSS = 3;
/** 装饰类型：条纹（蜜瓜/西瓜）。 */
export const DECOR_STRIPE = 4;
/** 装饰类型：尖刺（榴莲）。 */
export const DECOR_SPIKE = 5;

/** 单个水果的外观定义。 */
export interface FruitDef {
	tier: number;
	value: number;
	name: string;
	body: Color.Type;
	edge: Color.Type;
	text: Color.Type;
	decor: number;
}

/** 大榴莲所在层级。 */
export const DURIAN_TIER = 10;

/** 11 级水果外观表（tier 0 → 2 … tier 10 → 2048）。 */
export const FRUITS: FruitDef[] = [
	{ tier: 0, value: 2, name: '樱桃', body: Color(198, 42, 52, 255), edge: Color(132, 22, 32, 255), text: Color(255, 246, 242, 255), decor: DECOR_LEAF },
	{ tier: 1, value: 4, name: '草莓', body: Color(226, 72, 74, 255), edge: Color(154, 38, 44, 255), text: Color(255, 246, 242, 255), decor: DECOR_LEAF },
	{ tier: 2, value: 8, name: '葡萄', body: Color(126, 82, 200, 255), edge: Color(84, 48, 148, 255), text: Color(248, 244, 255, 255), decor: DECOR_STEM },
	{ tier: 3, value: 16, name: '柠檬', body: Color(236, 205, 58, 255), edge: Color(166, 138, 20, 255), text: Color(58, 46, 12, 255), decor: DECOR_RING },
	{ tier: 4, value: 32, name: '橙子', body: Color(240, 146, 58, 255), edge: Color(178, 98, 24, 255), text: Color(72, 40, 10, 255), decor: DECOR_STEM },
	{ tier: 5, value: 64, name: '苹果', body: Color(214, 62, 72, 255), edge: Color(146, 30, 42, 255), text: Color(255, 246, 242, 255), decor: DECOR_LEAF },
	{ tier: 6, value: 128, name: '桃子', body: Color(246, 158, 140, 255), edge: Color(190, 104, 92, 255), text: Color(92, 42, 38, 255), decor: DECOR_LEAF },
	{ tier: 7, value: 256, name: '菠萝', body: Color(232, 192, 60, 255), edge: Color(162, 126, 20, 255), text: Color(64, 48, 12, 255), decor: DECOR_CROSS },
	{ tier: 8, value: 512, name: '蜜瓜', body: Color(168, 201, 74, 255), edge: Color(114, 146, 38, 255), text: Color(44, 60, 16, 255), decor: DECOR_STRIPE },
	{ tier: 9, value: 1024, name: '西瓜', body: Color(60, 160, 92, 255), edge: Color(30, 106, 58, 255), text: Color(255, 246, 242, 255), decor: DECOR_STRIPE },
	{ tier: 10, value: 2048, name: '榴莲', body: Color(201, 162, 39, 255), edge: Color(130, 100, 14, 255), text: Color(52, 40, 8, 255), decor: DECOR_SPIKE },
];

/** 取某层级的水果定义，越界时收敛到首尾项。 */
export function fruitOfTier(tier: number): FruitDef {
	let index = tier;
	if (index < 0) {
		index = 0;
	}
	if (index > FRUITS.length - 1) {
		index = FRUITS.length - 1;
	}
	return FRUITS[index];
}

/** 由数值反查层级，未知数值返回 -1。 */
export function tierOfValue(value: number): number {
	for (let i = 0; i < FRUITS.length; i++) {
		if (FRUITS[i].value === value) {
			return i;
		}
	}
	return -1;
}

/** 水果中文名（未知数值返回数值文本）。 */
export function fruitName(value: number): string {
	const tier = tierOfValue(value);
	if (tier < 0) {
		return '' + value;
	}
	return FRUITS[tier].name;
}

/** 绘制圆环（用折线近似）。 */
function drawRing(node: DrawNode.Type, center: Vec2.Type, radius: number, thickness: number, color: Color.Type, segments: number): void {
	let prevX = center.x + radius;
	let prevY = center.y;
	for (let i = 1; i <= segments; i++) {
		const angle = (i / segments) * Math.PI * 2;
		const x = center.x + Math.cos(angle) * radius;
		const y = center.y + Math.sin(angle) * radius;
		node.drawSegment(Vec2(prevX, prevY), Vec2(x, y), thickness, color);
		prevX = x;
		prevY = y;
	}
}

/** 绘制叶子：朝右上的一片小叶子。 */
function drawLeaf(node: DrawNode.Type, radius: number): void {
	const leaf = Color(86, 168, 78, 255);
	const stem = Color(70, 112, 46, 255);
	const baseX = radius * 0.18;
	const baseY = radius * 0.92;
	node.drawSegment(Vec2(0, radius * 0.86), Vec2(baseX, baseY), radius * 0.08, stem);
	node.drawPolygon([
		Vec2(baseX, baseY),
		Vec2(radius * 0.66, radius * 1.06),
		Vec2(radius * 1.02, radius * 0.82),
		Vec2(radius * 0.52, radius * 0.74),
	], leaf);
}

/** 绘制梗：果实顶部一小段短梗。 */
function drawStem(node: DrawNode.Type, radius: number): void {
	const stem = Color(96, 72, 40, 255);
	node.drawSegment(Vec2(0, radius * 0.9), Vec2(radius * 0.08, radius * 1.28), radius * 0.11, stem);
	node.drawDot(Vec2(radius * 0.08, radius * 1.28), radius * 0.1, Color(126, 96, 54, 255));
}

/** 绘制菠萝交叉纹。 */
function drawCross(node: DrawNode.Type, radius: number, color: Color.Type): void {
	for (let i = 0; i < 3; i++) {
		const offset = (i - 1) * radius * 0.42;
		node.drawSegment(Vec2(offset - radius * 0.42, radius * 0.42), Vec2(offset + radius * 0.42, -radius * 0.42), radius * 0.05, color);
		node.drawSegment(Vec2(offset - radius * 0.42, -radius * 0.42), Vec2(offset + radius * 0.42, radius * 0.42), radius * 0.05, color);
	}
}

/** 绘制蜜瓜/西瓜条纹。 */
function drawStripe(node: DrawNode.Type, radius: number, color: Color.Type): void {
	for (let i = -2; i <= 2; i++) {
		const x = i * radius * 0.34;
		node.drawSegment(Vec2(x, -radius * 0.78), Vec2(x * 0.5, radius * 0.78), radius * 0.06, color);
	}
}

/** 绘制榴莲尖刺：沿外圈放射的短刺。 */
function drawSpike(node: DrawNode.Type, radius: number, color: Color.Type): void {
	const count = 14;
	for (let i = 0; i < count; i++) {
		const angle = (i / count) * Math.PI * 2;
		const cos = Math.cos(angle);
		const sin = Math.sin(angle);
		const innerX = cos * radius * 0.86;
		const innerY = sin * radius * 0.86;
		const outerX = cos * radius * 1.18;
		const outerY = sin * radius * 1.18;
		node.drawSegment(Vec2(innerX, innerY), Vec2(outerX, outerY), radius * 0.09, color);
	}
}

/** 在指定 DrawNode 上绘制对应层级的水果（以节点局部原点为果实中心）。 */
export function drawFruit(node: DrawNode.Type, tier: number, radius: number): void { freshFruit(node,tier,radius); }
