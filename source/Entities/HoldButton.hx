package;

import flixel.FlxG;
import flixel.FlxSprite;

/*#if android
import Hardware;
#end*/

class HoldButton extends Button
{
    static inline var StateIdle : Int = 0;
    static inline var StatePressed : Int = 1;

    var beingTapped : Bool;

    var pressedCallback : Void -> Void;
    var releasedCallback : Void -> Void;

    var state : Int;

    public function new(X : Float, Y : Float, ?PressedCallback : Void -> Void = null, ?ReleasedCallback : Void -> Void = null)
    {
        super(X, Y, onHoldButtonReleased);

        pressedCallback = PressedCallback;
        releasedCallback = ReleasedCallback;

        state = StateIdle;
        beingTapped = false;
    }

    function onHoldButtonReleased()
    {
        switch (state)
        {
            case HoldButton.StateIdle:
                state = HoldButton.StatePressed;
                if (pressedCallback != null)
                    pressedCallback();
            case HoldButton.StatePressed:
                state = HoldButton.StateIdle;
                if (releasedCallback != null)
                    releasedCallback();
        }
    }

    public function setPressed(pressed : Bool, ?invokeCallback : Bool = false)
    {
        if (pressed && state == StateIdle)
        {
            state = HoldButton.StatePressed;
            animation.play("pressed");
            if (invokeCallback && pressedCallback != null)
                pressedCallback();
        }
        else if (!pressed && state == StatePressed)
        {
            clock();
            state = HoldButton.StateIdle;
            animation.play("idle");
            if (invokeCallback && releasedCallback != null)
                releasedCallback();
        }
    }

    public function isPressed() : Bool
    {
        return state == StatePressed;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        beingTapped = false;

        #if (!mobile)
        if (mouseOver() && FlxG.mouse.pressed)
        {
            beingTapped = true;
        }
        #else
        for (touch in FlxG.touches.list)
		{
            if (touch.overlaps(this) && touch.pressed)
            {
				beingTapped = true;
                break;
            }
        }
        #end

        if (!beingTapped)
        {
            switch (state)
            {
                case HoldButton.StateIdle:
                    animation.play("idle");
                case HoldButton.StatePressed:
                    animation.play("pressed");
            }
        }
    }
}
