package scenes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class PuzzleAnnouncement extends FlxSprite
{
    var completionHandler : Void -> Void;

    var angleTween : FlxTween;

    public function new(X : Float, Y : Float)
    {
        super(X, Y);

        loadGraphic("assets/images/announcement-puzzle.png");

        x -= width/2;
        y -= height;

        // Compose the graphic with a random  message
        var message : FlxSprite = new FlxSprite(0, 0).loadGraphic("assets/images/puzzle-announcement-messages.png", true, 88, 16);
        message.animation.add("msgs", [0, 1, 2, 3], 0);
        message.animation.play("msgs");
        message.animation.paused = true;
        message.animation.randomFrame();

        stamp(message, 24, 52);

        message.destroy();
        message = null;
    }

    public function init(?OnComplete : Void -> Void = null) : Void
    {
        completionHandler = OnComplete;

        setupRotation(0.75);

        FlxTween.tween(this, {y : 240/2-height/2}, 0.8, { ease : FlxEase.elasticOut, complete: function(_t:FlxTween) {
            angleTween.cancel();
            if (completionHandler != null)
                completionHandler();
            }});
    }

    function setupRotation(time : Float)
    {
        if (angleTween != null)
            angleTween.cancel();

        angleTween = FlxTween.angle(this, -720, 7, time, {ease : FlxEase.cubeInOut, complete : function(_t:FlxTween) {
            angleTween.cancel();
            //setupRotation(time * 2);
        }});
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}
