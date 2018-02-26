package;

import flixel.FlxG;
import flixel.FlxSprite;

class Button extends FlxSprite
{
    public var callback : Void -> Void;
    public var onPressCallback : Void -> Void;

    var hasGraphic : Bool;

    var pressed : Bool;

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
        var wasPressed : Bool = pressed;

        if (hasGraphic)
            animation.play("idle");
        else
            visible = false;

        #if desktop
        if (mouseOver())
        {
            if (FlxG.mouse.pressed)
            {
                pressed = true;
            }
            else if (FlxG.mouse.justReleased)
            {
                pressed = false;
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
                    pressed = true;
                    break;
                }
                else if (touch.justReleased)
                {
                    pressed = false;
                    break ;
                }
            }
        }
        #end

        if (!wasPressed && pressed)
            onPressed();
        else if (pressed)
            whilePressed();

        if (wasPressed && !pressed)
            onReleased();
        else if (!pressed)
            whileReleased();

        // Post callback state handling?
        #if desktop
        if (pressed && FlxG.mouse.justReleased)
        {
            pressed = false;
        }
        #end

        #if mobile
        if (pressed)
            for (touch in FlxG.touches.list)
    		{
                if (touch.justReleased)
                {
                    pressed = false;
                    break;
                }
            }
        #end

        super.update(elapsed);
    }

    function onPressed() : Void
    {
        click();
        if (hasGraphic)
            animation.play("pressed");
        if (onPressCallback != null)
            onPressCallback();
    }

    function whilePressed() : Void
    {
        if (hasGraphic)
            animation.play("pressed");
    }

    function onReleased() : Void
    {
        clock();
        if (hasGraphic)
            animation.play("idle");
        if (callback != null)
            callback();
    }

    function whileReleased() : Void
    {
        if (hasGraphic)
            animation.play("released");
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
        SfxEngine.play(SfxEngine.SFX.Click);
    }

    public function clock()
    {
        #if android
        Hardware.vibrate(10);
        #end
        SfxEngine.play(SfxEngine.SFX.Clock);
    }
}
