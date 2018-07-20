package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class TextNotice extends FlxSprite
{
    var textDelta : FlxPoint;

    var border : Int;
    var pxtext : FlxBitmapText;
    var background : FlxSprite;
    var colorTween : FlxTween;

    var serious : Bool;

    public function new(X : Float, Y : Float, Text : String, ?Color : Int = -1, ?seriousMode : Bool = false, ?borderless : Bool = false)
    {
        super(X, Y);

        serious = seriousMode;

        // Initial displacement
        y += 8;
        alpha = 0;

        pxtext = text.PixelText.New(X, Y, Text, Color);
        pxtext.x = Math.max(16, X - pxtext.width / 2);
        if (pxtext.x + pxtext.width + 16 > Constants.Width)
        {
            pxtext.x = Constants.Width - 16 - pxtext.width;
        }
        pxtext.y = Y - pxtext.height / 2;

        border = 4;
        if (seriousMode)
            border = 16;

        background = new FlxSprite(pxtext.x - border/2, pxtext.y - border/2);
        background.makeGraphic(Std.int(pxtext.width + border), Std.int(pxtext.height + border), (borderless ? 0x00000000 : Palette.Black));

        textDelta = FlxPoint.get(pxtext.x - x, pxtext.y - y);

        FlxTween.tween(this, {y: y-8}, 0.3, {ease: FlxEase.cubeOut, startDelay: 0});
        FlxTween.tween(this, {alpha: 1}, 0.3, {ease: FlxEase.circOut, startDelay: 0, onComplete: onAppeared});

        if (!seriousMode || Text.indexOf("\\") >= 0)
            doColor(null);
    }

    function doColor(t : FlxTween)
    {
        if (t != null)
            t.destroy();
        var colors : Array<Int> = [Palette.White, Palette.Pink, Palette.Peach, Palette.Yellow, Palette.Red, Palette.Green, Palette.Blue];
        colorTween = FlxTween.color(pxtext, 0.3, color, FlxG.random.getObject(colors), {ease : FlxEase.circInOut, onComplete: doColor});
    }

    override public function destroy()
    {
        textDelta.put();
        pxtext.destroy();
        if (colorTween != null)
        {
            colorTween.cancel();
            colorTween.destroy();
        }

        super.destroy();
    }

    function onAppeared(t:FlxTween)
    {
        FlxTween.tween(this, {y: y-8}, 1, {ease: FlxEase.cubeOut, startDelay: 0.5 + (serious ? 1 : 0)});
        FlxTween.tween(this, {alpha: 0}, 0.5, {ease: FlxEase.circOut, startDelay: 1 + (serious ? 1 : 0), onComplete: onDisapeared});
    }

    function onDisapeared(t:FlxTween)
    {
        if (t != null)
            t.cancel();

        destroy();
    }

    override public function update(elapsed : Float)
    {
        super.update(elapsed);

        pxtext.alpha = alpha;
        pxtext.x = x + textDelta.x;
        pxtext.y = y + textDelta.y;
        pxtext.update(elapsed);

        background.alpha = alpha;
        background.x = pxtext.x - border/2;
        background.y = pxtext.y - border/2;
    }

    override public function draw()
    {
        // super.draw();
        background.draw();
        pxtext.draw();
    }
}
