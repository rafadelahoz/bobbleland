package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class PuzzleClear extends FlxSprite
{
    var completionHandler : Void -> Void;

    var angleTween : FlxTween;

    public function new(X : Float, Y : Float)
    {
        super(X, Y);

        loadGraphic("assets/images/puzzle-clear.png");

        x -= width/2;
        y -= height;
    }

    public function init(?OnComplete : Void -> Void = null) : Void
    {
        completionHandler = OnComplete;

        setupRotation(0.75);

        FlxTween.tween(this, {y : Constants.Height/2-height/2}, 0.8, { ease : FlxEase.elasticOut,onComplete: function(_t:FlxTween) {
            angleTween.cancel();
            if (completionHandler != null)
                completionHandler();
            }});
    }

    public function exit(?OnComplete : Void -> Void = null) : Void
    {
        var angleTween : FlxTween = FlxTween.angle(this, 720, -7, 0.5, {ease : FlxEase.cubeInOut,onComplete: function(_t:FlxTween) {
            angleTween.cancel();
        }});

        new FlxTimer().start(0.5, function(_t:FlxTimer) {
            FlxTween.tween(this, {y : Constants.Height+height/2}, 0.7, { ease : FlxEase.elasticOut, startDelay: 0.5,onComplete: function(_t:FlxTween) {
                if (OnComplete != null)
                    OnComplete();
                }
            });
        });
    }

    function setupRotation(time : Float)
    {
        if (angleTween != null)
            angleTween.cancel();

        angleTween = FlxTween.angle(this, 0, -7, time, {ease : FlxEase.cubeInOut,onComplete: function(_t:FlxTween) {
            angleTween.cancel();
        }});
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}
