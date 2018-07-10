package;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class GoldenPrinter extends PrinterMachine
{
    public static var TargetIntensity : Float = 10;

    public var intensity : Float;

    public var intensityCallback : Void -> Void;
    public var backgroundShader : Entity;
    var colorTween : FlxTween;

    public function new()
    {
        super();

        intensity = 0;
        colorTween = null;
    }

    override function getBgGraphic() : String
	{
		return "assets/ui/unlock-machine-bg.png";
	}

    override function getFgGraphic() : String
	{
		return "assets/ui/unlock-machine-fg.png";
	}

    override function buildButton() : Button
	{
		var button = new Button(16, 288 + 64);
        button.loadSpritesheet("assets/ui/btn-unlock-checkout.png", 80, 24);
        button.allowReleaseOutside = true;
        button.whilePressedCallback = whileButtonPressed;
        button.callback = onButtonReleased;
        return button;
	}

    function whileButtonPressed()
    {
        if (intensity > TargetIntensity)
            return;

        intensity += FlxG.elapsed;
        
        startMachineVibration(1 + intensity);
        BgmEngine.play(BgmEngine.BGM.Unlock, 0.5 + (intensity/TargetIntensity)*2);

        if (backgroundShader != null && colorTween == null)
        {
            colorTween = FlxTween.color(backgroundShader, TargetIntensity*0.85, backgroundShader.color, Palette.Orange);
        }

        if (intensity > TargetIntensity && intensityCallback != null)
        {
            btnCheckout.active = false;
            BgmEngine.stopCurrent();

            intensityCallback();
        }
    }

    function onButtonReleased()
    {
        if (intensity > TargetIntensity)
            return;

        intensity = 0;
        stopMachineVibration();
        BgmEngine.stopCurrent();

        if (colorTween != null)
        {
            backgroundShader.color = 0xFF000000;
            colorTween.cancel();
            colorTween = null;
        }
    }

    override function startMachineVibration(?Intensity : Float = 1)
	{
		machineBG.vibrate(true, Intensity, true);
		machineFG.vibrate(true, Intensity, true);
		btnCheckout.vibrate(true, Intensity, true);
	}

    override function printTicket(?t : FlxTween = null)
	{
		var targetY : Float = FlxG.height/2 - ticket.height/2;
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
			printTime *= 0.25;

		var startDelay : Float = (quickPrinting ? 0 : FlxG.random.float(0, 0.45));
		new FlxTimer().start(startDelay, playPrintSfx);

		printTween = FlxTween.tween(ticket, {y : ticket.y + delta}, printTime, {
			ease : FlxEase.sineOut,
			startDelay: startDelay,
			onComplete: (done ? onPrintFinished : printTicket)
		});
	}
}