package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.touch.FlxTouch;

class SliderButton extends Button
{
    static var StateIdle : Int = 0;
    static var StateBound : Int = 1;

    var state : Int;
    var boundTouch : FlxTouch;

    var unboundCallback : Void -> Void;

    var left : Float;
    var right : Float;

    public function new(X : Float, Y : Float, ?Callback : Void -> Void = null)
    {
        super(X, Y);

        state = StateIdle;
        unboundCallback = Callback;
    }

    public function setLimits(leftLimit : Float, rightLimit : Float)
    {
        left = leftLimit;
        right = rightLimit;
    }

    override public function update(elapsed:Float)
    {
        switch (state)
        {
            case SliderButton.StateIdle:
                if (mouseOver())
                {
                    if (FlxG.mouse.pressed)
                    {
                        state = StateBound;
                    }
                }

                for (touch in FlxG.touches.list)
        		{
                    if (touch.overlaps(this))
                    {
            			if (touch.pressed)
            			{
            				state = StateBound;
                            boundTouch = touch;
                            break;
                        }
                    }
                }
            case SliderButton.StateBound:

                // Follow the touch/mouse
                if (boundTouch != null)
                    x = boundTouch.x - width/2;
                else
                    x = FlxG.mouse.x - width/2;

                // Handle limits
                if (x < left + width/2)
                    x = left + width/2;
                else if (x > right - width/2)
                    x = right - width/2;

                // Check for release
                if (FlxG.mouse.justReleased ||
                    (boundTouch != null && boundTouch.justReleased))
                {
                    boundTouch = null;
                    state = StateIdle;

                    if (unboundCallback != null)
                        unboundCallback();
                }

        }

        super.update(elapsed);

        // Override parent animation control
        if (state == StateIdle)
            animation.play("idle");
        else if (state == StateBound)
            animation.play("pressed");
    }
}
