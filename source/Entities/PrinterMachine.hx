package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class PrinterMachine extends FlxGroup
{
    var machineBG : Entity;

	var ticketLayer : FlxGroup;

	var machineFG : Entity;
	var btnCheckout : Button;

	var ticket : FlxSprite;
	var printing : Bool;
	var quickPrinting : Bool;
	var printTween : FlxTween;

    var callback : Void -> Void;

    var golden : Bool;

    public function new()
    {
        super();
    }

    public function create(builtTicket : FlxSprite, ?printFinishedCallback : Void -> Void = null)
    {
        machineBG = new Entity(0, 264 + 64, getBgGraphic());
        add(machineBG);

        // Ticket will go here
        ticketLayer = new FlxGroup();
        add(ticketLayer);

        machineFG = new Entity(0, 264 + 64, getFgGraphic());
        add(machineFG);

        // Checkout button
        btnCheckout = buildButton();
		add(btnCheckout);

		appear();

        ticket = builtTicket;

        callback = printFinishedCallback;

        printing = false;
		printTween = null;
    }

	function getBgGraphic() : String
	{
		return "assets/ui/go-machine-bg.png";
	}

	function getFgGraphic() : String
	{
		return "assets/ui/go-machine-fg.png";
	}

	function buildButton() : Button
	{
		var button = new Button(16, 288 + 64, onCheckoutButtonPressed);
        button.loadSpritesheet("assets/ui/btn-go-checkout.png", 80, 24);
        return button;
	}

	function appear()
	{
		var appearDuration : Float = 0.5;
		FlxTween.tween(machineBG, {y : 264}, appearDuration, {ease: FlxEase.circOut});
		FlxTween.tween(machineFG, {y : 264}, appearDuration, {ease: FlxEase.circOut});
		FlxTween.tween(btnCheckout, {y : 288}, appearDuration, {ease: FlxEase.circOut});
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

		// Stop vibration
		stopMachineVibration();

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

    function onPrintFinished(?t : FlxTween = null)
    {
        stopMachineVibration();
		SfxEngine.stop(SfxEngine.SFX.Print);

        // TODO: hide?
        hide();

        if (callback != null)
        {
            callback();
        }
    }

    public function hide(?Duration : Float = 0.5)
    {
        var hideDuration : Float = Duration;
		FlxTween.tween(machineBG, {y : 264 + 128}, hideDuration, {ease: FlxEase.circInOut});
		FlxTween.tween(machineFG, {y : 264 + 128}, hideDuration, {ease: FlxEase.circInOut});
		FlxTween.tween(btnCheckout, {y : 288 + 128}, hideDuration, {ease: FlxEase.circInOut});
    }

	function playPrintSfx(t : FlxTimer)
	{
		SfxEngine.play(SfxEngine.SFX.Print, 0.25);
		startMachineVibration();
	}

    function startMachineVibration()
	{
		var shared : Bool = golden;
		machineBG.vibrate(true, shared);
		machineFG.vibrate(true, shared);
		btnCheckout.vibrate(true, shared);
	}

	function stopMachineVibration()
	{
		machineBG.vibrate(false);
		machineFG.vibrate(false);
		btnCheckout.vibrate(false);
	}
}
