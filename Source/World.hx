package;

import openfl.geom.Rectangle;
import openfl.Vector;
import starling.display.MovieClip;
import starling.display.Image;
import starling.textures.Texture;
import starling.display.Sprite;

class World extends Sprite {
    private var _width:Int;
    private var _height:Int;

    private var _bird:MovieClip;
    private var _birdVelocity:Float = 0.0;
    private static inline var BIRD_RADIUS = 18;
    
    private var _ground:Image;

    private static inline var SCROLL_VELOCITY = 130;
    private static inline var FLAP_VELOCITY = -300;
    private static inline var GRAVITY = 800;

    public static inline var PHASE_IDLE:String = "phaseIdle";
    public static inline var PHASE_PLAYING:String = "phasePlaying";
    public static inline var PHASE_CRASHED:String = "phaseCrashed";
    public static inline var BIRD_CRASHED:String = "birdCrashed";

    private static inline var OBSTACLE_DISTANCE:Int = 180;
    private static inline var OBSTALCE_GAP_HEIGHT:Int = 300;
    public static inline var OBSTACLE_PASSED:String = "obstaclePassed";

    private var _obstacles:Sprite;
    private var _currentX:Float;
    private var _lastObstacleX:Float;

    // Phase Declaration
    public var phase(get, null):String;
    private var _phase:String;
    public function get_phase() {
        return _phase;
    }

    public function new(width:Int, height:Int) {
        super();

        _phase = PHASE_IDLE;

        _width = width;
        _height = height;

        addBackground();
        addObstacleSprite();
        addGround();
        addBird();
    }

    public function start() {
        _phase = PHASE_PLAYING;
        _currentX = _lastObstacleX = 0;
    }

    public function reset() {
        _phase = PHASE_IDLE;
        _obstacles.removeChildren(0, -1, true);
        resetBird();
    }

    private function resetBird() {
        _bird.x = _width / 3;
        _bird.y = _height / 2;
    }

    private function addBackground() {
        var skyTexture:Texture = Game.sAssets.getTexture("sky");
        var sky:Image = new Image(skyTexture);
        sky.y = _height - skyTexture.height;
        addChild(sky);

        var cloud1:Image = new Image(Game.sAssets.getTexture("cloud-1"));
        cloud1.x = _width * 0.5;
        cloud1.y = _height * 0.1;
        addChild(cloud1);

        var cloud2:Image = new Image(Game.sAssets.getTexture("cloud-2"));
        cloud2.x = _width * 0.1;
        cloud2.y = _height * 0.2;
        addChild(cloud2);
    }

    private function addBird() {
        var birdTextures:Vector<Texture> = Game.sAssets.getTextures("bird-");
        birdTextures.push(birdTextures[1]);

        _bird = new MovieClip(birdTextures);
        _bird.pivotX = 46;
        _bird.pivotY = 45;
        _bird.x = _width / 3;
        _bird.y = _height / 2;

        addChild(_bird);
    }

    private function addGround() {
        var tile:Texture = Game.sAssets.getTexture("ground");

        _ground = new Image(tile);
        _ground.y = _height - tile.height;
        _ground.width = _width;
        _ground.tileGrid = new Rectangle(0, 0, tile.width, tile.height);
        addChild(_ground);
    }

    private function addObstacleSprite() {
        _obstacles = new Sprite();
        addChild(_obstacles);
    }

    public function advanceTime(passedTime:Float) {
        if (_phase == PHASE_IDLE || _phase == PHASE_PLAYING) {
            advanceGround(passedTime);
            _bird.advanceTime(passedTime);
        }
        
        if (_phase == PHASE_PLAYING) {
            _currentX += SCROLL_VELOCITY * passedTime;
            advanceObstalces(passedTime);
            advancePhysics(passedTime);
            checkForCollisions();
        }
    }
    
	private function advanceObstalces(passedTime:Float) {
		if (_currentX >= _lastObstacleX + OBSTACLE_DISTANCE) {
			_lastObstacleX = _currentX;
			addObstalce();
		}
		var obstacle:Obstacle;
		var numObstacles:Int = _obstacles.numChildren;

		var i:Int = 0;
		while (i < _obstacles.numChildren) {
			var obstacle:Obstacle = cast _obstacles.getChildAt(i), Obstacle;

			if (obstacle.x < -obstacle.width / 2) {
				obstacle.removeFromParent(true);
				// No increment, because the next item shifts into this index
			} else {
				obstacle.x -= passedTime * SCROLL_VELOCITY;
				i++; // Only move forward if not removing
			}
		}
	}
        
	function addObstalce() {
		var minY:Float = OBSTALCE_GAP_HEIGHT / 2;
        var maxY:Float = _ground.y - (OBSTALCE_GAP_HEIGHT / 2);
        var obstacle:Obstacle = new Obstacle(OBSTALCE_GAP_HEIGHT);

        obstacle.y = minY + Math.random() * (maxY - minY);
        obstacle.x = _width + (obstacle.width / 2);
        _obstacles.addChild(obstacle);
	}
    
    private function advanceGround(passedTime:Float) {
        var distance:Float = SCROLL_VELOCITY * passedTime;

        _ground.tileGrid.x -= distance;
        _ground.tileGrid = _ground.tileGrid;
    }

    private function advancePhysics(passedTime:Float) {
        _bird.y += _birdVelocity * passedTime;
        _birdVelocity += GRAVITY * passedTime;
    }

    public function flapBird() {
        _birdVelocity = FLAP_VELOCITY;
    }

    private function checkForCollisions() {
        var bottom:Float = _ground.y - BIRD_RADIUS;
        var collision:Bool = false;

        if (_bird.y > bottom) {
            _bird.y = bottom;
            _birdVelocity = 0;
            collision = true;
        } else {
            for(i in 0..._obstacles.numChildren) {
                var obstacle:Obstacle = cast(_obstacles.getChildAt(i), Obstacle);

                if (!obstacle.passed && _bird.x > obstacle.x)
                {
                    obstacle.passed = true;
                    dispatchEventWith(OBSTACLE_PASSED, true);
                }

                if (obstacle.collidesWithBird(_bird.x, _bird.y, BIRD_RADIUS)) {
                    collision = true;
                    break;
                }
            }
        }

        if (collision) {
            _phase = PHASE_CRASHED;
            dispatchEventWith(BIRD_CRASHED);
        }
    }
}