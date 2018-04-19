package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
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

	var machineBG : FlxSprite;

	var ticketLayer : FlxGroup;

	var machineFG : FlxSprite;
	var btnCheckout : Button;

	var ticket : Ticket;
	var printing : Bool;
	var quickPrinting : Bool;
	var printTween : FlxTween;

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

		// Build machine
			machineBG = new FlxSprite(0, 264 + 64, "assets/ui/go-machine-bg.png");
			add(machineBG);

			// Ticket will go here
			ticketLayer = new FlxGroup();
			add(ticketLayer);

			machineFG = new FlxSprite(0, 264 + 64, "assets/ui/go-machine-fg.png");
			add(machineFG);

			// Checkout button
			btnCheckout = new Button(16, 288 + 64, onCheckoutButtonPressed);
			btnCheckout.loadSpritesheet("assets/ui/btn-go-checkout.png", 80, 24);
			add(btnCheckout);

		var appearDuration : Float = 0.5;
		FlxTween.tween(machineBG, {y : 264}, appearDuration, {ease: FlxEase.circOut});
		FlxTween.tween(machineFG, {y : 264}, appearDuration, {ease: FlxEase.circOut});
		FlxTween.tween(btnCheckout, {y : 288}, appearDuration, {ease: FlxEase.circOut});

		// Generate results ticket
		ticket = new Ticket();
		ticket.init(data);
		ticket.signatureCallback = onTicketSigned;
		printing = false;
		printTween = null;
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

	function onCheckoutButtonPressed() : Void
	{
		// Print ticket
		if (!printing)
		{
			printing = true;
			ticketLayer.add(ticket);
			ticket.y = FlxG.height - 32;
			printTicket();
		}
		else if (!quickPrinting)
		{
			quickPrinting = true;
			printTween.cancel();
			printTicket();
		}
	}

	function printTicket(?t : FlxTween = null)
	{
		var targetY : Float = 256 - ticket.height;
		var delta : Float = 0;
		var done : Bool = false;
		if (quickPrinting || Math.abs(targetY - ticket.y) < 48)
		{
			delta = targetY - ticket.y;
			done = true;
		}
		else
		{
			delta = FlxG.random.float(-16, (targetY - ticket.y) * 0.4);
		}

		var printTime : Float = (Math.abs(delta) / 8) * FlxG.random.float(0.05, 0.08);
		if (quickPrinting)
			printTime *= 0.5;

		var startDelay : Float = (quickPrinting ? 0 : FlxG.random.float(0, 0.45));
		new FlxTimer().start(startDelay, playPrintSfx);

		printTween = FlxTween.tween(ticket, {y : ticket.y + delta}, printTime, {
			ease : FlxEase.sineOut,
			startDelay: startDelay,
			onComplete: (done ? onPrintFinished : printTicket)
		});
	}

	function playPrintSfx(t : FlxTimer)
	{
		SfxEngine.play(SfxEngine.SFX.Print, 0.5);
	}

	function onPrintFinished(?t : FlxTween = null)
	{
		// Hide machine
		var hideDuration : Float = 0.5;
		FlxTween.tween(machineBG, {y : 264 + 128}, hideDuration, {ease: FlxEase.circInOut});
		FlxTween.tween(machineFG, {y : 264 + 128}, hideDuration, {ease: FlxEase.circInOut});
		FlxTween.tween(btnCheckout, {y : 288 + 128}, hideDuration, {ease: FlxEase.circInOut});
	}

	function onTicketSigned()
	{
		// Enable buttons
		btnRetry.active = true;
		btnRetry.visible = true;
		btnGiveup.active = true;
		btnGiveup.visible = true;
	}
}
