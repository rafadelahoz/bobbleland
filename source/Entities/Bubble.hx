package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;
import flixel.util.FlxSpriteUtil;
import flixel.group.FlxTypedGroup;
import flixel.group.FlxTypedGroupIterator;
import flixel.tweens.FlxTween;

class Bubble extends FlxSprite
{
	public static var StateAiming : Int = 0;
	public static var StateFlying : Int = 1;
	public static var StateIdling : Int = 2;
	public static var StatePopping : Int = 3;
	public static var StateDebug  : Int = 4;

	public var crunchTime : Float = 0.25;
	public var waitTime : Float = 0.25;
	public var popTime : Float = 0.2;
	public var jumpWaitTime : Float = 0.05;

	public var Speed : Float = 350;
	public var Size : Float;
	public var HalfSize : Float;

	public var popPoints : Int;
	public var fallPoints : Int;

	public var world : PlayState;
	public var grid : BubbleGrid;

	public var bubbleColor : BubbleColor;

	public var safe : Bool;

	public var state : Int;
	public var falling : Bool;

	public var lastPosition : FlxPoint;
	public var cellPosition : FlxPoint;
	public var cellCenterPosition : FlxPoint;

	public var special : Int;

	public function new(X : Float, Y : Float, World : PlayState, Color : BubbleColor)
	{
		super(X, Y);

		world = World;
		grid = world.grid;

		Size = world.grid.cellSize / 2 * 0.9;
		HalfSize = Size / 2;

		bubbleColor = Color;

		cellPosition = new FlxPoint();
		lastPosition = new FlxPoint();
		cellCenterPosition = new FlxPoint();

		state = StateAiming;

		safe = false;
		falling = false;

		// Negative color indexes mean special bubbles
		special = BubbleColor.SpecialNone;
		if (bubbleColor.isSpecial)
		{
			handleSpecialBubble(bubbleColor);
		}

		handlePoints();

		handleGraphic();
	}

	public function handleSpecialBubble(color : BubbleColor)
	{
		special = color.colorIndex;

		switch (special)
		{
			case BubbleColor.SpecialTarget:
				// Special things here
			case BubbleColor.SpecialAnchor:
				safe = true;
			default:
		}
	}

	public function handlePoints()
	{
		switch (special)
		{
			case BubbleColor.SpecialNone:
				popPoints = Constants.ScBubblePop;
				fallPoints = Constants.ScBubbleFall;
			case BubbleColor.SpecialAnchor:
				popPoints = Constants.ScBubblePop * 2;
				fallPoints = Constants.ScBubbleFall * 2;
			default:
				popPoints = Constants.ScBubblePop * 2;
				fallPoints = Constants.ScBubbleFall * 2;
		}
	}

	public function handleGraphic()
	{
		switch (special)
		{
			case BubbleColor.SpecialAnchor:
				makeGraphic(Std.int((Size+1)*2), Std.int((Size+1)*2), 0x00000000);
				// FlxSpriteUtil.drawRoundRect(this, 1, 1, Size*2, Size*2, 4, 4, 0xFF414471);
				FlxSpriteUtil.drawCircle(this, width/2, height/2, Size, 0xFFFFFFFF);
				// offset.set(0, 0);
			case BubbleColor.SpecialTarget:
				trace("Target bubble instantiated");
				var sprite : String = world.puzzleData.target + ".png";
				loadGraphic("assets/images/" + sprite);
			default:
				loadGraphic("assets/images/bubbles_sheet.png", true, 16, 16);
				if (bubbleColor.colorIndex < 5)
				{
					animation.add("idle", [bubbleColor.colorIndex]);
				}
				else
				{
					animation.add("idle", [5]);
				}

				animation.play("idle");
		}
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
				if (x + width/2 - Size * 1 <= grid.getLeft() || x + width/2 + Size * 1 >= grid.getRight())
					velocity.x *= -1;

				// Stick to the ceiling
				if (y - HalfSize <= grid.getTop())
				{
					onHitCeiling();
				}
				// Stick to the bubble mass
				else if (checkCollisionWithTarget())
				{
					// What?
					onHitBubbles();
				}
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
						x = FlxMath.lerp(x, cellCenterPosition.x, 0.5);
						y = FlxMath.lerp(y, cellCenterPosition.y, 0.5);
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

	public function onTargetHit(other : Bubble)
	{
		if (special == BubbleColor.SpecialTarget)
		{
			trace("Target bubble hit!");
			world.onTargetBubbleHit();
			// Some effect to the target or something?
		}
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
			if (!grid.isPositionValid(cellPosition) || grid.getData(cellPosition.x, cellPosition.y) != null)
			{
				trace(cellPosition + " is already occupied, returning to " + lastPosition);
				cellPosition.set(lastPosition.x, lastPosition.y);
				cellCenterPosition = grid.getCellCenter(Std.int(cellPosition.x), Std.int(cellPosition.y));
			}

			var mayHaveLost : Bool = false;
			// Check whether the bubble is below the target line
			if (cellPosition.y >= grid.bottomRow)
			{
				reposition(cellPosition.x, cellPosition.y);
				mayHaveLost = true;
			}

			// Store your data
			grid.setData(cellPosition.x, cellPosition.y, this);

			if (!debug)
			{
				// And notify the world
				world.handleBubbleStop(mayHaveLost);
			}
		}
	}

