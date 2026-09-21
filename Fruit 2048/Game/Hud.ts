import { Color, DrawNode, Label, Node, Size, Vec2 } from 'Dora';
import { roundedRect } from 'Game/FreshArt';
import {
	COLOR_ACCENT, COLOR_TEXT, COLOR_TEXT_MUTED, FONT_NAME,
	HUD_LABEL_SIZE, HUD_VALUE_SIZE, SCREEN_MARGIN, TITLE_SIZE, Z_HUD,
} from 'Game/Theme';

/** Scene-owned controls work in the native player and Web exports. */
export class Hud {
	root: Node.Type;
	backdrop: DrawNode.Type;
	titleLabel: Label.Type | undefined;
	goalLabel: Label.Type | undefined;
	scoreLabel: Label.Type | undefined;
	scoreValueLabel: Label.Type | undefined;
	bestLabel: Label.Type | undefined;
	bestValueLabel: Label.Type | undefined;
	hintLabel: Label.Type | undefined;
	restartButton: Node.Type;
	onRestart: (() => void) | undefined;

	constructor(parent: Node.Type) {
		this.root = Node();
		this.root.order = Z_HUD;
		this.root.addTo(parent);
		this.backdrop = DrawNode();
		this.backdrop.order = -1;
		this.backdrop.addTo(this.root);
		this.titleLabel = this.makeLabel('水果 2048', TITLE_SIZE, COLOR_ACCENT, Vec2(0, 0.5));
		this.goalLabel = this.makeLabel('目标：合成大榴莲', HUD_LABEL_SIZE, COLOR_TEXT_MUTED, Vec2(0, 0.5));
		this.scoreLabel = this.makeLabel('分数', HUD_LABEL_SIZE, COLOR_TEXT_MUTED, Vec2(0.5, 0.5));
		this.scoreValueLabel = this.makeLabel('0', HUD_VALUE_SIZE, COLOR_TEXT, Vec2(0.5, 0.5));
		this.bestLabel = this.makeLabel('最高分', HUD_LABEL_SIZE, COLOR_TEXT_MUTED, Vec2(0.5, 0.5));
		this.bestValueLabel = this.makeLabel('0', HUD_VALUE_SIZE, COLOR_TEXT, Vec2(0.5, 0.5));
		this.hintLabel = this.makeLabel('滑动棋盘，合成水果', HUD_LABEL_SIZE, COLOR_TEXT_MUTED, Vec2(0.5, 0.5));
		this.restartButton = Node();
		this.restartButton.size = Size(168, 44);
		this.restartButton.swallowTouches = true;
		this.restartButton.addTo(this.root);
		const face = DrawNode();
		roundedRect(face, 84, 20, 168, 44, 15, Color(55, 102, 78, 40));
		roundedRect(face, 84, 22, 168, 44, 15, Color(82, 135, 107, 255));
		face.addTo(this.restartButton);
		const label = this.makeLabel('重新开始', 17, Color(255, 254, 245, 255), Vec2(0.5, 0.5));
		if (label) {
			label.removeFromParent(false);
			label.position = Vec2(84, 22);
			label.addTo(this.restartButton);
		}
		this.restartButton.onTapped(() => { if (this.onRestart) this.onRestart(); });
	}

	makeLabel(text: string, size: number, color: Color.Type, anchor: Vec2.Type): Label.Type | undefined {
		const label = Label(FONT_NAME, size * 3, false);
		if (!label) return undefined;
		label.scaleX = label.scaleY = 1 / 3;
		label.text = text;
		label.color = color;
		label.anchor = anchor;
		label.order = Z_HUD;
		label.addTo(this.root);
		return label;
	}

	layout(viewWidth: number, viewHeight: number): void {
		const halfWidth = viewWidth / 2;
		const halfHeight = viewHeight / 2;
		const topY = halfHeight - SCREEN_MARGIN;
		if (this.titleLabel) this.titleLabel.position = Vec2(-halfWidth + SCREEN_MARGIN, topY - TITLE_SIZE * 0.6);
		if (this.goalLabel) this.goalLabel.position = Vec2(-halfWidth + SCREEN_MARGIN, topY - TITLE_SIZE * 1.5);
		const chipWidth = 144;
		const chipHeight = 56;
		const centerY = topY - 76 - chipHeight / 2;
		this.backdrop.clear();
		for (const centerX of [-78, 78]) {
			roundedRect(this.backdrop, centerX, centerY - 2, chipWidth, chipHeight, 12, Color(174, 197, 166, 65));
			roundedRect(this.backdrop, centerX, centerY, chipWidth, chipHeight, 12, Color(255, 253, 247, 255));
		}
		if (this.scoreLabel) this.scoreLabel.position = Vec2(-78, centerY + 13);
		if (this.scoreValueLabel) this.scoreValueLabel.position = Vec2(-78, centerY - 11);
		if (this.bestLabel) this.bestLabel.position = Vec2(78, centerY + 13);
		if (this.bestValueLabel) this.bestValueLabel.position = Vec2(78, centerY - 11);
		this.restartButton.position = Vec2(0, -halfHeight + 54);
		if (this.hintLabel) this.hintLabel.position = Vec2(0, -halfHeight + 18);
	}

	setScore(score: number): void {
		if (this.scoreValueLabel) this.scoreValueLabel.text = '' + score;
	}

	setBest(best: number, persisted: boolean): void {
		if (this.bestValueLabel) this.bestValueLabel.text = persisted ? '' + best : best + '*';
	}

	setHint(text: string): void {
		if (this.hintLabel) this.hintLabel.text = text;
	}
}
