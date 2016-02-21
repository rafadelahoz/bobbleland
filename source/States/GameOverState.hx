package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.addons.ui.FlxButtonPlus;

import text.PixelText;
import text.TextUtils;

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

	var mode : Int;

	public function new(Mode : Int, Data : Dynamic)
	{
		super();

		mode = Mode;

		score = Data.score;
		bubbleCount = Data.bubbles;
		playTime = Data.time;
		cleanScreens = Data.cleans;
	}

	override public function create()
	{
		super.create();

		var baseY : Float = FlxG.height / 5;

		titleLabel = PixelText.New(FlxG.width / 2 - 36, baseY, "GAME OVER!");
		add(titleLabel);

		if (mode == PlayState.ModeArcade)
		{
			labelLabel = PixelText.New(16, baseY + 40, "Score:");
			scoreLabel = PixelText.New(FlxG.width / 2, baseY + 40, TextUtils.padWith("" + score, 8, " "));
			add(labelLabel);
			add(scoreLabel);
		}

		btnRetry = new FlxButtonPlus(FlxG.width / 2 - 24, 3*FlxG.height / 4, onRetryButtonPressed, "Retry", 48, 16);
		btnRetry.updateActiveButtonColors([0xFF101010, 0xFF101010]);
		btnRetry.updateInactiveButtonColors([0xFF000000, 0xFF000000]);

		btnGiveup = new FlxButtonPlus(FlxG.width / 2 - 24, 3*FlxG.height / 4 + 24, onGiveupButtonPressed, "Give up", 48, 16);
		btnGiveup.updateActiveButtonColors([0xFF101010, 0xFF101010]);
		btnGiveup.updateInactiveButtonColors([0xFF000000, 0xFF000000]);


		baseY += 40;

		add(PixelText.New(16, baseY + 40, "Play Time:"));
		add(PixelText.New(FlxG.width / 2, baseY + 40,
						TextUtils.padWith(TextUtils.formatTime(playTime), 9)));

		add(PixelText.New(16, baseY + 48, "Bubbles:"));
		add(PixelText.New(FlxG.width / 2, baseY + 48,
						TextUtils.padWith("" + bubbleCount, 8)));

		add(PixelText.New(16, baseY + 56, "Cleans:"));
		add(PixelText.New(FlxG.width / 2, baseY + 56,
						TextUtils.padWith("" + cleanScreens, 8)));

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
		if (mode == PlayState.ModeArcade)
			GameController.StartArcadeGame();
		else if (mode == PlayState.ModePuzzle)
			GameController.StartAdventureGame();
	}
}
