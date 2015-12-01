package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.group.FlxTypedGroup;

class Bubble extends FlxSprite
{
	public static var StateAiming : Int = 0;
	public static var StateFlying : Int = 1;
	public static var StateIdling : Int = 2;
	public static var StateDebug  : Int = 3;
	
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
		FlxSpriteUtil.drawCircle(this, 10, 10, Size, 0xFFFFFFFF);
		
		color = Color;
		
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
				if (x - Size <= grid.bounds.left || x + Size >= grid.bounds.right)
					velocity.x *= -1;
				
				// Stick to the ceiling
				if (y - HalfSize <= grid.bounds.top)
				{
					onHitCeiling();
				}
				else
				// Stick to the bubble mass
				if (checkCollisionWithBubbles())
				{
					onHitBubbles();
				}
				
			case Bubble.StateIdling:
				
				// Rest
				velocity.set();
				
				// Positioning yourself slowly
				if (Math.abs(x - cellPosition.x) > 1 || Math.abs(y - cellPosition.y) > 1)
				{
					x = FlxMath.lerp(x, cellPosition.x, 0.25);
					y = FlxMath.lerp(y, cellPosition.y, 0.25);
				}
				else
				{
					x = cellPosition.x;
					y = cellPosition.y;
				}
				
			case Bubble.StateDebug:
				
				var mousePos : FlxPoint = FlxG.mouse.getWorldPosition();
				x = mousePos.x;
				y = mousePos.y;
		
				if (checkCollisionWithBubbles())
					alpha = 0.4;
				else
					alpha = 1;
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
		onHitSomething();
	}
	
	public function onHitBubbles()
	{
		onHitSomething();
	}
	
	public function onHitSomething()
	{
		if (state == StateFlying)
		{
			// Rest!
			state = StateIdling;
			
			// Fetch your idling place
			cellPosition = grid.getCenterOfCellAt(x, y);
			
			// And notify
			world.onBubbleStop();
		}
	}
	
	public function checkCollisionWithBubbles() : Bool
	{
		var bubbles : FlxTypedGroup<Bubble> = world.bubbles;
		for (bubble in bubbles)
		{
			if (bubble.touches(this))
				return true;
		}
		
		return false;
	}
	
	public function touches(bubble : Bubble) : Bool
	{
		var deltaXSquared : Float = x - bubble.x;
		deltaXSquared *= deltaXSquared;
		var deltaYSquared : Float = y - bubble.y;
		deltaYSquared *= deltaYSquared;

		// Calculate the sum of the radii, then square it
		var sumRadiiSquared : Float = Size + bubble.Size; 
		sumRadiiSquared *= sumRadiiSquared;

		return (deltaXSquared + deltaYSquared <= sumRadiiSquared);
	}
}