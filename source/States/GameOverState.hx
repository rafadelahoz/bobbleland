package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxBitmapTextField;

import text.PixelText;

class GameOverState extends FlxState
{
	public var titleLabel : FlxBitmapTextField;
	public var labelLabel : FlxBitmapTextField;
	public var scoreLabel : FlxBitmapTextField;
	public var optionsLabel : FlxBitmapTextField;
	
	public var score : Int;
	
	public function new(Score : Int)
	{
		super();
		
		score = Score;
	}
	
	override public function create()
	{
		super.create();
		
		titleLabel = PixelText.New(FlxG.width / 2 - 36, FlxG.height / 5, "GAME OVER!");		
		labelLabel = PixelText.New(16, titleLabel.y + 8 + 32, "Score:");
		scoreLabel = PixelText.New(FlxG.width / 2, titleLabel.y + 8 + 32, padWith("" + score, 8));		
		optionsLabel = PixelText.New(FlxG.width / 2 - 24, 3*FlxG.height / 4, "GIVE UP");
		
		add(titleLabel);
		add(labelLabel);
		add(scoreLabel);
		add(optionsLabel);
	}
	
	override public function update()
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			GameController.ToMenu();
		}
	
		super.update();
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