package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;
import flixel.addons.display.FlxBackdrop;

import text.PixelText;
import text.TextUtils;

import database.BackgroundDatabase;

class MenuState extends FlxState
{
	public var tween : FlxTween;

	var touchLabel : FlxBitmapText;
	var yearsLabel : FlxBitmapText;
	var creditsLabel : FlxBitmapText;
	var background : FlxBackdrop;

	var startTouchZone : FlxObject;

	override public function create():Void
	{
		super.create();

		GameController.Init();

        background = BackgroundDatabase.BuildRandomBackground();
		background.scrollFactor.set(0.35, 0.35);
        background.velocity.set(0, 10);
		background.alpha = 0;
        add(background);

		var borderTop : FlxSprite = new FlxSprite(0, -8, "assets/ui/border-top.png");
		add(borderTop);

		var borderBottom : FlxSprite = new FlxSprite(0, FlxG.height - 24, "assets/ui/border-top.png");
		borderBottom.scale.y = -1;
		add(borderBottom);

		var logo : FlxSprite = new FlxSprite(0, -64, "assets/ui/title.png");
		add(logo);

		tween = FlxTween.tween(logo, {y : 64}, 0.75, {onComplete: onLogoPositioned, ease : FlxEase.elasticOut });

		touchLabel = PixelText.New(FlxG.width / 2 - 56, Std.int(FlxG.height - FlxG.height/4), "Touch to start");
		touchLabel.alpha = 0;
		add(touchLabel);

		startTouchZone = new FlxObject(0, touchLabel.y - 32, FlxG.width, 72);
		add(startTouchZone);

		yearsLabel = PixelText.New(FlxG.width / 2 - 44, Std.int(FlxG.height - FlxG.height/6) + 4, "2015-2018");
		yearsLabel.alpha = 0;
		add(yearsLabel);
		creditsLabel = PixelText.New(FlxG.width / 2 - 48, yearsLabel.y + 12, "The Badladns");
		creditsLabel.alpha = 0;
		add(creditsLabel);

		FlxTween.tween(yearsLabel, {alpha : 1}, 0.75, {ease : FlxEase.cubeInOut});
		FlxTween.tween(creditsLabel, {alpha : 1}, 0.75, {ease : FlxEase.cubeInOut});
	}

	public function onLogoPositioned(_t:FlxTween):Void
	{
		FlxTween.tween(touchLabel, {alpha : 1}, 1, {ease : FlxEase.cubeInOut});
		FlxTween.tween(background, {alpha : 0.8}, 1.5, {ease : FlxEase.cubeInOut});
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		#if desktop
        if (FlxG.mouse.pressed)
        {
            // animation.play("pressed");
        }
        else if (FlxG.mouse.justReleased)
        {
            // animation.play("idle");
            onArcadeButtonPressed();
        }
        #end

        #if mobile
        for (touch in FlxG.touches.list)
		{
            if (touch.overlaps(startTouchZone))
            {
    			if (touch.pressed)
    			{
    				// animation.play("pressed");
                    break;
                }
                else if (touch.justReleased)
                {
                    // animation.play("idle");
                    onArcadeButtonPressed();
                    break ;
                }
            }
        }
        #end
	}

	public function onArcadeButtonPressed() : Void
	{
		GameController.StartArcadeGame();
	}
}
