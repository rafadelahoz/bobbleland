package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;

import text.PixelText;

import database.BackgroundDatabase;

class MenuState extends BubbleState
{
	public var tween : FlxTween;

	var touchLabel : FlxBitmapText;
	var yearsLabel : FlxBitmapText;
	var creditsLabel : FlxBitmapText;
	var background : FlxBackdrop;
	var backgroundShader : FlxSprite;

	var startTouchZone : FlxObject;

	var optionsPanel : OptionsPanel;

	var interactable : Bool;

	override public function create():Void
	{
		super.create();

		// Missing a preloader
		BgmEngine.init();
		SfxEngine.init();

		GameController.Init();

		// Set scale mode?

		interactable = false;

		bgColor = 0xFF000000;

        background = BackgroundDatabase.BuildRandomBackground();
		background.scrollFactor.set(0.35, 0.35);
        background.velocity.set(0, 10);
		background.alpha = 1;
        add(background);

		backgroundShader = new FlxSprite(0, 0);
		backgroundShader.makeGraphic(Constants.Width, Constants.Height, 0xFF000000);
		backgroundShader.alpha = 1;
		add(backgroundShader);

		var borderTop : FlxSprite = new FlxSprite(0, -8, "assets/ui/border-top.png");
		add(borderTop);

		optionsPanel = new OptionsPanel();
		add(optionsPanel);

		var borderBottom : FlxSprite = new FlxSprite(0, Constants.Height - 24, "assets/ui/border-top.png");
		borderBottom.scale.y = -1;
		add(borderBottom);

		var logo : FlxSprite = new FlxSprite(0, -164, "assets/ui/title.png");
		add(logo);

		var startText : String = "Touch to start";
		if (SaveStateManager.savestateExists())
			startText = "Touch to continue";
		// touchLabel = PixelText.New(Constants.Width / 2 - 56, Std.int(Constants.Height - Constants.Height/4), "Touch to start");
		touchLabel = PixelText.New(Constants.Width / 2 - (startText.length/2)*8, Std.int(Constants.Height - Constants.Height/4), startText);
		touchLabel.alpha = 0;
		add(touchLabel);

		var credits : FlxSprite = new FlxSprite(Constants.Width / 2 - 42, Std.int(Constants.Height - Constants.Height/6) + 4, "assets/ui/title-credits.png");
		credits.alpha = 0;
		add(credits);

		var startDelay : Float = 0.35;
		tween = FlxTween.tween(logo, {y : 64}, 0.75, {startDelay: startDelay, onComplete: onLogoPositioned, ease : FlxEase.elasticOut });
		FlxTween.tween(credits, {alpha : 1}, 0.75, {startDelay:startDelay, ease : FlxEase.cubeInOut});

		FlxG.camera.scroll.set(0, 0);
	}

	public function onLogoPositioned(_t:FlxTween):Void
	{
		interactable = true;

		BgmEngine.play(BgmEngine.BGM.Title);

		startTouchZone = new FlxObject(0, 160, Constants.Width, 120);
		add(startTouchZone);

		FlxTween.tween(touchLabel, {alpha : 1}, 1, {ease : FlxEase.cubeInOut});
		FlxTween.tween(backgroundShader, {alpha : 0.22}, 1.5, {ease : FlxEase.cubeInOut});
		FlxTween.tween(optionsPanel.optionsTab, {alpha: 1}, 1, {ease : FlxEase.cubeInOut});

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
		if (FlxG.keys.justPressed.O)
			Screenshot.take();

		if (interactable)
		{
			#if (!mobile)
			if (startTouchZone.getHitbox().containsPoint(FlxG.mouse.getPosition()))
			{
		        if (FlxG.mouse.pressed)
		        {
					onTouchLabelPressed();
		        }
		        else if (FlxG.mouse.justReleased)
		        {
		            onTouchLabelReleased();
					onArcadeButtonPressed();
		        }
			}
	        #else
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
			// Testing screenshots on mobile
			// Screenshot.take();
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
