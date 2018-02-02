package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;

import text.PixelText;
import text.TextUtils;

class GameOverState extends FlxTransitionableState
{
	public var labelLabel : FlxBitmapText;
	public var scoreLabel : FlxBitmapText;

	public var btnRetry : Button;
	public var btnGiveup : Button;

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

		var background : FlxBackdrop = database.BackgroundDatabase.BuildRandomBackground();
        background.scrollFactor.set(0.35, 0.35);
        background.velocity.set(0, -5);
        add(background);

		var backLayer : FlxSprite = new FlxSprite(0, 0, "assets/ui/gameover-bg.png");
		add(backLayer);

		if (mode == PlayState.ModeArcade)
		{
			labelLabel = PixelText.New(16, 152, "Score:");
			scoreLabel = PixelText.New(FlxG.width / 2, 152, TextUtils.padWith("" + score, 8, " "));
			add(labelLabel);
			add(scoreLabel);
		}

		var baseY : Int = 173;

		add(PixelText.New(16, baseY, "Play Time:"));
		add(PixelText.New(FlxG.width / 2, baseY,
						TextUtils.padWith(TextUtils.formatTime(playTime), 9)));

		add(PixelText.New(16, baseY + 8, "Bubbles:"));
		add(PixelText.New(FlxG.width / 2, baseY + 8,
						TextUtils.padWith("" + bubbleCount, 8)));

		add(PixelText.New(16, baseY + 16, "Cleans:"));
		add(PixelText.New(FlxG.width / 2, baseY + 16,
						TextUtils.padWith("" + cleanScreens, 8)));

		btnGiveup = new Button(8, 256, onGiveupButtonPressed);
		btnGiveup.loadSpritesheet("assets/ui/btn-gameover-tomenu.png", 80, 26);
		add(btnGiveup);

		btnRetry = new Button(92, 256, onRetryButtonPressed);
		btnRetry.loadSpritesheet("assets/ui/btn-gameover-again.png", 80, 26);
		add(btnRetry);
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
		if (mode == PlayState.ModeArcade)
			GameController.StartArcadeGame();
	}

	function onRetryButtonPressed() : Void
	{
		if (mode == PlayState.ModeArcade)
			GameController.BeginArcade();
	}
}
