package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Entity extends FlxSprite
{
    public var vibrationEnabled : Bool;
    public var vibrationIntensity : Float;

    public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
    {
        super(X, Y, SimpleGraphic);

        vibrationEnabled = false;
        vibrationIntensity = 0;
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
}
