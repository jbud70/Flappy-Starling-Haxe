package;

import openfl.net.SharedObject;
import starling.text.TextField;
import starling.utils.Color;
import starling.text.BitmapFont;
import starling.text.TextFormat;
import starling.core.Starling;
import starling.events.TouchPhase;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.Event;
import starling.assets.AssetManager;
import starling.display.Sprite;

class Game extends Sprite {
    // Asset manager declaration
    public static var sAssets(default, null):AssetManager;
    private static var _sAssets:AssetManager;

    private var _world:World;

    private static var sDefaultTextFormat:TextFormat = new TextFormat("bradybunch", BitmapFont.NATIVE_SIZE, Color.WHITE);

    // Score Declarations
    private var _score:Int;
	private var _scoreLabel:TextField;
	public var score(get, set):Int;
	private function get_score():Int {
		return _score;
	}
	private function set_score(value:Int):Int {
		_score = value;
		if (_scoreLabel != null) {
			_scoreLabel.text = Std.string(_score);
		}
		return _score;
	}

    private var _sharedObject:SharedObject;

	public var topScore(get, set):Int;

	private function get_topScore():Int {
		var raw:Dynamic = Reflect.field(_sharedObject.data, "topScore");

		if (Std.isOfType(raw, Int)) {
			return cast raw;
		}

		if (Std.isOfType(raw, Float)) {
			return Std.int(cast raw);
		}

		if (Std.isOfType(raw, String)) {
			var parsed = Std.parseInt(cast raw);
			return (parsed != null) ? parsed : 0;
		}

		return 0;
	}

	private function set_topScore(value:Int):Int {
		Reflect.setField(_sharedObject.data, "topScore", value);
		try {
			_sharedObject.flush(); // Saves to disk
		} catch (e:Dynamic) {
			trace("SharedObject flush failed: " + e);
		}
		return value;
	}

    private var _title:TitleOverlay;

    public function new() {
        super(); 
    }

    public function start(assets:AssetManager) {
        sAssets = assets;
        _sharedObject = SharedObject.getLocal("flappy-data");

        _world = new World(stage.stageWidth, stage.stageHeight);
        _world.addEventListener(World.BIRD_CRASHED, onBirdCollided);
        addChild(_world);

        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(TouchEvent.TOUCH, onTouch);

        _scoreLabel = new TextField(180, 80, "0", sDefaultTextFormat);
        _scoreLabel.visible = false;
        addChild(_scoreLabel);

        _title = new TitleOverlay(stage.stageWidth, stage.stageHeight);
        addChild(_title);

        showTitle();

        _world.addEventListener(World.OBSTACLE_PASSED, onObstaclePassed);
    }

    private function onObstaclePassed() {
        this.score += 1;
        // _scoreLabel.text = Std.string(_score);
    }

    private function onEnterFrame(event:Event, passedTime:Float)
    {
        _world.advanceTime(passedTime);
    }

    private function onTouch(event:TouchEvent) {
        var touch:Touch = event.getTouch(stage, TouchPhase.BEGAN);
        if (touch != null) {
            if (_world.phase == World.PHASE_IDLE) 
            {
                hideTitle();
                this.score = 0;
                _scoreLabel.visible = true;
                _world.start();
            }
            _world.flapBird();
        }
    }

    private function onBirdCollided() {
        if (score > topScore) topScore = score;
        Starling.current.juggler.delayCall(restart, 1.5);
    }

    private function restart() {
        _scoreLabel.visible = false;
        _world.reset();
        showTitle();
    }

    private function showTitle() {
        _title.alpha = 0.0;
        _title.topScore = topScore;

        Starling.current.juggler.tween(_title, 1.0, { alpha: 1.0 });
    }

    private function hideTitle() {
        Starling.current.juggler.removeTweens(_title);
        Starling.current.juggler.tween(_title, 0.5, { alpha: 0.0 });
    }
}