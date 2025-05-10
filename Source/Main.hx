package;

import openfl.utils.Assets;
import starling.assets.AssetManager;
import starling.events.Event;
import openfl.display.Sprite;
import starling.core.Starling;

class Main extends Sprite
{
	private var _starling:Starling;

	public function new()
	{
		super();

		_starling = new Starling(Game, stage);
		_starling.addEventListener(Event.ROOT_CREATED, onRootCreated);
		_starling.start();
	}

	private function onRootCreated(event:Event, game:Game) {
		var assets:AssetManager = new AssetManager();

		assets.enqueue([
			Assets.getPath("assets/textures/1x/atlas.xml"),
			Assets.getPath("assets/textures/1x/atlas.png"),
			Assets.getPath("assets/fonts/1x/bradybunch.fnt"),
			Assets.getPath("assets/fonts/1x/bradybunch.png")
		]);

		assets.loadQueue( () -> { game.start(assets); });
	}
}
