package;

import starling.textures.Texture;
import starling.utils.Color;
import starling.text.BitmapFont;
import starling.display.Image;
import starling.text.TextField;
import starling.display.Sprite;

class TitleOverlay extends Sprite {
    public var topScore(get, set):Int;
    private var _topScoreLabel:TextField;
    private var _topScore:Int;
    public function get_topScore() {
        return _topScore;
    }
    public function set_topScore(value:Int) {
        _topScore = value;
		if (_topScoreLabel != null) {
			_topScoreLabel.text = Std.string("Current Record: " + _topScore);
		}
		return _topScore;
    }

    

    public function new(width:Int, height:Int) {
        super();

        var title:TextField = new TextField(width, 200, "Flappy\nStarling");
        title.format.setTo("bradybunch", BitmapFont.NATIVE_SIZE, Color.WHITE);
        title.format.leading = -20;

        var tapTexture:Texture = Game.sAssets.getTexture("tap-indicator");
        var tapIndicator:Image = new Image(tapTexture);
        tapIndicator.x = width / 2;
        tapIndicator.y = (height - tapIndicator.height) / 2;

        _topScoreLabel = new TextField(width, 50, "");
        _topScoreLabel.format.setTo(BitmapFont.MINI, BitmapFont.NATIVE_SIZE * 2);
        _topScoreLabel.y = height * 0.80;

        addChild(title);
        addChild(tapIndicator);
        addChild(_topScoreLabel);
    }
}