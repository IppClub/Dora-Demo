// @preview-file on clear
import { React, toNode, useRef } from 'DoraX';
import { Audio, BodyMoveType, ButtonName, Director, KeyName, Label, Node, PhysicsWorld, Sprite, TypeName, Vec2, View, emit, sleep, thread, tolua } from 'Dora';
import { CreateManager, Trigger, GamePad } from 'InputManager';

const Pressed = (keyName: KeyName, buttonName: ButtonName) => {
	return Trigger.Selector([
		Trigger.KeyPressed(keyName),
		Trigger.ButtonPressed(buttonName)
	]);
};

const inputManager = CreateManager({
	Game: {
		Up: Pressed(KeyName.W, ButtonName.Up),
		Down: Pressed(KeyName.S, ButtonName.Down),
		Left: Pressed(KeyName.A, ButtonName.Left),
		Right: Pressed(KeyName.D, ButtonName.Right),
	},
	UI: {
		Start: Trigger.Selector([
			Trigger.KeyDown(KeyName.Return),
			Trigger.ButtonDown(ButtonName.Start)
		]),
	}
});

inputManager.getNode().addTo(Director.ui);

toNode(
	<GamePad inputManager={inputManager} noLeftStick noRightStick noButtonPad noTriggerPad noControlPad/>
)?.addTo(Director.ui);

const enum Animation {
	enemyFlyingAlt = 'enemyFlyingAlt_',
	enemyWalking = 'enemyWalking_',
	enemySwimming = 'enemySwimming_',
	playerGrey_up = 'playerGrey_up',
	playerGrey_walk = 'playerGrey_walk',
};

const playAnimation = (node: Node.Type, name: Animation) => {
	node.removeAllChildren();
	const interval = 0.2;
	const frames = [
		Sprite(`Image/art.clip|${name}1`) ?? Sprite(),
		Sprite(`Image/art.clip|${name}2`) ?? Sprite()
	];
	for (let frame of frames) {
		if (name.startsWith('enemy')) {
			frame.angle = -90;
		}
		frame.addTo(node);
	}
	let i = 0;
	node.loop(() => {
		frames[i].visible = true;
		i = (i + 1) % 2;
		frames[i].visible = false;
		sleep(interval);
		return false;
	});
};

const width = 480;
const height = 700;
const hw = width / 2;
const hh = height / 2;

const DesignSceneHeight = height;
const updateViewSize = () => {
	const camera = tolua.cast(Director.currentCamera, TypeName.Camera2D);
	if (camera) {
		camera.zoom = View.size.height / DesignSceneHeight;
	}
};
updateViewSize();
Director.entry.onAppChange(settingName => {
	if (settingName === 'Size') {
		updateViewSize();
	}
});

const Enemy = (world: PhysicsWorld.Type, score: number) => {
	const dir = math.random(0, 3);
	const angle = math.random(dir * 90 + 25, dir * 90 + 180 - 25);
	let pos = Vec2.zero;
	const minW = -hw - 40; const maxW = hw + 40;
	const minH = -hh - 40; const maxH = hh + 40;
	const randW = math.random(minW, maxW);
	const randH = math.random(minH, maxH);
	switch (dir) {
		case 0: pos = Vec2(minW, randH); break; // left
		case 1: pos = Vec2(randW, maxH); break; // bottom
		case 2: pos = Vec2(maxW, randH); break; // right
		case 3: pos = Vec2(randW, minH); break; // top
	}
	const radian = math.rad(angle);
	const velocity = Vec2(math.sin(radian), math.cos(radian)).normalize().mul(200 + score * 2);
	toNode(
		<body world={world} group={0} type={BodyMoveType.Dynamic} linearAcceleration={Vec2.zero}
			x={pos.x} y={pos.y} velocityX={velocity.x} velocityY={velocity.y} angle={angle}
			onMount={node => {
				const enemys = [Animation.enemyFlyingAlt, Animation.enemySwimming, Animation.enemyWalking];
				playAnimation(node, enemys[math.random(0, 2)]);
			}}>
			<disk-fixture radius={40}/>
		</body>
	)?.addTo(world);
};

