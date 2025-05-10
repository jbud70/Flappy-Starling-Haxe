package;

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
    
    public function new() {
        super(); 
    }

    public function start(assets:AssetManager) {
        sAssets = assets;

        _world = new World(stage.stageWidth, stage.stageHeight);
        _world.addEventListener(World.BIRD_CRASHED, onBirdCollided);
        addChild(_world);

        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(TouchEvent.TOUCH, onTouch);
    }

    private function onEnterFrame(event:Event, passedTime:Float)
    {
        _world.advanceTime(passedTime);
    }

    private function onTouch(event:TouchEvent) {
        var touch:Touch = event.getTouch(stage, TouchPhase.BEGAN);
        if (touch != null) {
            if (_world.phase == World.PHASE_IDLE) _world.start();
            _world.flapBird();
        }
    }

    private function onBirdCollided() {
        Starling.current.juggler.delayCall(restart, 1.5);
    }

    private function restart() {
        _world.reset();
    }
}