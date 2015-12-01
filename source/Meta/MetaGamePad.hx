package;

import openfl.display.Sprite;
import openfl.Lib;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.ui.Multitouch;

import flixel.FlxG;

class MetaGamePad extends Sprite
{
	var currentPadState : Map<Int, Bool>;
	var previousPadState : Map<Int, Bool>;
	
	var buttons : Array<GamePadButton>;
	public var touchPoints : Map<Int, Point>;
	
	private static var _current : MetaGamePad;
	public static var Current(get, null) : MetaGamePad;
	public static function get_Current() : MetaGamePad {
		return _current;
	}
	
	public function new()
	{
		super();
		
		_current = this;
		
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		
		var leftPanelWidth : Int = Std.int(stageWidth / 4);
		var rightPanelWidth : Int = leftPanelWidth;
		var rightPanelX : Int = 3*leftPanelWidth;
		
		var buttonWidth : Int = Std.int(leftPanelWidth/2);
		var buttonHeight : Int = Std.int(stageHeight / 3);
		var halfHeight : Int = Std.int(buttonHeight / 2);
		
		var upBtn    : GamePadButton = new GamePadButton(Up, 	0, stageHeight - halfHeight*3, leftPanelWidth, halfHeight); 
		var downBtn  : GamePadButton = new GamePadButton(Down,  0, buttonHeight*3 - buttonHeight / 2, leftPanelWidth, halfHeight);
		var leftBtn  : GamePadButton = new GamePadButton(Left,  0, downBtn.y - downBtn.height, buttonWidth, halfHeight);
		var rightBtn : GamePadButton = new GamePadButton(Right, buttonWidth, downBtn.y - downBtn.height, buttonWidth, halfHeight);
		
		var aBtn : GamePadButton = new GamePadButton(A, rightPanelX + buttonWidth, buttonHeight, buttonWidth, buttonHeight*2);
		var bBtn : GamePadButton = new GamePadButton(B, rightPanelX, buttonHeight, buttonWidth, buttonHeight*2);
		
		var startBtn : GamePadButton = new GamePadButton(Start, rightPanelX + buttonWidth, 0, buttonWidth, halfHeight);
		var selectBtn : GamePadButton = new GamePadButton(Select, rightPanelX, 0, buttonWidth, halfHeight);
		
		buttons = [upBtn, downBtn, leftBtn, rightBtn, aBtn, bBtn, startBtn, selectBtn];
		
		for (button in buttons)
		{
			addChild(button);
		}
		
		initPadState();
		
		touchPoints = new Map<Int, Point>();
	}
	
	public function checkButton(button : Int) : Bool
	{
		return currentPadState.get(button);
	}

	public function justPressed(button : Int) : Bool
	{
		return currentPadState.get(button) && !previousPadState.get(button);
	}

	public function justReleased(button : Int) : Bool
	{
		return !currentPadState.get(button) && previousPadState.get(button);
	}
	
	public function resetInputs() : Void
	{
		initPadState();
	}
	
	public function handlePadState() : Void
	{
		previousPadState = currentPadState;
		
		currentPadState = new Map<Int, Bool>();
		
		for (button in buttons)
		{
			button.pressed = false;
			currentPadState.set(button.id, button.isPressed(touchPoints));
		}
		
		currentPadState.set(Left, 	currentPadState.get(Left) 	|| FlxG.keys.anyPressed(["LEFT"]));
		currentPadState.set(Right, 	currentPadState.get(Right) 	|| FlxG.keys.anyPressed(["RIGHT"]));
		currentPadState.set(Up, 	currentPadState.get(Up) 	|| FlxG.keys.anyPressed(["UP"]));
		currentPadState.set(Down, 	currentPadState.get(Down) 	|| FlxG.keys.anyPressed(["DOWN"]));
			
		currentPadState.set(A,  	currentPadState.get(A) 		|| FlxG.keys.anyPressed(["A", "Z"]));
		currentPadState.set(B,  	currentPadState.get(B) 		|| FlxG.keys.anyPressed(["S", "X"]));
		
		currentPadState.set(Start,  currentPadState.get(Start) 	|| FlxG.keys.anyPressed(["ENTER"]));
		currentPadState.set(Select, currentPadState.get(Select) || FlxG.keys.anyPressed(["SPACE"]));
	}
	
	private function initPadState() : Void
	{
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

	public static var Left 	: Int = 0;
	public static var Right : Int = 1;
	public static var Up	: Int = 2;
	public static var Down	: Int = 3;
	public static var A 	: Int = 4;
	public static var B 	: Int = 5;
	public static var Start : Int = 6;
	public static var Select : Int = 7;
}