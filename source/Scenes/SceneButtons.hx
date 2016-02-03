package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class SceneButtons extends FlxSpriteGroup
{
	var advanceButton : FlxSprite;

	var _width : Int;
	var _height : Int;

	public function new(X : Float, Y : Float)
	{
		super(X, Y);

		_width = Std.int(FlxG.width);
		_height = Std.int(FlxG.height);
		
		// Add the buttons
		add(advanceButton = new FlxSprite(0, 0).makeGraphic(_width, _height, 0xFFFFFFFF));
	}

	override public function update()
	{
		for (button in [advanceButton])
		{
			button.alpha = 0.0;
		}

		// Check whether any of the touches affects the buttons
		for (touch in FlxG.touches.list)
		{
			if (touch.pressed)
			{
				if (touch.overlaps(advanceButton))
				{
					GamePad.setPressed(GamePad.Shoot);
					advanceButton.alpha = 0.05;
				}
			}
		}

		super.update();
	}
}
