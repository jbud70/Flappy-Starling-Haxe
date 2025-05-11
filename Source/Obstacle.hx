package;

import lime.media.FlashAudioContext;
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

	public function collidesWithBird(birdX:Float, birdY:Float, birdRadius:Int) {
		// check if bird is completely left or right of the obstacle
		if (birdX + birdRadius < x - _radius || birdX - birdRadius > x + _radius)
			return false;

		var topY:Float = y - _gapHeight / 2;
		var bottomY:Float = y + _gapHeight / 2;
        
		// check if bird is within gap
		if (birdY < topY || birdY > bottomY)
			return true;

		var distX:Float = x - birdX;
		var distY:Float;

		// top trunk
		distY = topY - birdY;
		if (Math.sqrt(distX * distX + distY * distY) < _radius + birdRadius)
			return true;

		// bottom trunk
		distY = bottomY - birdY;
		if (Math.sqrt(distX * distX + distY * distY) < _radius + birdRadius)
			return true;

		// bird flies through in-between the circles
		return false;
	}
    
}