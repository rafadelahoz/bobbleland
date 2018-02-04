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
import flixel.addons.transition.FlxTransitionableState;

import text.PixelText;
import text.TextUtils;

import database.BackgroundDatabase;

class MenuState extends FlxTransitionableState
{
	public var tween : FlxTween;

	var touchLabel : FlxBitmapText;
	var yearsLabel : FlxBitmapText;
	var creditsLabel : FlxBitmapText;
	var background : FlxBackdrop;

	var startTouchZone : FlxObject;

	var interactable : Bool;

	override public function create():Void
	{
		super.create();

		// Missing a preloader
		BgmEngine.init();

		GameController.Init();

		interactable = false;

		bgColor = 0xFF000000;

        background = BackgroundDatabase.BuildRandomBackground();
		background.scrollFactor.set(0.35, 0.35);
        background.velocity.set(0, 10);
		background.alpha = 0;
        add(background);

		var backgroundShader : FlxSprite = new FlxSprite(0, 0);
		backgroundShader.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		backgroundShader.alpha = 0.22;
		add(backgroundShader);

		var borderTop : FlxSprite = new FlxSprite(0, -8, "assets/ui/border-top.png");
		add(borderTop);

		var borderBottom : FlxSprite = new FlxSprite(0, FlxG.height - 24, "assets/ui/border-top.png");
		borderBottom.scale.y = -1;
		add(borderBottom);

		var logo : FlxSprite = new FlxSprite(0, -164, "assets/ui/title.png");
		add(logo);

		touchLabel = PixelText.New(FlxG.width / 2 - 56, Std.int(FlxG.height - FlxG.height/4), "Touch to start");
		touchLabel.alpha = 0;
		add(touchLabel);

		var credits : FlxSprite = new FlxSprite(FlxG.width / 2 - 42, Std.int(FlxG.height - FlxG.height/6) + 4, "assets/ui/title-credits.png");
		credits.alpha = 0;
		add(credits);

		var startDelay : Float = 0.35;
		tween = FlxTween.tween(logo, {y : 64}, 0.75, {startDelay: startDelay, onComplete: onLogoPositioned, ease : FlxEase.elasticOut });
		FlxTween.tween(credits, {alpha : 1}, 0.75, {startDelay:startDelay, ease : FlxEase.cubeInOut});
	}

	public function onLogoPositioned(_t:FlxTween):Void
	{
		interactable = true;

		BgmEngine.play(BgmEngine.BGM.Title);

		startTouchZone = new FlxObject(0, 120, FlxG.width, 160);
		add(startTouchZone);

		FlxTween.tween(touchLabel, {alpha : 1}, 1, {ease : FlxEase.cubeInOut});
		FlxTween.tween(background, {alpha : 1}, 1.5, {ease : FlxEase.cubeInOut});

		startTouchBuzz(null);
	}

	function startTouchBuzz(_t:FlxTween)
	{
		var touchLabelBaseY = touchLabel.y;
		FlxTween.tween(touchLabel, {y : touchLabelBaseY-4}, 0.2, {ease: FlxEase.circOut, startDelay: 2, onComplete: continueTouchBuzz});
	}

	function continueTouchBuzz(_t:FlxTween)
	{
		var touchLabelBaseY = touchLabel.y;
		FlxTween.tween(touchLabel, {y : touchLabelBaseY+4}, 0.5, {ease: FlxEase.elasticOut, onComplete: startTouchBuzz});
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		if (interactable)
		{
			#if desktop
	        if (FlxG.mouse.pressed)
	        {
				onTouchLabelPressed();
	        }
	        else if (FlxG.mouse.justReleased)
	        {
	            onTouchLabelReleased();
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
	    				onTouchLabelPressed();
	                }
	                else if (touch.justReleased)
	                {
	                    onTouchLabelReleased();
	                    onArcadeButtonPressed();
	                    break ;
	                }
	            }
				else if (touchLabel.color != 0xFFFFFFFF)
				{
					if (touch.justReleased)
	                {
						onTouchLabelReleased();
	                    break ;
	                }
				}
	        }
	        #end
		}

		super.update(elapsed);
	}

	function onTouchLabelPressed()
	{
		// animation.play("pressed");
		if (touchLabel.color != 0xFFFFEC27)
		{
			touchLabel.color = 0xFFFFEC27;
			touchLabel.x += 2;
			touchLabel.y += 2;
		}
	}

	function onTouchLabelReleased()
	{
		// animation.play("idle");
		if (touchLabel.color != 0xFFFFFFFF)
		{
			touchLabel.color = 0xFFFFFFFF;
			touchLabel.x -= 2;
			touchLabel.y -= 2;
		}
	}

	public function onArcadeButtonPressed() : Void
	{
		GameController.StartArcadeGame();
	}
}
