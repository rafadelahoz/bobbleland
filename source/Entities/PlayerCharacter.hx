package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class PlayerCharacter extends Entity
{
    public var world : PlayState;

    public var characterId : String;

    public var belt : FlxSprite;
    public var hurry : FlxSprite;
    public var hurryTween : FlxTween;

    public var sleepy : Int;

    public var isSleepy(get, null) : Bool;
    public inline function get_isSleepy() : Bool
    {
        return sleepy >= 2;
    }

    var sweatTimer : FlxTimer;
    var sweatRight : Bool;
    static var SweatDelay : Float = 0.75;

    var sweatRect : FlxRect;

    var alternate : Bool;
    var shiner : Entity;

    public function new(X : Float, Y : Float, World : PlayState, CharacterId : String)
    {
        super(X, Y);
        world = World;
        characterId = CharacterId;

        alternate = ArcadeGameStatus.getConfigData().alternate;

        prepareGraphic();
        animation.play("idle");

        facing = FlxObject.RIGHT;

        belt = new FlxSprite(x-8, y + height).loadGraphic("assets/images/conveyor-a.png", true, 48, 8);
        belt.animation.add("move", [0, 1], 4);
        belt.animation.play("move");
        belt.animation.paused = true;

        if (characterId == "crab")
            belt.y -= 16;
        else if (characterId == "frog")
        {
            belt.y -= 4;
        }
        else if (characterId == "bear")
        {
            belt.x -= 4;
            belt.y -= 14;
        }
        else if (characterId == "catbomb")
        {
            belt.y += 8;
        }

        if (characterId == "catbomb")
            belt.color = Palette.CatBombDarkGray;
        else
            belt.color = Palette.DarkPurple;

        setupSweatRectangle();

        if (alternate && characterId == "frog")
        {
            shiner = new Entity(sweatRect.x, sweatRect.y);
            shiner.makeGraphic(Std.int(sweatRect.width), Std.int(sweatRect.height), 0x00000000);
            world.add(shiner);
            shiner.shine();
        }

        hurry = new FlxSprite(x-8, y-19, "assets/images/hurry.png");
        hurry.visible = false;
        hurry.scale.set(0.9, 0.9);
        hurryTween = FlxTween.tween(hurry.scale, {x : 1, y : 1}, 0.25, { ease : FlxEase.elasticInOut, loopDelay: 0.15, type : FlxTween.PINGPONG });

        if (characterId == "cat")
            sleepy = 0;
        else
            sleepy = -1;

        sweatTimer = new FlxTimer();
    }

    function setupSweatRectangle()
    {
        switch (characterId)
        {
            case "pug":
                sweatRect = FlxRect.get(x-4, y-3, width+4, height);
            case "cat":
                sweatRect = FlxRect.get(x-6, y-4, width+8, height+4);
            case "crab":
                sweatRect = FlxRect.get(x-4, y-4, width+8, height+4);
            case "frog":
                sweatRect = FlxRect.get(x+6-offset.x, y, width-16+4, height-4);
            case "bear":
                sweatRect = FlxRect.get(x - offset.x, y - offset.y, width, height);
            case "catbomb":
                sweatRect = FlxRect.get(x-4, y-4, 36, 24);
            default:
                sweatRect = null;
        }
    }

    override public function destroy()
    {
        if (sweatTimer != null)
        {
            sweatTimer.cancel();
            sweatTimer.destroy();
            sweatTimer = null;
        }

        if (hurry != null)
        {
            hurry.destroy();
            hurry = null;
        }

        if (hurryTween != null)
        {
            hurryTween.cancel();
            hurryTween.destroy();
            hurryTween = null;
        }

        if (belt != null)
        {
            belt.destroy();
            belt = null;
        }

        sweatRect.put();

        super.destroy();
    }

    function prepareGraphic()
    {
        if (characterId == null)
            trace("No character specified");

        switch (characterId)
        {
            case "pug":
                loadGraphic("assets/images/char-pug-sheet" + (alternate ? "-alternate.png" : ".png"), true, 32, 24);
                animation.add("idle", [0, 7], 3);
                animation.add("run", [0, 1, 2, 3, 4, 5, 6], 20);
                animation.add("action", [8, 9, 10, 11, 12, 13], 30, false);
                animation.add("happy", [14, 15, 16, 17, 17, 16, 15, 14], 20);
            case "cat":
                loadGraphic("assets/images/char-cat-sheet" + (alternate ? "-alternate.png" : ".png"), true, 32, 24);
                animation.add("idle", [0]);
                animation.add("run", [5, 6, 7, 1, 2, 3, 4], 20);
                animation.add("action", [0, 8, 9, 10, 11, 12, 13, 14, 15], 30, false);
                animation.add("happy", [0, 0, 0, 0, 32, 33, 34, 35, 46, 35, 46, 35, 46, 35, 46, 35, 46, 35, 46, 35, 46, 35, 46, 35, 46, 35, 46], 3, false);

                // Special animations for catbomb unlocking
                animation.add("yawn", [16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31], 20, false);
                animation.add("sleep-in", [32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45], 25, false);
                animation.add("sleep", [44, 45], 2);
            case "crab":
                loadGraphic("assets/images/char-crab-sheet" + (alternate ? "-alternate.png" : ".png"), true, 32, 40);
                animation.add("idle", [0, 1, 2, 3, 0, 0], 4, true);
                animation.add("left", [10, 11, 12, 13, 14, 15, 16], 20, true);
                animation.add("right", [20, 21, 22, 23, 24, 25, 26], 20, true);
                animation.add("action", [30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 30], 30, false);
                animation.add("happy", [0, 1, 2, 3, 0, 0], 4, true);
                offset.x = 2;
                offset.y = 13;
            case "frog":
                loadGraphic("assets/images/char-frog-sheet" + (alternate ? "-alternate.png" : ".png"), true, 48, 28);
                animation.add("idle", [0]);
                animation.add("run", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21], 30, true);
                animation.add("action", [22, 23, 24, 25, 26, 26, 27, 28, 28, 29, 30], 30, false);
                animation.add("happy", [22, 23, 24], 20, false);
                offset.x = 8;
                offset.y = 4;
            case "bear":
                loadGraphic("assets/images/char-bear-sheet" + (alternate ? "-alternate.png" : ".png"), true, 64, 38);
                animation.add("idle", [0]);
                animation.add("run", [0, 1, 2, 3, 4, 5, 6, 7, 8], 25, true);
                animation.add("action", [9, 10, 11, 12, 13, 14, 15, 16], 30, false);
                animation.add("happy", [17, 18], 2, true);
                offset.x = 20;
                offset.y = 14;
            case "catbomb":
                loadGraphic("assets/images/char-catbomb-sheet" + (alternate ? "-alternate.png" : ".png"), true, 16, 16);
                animation.add("idle", [0, 1], 1, true);
                animation.add("run", [0, 1], 8, true);
                animation.add("action", [6, 7, 6, 7], 8, false);
                animation.add("happy", [4, 5], 6, true);
                offset.x = -8;
                offset.y = -8;
        }

    }

    override public function update(elapsed:Float)
    {
        /*if (!canSwitchAnim())
            color = Palette.Red;
        else
            color = Palette.White;
            */

        if (world.state != PlayState.StateLosing)
        {
            if (world.inDanger() && !world.paused && sleepy < 2)
            {
                if (!sweatTimer.active)
                {
                    sweatTimer.start(SweatDelay, onSweatTimer);
                    sweatRight = FlxG.random.bool();
                }
            }
            else
            {
                if (sweatTimer.active)
                {
                    sweatTimer.active = false;
                }
            }
        }
        else
        {
            sweatTimer.cancel();
        }

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

                    // Actions make the cat awake, and he can't sleep again
                    awake();
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
                            if (canSwitchAnim())
                            {
                                if (animation.name != "run")
                                    animation.play("run", true);
                                facing = FlxObject.LEFT;
                                belt.animation.paused = false;
                            }
                    }

                    // Actions make the cat awake, and he can't sleep again
                    awake();
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
                            if (canSwitchAnim())
                            {
                                if (animation.name != "run")
                                    animation.play("run", true);
                                facing = FlxObject.RIGHT;
                                belt.animation.paused = false;
                            }
                    }

                    awake();
                }
                else
                {
                    // Avoid changing animations while sleeping
                    if (sleepy <= 0 && canSwitchAnim())
                    {
                        animation.play("idle");
                    }
                    belt.animation.paused = true;
                }
            }

            switch (characterId)
            {
                case "crab":
                    flipX = false;
                default:
                    flipX = !(facing == FlxObject.LEFT);
            }

            // Avoid hurrying while sleeping
            if (sleepy > 0)
            {
                hurry.visible = false;
                hurryTween.active = false;
            }
            else
            {
                hurry.visible = (world.notifyAiming);
                hurryTween.active = (world.notifyAiming && !world.paused);
            }
        }
        else
        {
            // Avoid changing animations while sleeping
            if (sleepy < 3)
            {
                if (world.state == PlayState.StateWinning || world.state == PlayState.StateLosing)
                {
                    if (animation.name != "happy")
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
        }

        /** Catbomb unlocking gimmick **/
        /* Handle sleepy status for the cat */
        // First, yawn (always, even with hint off, foreshadowing the lazy cat thing)
        if (sleepy == 0 && world.grid.getLowestBubbleRow() == 7)
        {
            sleepy = 1;
            animation.play("yawn");
        }
        // Then, lay down (ONLY if catbomb hint is on)
        else if (sleepy == 1 && world.grid.getLowestBubbleRow() == 9
                 && ProgressStatus.progressData.catbombHint && !ProgressStatus.progressData.catbombChar)
        {
            BgmEngine.fadeCurrent();
            sleepy = 2;
            animation.play("sleep-in");
        }
        // When finished, sleep
        else if (sleepy == 2 && animation.name == "sleep-in" && animation.finished)
        {
            sleepy = 3;
            animation.play("sleep");
        }
        // And keep sleeping
        else if (sleepy == 3)
        {
            animation.play("sleep");
        }

        belt.update(elapsed);
        hurry.update(elapsed);

        super.update(elapsed);
    }

    override function onPause()
    {
        if (shiner != null)
            shiner.matte();
    }

    override function onResume()
    {
        if (shiner != null)
            shiner.shine();
    }

    function onSweatTimer(t : FlxTimer)
    {
        sweatRight = !sweatRight;
        world.add(new Sweat(sweatRect, sweatRight));
        t.start(SweatDelay, onSweatTimer);
    }

    function canSwitchAnim(?target : String = null)
    {
        switch (characterId)
        {
            case "frog":
                if (animation.name == "run")
                    return (animation.frameIndex == 0);
                else return true;
            default:
                return true;
        }
    }

    function awake()
    {
        if (sleepy > -1)
        {
            // Actions make the cat awake, and he can't sleep again
            sleepy = -1;

            // BgmEngine.play(BgmEngine.current, 1);
            BgmEngine.fadeInCurrent(2);
        }
    }

    override public function draw()
    {
        belt.draw();
        super.draw();

        if (hurry.visible)
            hurry.draw();
    }
}

class Sweat extends FlxSprite
{
    public function new(owner : FlxRect, toRight : Bool)
    {
        super(owner.x, owner.y);

        if (toRight)
        {
            x += owner.width - 8;
        }
        else
        {
            flipX = true;
        }

        loadGraphic("assets/images/sweat-sheet.png", true, 10, 14);
        animation.add("go", [0, 1, 2, 3, 4, 5], 12, false);
        animation.play("go");
    }

    override public function update(elapsed : Float)
    {
        if (animation.finished)
        {
            destroy();
        }
        else
            super.update(elapsed);
    }
}
