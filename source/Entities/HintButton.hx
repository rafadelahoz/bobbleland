package;

import flixel.FlxState;

class HintButton extends Button
{
    var world : FlxState;
    var message : String;
    var notice : TextNotice;
    var serious : Bool;

    public function new(X : Float, Y : Float, World : FlxState, Message : String, ?Serious : Bool = true)
    {
        super(X, Y, handleHintButton);
        loadSpritesheet("assets/ui/char-hint.png", 32, 32);

        world = World;

        message = Message;
        serious = Serious;
        notice = null;
    }

    function handleHintButton()
    {
        if (notice == null || notice.alpha < 0.2 || !notice.active)
            world.add(notice = new TextNotice(x, y, message, serious));
    }
}