const Player = (world: PhysicsWorld.Type) => {
	const node = toNode(
		<body world={world} group={1} type={BodyMoveType.Dynamic} linearAcceleration={Vec2.zero}
			onContactStart={other => {
				if (other.group === 0) {
					toNode(<label fontName='Xolonium-Regular' fontSize={80} text='Game Over' textWidth={300}/>);
					node?.removeFromParent();
					thread(() => {
						sleep(2);
						Director.entry.removeAllChildren();
						toNode(<StartUp/>);
					});
					Audio.stopStream(0.5);
					Audio.play('Audio/gameover.wav');
				}
			}}>
			<disk-fixture radius={40}/>
		</body>
	);
	if (!node) error('failed to create player!');
	node.addTo(world);
	let x = 0; let y = 0;
	node.gslot('Input.Up', () => y = 1);
	node.gslot('Input.Down', () => y = -1);
	node.gslot('Input.Left', () => x = -1);
	node.gslot('Input.Right', () => x = 1);
	node.loop(() => {
		const direction = Vec2(x, y).normalize();
		if (direction.length > 0) {
			node.angle = -math.deg(math.atan(direction.y, direction.x)) + 90;
		}
		const newPos = node.position.add(Vec2(x, y).normalize().mul(10));
		node.position = newPos.clamp(Vec2(-hw + 40, -hh + 40), Vec2(hw - 40, hh - 40));
		x = 0; y = 0;
		return false;
	});
	const animNode = Node().addTo(node);
	playAnimation(animNode, Animation.playerGrey_walk);
};

const Background = () => <draw-node><rect-shape width={width} height={height} fillColor={0xff4b6b6c}/></draw-node>;

const StartUp = () => {
	inputManager.popContext();
	inputManager.pushContext('UI');
	return (
		<>
			<Background/>
			<label fontName='Xolonium-Regular' fontSize={80} text='Dodge the Creeps!' textWidth={400}/>
			<draw-node y={-150}>
				<rect-shape width={250} height={80} fillColor={0xff3a3a3a}/>
				<label fontName='Xolonium-Regular' fontSize={60} text={'Start'}/>
				<node width={250} height={80} onTapped={() => emit('Input.Start')} onMount={node => {
					node.gslot('Input.Start', () => {
						Director.entry.removeAllChildren();
						toNode(<Game/>);
					});
				}}/>
			</draw-node>
		</>
	);
};

const Game = () => {
	inputManager.popContext();
	inputManager.pushContext('Game');
	let score = 0;
	const label = useRef<Label.Type>();
	Audio.playStream('Audio/House In a Forest Loop.ogg', true);
	return (
		<clip-node stencil={<Background/>}>
			<Background/>
			<physics-world onMount={world => {
				Player(world);
				world.once(() => {
					const msg = toNode(
						<label fontName='Xolonium-Regular' fontSize={80} text='Get Ready!' y={200}/>
					);
					sleep(1);
					msg?.removeFromParent();
					if (label.current) {
						label.current.visible = true;
					}
					world.loop(() => {
						sleep(0.5);
						Enemy(world, score);
						return false;
					});
				});
			}}>
				<contact groupA={0} groupB={0} enabled={false}/>
				<contact groupA={0} groupB={1} enabled/>
				<body type={BodyMoveType.Static} group={1} onBodyLeave={() => {
					score++;
					if (label.current) {
						label.current.text = score.toString();
					}
				}}>
					<rect-fixture sensorTag={0} width={width} height={height}/>
				</body>
			</physics-world>
			<label ref={label} fontName='Xolonium-Regular' fontSize={60} text='0' y={300} visible={false}/>
		</clip-node>
	);
};

toNode(<StartUp/>);