/**
 * 特效层：自绘粒子、飘分文字、全屏闪光与终局遮罩。
 * 内部不挂调度，所有推进都由外部每帧调用 update(dt) 完成。
 */

import { Color, DrawNode, Ease, Label, Move, Node, Opacity, Sequence, Spawn, Vec2 } from 'Dora';
import { COLOR_SCRIM, FONT_NAME, Z_EFFECT, Z_OVERLAY } from 'Game/Theme';

/** 单颗粒子。 */
interface Particle {
	x: number;
	y: number;
	vx: number;
	vy: number;
	life: number;
	maxLife: number;
	size: number;
	gravity: number;
	drag: number;
	color: Color.Type;
}

/** 到期待移除的临时节点（飘分数字等）。 */
interface Transient {
	node: Node.Type;
	ttl: number;
}

/** 粒子数量上限：超出后丢弃新粒子，保证帧率与画面可读性。 */
const MAX_PARTICLES = 240;

/** 自绘特效层。 */
export class EffectsLayer {
	/** 局部特效容器（坐标与 localParent 相同）。 */
	root: Node.Type;
	/** 粒子画布。 */
	canvas: DrawNode.Type;
	/** 全屏覆盖层容器（屏幕中心原点）。 */
	overlay: Node.Type;
	/** 终局遮罩。 */
	scrim: DrawNode.Type;
	/** 庆祝闪光。 */
	flashNode: DrawNode.Type;
	particles: Particle[];
	transients: Transient[];
	viewWidth: number;
	viewHeight: number;
	particleDirty: boolean;
	jitterSeed: number;

	constructor(localParent: Node.Type, overlayParent: Node.Type) {
		this.root = Node();
		this.root.order = Z_EFFECT;
		this.root.addTo(localParent);

		this.canvas = DrawNode();
		this.canvas.order = Z_EFFECT;
		this.canvas.addTo(this.root);

		this.overlay = Node();
		this.overlay.order = Z_OVERLAY;
		this.overlay.addTo(overlayParent);

		this.scrim = DrawNode();
		this.scrim.visible = false;
		this.scrim.addTo(this.overlay);

		this.flashNode = DrawNode();
		this.flashNode.opacity = 0;
		this.flashNode.addTo(this.overlay);

		this.particles = [];
		this.transients = [];
		this.viewWidth = 0;
		this.viewHeight = 0;
		this.particleDirty = true;
		this.jitterSeed = 9781;
	}

	/** 以屏幕中心原点绘制一个全屏矩形。 */
	drawFullRect(node: DrawNode.Type, color: Color.Type): void {
		node.clear();
		const halfW = this.viewWidth / 2;
		const halfH = this.viewHeight / 2;
		node.drawPolygon([
			Vec2(-halfW, -halfH),
			Vec2(halfW, -halfH),
			Vec2(halfW, halfH),
			Vec2(-halfW, halfH),
		], color);
	}

	/** 视口变化时重绘覆盖层矩形。 */
	layout(viewWidth: number, viewHeight: number): void {
		this.viewWidth = viewWidth;
		this.viewHeight = viewHeight;
		this.drawFullRect(this.scrim, COLOR_SCRIM);
		this.drawFullRect(this.flashNode, Color(255, 212, 138, 255));
	}

	/** 生成对称但略带抖动的角度偏移。 */
	nextJitter(): number {
		this.jitterSeed = (this.jitterSeed * 16807) % 2147483647;
		return ((this.jitterSeed % 1000) / 1000 - 0.5) * 0.5;
	}

	addParticle(particle: Particle): void {
		if (this.particles.length >= MAX_PARTICLES) {
			return;
		}
		this.particles.push(particle);
		this.particleDirty = true;
	}

