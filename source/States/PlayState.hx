package;

import flixel.FlxG;
import flixel.FlxState;

class PlayState extends FlxState
{
	public static var StateAiming : Int = 0;
	public static var StateWaiting : Int = 1;

	public var state : Int;
	
	public var grid : BubbleGrid;
	public var cursor : PlayerCursor;

	public function new()
	{
		super();
	}

	override public function create()
	{
		super.create();
		
		grid = new BubbleGrid(0, 0, FlxG.width, FlxG.height - 32);
		add(grid);
		
		cursor = new PlayerCursor(FlxG.width / 2 - 16, FlxG.height - 32);
		add(cursor);
		
		state = StateAiming;
	}
	
	override public function update()
	{
		switch (state)
		{
			case PlayState.StateAiming:
				onAimingState();
			case PlayState.StateWaiting:
				onWaitingState();
		}
		
		super.update();
	}
	
	public function onAimingState()
	{
		// haha
	}
	
	public function onWaitingState()
	{
	}
}