	public function onBubblesPopped()
	{
		switch (special)
		{
			case BubbleColor.SpecialAnchor:
				var neighbours : Array<Bubble> = grid.getNeighbours(this);
				if (neighbours.length == 0)
				{
					triggerPop();
				}
			default:
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
			if (grid.isPositionValid(cellPosition))
				grid.setData(cellPosition.x, cellPosition.y, null);

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
			if (grid.isPositionValid(cellPosition))
				grid.setData(cellPosition.x, cellPosition.y, null);

			FlxTween.tween(this.scale, {x : 0.9, y : 0.9}, jumpWaitTime*0.5);

			new FlxTimer(jumpWaitTime, function (_t:FlxTimer) {
				velocity.y = -100;
				scale.set(1, 1);
				// velocity.x = FlxRandom.intRanged(-20, 20);
				falling = true;
			});
		}
	}

	public function triggerRot()
	{
		state = StateIdling;

		var rotTime : Float = (grid.rows - cellPosition.y)*0.25 + (cellPosition.y)*0.15;

		// Rot quickly
		new FlxTimer(rotTime * 0.25, function (_t:FlxTimer) {
			color = 0xFF606060;
		});

		// Fall less quickly
		new FlxTimer(rotTime, function (_t:FlxTimer) {
			triggerFall();
		});
	}

	public function checkCollisionWithTarget() : Bool
	{
		var bubbles : FlxTypedGroup<Bubble> = world.bubbles;
		var iterator : FlxTypedGroupIterator<Bubble> =
										bubbles.iterator(onlyTargetBubbles);
		while (iterator.hasNext())
		{
			var bubble : Bubble = iterator.next();
			if (bubble.touches(this))
			{
				bubble.onTargetHit(this);
				return true;
			}
		}

		return false;
	}

	function onlyTargetBubbles(bubble : Bubble) : Bool
	{
		return (bubble != null && bubble.special == BubbleColor.SpecialTarget);
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

	public function getCurrentCell() : FlxPoint
	{
		return grid.getCellAt(x+Size, y+Size);
	}

	public function reposition(X : Float, Y : Float)
	{
		var oldPos : FlxPoint = new FlxPoint(cellPosition.x, cellPosition.y);

		cellPosition.set(Std.int(X), Std.int(Y));
		cellCenterPosition = grid.getCellCenter(Std.int(cellPosition.x), Std.int(cellPosition.y));
	}

	public function isSafe() : Bool
	{
		return special == BubbleColor.SpecialAnchor;
	}

	public function getPopPoints() : Int
	{
		return popPoints;
	}

	public function getFallPoints() : Int
	{
		return fallPoints;
	}

	public static function compare(A : FlxPoint, B : FlxPoint) : Bool
	{
		return A.x == B.x && A.y == B.y;
	}

	public static function CreateAt(X : Float, Y : Float, Color : BubbleColor, World : PlayState) : Bubble
	{
		var cellCenter : FlxPoint = World.grid.getCellCenter(Std.int(X), Std.int(Y));

		var bubble : Bubble = new Bubble(cellCenter.x, cellCenter.y - World.grid.cellSize, World, Color);
		bubble.cellPosition.set(X, Y);
		bubble.cellCenterPosition.set(cellCenter.x, cellCenter.y);
		bubble.state = StateIdling;

		World.grid.setData(X, Y, bubble);
		World.bubbles.add(bubble);

		return bubble;
	}
}
