package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;

class PlayState extends FlxState
{
	public static var StateAiming : Int = 0;
	public static var StateWaiting : Int = 1;

	public var state : Int;

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
		
		bubbles = new FlxTypedGroup<Bubble>();
		add(bubbles);
		
		grid = new BubbleGrid(0, 0, FlxG.width, FlxG.height - 32);
		add(grid);
		
		cursor = new PlayerCursor(FlxG.width / 2 - 16, FlxG.height - 32);
		add(cursor);
		
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
		/*if (!bubble.inWorldBounds())
		{
			bubble.destroy();
			generateBubble();
			state = StateAiming;
		}*/
	}
	
	public function onBubbleStop()
	{
		// Store bubble
		bubbles.add(bubble);
		// And generate a new one
		generateBubble();
		state = StateAiming;
	}
	
	public function generateBubble()
	{
		bubble = new Bubble(cursor.x + cursor.aimOrigin.x - 8, 
							cursor.y + cursor.aimOrigin.y - 8, this, 0xFF5151FF);
		add(bubble);
	}
}