package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;

import text.PixelText;
import text.TextUtils;

class GameOverState extends FlxTransitionableState
{
	var buttonLayer : FlxGroup;
	public var btnRetry : Button;
	public var btnGiveup : Button;

	var ticket : Ticket;
	var data : Dynamic;

	var mode : Int; // Unused

	public function new(Mode : Int, Data : Dynamic)
	{
		super();

		mode = Mode;
		data = Data;
	}

	override public function create()
	{
		super.create();

		var background : FlxBackdrop = database.BackgroundDatabase.BuildRandomBackground();
        background.scrollFactor.set(0.35, 0.35);
        background.velocity.set(0, -5);
        // add(background);

		var blackStrip : FlxSprite;
		blackStrip = new FlxSprite(0, 272);
		blackStrip.makeGraphic(FlxG.width, 48, 0xFF000000);
		add(blackStrip);

		// Build action button layer
		buttonLayer = new FlxGroup();
		add(buttonLayer);

		btnGiveup = new Button(8, 280, onGiveupButtonPressed);
		btnGiveup.loadSpritesheet("assets/ui/btn-gameover-tomenu.png", 80, 26);
		btnGiveup.active = false;
		btnGiveup.visible = false;
		buttonLayer.add(btnGiveup);

		btnRetry = new Button(92, 280, onRetryButtonPressed);
		btnRetry.loadSpritesheet("assets/ui/btn-gameover-again.png", 80, 26);
		btnRetry.active = false;
		btnRetry.visible = false;
		buttonLayer.add(btnRetry);

		// Generate results ticket
		ticket = new Ticket();
		ticket.init(data);
		ticket.signatureCallback = onTicketSigned;

		var printer : PrinterMachine = new PrinterMachine();
		printer.create(ticket);
		add(printer);

		FlxG.camera.setPosition(0, 0);
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			GameController.ToMenu();
		}

		if (FlxG.keys.justPressed.S)
		{
			var filename : String = Screenshot.take();
			trace(filename);
		}

		super.update(elapsed);
	}

	function onGiveupButtonPressed() : Void
	{
		// if (mode == PlayState.ModeArcade)
		GameController.StartArcadeGame(true);
	}

	function onRetryButtonPressed() : Void
	{
		// TODO: Missing difficulty setting?
		GameController.BeginArcade();
	}

	function onTicketSigned()
	{
		// Enable buttons
		btnGiveup.active = true;
		btnGiveup.visible = true;

		if (ProgressStatus.progressData.fanfare == null || ProgressStatus.progressData.fanfare == "none")
		{
			// Don't allow to retry if a new character has been unlocked
			btnRetry.active = true;
			btnRetry.visible = true;
		} else {
			btnGiveup.ShineTimerBase = 0.3;
        	btnGiveup.ShineTimerVariation = 0.1;
			btnGiveup.ShineSparkColor = Palette.Yellow;
			btnGiveup.shine();
		}
	}
}
