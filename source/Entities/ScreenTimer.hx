package;

import flixel.FlxSprite;
import flixel.util.FlxTimer;

class ScreenTimer extends FlxSprite
{
    var clock : FlxSprite;
    var firstFigure : FlxSprite;
    var lastFigure : FlxSprite;

    var remainingTime: Int;
    var callback : Void -> Void;

    var timer : FlxTimer;

    public function new(X : Float, Y : Float, Time : Int, Callback : Void -> Void)
    {
        super(X, Y);

        remainingTime = Time;
        callback = Callback;

        loadGraphic("assets/images/hud-timer-bg.png");

        clock = new FlxSprite(x+8, y);
        firstFigure = new FlxSprite(x+16, y);
        lastFigure = new FlxSprite(x+24, y);

        clock.loadGraphic("assets/images/hud-timer.png", true, 8, 16);
        firstFigure.loadGraphic("assets/images/hud-timer.png", true, 8, 16);
        lastFigure.loadGraphic("assets/images/hud-timer.png", true, 8, 16);

        clock.animation.add("clock", [10]);
        firstFigure.animation.add("first", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
        lastFigure.animation.add("last", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

        clock.animation.play("clock");
        firstFigure.animation.play("first");
        lastFigure.animation.play("last");

        for (elem in [clock, firstFigure, lastFigure])
            elem.animation.pause();

        updateFigures();

        timer = new FlxTimer(1.5, onSecondElapsed, Time);
    }

    override public function update()
    {
        clock.update();
        firstFigure.update();
        lastFigure.update();

        super.update();
    }

    override public function draw()
    {
        super.draw();

        clock.draw();
        firstFigure.draw();
        lastFigure.draw();
    }

    private function onSecondElapsed(timer : FlxTimer) : Void
    {
        remainingTime--;

        updateFigures();

        if (remainingTime <= 0)
        {
            timer.cancel();
            if (callback != null)
                callback();
        }
    }

    private function updateFigures() : Void
    {
        var timeFigures = getRemainingTimeFigures();
        firstFigure.animation.frameIndex = Std.int(timeFigures.first);
        lastFigure.animation.frameIndex = Std.int(timeFigures.last);
    }

    private function getRemainingTimeFigures(): Dynamic
    {
        return {
            first: remainingTime / 10,
            last: remainingTime % 10
        }
    }
}
