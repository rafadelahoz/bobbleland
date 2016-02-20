package;

import flixel.FlxSprite;

class Lever extends FlxSprite
{
    public var world : PlayState;

    public function new(X : Float, Y : Float, World : PlayState)
    {
        super(X, Y);
        world = World;

        loadGraphic("assets/images/lever.png", true, 24, 16);
        animation.add("left", [0]);
        animation.add("center", [1]);
        animation.add("right", [2]);
        animation.play("center");


    }

    override public function update(elapsed:Float)
    {
        if (world.cursor.enabled)
        {
            if (GamePad.checkButton(GamePad.Left))
                animation.play("left");
            else if (GamePad.checkButton(GamePad.Right))
                animation.play("right");
            else
                animation.play("center");
        }

        super.update(elapsed);
    }
}
