package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
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

	var machineBG : FlxSprite;

	var ticketLayer : FlxGroup;

	var machineFG : FlxSprite;
	var btnCheckout : FlxSprite;

	var data : Dynamic;

	var mode : Int;

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

			btnGiveup = new Button(8, 296, onGiveupButtonPressed);
			btnGiveup.loadSpritesheet("assets/ui/btn-gameover-tomenu.png", 80, 26);
			buttonLayer.add(btnGiveup);

			btnRetry = new Button(92, 296, onRetryButtonPressed);
			btnRetry.loadSpritesheet("assets/ui/btn-gameover-again.png", 80, 26);
			buttonLayer.add(btnRetry);

		// Build machine
			machineBG = new FlxSprite(0, 264 + 64, "assets/ui/go-machine-bg.png");
			add(machineBG);

			// Ticket will go here
			ticketLayer = new FlxGroup();
			add(ticketLayer);

			machineFG = new FlxSprite(0, 264 + 64, "assets/ui/go-machine-fg.png");
			add(machineFG);

			// TODO: Checkout button

		var appearDuration : Float = 0.5;
		FlxTween.tween(machineBG, {y : 264}, appearDuration, {ease: FlxEase.circOut});
		FlxTween.tween(machineFG, {y : 264}, appearDuration, {ease: FlxEase.circOut});
		// TODO: Tween ticket button also!
		
		// Add ticket
		// TODO: Make it print!
		/*new flixel.util.FlxTimer().start(0.25, function(t:flixel.util.FlxTimer) {
			var t : Ticket = new Ticket();
			t.init(data);
			ticketLayer.add(t);
		});*/
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
		// if (mode == PlayState.ModeArcade)
		GameController.StartArcadeGame(true);
	}

	function onRetryButtonPressed() : Void
	{
		// if (mode == PlayState.ModeArcade)
		GameController.BeginArcade();
	}
}
