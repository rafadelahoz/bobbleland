package;

import flixel.FlxSprite;
import flixel.util.FlxTimer;

class Curtain extends FlxSprite
{
    var world : PauseSubstate;

    var curtainSprite : FlxSprite;
    var fullImage : FlxSprite;
    var slabTimer : FlxTimer;

    var slabDelay : Float = 0.01;
    var slabFactor : Float = 0.4;

    var callback : Void -> Void;

    public function new(X : Float, Y : Float, World : PauseSubstate, ?Callback : Void -> Void = null)
    {
        super(X, Y);

        world = World;
        callback = Callback;

        curtainSprite = new FlxSprite(0, 0).loadGraphic("assets/ui/pause-curtain.png", true, 128, 8);
        makeGraphic(128, 176, 0x00000000);

        slabTimer = new FlxTimer();

        flixel.util.FlxSpriteUtil.fill(this, 0x0);
        curtainSprite.animation.frameIndex = -1;
        slabTimer.start(slabDelay, addSlab);
    }

    public function hide(Callback : Void -> Void)
    {
        trace("HIDE with delay " + slabDelay);

        fullImage = new FlxSprite(0, 0).makeGraphic(128, 176, 0x0);
        fullImage.stamp(this);
        fullImage.stamp(world.btnResume, Std.int(world.btnResume.x - x), Std.int(world.btnResume.y - y));
        fullImage.stamp(world.btnExit, Std.int(world.btnExit.x - x), Std.int(world.btnExit.y - y));
        world.btnResume.visible = false;
        world.btnExit.visible = false;

        callback = Callback;

        curtainSprite.animation.frameIndex = 0;
        slabTimer.start(slabDelay, removeSlab);
    }

    function addSlab(t : FlxTimer)
    {
        var first : Bool = curtainSprite.animation.frameIndex == -1;
        curtainSprite.animation.frameIndex++;
        // If we have finished
        if (!first && curtainSprite.animation.frameIndex == 0)
        {
            trace("Done!");
            if (callback != null)
                callback();
        }
        else
        {
            trace("height", height);
            curtainSprite.drawFrame(true);
            stamp(curtainSprite, 0, curtainSprite.animation.frameIndex * 8);

            slabDelay *= slabFactor;
            slabTimer.start(slabDelay, addSlab);
        }
    }

    function removeSlab(t : FlxTimer)
    {
        // If we have finished
        if (height == 0)
        {
            trace("Done!");
            if (callback != null)
                callback();
        }
        else
        {
            makeGraphic(128, Std.int(height - 8), 0x0);
            stamp(fullImage);

            slabDelay *= (1-slabFactor);
            slabTimer.start(slabDelay, removeSlab);
        }
    }
}
