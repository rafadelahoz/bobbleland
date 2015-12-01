package;

import flash.display.BitmapData;

import flixel.FlxG;

class GamePad
{
	static var previousPadState : Map<Int, Bool>;
	static var currentPadState : Map<Int, Bool>;
	
	public static var Buttons : Array<Int>;
	public static var buttonHistory : String;
	
	public static function setupVirtualPad() : Void
	{	
		initPadState();
		
		trace(Buttons);
	}
	
	public static function handlePadState() : Void
	{
		// Store the history
		for (button in Buttons)
		{
			if (justPressed(button))
				buttonHistory += buttonCode(button);
		}
		
		// Maintaining its length to max 50
		if (buttonHistory.length >= 100)
			buttonHistory = buttonHistory.substring(50);
			
		GameDebug.CheatParser();
	
		/*previousPadState = currentPadState;
		
		currentPadState = new Map<Int, Bool>();
		
		var metapad : MetaGamePad = MetaGamePad.Current;*/
		
		/*currentPadState.set(Left, FlxG.keys.anyPressed(["LEFT"]));
		currentPadState.set(Right, FlxG.keys.anyPressed(["RIGHT"]));
		currentPadState.set(Up, FlxG.keys.anyPressed(["UP"]));
		currentPadState.set(Down, FlxG.keys.anyPressed(["DOWN"]));
			
		currentPadState.set(A, FlxG.keys.anyPressed(["A", "Z"]));
		currentPadState.set(B, FlxG.keys.anyPressed(["S", "X"]));
		
		currentPadState.set(Start, FlxG.keys.anyPressed(["ENTER"]));
		currentPadState.set(Select, FlxG.keys.anyPressed(["SPACE"]));*/
	}
	
	public static function checkButton(button : Int) : Bool
	{
		return MetaGamePad.Current.checkButton(button);
	}

	public static function justPressed(button : Int) : Bool
	{
		return MetaGamePad.Current.justPressed(button);
	}

	public static function justReleased(button : Int) : Bool
	{
		return MetaGamePad.Current.justReleased(button);
	}
	
	public static function resetInputs() : Void
	{
		if (MetaGamePad.Current != null)
			MetaGamePad.Current.resetInputs();
		initPadState();
	}
	
	private static function initPadState() : Void
	{
		Buttons = [Left, Right, Up, Down, A, B, Start, Select];
	
		buttonHistory = "";
	
		currentPadState = new Map<Int, Bool>();
		currentPadState.set(Left, false);
		currentPadState.set(Right, false);
		currentPadState.set(Up, false);
		currentPadState.set(Down, false);
		currentPadState.set(A, false);
		currentPadState.set(B, false);
		currentPadState.set(Start, false);
		currentPadState.set(Select, false);

		previousPadState = new Map<Int, Bool>();
		previousPadState.set(Left, false);
		previousPadState.set(Right, false);
		previousPadState.set(Up, false);
		previousPadState.set(Down, false);
		previousPadState.set(A, false);
		previousPadState.set(B, false);
		previousPadState.set(Start, false);
		previousPadState.set(Select, false);
	}
	
	public static function findInHistory(code : String) : Bool
	{
		var found : Bool =  buttonHistory.lastIndexOf(code) > -1;
		if (found)
		{
			buttonHistory = "";
		}
		
		return found;
	}
	
	public static function buttonCode(button : Int) : String
	{
		var code : String = "";
		
		switch (button)
		{
			case GamePad.Left:
				code = "L";
			case GamePad.Right:
				code = "R";
			case GamePad.Up:
				code = "U";
			case GamePad.Down:
				code = "D";
			case GamePad.A:
				code = "A";
			case GamePad.B:
				code = "B";
			case GamePad.Start:
				code = "S";
			case GamePad.Select:
				code = "T";
			default:
				code = "WHAT?";
		}
		return code;
	}

	public static var Left 	: Int = 0;
	public static var Right : Int = 1;
	public static var Up	: Int = 2;
	public static var Down	: Int = 3;
	public static var A 	: Int = 4;
	public static var B 	: Int = 5;
	public static var Start : Int = 6;
	public static var Select : Int = 7;
}