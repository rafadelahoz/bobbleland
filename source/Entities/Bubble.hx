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
	
	public var Speed : Float = 400;
	public var Size : Float = 9;
	public var HalfSize : Float = 4.5;
	
	public var world : PlayState;
	public var grid : BubbleGrid;
	
	public var state : Int;
	
	public var lastPosition : FlxPoint;
	public var cellPosition : FlxPoint;
	public var cellCenterPosition : FlxPoint;
	
	public function new(X : Float, Y : Float, World : PlayState, Color : Int)
	{
		super(X, Y);
		
		makeGraphic(20, 20, 0x00000000);
		FlxSpriteUtil.drawCircle(this, 10, 10, Size, 0xFFFFFFFF);
		offset.set(0, 0);
		
		color = Color;
		
		world = World;
		grid = world.grid;
		
		cellPosition = new FlxPoint();
		lastPosition = new FlxPoint();
		
		state = StateAiming;
	}
	
	override public function update()
	{
		switch (state)
		{
			case Bubble.StateAiming:
				
				// Do nothing
				velocity.set();
				
				cellPosition.set(-1, -1);
				lastPosition.set(-1, -1);
				
			case Bubble.StateFlying:
				
				// Bounce off walls
				if (x - Size * 1.5 <= grid.bounds.left || x + Size * 1.5 >= grid.bounds.right)
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
				
				// Remember your way
				var currentPosition : FlxPoint = grid.getCellAt(x, y);
				if (!compare(currentPosition, cellPosition))
				{
					lastPosition.set(cellPosition.x, cellPosition.y);
					cellPosition.set(currentPosition.x, currentPosition.y);
				}
				
			case Bubble.StateIdling:
				
				// Rest
				velocity.set();
				
				// Positioning yourself slowly
				if (Math.abs(x - cellCenterPosition.x) > 1 || Math.abs(y - cellCenterPosition.y) > 1)
				{
					x = FlxMath.lerp(x, cellCenterPosition.x, 0.25);
					y = FlxMath.lerp(y, cellCenterPosition.y, 0.25);
				}
				else
				{
					x = cellCenterPosition.x;
					y = cellCenterPosition.y;
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
		onHitSomething(true);
	}
	
	public function onHitBubbles()
	{
		onHitSomething(false);
	}
	
	public function onHitSomething(useNewPosition : Bool)
	{
		if (state == StateFlying)
		{
			// Rest!
			state = StateIdling;
			
			// Discriminate between ceiling and bubble hit
			if (useNewPosition)
			{
				// Fetch your idling place
				var currentPosition : FlxPoint = grid.getCellAt(x, y);
				cellPosition.set(currentPosition.x, currentPosition.y);
				cellCenterPosition = grid.getCenterOfCellAt(x, y);
			}
			else
			{
				// Consider the last valid position visited
				cellCenterPosition = grid.getCellCenter(Std.int(cellPosition.x), Std.int(cellPosition.y));
			}
			
			// If it's already occupied, go to the last one free you got
			if (grid.getData(cellPosition.x, cellPosition.y) != 0)
			{
				trace(cellPosition + " is already occupied, returning to " + lastPosition);
				cellCenterPosition = grid.getCellCenter(Std.int(lastPosition.x), Std.int(lastPosition.y));
			}
			
			// Store your data
			grid.setData(cellPosition.x, cellPosition.y, color);
			
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
	
	public static function compare(A : FlxPoint, B : FlxPoint) : Bool
	{
		return A.x == B.x && A.y == B.y;
	}
	
	public function touches(bubble : Bubble) : Bool
	{
		var deltaXSquared : Float = x - bubble.x;
		deltaXSquared *= deltaXSquared;
		var deltaYSquared : Float = y - bubble.y;
		deltaYSquared *= deltaYSquared;

		// Calculate the sum of the radii, then square it
		var sumRadiiSquared : Float = Size * 0.9 + bubble.Size * 0.9;
		sumRadiiSquared *= sumRadiiSquared;

		return (deltaXSquared + deltaYSquared <= sumRadiiSquared);
	}
}