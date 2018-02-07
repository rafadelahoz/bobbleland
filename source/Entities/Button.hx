package;

import flixel.FlxG;
import flixel.FlxSprite;

class Button extends FlxSprite
{
    var callback : Void -> Void;
    var hasGraphic : Bool;

    public function new(X : Float, Y : Float, ?Callback : Void -> Void = null)
    {
        super(X, Y);

        callback = Callback;

        hasGraphic = false;
    }

    public function loadSpritesheet(Sprite : String, Width : Float, Height : Float)
    {
        loadGraphic(Sprite, true, Std.int(Width), Std.int(Height));

        animation.add("idle", [0]);
        animation.add("pressed", [1]);
        animation.play("idle");

        hasGraphic = true;
    }

    override public function update(elapsed:Float)
    {
        if (hasGraphic)
            animation.play("idle");
        else
            visible = false;

        #if desktop
        if (mouseOver())
        {
            if (FlxG.mouse.pressed)
            {
                if (hasGraphic)
                    animation.play("pressed");
            }
            else if (FlxG.mouse.justReleased)
            {
                if (hasGraphic)
                    animation.play("idle");
                if (callback != null)
                    callback();
            }
        }
        #end

        #if mobile
        for (touch in FlxG.touches.list)
		{
            if (touch.overlaps(this))
            {
    			if (touch.pressed)
    			{
                    if (hasGraphic)
    				    animation.play("pressed");
                    break;
                }
                else if (touch.justReleased)
                {
                    if (hasGraphic)
                        animation.play("idle");
                    if (callback != null)
                        callback();

                    break ;
                }
            }
        }
        #end

        super.update(elapsed);
    }

    function mouseOver()
    {
        var mouseX : Float = FlxG.mouse.x;
        var mouseY : Float = FlxG.mouse.y;

        if (scrollFactor.x == 0)
            mouseX = FlxG.mouse.screenX;

        if (scrollFactor.y == 0)
            mouseY = FlxG.mouse.screenY;

        return mouseX >= x && mouseX < (x + width) &&
               mouseY >= y && mouseY < (y + height);
    }

    public function click()
    {
        #if android
        Hardware.vibrate(20);
        #end
        FlxG.sound.play("assets/sounds/btn_click.wav");
    }

    public function clock()
    {
        #if android
        Hardware.vibrate(10);
        #end
        FlxG.sound.play("assets/sounds/btn_clock.wav");
    }
}
