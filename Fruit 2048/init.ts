import { Director, Node, View, tolua, TypeName } from 'Dora';
import { FruitGame } from 'Game/FruitGame';

const game = new FruitGame(Director.entry);
let lastWidth = 0;
let lastHeight = 0;

// Logical pixels keep the portrait layout readable at different screen densities.
function layout(): void {
	const size = View.size;
	const scale = math.min(size.width / 360, size.height / 640);
	const camera = tolua.cast(Director.currentCamera, TypeName.Camera2D);
	if (camera) camera.zoom = scale;
	game.layout(size.width / scale, size.height / scale);
	lastWidth = size.width;
	lastHeight = size.height;
}

layout();
const loop = Node();
loop.addTo(Director.entry);
loop.schedule((dt: number) => {
	if (View.size.width !== lastWidth || View.size.height !== lastHeight) layout();
	game.update(dt);
	return false;
});
