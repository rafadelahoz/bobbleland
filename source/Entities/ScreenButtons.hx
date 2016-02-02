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

	var _width : Int;
	var _height : Int;

	public function new(X : Float, Y : Float, State : PlayState)
	{
		super(X, Y);

		state = State;

		_width = Std.int(FlxG.width);
		_height = Std.int(FlxG.height - y);
		var halfWidth = Std.int(_width / 2);
		var halfHeight = Std.int(_height / 2);

		// Add the buttons
		add(leftButton = new FlxSprite(0, halfHeight).loadGraphic("assets/images/btnLeft.png", true, 90, 40));
		add(rightButton = new FlxSprite(halfWidth, halfHeight).loadGraphic("assets/images/btnRight.png", true, 90, 40));
		add(shootButton = new FlxSprite(0, 0).loadGraphic("assets/images/btnShoot.png", true, 180, 40));

		for (button in [leftButton, rightButton, shootButton])
		{
			button.animation.add("idle", [0]);
			button.animation.add("pressed", [1]);
			button.animation.play("idle");
		}
	}

	override public function update()
	{
		for (button in [leftButton, rightButton, shootButton])
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
			}
		}

		super.update();
	}
}
