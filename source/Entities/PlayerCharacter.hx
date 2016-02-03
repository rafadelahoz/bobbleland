package;

import flixel.FlxSprite;

class PlayerCharacter extends FlxSprite
{
    public var world : PlayState;    

    public function new(X : Float, Y : Float, World : PlayState)
    {
        super(X, Y);
        world = World;

        loadGraphic("assets/images/char-pug.png", true, 24, 24);
        animation.add("left", [0]);
        animation.add("center", [1]);
        animation.add("right", [2]);
        animation.play("center");


    }

    override public function update()
    {
        if (GamePad.checkButton(GamePad.Left))
            animation.play("left");
        else if (GamePad.checkButton(GamePad.Right))
            animation.play("right");
        else
            animation.play("center");

        super.update();
    }
}
