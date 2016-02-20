package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.addons.ui.FlxButtonPlus;

import text.PixelText;

class GameOverState extends FlxState
{
	public var titleLabel : FlxBitmapText;
	public var labelLabel : FlxBitmapText;
	public var scoreLabel : FlxBitmapText;

	public var btnRetry : FlxButtonPlus;
	public var btnGiveup : FlxButtonPlus;

	public var score : Int;

	var bubbleCount : Int;
	var playTime : Int;
	var cleanScreens : Int;

	public function new(Score : Int, Data : Dynamic)
	{
		super();

		score = Score;

		bubbleCount = Data.bubbles;
		playTime = Data.time;
		cleanScreens = Data.cleans;
	}

	override public function create()
	{
		super.create();

		titleLabel = PixelText.New(FlxG.width / 2 - 36, FlxG.height / 5, "GAME OVER!");
		labelLabel = PixelText.New(16, titleLabel.y + 8 + 32, "Score:");
		scoreLabel = PixelText.New(FlxG.width / 2, titleLabel.y + 8 + 32, padWith("" + score, 8, " "));

		// optionsLabel = PixelText.New(FlxG.width / 2 - 24, 3*FlxG.height / 4, "GIVE UP");

		btnRetry = new FlxButtonPlus(FlxG.width / 2 - 24, 3*FlxG.height / 4, onRetryButtonPressed, "Retry", 48, 16);
		btnRetry.updateActiveButtonColors([0xFF101010, 0xFF101010]);
		btnRetry.updateInactiveButtonColors([0xFF000000, 0xFF000000]);

		btnGiveup = new FlxButtonPlus(FlxG.width / 2 - 24, 3*FlxG.height / 4 + 24, onGiveupButtonPressed, "Give up", 48, 16);
		btnGiveup.updateActiveButtonColors([0xFF101010, 0xFF101010]);
		btnGiveup.updateInactiveButtonColors([0xFF000000, 0xFF000000]);

		add(titleLabel);
		add(labelLabel);
		add(scoreLabel);

		add(PixelText.New(16, scoreLabel.y + 8 + 32, "Play Time:"));
		add(PixelText.New(FlxG.width / 2, scoreLabel.y + 8 + 32, padWith("" + playTime, 8)));
		add(PixelText.New(16, scoreLabel.y + 16 + 32, "Bubbles:"));
		add(PixelText.New(FlxG.width / 2, scoreLabel.y + 16 + 32, padWith("" + bubbleCount, 8)));
		add(PixelText.New(16, scoreLabel.y + 24 + 32, "Cleans:"));
		add(PixelText.New(FlxG.width / 2, scoreLabel.y + 24 + 32, padWith("" + cleanScreens, 8)));

		add(btnRetry);
		add(btnGiveup);
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			GameController.ToMenu();
		}

		super.update(elapsed);
	}

	function onGiveupButtonPressed() : Void
	{
		GameController.ToMenu();
	}

	function onRetryButtonPressed() : Void
	{
		GameController.StartArcadeGame();
	}

	/* Pads the provided string with the given character */
	public static function padWith(string : String, length : Int, ?char : String = " ") : String
	{
		while (string.length < length)
		{
			string = char + string;
		}

		return string;
	}
}
