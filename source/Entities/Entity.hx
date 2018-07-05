package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Entity extends FlxSprite
{
    public var vibrationEnabled : Bool;
    public var vibrationIntensity : Float;

    public var ShineTimerBase : Float = 1;
    public var ShineTimerVariation : Float = 0.25;
    public var ShineSparkColor : Int = Palette.White;

    var shineTimer : FlxTimer;
    
    public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
    {
        super(X, Y, SimpleGraphic);

        vibrationEnabled = false;
        vibrationIntensity = 0;

        shineTimer = new FlxTimer();
    }

    override public function destroy()
    {
        if (shineTimer != null)
        {
            shineTimer.cancel();
            shineTimer.destroy();
        }

        super.destroy();
    }

    public function vibrate(?enabled = true, ?intensity : Float = 1)
    {
        vibrationEnabled = enabled;
        vibrationIntensity = intensity;
    }

    override public function draw()
    {
        if (vibrationEnabled) {
			var tx : Float = x;
			var ty : Float = y;

			x += FlxG.random.float(-vibrationIntensity, vibrationIntensity);
			y += FlxG.random.float(-vibrationIntensity, vibrationIntensity);

			super.draw();

			x = tx;
			y = ty;
		}
		else
		{
			super.draw();
		}
    }

    public function shine(?t : FlxTimer = null)
    {
        if (t == null)
        {
            if (shineTimer == null)
            {
                shineTimer = new FlxTimer();
            }

            t = shineTimer;
        }

        FlxG.state.add(new FxSpark(FlxG.random.float(x+2, x+width-10),
                                   FlxG.random.float(y+2, y+width-10),
                                   this,
                                   getSparkColor()));
        t.start(FlxG.random.float(ShineTimerBase * (1-ShineTimerVariation),
                                  ShineTimerBase * (1 + ShineTimerVariation)),
                            shine);
    }

    public function getSparkColor() : Int
    {
        return ShineSparkColor;
    }
}

class FxSpark extends FlxSprite
{
    var delta : FlxPoint;
    var owner : FlxSprite;

    public function new(X : Float, Y : Float, Owner : FlxSprite, ?Color : Int = -1)
    {
        super(X, Y);

        owner = Owner;
        delta = FlxPoint.get(X - Owner.x, Y - Owner.y);

        loadGraphic("assets/images/spark_sheet.png", true, 8, 8);
        animation.add("blink", [0, 1, 2, 3, 1, 0], FlxG.random.int(7, 10), false);
        animation.finishCallback = onAnimationFinish;
        animation.play("blink");

        if (Color != -1)
            color = Color;
        else
            color = Palette.White;
    }

    override public function destroy()
    {
        delta.put();
        super.destroy();
    }

    function onAnimationFinish(animName : String)
    {
        destroy();
    }

    override public function draw()
    {
        // Move with your owner entity
        x = owner.x + delta.x;
        y = owner.y + delta.y;

        super.draw();
    }
}