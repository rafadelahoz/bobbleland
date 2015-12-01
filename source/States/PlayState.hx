package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.group.FlxTypedGroup;

class PlayState extends FlxState
{
	public static var StateAiming : Int = 0;
	public static var StateWaiting : Int = 1;

	public var state : Int;

	public var bubbleColors : Array<Int>;
	public var bubbles : FlxTypedGroup<Bubble>;
	
	public var grid : BubbleGrid;
	public var cursor : PlayerCursor;
	public var bubble : Bubble;

	public function new()
	{
		super();
	}

	override public function create()
	{
		super.create();
		
		grid = new BubbleGrid(0, 0, FlxG.width, FlxG.height - 32);
		add(grid);
		
		bubbles = new FlxTypedGroup<Bubble>();
		add(bubbles);
		
		cursor = new PlayerCursor(FlxG.width / 2 - 16, FlxG.height - 32);
		add(cursor);
		
		/*var debugBubble : Bubble = new Bubble(0, 0, this, 0xFFFFFFFF);
		debugBubble.state = Bubble.StateDebug;
		add(debugBubble);*/
		
		bubbleColors = [0xFFFF5151, 0xFF51FF51, 0xFF5151FF, 0xFFFFFF51];
		
		generateBubble();
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
		
		handleDebugRoutines();
		
		super.update();
	}
	
	public function onAimingState()
	{
		if (FlxG.keys.justPressed.A)
		{
			// Play anim or whatever
			cursor.onShoot();
			
			var aimAngle : Float = cursor.aimAngle;
			
			bubble.x = cursor.x + cursor.aimOrigin.x - (bubble.width / 2);
			bubble.y = cursor.y + cursor.aimOrigin.y - (bubble.height / 2);
			
			bubble.shoot(aimAngle);
			
			state = StateWaiting;
		}
	}
	
	public function onWaitingState()
	{
	}
	
	public function onBubbleStop()
	{
		// Store bubble
		bubbles.add(bubble);
		
		// Check for group of three
		var condemned : Array<Bubble> = grid.locateBubbleGroup(bubble);

		if (condemned.length >= 3)
		{
			for (bub in condemned)
			{
				bubbles.remove(bub);
				bub.kill();
			}
		}
		
		// And generate a new one
		generateBubble();
		state = StateAiming;
	}
	
	public function generateBubble()
	{
		remove(bubble);
		bubble = null;
		
		var nextColor : Int = FlxRandom.getObject(bubbleColors);
		
		bubble = new Bubble(cursor.x + cursor.aimOrigin.x - 8, 
							cursor.y + cursor.aimOrigin.y - 8, this, nextColor);
		add(bubble);
	}
	
	public function handleDebugRoutines()
	{
		var mouse : FlxPoint = FlxG.mouse.getWorldPosition();
		if (FlxG.keys.justPressed.ONE)
		{
			var cell = grid.getCellAt(mouse.x, mouse.y);
			
			var b : Bubble = new Bubble(mouse.x, mouse.y, this, 0xFF5151FF);
			b.state = Bubble.StateFlying;
			b.cellPosition.set(cell.x, cell.y);
			b.onHitSomething(false);
		}
	}
}