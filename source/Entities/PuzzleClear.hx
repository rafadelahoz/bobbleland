package;

import flixel.FlxG;
import flixel.FlxSprite;
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

        FlxTween.tween(this, {y : FlxG.height/2-height/2}, 0.8, { ease : FlxEase.elasticOut, complete: function(_t:FlxTween) {
            angleTween.cancel();
            if (completionHandler != null)
                completionHandler();
            }});
    }

    function setupRotation(time : Float)
    {
        if (angleTween != null)
            angleTween.cancel();

        angleTween = FlxTween.angle(this, 0, -7, time, {ease : FlxEase.cubeInOut, complete : function(_t:FlxTween) {
            angleTween.cancel();
        }});
    }

    override public function update()
    {
        super.update();
    }
}
