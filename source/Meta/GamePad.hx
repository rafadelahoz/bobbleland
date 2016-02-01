package;

import flash.display.BitmapData;

import flixel.FlxG;

class GamePad
{
	static var previousPadState : Map<Int, Bool>;
	static var currentPadState : Map<Int, Bool>;
	static var bufferPadState : Map<Int, Bool>;

	public static function init() : Void
	{	
		initPadState();
	}
	
	public static function handlePadState() : Void
	{
		previousPadState = currentPadState;

		currentPadState = bufferPadState;
		currentPadState.set(Left, currentPadState.get(Left) || FlxG.keys.pressed.LEFT);
		currentPadState.set(Right, currentPadState.get(Right) || FlxG.keys.pressed.RIGHT);
		currentPadState.set(Shoot, currentPadState.get(Shoot) || FlxG.keys.pressed.A);

		bufferPadState = new Map<Int, Bool>();
		bufferPadState.set(Left, false);
		bufferPadState.set(Right, false);
		bufferPadState.set(Shoot, false);
	}
	
	public static function setPressed(button : Int)
	{
		bufferPadState.set(button, true);
	}

	public static function checkButton(button : Int) : Bool
	{
		return currentPadState.get(button);
	}

	public static function justPressed(button : Int) : Bool
	{
		return currentPadState.get(button) && !previousPadState.get(button);
	}

	public static function justReleased(button : Int) : Bool
	{
		return !currentPadState.get(button) && previousPadState.get(button);
	}
	
	public static function resetInputs() : Void
	{
		initPadState();
	}
	
	private static function initPadState() : Void
	{
		bufferPadState = new Map<Int, Bool>();
		bufferPadState.set(Left, false);
		bufferPadState.set(Right, false);
		bufferPadState.set(Shoot, false);

		currentPadState = new Map<Int, Bool>();
		currentPadState.set(Left, false);
		currentPadState.set(Right, false);
		currentPadState.set(Shoot, false);

		previousPadState = new Map<Int, Bool>();
		previousPadState.set(Left, false);
		previousPadState.set(Right, false);
		previousPadState.set(Shoot, false);
	}

	public static var Left 	: Int = 0;
	public static var Right : Int = 1;
	public static var Shoot	: Int = 2;
}