package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/*#if android
import Hardware;
#end*/

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
		add(pauseButton = new FlxSprite(0, 0).loadGraphic("assets/images/btnPause.png", true, 20, 16));
		add(leftButton = new FlxSprite(0, BottomHeight + halfHeight).loadGraphic("assets/images/btnLeft.png", true, 90, 40));
		add(rightButton = new FlxSprite(halfWidth, BottomHeight + halfHeight).loadGraphic("assets/images/btnRight.png", true, 90, 40));
		add(shootButton = new FlxSprite(0, BottomHeight).loadGraphic("assets/images/btnShoot.png", true, 180, 40));

		for (button in [leftButton, rightButton, shootButton, pauseButton])
		{
			button.animation.add("idle", [0]);
			button.animation.add("pressed", [1]);
			button.animation.play("idle");
		}

		pauseButton.setSize(_width, FlxG.height/2);
		pauseButton.offset.set(-(width-20), 0);
	}

	override public function update(elapsed:Float)
	{
		if (state.state != PlayState.StateLosing)
		{
			handleTouchInput();
			handleMouseInput();

			// Handle button graphics
			// Reset them all to idle
			for (button in [leftButton, rightButton, shootButton, pauseButton])
			{
				button.animation.play("idle");
			}

			// Press the pressed ones
			if (GamePad.checkButton(GamePad.Left))
				leftButton.animation.play("pressed");
			if (GamePad.checkButton(GamePad.Right))
				rightButton.animation.play("pressed");
			if (GamePad.checkButton(GamePad.Shoot))
				shootButton.animation.play("pressed");
			if (GamePad.checkButton(GamePad.Pause))
				pauseButton.animation.play("pressed");
		} else {
			// Handle button graphics
			// Reset them all to idle
			for (button in [leftButton, rightButton, shootButton, pauseButton])
			{
				button.animation.play("idle");
			}
		}

		super.update(elapsed);
	}

	function handleTouchInput()
	{
		#if mobile
		// Check whether any of the touches affects the buttons
		for (touch in FlxG.touches.list)
		{
			if (touch.pressed)
			{
				if (touch.overlaps(leftButton))
				{
					GamePad.setPressed(GamePad.Left);
				}
				else if (touch.overlaps(rightButton))
				{
					GamePad.setPressed(GamePad.Right);
				}
				else if (touch.overlaps(shootButton))
				{
					#if android
					// TODO: Vibration disabled, really not working
					/*if (!GamePad.checkButton(GamePad.Shoot)) {
						Hardware.vibrate(100);
					}*/
					#end

					GamePad.setPressed(GamePad.Shoot);
				}
				else if (touch.overlaps(pauseButton))
				{
					GamePad.setPressed(GamePad.Pause);
				}
			}
		}
		#end
	}

	function handleMouseInput()
	{
		#if (!mobile)
		if (FlxG.mouse.pressed)
		{
			if (mouseOver(leftButton))
			{
				GamePad.setPressed(GamePad.Left);
			}
			else if (mouseOver(rightButton))
			{
				GamePad.setPressed(GamePad.Right);
			}
			else if (mouseOver(shootButton))
			{
				GamePad.setPressed(GamePad.Shoot);
			}
			else if (mouseOver(pauseButton))
			{
				// GamePad.setPressed(GamePad.Pause);
			}
        }
        #end
	}

	function mouseOver(element : FlxObject)
    {
        var mouseX : Float = FlxG.mouse.x;
        var mouseY : Float = FlxG.mouse.y;

        if (scrollFactor.x == 0)
            mouseX = FlxG.mouse.screenX;

        if (scrollFactor.y == 0)
            mouseY = FlxG.mouse.screenY;

        return mouseX >= element.x && mouseX < (element.x + element.width) &&
               mouseY >= element.y && mouseY < (element.y + element.height);
    }
}
