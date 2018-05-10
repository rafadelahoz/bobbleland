package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class PlayerCharacter extends FlxSprite
{
    public var world : PlayState;

    public var characterId : String;

    public var belt : FlxSprite;
    public var hurry : FlxSprite;
    public var hurryTween : FlxTween;

    public function new(X : Float, Y : Float, World : PlayState, CharacterId : String)
    {
        super(X, Y);
        world = World;
        characterId = CharacterId;

        prepareGraphic();
        animation.play("idle");

        facing = FlxObject.RIGHT;

        belt = new FlxSprite(x-8, y + height).loadGraphic("assets/images/conveyor-a.png", true, 48, 8);
        belt.animation.add("move", [0, 1], 4);
        belt.animation.play("move");
        belt.animation.paused = true;
        if (characterId == "crab")
            belt.y -= 16;

        hurry = new FlxSprite(x-8, y-19, "assets/images/hurry.png");
        hurry.visible = false;
        hurry.scale.set(0.9, 0.9);
        hurryTween = FlxTween.tween(hurry.scale, {x : 1, y : 1}, 0.25, { ease : FlxEase.elasticInOut, loopDelay: 0.15, type : FlxTween.PINGPONG });
    }

    function prepareGraphic()
    {
        if (characterId == null)
            trace("No character specified");

        switch (characterId)
        {
            case "pug":
                loadGraphic("assets/images/char-pug-sheet.png", true, 32, 24);
                animation.add("idle", [0, 7], 3);
                animation.add("run", [0, 1, 2, 3, 4, 5, 6], 20);
                animation.add("action", [8, 9, 10, 11, 12, 13], 30, false);
                animation.add("happy", [14, 15, 16, 17, 17, 16, 15, 14], 20);
            case "cat":
                loadGraphic("assets/images/char-cat-sheet.png", true, 32, 24);
                animation.add("idle", [0]);
                animation.add("run", [5, 6, 7, 1, 2, 3, 4], 20);
                animation.add("action", [0, 8, 9, 10, 11, 12, 13, 14, 15], 30, false);
                animation.add("happy", [0, 8, 9, 10, 11, 12, 13, 14, 15], 30);
            case "crab":
                loadGraphic("assets/images/char-crab-sheet.png", true, 32, 40);
                animation.add("idle", [0, 1, 2, 3, 0, 0, 0, 0, 0], 4, true);
                animation.add("left", [10, 11, 12, 13, 14, 15, 16], 20, true);
                animation.add("right", [20, 21, 22, 23, 24, 25, 26], 20, true);
                animation.add("action", [30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 30], 30, false);
                offset.x = 2;
                offset.y = 13;
        }

    }

    override public function update(elapsed:Float)
    {
        if (world.cursor.enabled)
        {
            if (animation.name == "action")
            {
                if (animation.finished)
                {
                    animation.play("idle");
                }
            }
            else
            {
                if (GamePad.checkButton(GamePad.Shoot))
                {
                    animation.play("action");
                    belt.animation.paused = true;
                }
                else if (GamePad.checkButton(GamePad.Left))
                {
                    switch (characterId)
                    {
                        case "crab":
                            if (animation.name != "left")
                                animation.play("left", true);
                            facing = FlxObject.LEFT;
                            belt.animation.paused = false;
                        default:
                            if (animation.name != "run")
                                animation.play("run", true);
                            facing = FlxObject.LEFT;
                            belt.animation.paused = false;
                    }

                }
                else if (GamePad.checkButton(GamePad.Right))
                {
                    switch (characterId)
                    {
                        case "crab":
                            if (animation.name != "right")
                                animation.play("right", true);
                            facing = FlxObject.RIGHT;
                            belt.animation.paused = false;
                        default:
                            if (animation.name != "run")
                                animation.play("run", true);
                            facing = FlxObject.RIGHT;
                            belt.animation.paused = false;
                    }
                }
                else
                {
                    animation.play("idle");
                    belt.animation.paused = true;
                }
            }

            switch (characterId)
            {
                case "crab":
                    flipX = false;
                default:
                    flipX = (facing == FlxObject.LEFT);
            }


            hurry.visible = (world.notifyAiming);
            hurryTween.active = (world.notifyAiming && !world.paused);
        }
        else
        {
            if (world.state == PlayState.StateWinning)
            {
                animation.play("happy");
            }
            else
            {
                animation.play("idle");
            }

            belt.animation.paused = true;
            hurry.visible = false;
            hurryTween.active = false;
        }

        belt.update(elapsed);
        hurry.update(elapsed);

        super.update(elapsed);
    }

    override public function draw()
    {
        belt.draw();
        super.draw();

        if (hurry.visible)
            hurry.draw();
    }
}
