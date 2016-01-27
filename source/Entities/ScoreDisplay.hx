package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.text.FlxBitmapTextField;

class ScoreDisplay extends FlxObject
{
	public var mode : Int;

	public var score : Int;
	public var scoreLabel : FlxBitmapTextField;
	
	var scoreDelta : Int = 5;
	var targetScore : Int;

	public function new(X : Float, Y : Float, Mode : Int, ?Score : Int = 0)
	{
		super(X, Y);
		
		mode = Mode;
		
		score = Score;
		targetScore = Score;
		
		scoreLabel = text.PixelText.New(0, 0, "", 0xFFFFFFFF, FlxG.width);		
		
		if (mode == PlayState.ModePuzzle)
		{
			scoreLabel.text = "PUZZLE";
		}
		else
		{
			scoreLabel.text = padWith("" + score, 8);
		}
	}
	
	public function add(value : Int) : Int
	{
		targetScore += value;
		
		scoreDelta = Std.int((targetScore - score) / 60.0);
		
		return targetScore;
	}
	
	override public function update()
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
	
		scoreLabel.update();
		
		super.update();
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