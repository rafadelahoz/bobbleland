package;

import flixel.FlxG;
import flixel.FlxSprite;

class Button extends FlxSprite
{
    var callback : Void -> Void;

    public function new(X : Float, Y : Float, ?Callback : Void -> Void = null)
    {
        super(X, Y);

        callback = Callback;
    }

    public function loadSpritesheet(Sprite : String, Width : Float, Height : Float)
    {
        loadGraphic(Sprite, true, Std.int(Width), Std.int(Height));

        animation.add("idle", [0]);
        animation.add("pressed", [1]);
        animation.play("idle");
    }

    override public function update()
    {
        animation.play("idle");

        for (touch in FlxG.touches.list)
		{
            if (touch.overlaps(this))
            {
    			if (touch.pressed)
    			{
    				animation.play("pressed");
                    return;
                }
                else if (touch.justReleased)
                {
                    animation.play("idle");
                    if (callback != null)
                        callback();

                    return;
                }
            }
        }
    }
}