	/** 在局部坐标 at 处向四周爆发粒子。 */
	burst(at: Vec2.Type, color: Color.Type, count: number): void {
		for (let i = 0; i < count; i++) {
			const angle = (i / count) * Math.PI * 2 + this.nextJitter();
			const speed = 110 + (i % 4) * 26;
			this.addParticle({
				x: at.x,
				y: at.y,
				vx: Math.cos(angle) * speed,
				vy: Math.sin(angle) * speed * 0.9,
				life: 0.42,
				maxLife: 0.42,
				size: 3 + (i % 3),
				gravity: 240,
				drag: 1.8,
				color: color,
			});
		}
	}

	/** 环形爆发（达成大榴莲时使用）。 */
	ringBurst(at: Vec2.Type, color: Color.Type, count: number): void {
		for (let i = 0; i < count; i++) {
			const angle = (i / count) * Math.PI * 2 + this.nextJitter() * 0.6;
			const speed = 250 + (i % 6) * 45;
			this.addParticle({
				x: at.x,
				y: at.y,
				vx: Math.cos(angle) * speed,
				vy: Math.sin(angle) * speed,
				life: 0.9,
				maxLife: 0.9,
				size: 4 + (i % 3),
				gravity: 150,
				drag: 0.9,
				color: color,
			});
		}
	}

	/** 飘分文字：向上飘并淡出，到期后移除节点。 */
	floatText(at: Vec2.Type, text: string, color: Color.Type, size: number): void {
		const label = Label(FONT_NAME, size);
		if (!label) {
			return;
		}
		label.text = text;
		label.color = color;
		label.order = Z_EFFECT;
		label.position = Vec2(at.x, at.y);
		label.addTo(this.root);
		label.runAction(Spawn(
			Move(0.55, Vec2(at.x, at.y), Vec2(at.x, at.y + 44), Ease.OutCubic),
			Opacity(0.55, 1, 0),
		));
		this.transients.push({ node: label, ttl: 0.6 });
	}

	/** 全屏暖色闪光：淡入后淡出。 */
	flash(color: Color.Type): void {
		this.drawFullRect(this.flashNode, color);
		this.flashNode.runAction(Sequence(
			Opacity(0.12, 0, 0.72, Ease.OutQuad),
			Opacity(0.55, 0.72, 0, Ease.InQuad),
		));
	}

	/** 终局遮罩开关。 */
	setScrimVisible(visible: boolean): void {
		this.scrim.visible = visible;
	}

	/** 重绘粒子画布。 */
	redrawParticles(): void {
		this.canvas.clear();
		for (let i = 0; i < this.particles.length; i++) {
			const particle = this.particles[i];
			const t = particle.life / particle.maxLife;
			const radius = particle.size * (0.45 + t * 0.75);
			const alpha = Math.floor(255 * t);
			const color = Color(particle.color.r, particle.color.g, particle.color.b, alpha);
			this.canvas.drawDot(Vec2(particle.x, particle.y), radius, color);
		}
		this.particleDirty = false;
	}

	/** 每帧推进粒子与临时节点，返回是否仍有活动特效。 */
	update(dt: number): boolean {
		let active = false;
		for (let i = this.particles.length - 1; i >= 0; i--) {
			const particle = this.particles[i];
			particle.life -= dt;
			if (particle.life <= 0) {
				this.particles.splice(i, 1);
				this.particleDirty = true;
				continue;
			}
			const drag = 1 - particle.drag * dt;
			particle.vx *= drag;
			particle.vy *= drag;
			particle.vy -= particle.gravity * dt;
			particle.x += particle.vx * dt;
			particle.y += particle.vy * dt;
			active = true;
		}
		if (this.particles.length > 0 || this.particleDirty) {
			this.redrawParticles();
		}
		for (let i = this.transients.length - 1; i >= 0; i--) {
			const transient = this.transients[i];
			transient.ttl -= dt;
			if (transient.ttl <= 0) {
				transient.node.removeFromParent();
				this.transients.splice(i, 1);
			} else {
				active = true;
			}
		}
		return active;
	}
}
