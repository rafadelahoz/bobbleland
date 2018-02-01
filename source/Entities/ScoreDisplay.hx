package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.text.FlxBitmapText;
import flixel.util.FlxTimer;

class ScoreDisplay extends FlxObject
{
	public static var addDelay : Float = 1;

	public var mode : Int;

	public var score : Int;
	public var scoreLabel : FlxBitmapText;

	var scoreDelta : Int = 5;
	var targetScore : Int;

	var timer : FlxTimer;

	public function new(X : Float, Y : Float, Mode : Int, ?Score : Int = 0)
	{
		super(X, Y);
		
		mode = Mode;

		score = Score;
		targetScore = Score;

		scoreLabel = text.PixelText.New(X, Y, "", 0xFFFFFFFF, FlxG.width);

		if (mode == PlayState.ModePuzzle)
		{
			scoreLabel.text = "PUZZLE";
		}
		else
		{
			scoreLabel.text = padWith("" + score, 8);
		}

		timer = null;
	}

	public function add(value : Int)
	{
		if (timer == null)
		{
			timer = new FlxTimer().start(addDelay, function(t:FlxTimer) {
				targetScore += value;
				scoreDelta = Std.int((targetScore - score) / 60.0);
				timer = null;
			});
		}
		else
		{
			targetScore += value;
			scoreDelta = Std.int((targetScore - score) / 60.0);
		}
	}

	override public function update(elapsed:Float)
	{
		if (mode == PlayState.ModeArcade)
		{
			if (score < targetScore)
			{
				score += scoreDelta;
				if (score > targetScore)
				{
					score = targetScore;
				}

				scoreLabel.text = padWith("" + score, 8);
			}
		}
		else if (mode == PlayState.ModePuzzle)
		{
			// do nothing!
		}

		scoreLabel.update(elapsed);

		super.update(elapsed);
	}

	override public function draw()
	{
		scoreLabel.draw();

		super.draw();
	}

	/* Pads the provided string with the given character */
	public static function padWith(string : String, length : Int, ?char : String = "0") : String
	{
		while (string.length < length)
		{
			string = char + string;
		}

		return string;
	}
}
