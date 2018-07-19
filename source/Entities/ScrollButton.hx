package;

import flixel.FlxG;
import flixel.input.touch.FlxTouch;

class ScrollButton extends Button
{
    static inline var StateIdle : Int = 0;
    static inline var StateBound : Int = 1;

    var state : Int;
    var boundTouch : FlxTouch;

    public var moveCallback : Void -> Void;
    public var unboundCallback : Void -> Void;

    public var top : Float;
    public var bottom : Float;

    var prevY : Float;

    public var progress(get, null) : Float;
    function get_progress() : Float
    {
        return (y-top) / (bottom-top);
    }

    public function new(X : Float, Y : Float, ?MoveCallback : Void -> Void = null)
    {
        super(X, Y);

        state = StateIdle;
        unboundCallback = null;
        moveCallback = MoveCallback;

        loadSpritesheet("assets/ui/btn-scroller.png", 16, 32);

        prevY = 0;
    }

    public function setLimits(topLimit : Float, bottomLimit : Float)
    {
        top = topLimit;
        bottom = bottomLimit;
    }

    override public function update(elapsed:Float)
    {
        switch (state)
        {
            case ScrollButton.StateIdle:
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
            case ScrollButton.StateBound:

                var dy : Float;
                // Follow the touch/mouse
                if (boundTouch != null)
                    dy = boundTouch.y;
                else
                    dy = FlxG.mouse.y;

                dy -= prevY;

                y += dy;

                // Handle limits
                if (y < top)
                    y = top;
                else if (y > bottom)
                    y = bottom;

                if (moveCallback != null)
                    moveCallback();

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

        if (state == StateBound)
        {
            // SwipeManager.Enabled = false;
        }
        else
        {
            // SwipeManager.Enabled = true;
        }

        super.update(elapsed);

        // Override parent animation control
        if (state == StateIdle)
            animation.play("idle");
        else if (state == StateBound)
            animation.play("pressed");

        if (boundTouch != null)
            prevY = boundTouch.y;
        else
            prevY = FlxG.mouse.y;
    }
}
