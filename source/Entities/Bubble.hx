package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;
import flixel.util.FlxSpriteUtil;
import flixel.group.FlxTypedGroup;
import flixel.tweens.FlxTween;

class Bubble extends FlxSprite
{
	public static var StateAiming : Int = 0;
	public static var StateFlying : Int = 1;
	public static var StateIdling : Int = 2;
	public static var StatePopping : Int = 3;
	public static var StateDebug  : Int = 4;
	
	public var Speed : Float = 400;
	public var Size : Float = 9;
	public var HalfSize : Float = 4.5;
	
	public var world : PlayState;
	public var grid : BubbleGrid;
	
	public var colorIndex : Int;

	public var state : Int;
	public var falling : Bool;
	
	public var lastPosition : FlxPoint;
	public var cellPosition : FlxPoint;
	public var cellCenterPosition : FlxPoint;
	
	public function new(X : Float, Y : Float, World : PlayState, ColorIndex : Int)
	{
		super(X, Y);
		
		makeGraphic(20, 20, 0x00000000);
		FlxSpriteUtil.drawCircle(this, 10, 10, Size, 0xFFFFFFFF);
		offset.set(0, 0);
		
		world = World;
		grid = world.grid;

		colorIndex = ColorIndex;
		color = world.bubbleColors[colorIndex];
		
		cellPosition = new FlxPoint();
		lastPosition = new FlxPoint();
		cellCenterPosition = new FlxPoint();
		
		state = StateAiming;
		
		falling = false;
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
				if (x + width/2 - Size * 1 <= grid.bounds.left || x + width/2 + Size * 1 >= grid.bounds.right)
					velocity.x *= -1;
				
				// Stick to the ceiling
				if (y - HalfSize <= grid.bounds.top)
				{
					onHitCeiling();
				}
				// Stick to the bubble mass
				else if (checkCollisionWithBubbles())
				{
					onHitBubbles();
				}
				else
				{
					// Remember your way
					var currentPosition : FlxPoint = getCurrentCell();
					if (!compare(currentPosition, cellPosition))
					{
						lastPosition.set(cellPosition.x, cellPosition.y);
						cellPosition.set(currentPosition.x, currentPosition.y);
					}
				}
				
			case Bubble.StateIdling, Bubble.StatePopping:
				
				if (!falling)
				{
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
				}
				else
				{
					acceleration.y = 400;
					
					if (y > FlxG.height)
					{
						onDeath();
					}
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
	
		if (alive)
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
	
	public function onHitSomething(useNewPosition : Bool, debug : Bool = false)
	{
		if (debug || state == StateFlying)
		{
			// Rest!
			state = StateIdling;
			
			// Discriminate between ceiling and bubble hit
			if (useNewPosition)
			{
				// Fetch your idling place
				var currentPosition : FlxPoint = getCurrentCell();
				cellPosition.set(currentPosition.x, currentPosition.y);
				cellCenterPosition = grid.getCellCenter(Std.int(cellPosition.x), Std.int(cellPosition.y));
			}
			else
			{
				// Consider the last valid position visited
				cellCenterPosition = grid.getCellCenter(Std.int(cellPosition.x), Std.int(cellPosition.y));
			}
			
			// If it's already occupied, go to the last one free you got
			if (grid.getData(cellPosition.x, cellPosition.y) != null)
			{
				trace(cellPosition + " is already occupied, returning to " + lastPosition);
				cellPosition.set(lastPosition.x, lastPosition.y);
				
				cellCenterPosition = grid.getCellCenter(Std.int(cellPosition.x), Std.int(cellPosition.y));
			}
			
			// Store your data
			grid.setData(cellPosition.x, cellPosition.y, this);
			// trace("Storing bubble at " + cellPosition.x + ", " + cellPosition.y + " with " + colorIndex);
			
			if (!debug)
			{	
				// And notify
				world.onBubbleStop();
			}
		}
	}
	
	public function onDeath()
	{
		velocity.set();
		world.bubbles.remove(this);
		this.kill();
		this.destroy();
	}
	
	public function triggerPop()
	{
		if (state != Bubble.StatePopping)
		{
			// Start your death procedure
			state = Bubble.StatePopping;
			
			// Clear grid data
			grid.setData(cellPosition.x, cellPosition.y, null);
			
			var crunchTime : Float = 0.5;
			var waitTime : Float = 0.5;
			var popTime : Float = 0.15;
			FlxTween.tween(this.scale, {x : 0.5, y : 0.5}, crunchTime, 
							{ complete : function(_t:FlxTween) {
								new FlxTimer(waitTime, function(__t:FlxTimer) {
									FlxTween.tween(this.scale, {x : 3, y : 3}, popTime);
									FlxTween.tween(this, {alpha : 0}, popTime, { complete : function(___t:FlxTween) {
										onDeath();
									}});
								});
							}
						});
		}
	}
	
	public function triggerFall()
	{
		if (state != Bubble.StatePopping)
		{
			// Start your death procedure
			state = Bubble.StatePopping;
			
			// Clear grid data
			grid.setData(cellPosition.x, cellPosition.y, null);
			
			var jumpWaitTime : Float = 1;
			new FlxTimer(jumpWaitTime, function (_t:FlxTimer) {
				velocity.y = -100;
				velocity.x = FlxRandom.intRanged(-20, 20);
				falling = true;
			});
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
		if (state == StatePopping || bubble.state == StatePopping)
			return false;
	
		var squish : Float = 0.85;
	
		var deltaXSquared : Float = (x + width/2) - (bubble.x + width/2);
		deltaXSquared *= deltaXSquared;
		var deltaYSquared : Float = (y + height/2) - (bubble.y + height/2);
		deltaYSquared *= deltaYSquared;

		// Calculate the sum of the radii, then square it
		var sumRadiiSquared : Float = Size * squish + bubble.Size * squish;
		sumRadiiSquared *= sumRadiiSquared;

		return (deltaXSquared + deltaYSquared <= sumRadiiSquared);
	}
	
	public function getCurrentCell()
	{
		return grid.getCellAt(x+10, y+10);
	}
	
	public static function compare(A : FlxPoint, B : FlxPoint) : Bool
	{
		return A.x == B.x && A.y == B.y;
	}
	
	public static function CreateAt(X : Float, Y : Float, ColorIndex : Int, World : PlayState) : Bubble
	{
		var cellCenter : FlxPoint = World.grid.getCellCenter(Std.int(X), Std.int(Y));
		
		var bubble : Bubble = new Bubble(cellCenter.x, cellCenter.y, World, ColorIndex);
		bubble.cellPosition.set(X, Y);
		bubble.cellCenterPosition.set(cellCenter.x, cellCenter.y);
		bubble.state = StateIdling;
		
		World.grid.setData(X, Y, bubble);
		World.bubbles.add(bubble);
		
		return bubble;
	}
}