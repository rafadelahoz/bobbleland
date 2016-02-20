package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class ScreenButtons extends FlxSpriteGroup
{
	var state : PlayState;

	var leftButton : FlxSprite;
	var rightButton : FlxSprite;
	var shootButton : FlxSprite;
	var pauseButton : FlxSprite;

	var _width : Int;
	var _height : Int;

	public function new(X : Float, Y : Float, State : PlayState, BottomHeight : Float)
	{
		super(X, Y);

		state = State;

		_width = Std.int(FlxG.width);
		_height = Std.int(FlxG.height - BottomHeight);
		var halfWidth = Std.int(_width / 2);
		var halfHeight = Std.int(_height / 2);

		// Add the buttons
		add(pauseButton = new FlxSprite(halfWidth, 0).loadGraphic("assets/images/btnPause.png", true, 20, 16));
		add(leftButton = new FlxSprite(0, BottomHeight + halfHeight).loadGraphic("assets/images/btnLeft.png", true, 90, 40));
		add(rightButton = new FlxSprite(halfWidth, BottomHeight + halfHeight).loadGraphic("assets/images/btnRight.png", true, 90, 40));
		add(shootButton = new FlxSprite(0, BottomHeight).loadGraphic("assets/images/btnShoot.png", true, 180, 40));

		for (button in [leftButton, rightButton, shootButton, pauseButton])
		{
			button.animation.add("idle", [0]);
			button.animation.add("pressed", [1]);
			button.animation.play("idle");
		}

		pauseButton.setSize(halfWidth, halfHeight);
		pauseButton.offset.set(-(halfWidth-20), 0);
	}

	override public function update(elapsed:Float)
	{
		for (button in [leftButton, rightButton, shootButton, pauseButton])
		{
			button.animation.play("idle");
		}

		// Check whether any of the touches affects the buttons
		for (touch in FlxG.touches.list)
		{
			if (touch.pressed)
			{
				if (touch.overlaps(leftButton))
				{
					GamePad.setPressed(GamePad.Left);
					leftButton.animation.play("pressed");
				}
				else if (touch.overlaps(rightButton))
				{
					GamePad.setPressed(GamePad.Right);
					rightButton.animation.play("pressed");
				}
				else if (touch.overlaps(shootButton))
				{
					GamePad.setPressed(GamePad.Shoot);
					shootButton.animation.play("pressed");
				}
				else if (touch.overlaps(pauseButton))
				{
					GamePad.setPressed(GamePad.Pause);
					pauseButton.animation.play("pressed");
				}
			}
		}

		super.update(elapsed);
	}
}
