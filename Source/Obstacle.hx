package;

import starling.display.Image;
import starling.textures.Texture;
import starling.display.Sprite;

class Obstacle extends Sprite {
    private var _radius:Float;
    private var _gapHeight:Int;

    public var passed(default,default):Bool;
    private var _passed:Bool;

    public function new(gapHeight:Int) {
        super();

        var topTexture:Texture = Game.sAssets.getTexture("obstacle-top");
        var bottomTexture:Texture = Game.sAssets.getTexture("obstacle-bottom");
        
        _radius = topTexture.width / 2;
        _gapHeight = gapHeight;
        passed = false;

        var top:Image = new Image(topTexture);
        top.pixelSnapping = true;
        top.pivotX = _radius;
        top.pivotY = topTexture.height - _radius;
        top.y = gapHeight / -2;

        var bottom:Image = new Image(bottomTexture);
        bottom.pixelSnapping = true;
        bottom.pivotX = _radius;
        bottom.pivotY = _radius;
        bottom.y = gapHeight / 2;

        addChild(top);
        addChild(bottom);
    }
    
}