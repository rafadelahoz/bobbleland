package;

import flixel.FlxG;

class Button extends Entity
{
    public var callback : Void -> Void;
    public var onPressCallback : Void -> Void;

    var hasGraphic : Bool;

    var pressed : Bool;

    var enabled : Bool;

    public function new(X : Float, Y : Float, ?Callback : Void -> Void = null)
    {
        super(X, Y);

        callback = Callback;

        hasGraphic = false;

        enabled = true;
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

        if (enabled)
        {
            #if (!mobile)
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
            #else
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
            #if !mobile
            if (pressed && FlxG.mouse.justReleased)
            {
                pressed = false;
            }
            #else
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
        }

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

    public function click()
    {
        /*#if android
        Hardware.vibrate(20);
        #end*/
        SfxEngine.play(SfxEngine.SFX.Click);
    }

    public function clock()
    {
        /*#if android
        Hardware.vibrate(10);
        #end*/
        SfxEngine.play(SfxEngine.SFX.Clock);
    }

    public function enable()
    {
        enabled = true;
    }

    public function disable()
    {
        enabled = false;
    }
}
