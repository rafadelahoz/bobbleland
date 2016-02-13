package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class PlayerCharacter extends FlxSprite
{
    public var world : PlayState;

    public var belt : FlxSprite;
    public var hurry : FlxSprite;

    public function new(X : Float, Y : Float, World : PlayState)
    {
        super(X, Y);
        world = World;

        loadGraphic("assets/images/char-pug-sheet.png", true, 32, 24);
        animation.add("idle", [0, 7], 3);
        animation.add("run", [0, 1, 2, 3, 4, 5, 6], 20);
        animation.add("bark", [8, 9, 10, 11, 12, 13], 30, false);
        animation.play("idle");

        facing = FlxObject.RIGHT;

        belt = new FlxSprite(x-8, y + height).loadGraphic("assets/images/conveyor-a.png", true, 48, 8);
        belt.animation.add("move", [0, 1], 4);
        belt.animation.play("move");
        belt.animation.paused = true;

        hurry = new FlxSprite(x-8, y-19, "assets/images/hurry.png");
        hurry.visible = false;
        hurry.scale.set(0.9, 0.9);
        FlxTween.tween(hurry.scale, {x : 1, y : 1}, 0.25, { ease : FlxEase.elasticInOut, loopDelay: 0.15, type : FlxTween.PINGPONG });
    }

    override public function update()
    {
        if (world.cursor.enabled)
        {
            if (animation.name == "bark")
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
                    animation.play("bark");
                    belt.animation.paused = true;
                }
                else if (GamePad.checkButton(GamePad.Left))
                {
                    if (animation.name != "run")
                        animation.play("run", true);
                    facing = FlxObject.LEFT;
                    belt.animation.paused = false;
                }
                else if (GamePad.checkButton(GamePad.Right))
                {
                    if (animation.name != "run")
                        animation.play("run", true);
                    facing = FlxObject.RIGHT;
                    belt.animation.paused = false;
                }
                else
                {
                    animation.play("idle");
                    belt.animation.paused = true;
                }
            }

            flipX = (facing == FlxObject.LEFT);

            hurry.visible = (world.notifyAiming);
        }
        else
        {
            belt.animation.paused = true;
            hurry.visible = false;
            animation.play("idle");
        }

        belt.update();
        hurry.update();

        super.update();
    }

    override public function draw()
    {
        belt.draw();
        super.draw();

        if (hurry.visible)
            hurry.draw();
    }
}
