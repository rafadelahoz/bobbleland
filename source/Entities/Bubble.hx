package;

import flixel.FlxSprite;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;

class Bubble extends FlxSprite
{
	public static var StateAiming : Int = 0;
	public static var StateFlying : Int = 1;
	public static var StateIdling : Int = 2;
	
	public var Speed : Float = 200;
	public var Size : Float = 9;
	public var HalfSize : Float = 4.5;
	
	public var world : PlayState;
	public var grid : BubbleGrid;
	
	public var state : Int;
	
	public var cellPosition : FlxPoint;
	
	public function new(X : Float, Y : Float, World : PlayState, Color : Int)
	{
		super(X, Y);
		
		makeGraphic(20, 20, 0x00000000);
		FlxSpriteUtil.drawCircle(this, 10, 10, Size, Color);
		
		world = World;
		grid = world.grid;
		
		state = StateAiming;
	}
	
	override public function update()
	{
		switch (state)
		{
			case Bubble.StateAiming:
				
				// Do nothing
				velocity.set();
				
			case Bubble.StateFlying:
				
				// Highlight your way
				grid.getCellAt(x, y);
				
				// Bounce off walls
				if (x - HalfSize <= grid.bounds.left || x + HalfSize >= grid.bounds.right)
					velocity.x *= -1;
					
				if (y - HalfSize <= grid.bounds.top)
				{
					onHitCeiling();
				}
				
			case Bubble.StateIdling:
				
				// Rest
				velocity.set();
				
				// Positioning yourself slowly
				if (Math.abs(x - cellPosition.x) > 1 || Math.abs(y - cellPosition.y) > 1)
				{
					x = FlxMath.lerp(x, cellPosition.x, 0.5);
					y = FlxMath.lerp(y, cellPosition.y, 0.5);
				}
				else
				{
					x = cellPosition.x;
					y = cellPosition.y;
				}
				
		}
	
		super.update();
	}
	
	public function shoot(direction : Float)
	{
		state = Bubble.StateFlying;
		
		var cos : Float = Math.cos(direction * (Math.PI/180));
		var sin : Float = Math.sin(direction * (Math.PI/180));

		var velocityX : Float = cos * Speed;
		var velocityY : Float = -sin * Speed;
		
		velocity.set(velocityX, velocityY);
	}
	
	public function onHitCeiling()
	{
		// Rest!
		state = StateIdling;
		
		// Fetch your idling place
		cellPosition = grid.getCenterOfCellAt(x, y);
		
		// And notify
		world.onBubbleStop();
	}
}