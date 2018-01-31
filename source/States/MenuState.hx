package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.addons.ui.FlxButtonPlus;

import text.PixelText;
import text.TextUtils;

class MenuState extends FlxState
{
	public var btnArcade : FlxButtonPlus;
	public var btnPuzzle : FlxButtonPlus;
	public var btnOptions : FlxButtonPlus;

	public var titleLabel : FlxBitmapText;

	override public function create():Void
	{
		super.create();

		GameController.Init();

		titleLabel = PixelText.New(FlxG.width / 2 - 40, 64, "SOAP ALLEY");
		titleLabel.scale.x = 1.75;
		titleLabel.scale.y = 3;
		add(titleLabel);

		var touchLabel = PixelText.New(FlxG.width / 2 - 56, Std.int(FlxG.height - FlxG.height/4), "Touch to start");
		add(touchLabel);

		var creditsLabel = PixelText.New(FlxG.width / 2 - 48, Std.int(FlxG.height - FlxG.height/5), "2015 - 2018\nThe BADLADNS");
		creditsLabel.scale.x = 1;
		creditsLabel.scale.y = 1;
		add(creditsLabel);
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
            /*if (touch.overlaps(this))
            {*/
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
            /*}*/
        }
        #end
	}

	public function onArcadeButtonPressed() : Void
	{
		GameController.StartArcadeGame();
	}

	public function onPuzzleButtonPressed() : Void
	{
		GameController.StartAdventureGame();
	}

	public function onOptionsButtonPressed() : Void
	{
		GameController.ToOptions();
	}

	function decorateButton(button : FlxButtonPlus)
	{
		button.updateActiveButtonColors([0xFF202020, 0xFF202020]);
		button.updateInactiveButtonColors([0xFF000000, 0xFF000000]);
	}
}
