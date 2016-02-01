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
		add(leftButton = new FlxSprite(0, halfHeight).makeGraphic(halfWidth, halfHeight, 0xFFFF5151));
		add(rightButton = new FlxSprite(halfWidth, halfHeight).makeGraphic(halfWidth, halfHeight, 0xFF5151FF));
		add(shootButton = new FlxSprite(0, 0).makeGraphic(_width, halfHeight, 0xFF51FF51));
	}

	override public function update()
	{
		leftButton.alpha = 0.5;
		rightButton.alpha = 0.5;
		shootButton.alpha = 0.5;

		// Check whether any of the touches affects the buttons
		for (touch in FlxG.touches.list)
		{
			if (touch.pressed)
			{
				if (touch.overlaps(leftButton))
				{
					GamePad.setPressed(GamePad.Left);
					leftButton.alpha = 0.8;
				}
				else if (touch.overlaps(rightButton))
				{
					GamePad.setPressed(GamePad.Right);
					rightButton.alpha = 0.8;
				}
				else if (touch.overlaps(shootButton))
				{
					GamePad.setPressed(GamePad.Shoot);
					shootButton.alpha = 0.8;
				}
			}
		}

		super.update();
	}
}
