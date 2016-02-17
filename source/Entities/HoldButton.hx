package;

import flixel.FlxG;
import flixel.FlxSprite;

class HoldButton extends Button
{
    static var StateIdle : Int = 0;
    static var StatePressed : Int = 1;
    
    var pressedCallback : Void -> Void;
    var releasedCallback : Void -> Void;
    
    var state : Int;
    
    public function new(X : Float, Y : Float, ?PressedCallback : Void -> Void = null, ?ReleasedCallback : Void -> Void = null)
    {
        super(X, Y, onReleased);

        pressedCallback = PressedCallback;
        releasedCallback = ReleasedCallback;
        
        state = StateIdle;
    }

    function onReleased()
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
            state = HoldButton.StateIdle;
            animation.play("idle");
            if (invokeCallback && releasedCallback != null)
                releasedCallback();
        }
    }

    override public function update()
    {
        super.update();
        
        switch (state)
        {
            case HoldButton.StateIdle:
                animation.play("idle");
            case HoldButton.StatePressed:
                animation.play("pressed");
        }
    }
}
