package;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import SfxEngine.SFX;

class Bubble extends Entity
{
	public static inline var StateAiming : Int = 0;
	public static inline var StateFlying : Int = 1;
	public static inline var StateIdling : Int = 2;
	public static inline var StatePopping : Int = 3;
	public static inline var StateDebug  : Int = 4;

	public var crunchTime : Float = 0.25;
	public var waitTime : Float = 0.25;
	public var popTime : Float = 0.2;
	public var jumpWaitTime : Float = 0.05;

	public var Speed : Float = 350;
	public var Size : Float;
	public var HalfSize : Float;

	public var UseMoveToContact : Bool = true;

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

	var touchedBubble : Bubble;

	var turnTimer : FlxTimer;
	var scaleTween : FlxTween;
	var alphaTween : FlxTween;

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

	override public function destroy()
	{
		if (turnTimer != null)
		{
			turnTimer.cancel();
			turnTimer.destroy();
			turnTimer = null;
		}

		if (scaleTween != null)
		{
			scaleTween.cancel();
			scaleTween.destroy();
			scaleTween = null;
		}

		if (alphaTween != null)
		{
			alphaTween.cancel();
			alphaTween.destroy();
			alphaTween = null;
		}

		super.destroy();
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
			case BubbleColor.SpecialBlocker:
				popPoints = 0;
				fallPoints = Constants.ScBubbleFall * 3;
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
				// trace("Target bubble instantiated");
				var sprite : String = world.playSessionData.target + ".png";
				loadGraphic("assets/images/" + sprite);
			case BubbleColor.SpecialPresent:
				// Can't happen
			case BubbleColor.SpecialBlocker:
				loadGraphic("assets/images/blocker-sprite.png", true, 18, 18);
				animation.add("idle", [FlxG.random.getObject([0, 1, 3])], 1, true);
				animation.add("turn", [0, 1, 2, 3], FlxG.random.int(5, 10), false);
				animation.play("idle");
				// Add the special rotate animation
				function doTurn(t:FlxTimer){
					if (alive && visible && active)
					{
						// Sometimes, reverse the animation
						if (FlxG.random.bool(50))
							animation.getByName("turn").frames.reverse();
						// Select a new velocity for the animation
						animation.getByName("turn").frameRate = FlxG.random.int(5, 10);
						// Play it!
						animation.play("turn");
						// And wait some time beofre doing it again
						t.start(FlxG.random.float(1, 30), doTurn);
					}
				}

				turnTimer = new FlxTimer();
				turnTimer.start(FlxG.random.float(1, 30), doTurn);

			default:
				loadGraphic("assets/images/" + Bubble.GetSprite() + ".png", true, 16, 16);
				if (bubbleColor.colorIndex < 5)
				{
					animation.add("idle", [bubbleColor.colorIndex]);
				}
				else
				{
					animation.add("idle", [5]);
					// color = bubbleColor.getColor();
				}

				animation.play("idle");
		}
	}

	override public function update(elapsed:Float)
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
				{
					velocity.x *= -1;
					SfxEngine.play(SFX.BubbleBounce);
				}

				// Stick to the ceiling
				if (y - HalfSize <= grid.getTop())
				{
					onHitCeiling();
				}
				// Check collision vs bubbles
				else if (UseMoveToContact && checkCollisionWithBubblesAt(x + velocity.x * FlxG.elapsed, y + velocity.y * FlxG.elapsed))
				{
					// Check for presents
					var present : Bubble = getPresentBubbleMeetingAt(x + velocity.x * FlxG.elapsed, y + velocity.y * FlxG.elapsed, onlyPresentBubbles);

					var flyingVelocity = moveToContact(x + velocity.x * FlxG.elapsed,  y + velocity.y * FlxG.elapsed);

					// Remember your way
					var currentPosition : FlxPoint = getCurrentCell();
					//if (!compare(currentPosition, cellPosition))
					{
						lastPosition.set(cellPosition.x, cellPosition.y);
						cellPosition.set(currentPosition.x, currentPosition.y);

						world.grid.currentCell = cellPosition;
						world.grid.lastCell = lastPosition;
					}

					// trace(lastPosition + " -> " + cellPosition);
					if (present != null)
					{
						// onHitBubbles(false);
						present.onPresentHit(this, flyingVelocity);
					}
					else
					{
						onHitBubbles();
					}
				}
				else
				{
					// Remember your way
					var currentPosition : FlxPoint = getCurrentCell();
					if (!compare(currentPosition, cellPosition))
					{
						lastPosition.set(cellPosition.x, cellPosition.y);
						cellPosition.set(currentPosition.x, currentPosition.y);

						world.grid.currentCell = cellPosition;
						world.grid.lastCell = lastPosition;
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

					if (y > Constants.Height)
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

		if (world.notifyDrop && state == StateIdling && !world.paused)
		{
			vibrate(true, 0.5, true);
		}
		else
		{
			vibrate(false);
		}

		if (alive)
			super.update(elapsed);
	}

	public function shoot(direction : Float)
	{
		state = Bubble.StateFlying;

		var cos : Float = Math.cos(direction * (Math.PI/180));
		var sin : Float = Math.sin(direction * (Math.PI/180));

		var velocityX : Float = cos * Speed;
		var velocityY : Float = -sin * Speed;

		if (FlxG.keys.pressed.SHIFT)
		{
			velocityX *= 0.1;
			velocityY *= 0.1;
		}

		velocity.set(velocityX, velocityY);
	}

	public function onTargetHit(other : Bubble)
	{
		if (special == BubbleColor.SpecialTarget)
		{
			// trace("Target bubble hit!");
			world.onTargetBubbleHit();
			// Some effect to the target or something?
		}
	}

	public function onPresentHit(other : Bubble, flyingVelocity : FlxPoint)
	{
		if (special == BubbleColor.SpecialPresent)
		{
			bounceBubble(other, flyingVelocity);
			world.onPresentBubbleHit(this);
		}

		if (flyingVelocity != null)
			flyingVelocity.put();
	}

	public function bounceBubble(other : Bubble, flyingVelocity : FlxPoint)
	{
		world.bubbles.add(other);
		other.velocity.x = flyingVelocity.x * -0.25;
		other.fall(flyingVelocity.y * 0.1);
		alphaTween = FlxTween.tween(other, {alpha : 0}, 0.75, {ease : FlxEase.expoIn, onComplete: function(t:FlxTween) {
			alphaTween.destroy();
			alphaTween = null;
		}});
		FlxSpriteUtil.flicker(other);
	};

	public function onHitCeiling()
	{
		onHitSomething(true);
	}

	public function onHitBubbles(?notifyWorld : Bool = true)
	{
		onHitSomething(false, notifyWorld);
	}

	public function onHitSomething(useNewPosition : Bool, notifyWorld : Bool = true)
	{
		if (state == StateFlying)
		{
			// Rest!
			state = StateIdling;

			// Fetch your current place
			var currentPosition : FlxPoint = getCurrentCell();

			// Discriminate between ceiling and bubble hit
			if (useNewPosition)
			{
				cellPosition.set(currentPosition.x, currentPosition.y);
				cellCenterPosition = grid.getCellCenter(Std.int(cellPosition.x), Std.int(cellPosition.y));
			}
			else
			{
				// Consider the last valid position visited
				cellPosition.set(currentPosition.x, currentPosition.y);
				cellCenterPosition = grid.getCellCenter(Std.int(cellPosition.x), Std.int(cellPosition.y));
			}

			// If it's already occupied, go to the last one free you got
			if (!grid.isPositionValid(currentPosition) || grid.getData(currentPosition.x, currentPosition.y) != null)
			{
				// Store the target in case the fallback position is not valid
				var targetPosition : FlxPoint = null;
				if (touchedBubble != null)
					targetPosition = touchedBubble.getCurrentCell();
				else
					targetPosition = getCurrentCell();
				// var targetPosition : FlxPoint = FlxPoint.get(currentPosition.x, currentPosition.y);

				var invalid : Bool = !grid.isPositionValid(targetPosition);
				var occupied : Bool = grid.getData(targetPosition.x, targetPosition.y) != null;

				#if !mobile
				/* trace(cellPosition + " is" +
						(occupied ? " already occupied by " + grid.getData(targetPosition.x, targetPosition.y) : "") +
						(invalid ? " invalid" : "") +
						", returning to " + lastPosition);*/
				#end
				cellPosition.set(lastPosition.x, lastPosition.y);
				cellCenterPosition = grid.getCellCenter(Std.int(cellPosition.x), Std.int(cellPosition.y));

				var neighbours : Array<FlxPoint> = grid.getValidAdjacentPositions(targetPosition, touchedBubble == null);
				// trace(neighbours + " contains " + cellPosition + "? " + containsPoint(neighbours, cellPosition));
				if (!containsPoint(neighbours, cellPosition))
				{
					#if !mobile
						// Non adjacent position reached
						// trace("Invalid fallback from " + targetPosition + " to " + cellPosition);
						// Find the closest cell
						// trace("Trying to find closest to " + cellPosition + " between " + neighbours);
					#end
					cellPosition = findClosestCell(cellPosition, neighbours);
					if (cellPosition != null)
					{
						cellCenterPosition = grid.getCellCenter(Std.int(cellPosition.x), Std.int(cellPosition.y));
						#if !mobile
							// trace("Found: " + cellPosition);
						#end
					}
					else
					{
						// No valid position found?;
						// trace("Invalid position found!");
						bounceBubble(this, FlxPoint.get(0, 0));
					}
				}

				targetPosition.put();
			}

			var mayHaveLost : Bool = false;
			if (cellPosition != null)
			{
				// Check whether the bubble is below the target line
				if (cellPosition.y >= grid.bottomRow)
				{
					reposition(cellPosition.x, cellPosition.y);
					mayHaveLost = true;
				}

				// Store your data
				grid.setData(cellPosition.x, cellPosition.y, this);
			}

			if (notifyWorld)
			{
				// And notify the world
				world.handleBubbleStop(mayHaveLost);
			}
		}
	}

	function containsPoint(arr : Array<FlxPoint>, point : FlxPoint) : Bool
	{
		for (a in arr)
		{
			if (a.equals(point))
				return true;
		}

		return false;
	}

	function findClosestCell(target : FlxPoint, cells : Array<FlxPoint>) : FlxPoint
	{
		var closest : FlxPoint = null;
		var distance : Float = Math.POSITIVE_INFINITY;
		var center : FlxPoint = grid.getCenterOfCellAt(target.x, target.y);
		var ccenter : FlxPoint = null;
		for (cell in cells)
		{
			ccenter = grid.getCenterOfCellAt(cell.x, cell.y);
			if (center.distanceTo(ccenter) < distance)
			{
				closest = cell;
				distance = center.distanceTo(ccenter);
			}
		}

		return closest;
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
		world.presents.remove(this);

		this.kill();
		this.destroy();
	}

	public function triggerPop(?immediate : Bool = false)
	{
		if (state != Bubble.StatePopping)
		{
			// Start your death procedure
			state = Bubble.StatePopping;

			// Clear grid data
			if (grid.isPositionValid(cellPosition))
				grid.setData(cellPosition.x, cellPosition.y, null);

			scaleTween = FlxTween.tween(this.scale, {x : 0.5, y : 0.5}, immediate ? 0.01 : crunchTime,
							{onComplete: function(_t:FlxTween) {
								scaleTween.destroy();
								scaleTween = null;
								new FlxTimer().start(waitTime, function(__t:FlxTimer) {
									scaleTween = FlxTween.tween(this.scale, {x : 3, y : 3}, popTime, {onComplete: function(t:FlxTween) {
										scaleTween.destroy();
										scaleTween = null;
									}});
									alphaTween = FlxTween.tween(this, {alpha : 0}, popTime, {onComplete: function(___t:FlxTween) {
										alphaTween.destroy();
										alphaTween = null;
										onDeath();
									}});
								});
							}
						});
		}
	}

	public function triggerFall(?immediate : Bool = false)
	{
		if (state != Bubble.StatePopping)
		{
			// Start your death procedure
			state = Bubble.StatePopping;

			// Clear grid data
			if (grid.isPositionValid(cellPosition))
				grid.setData(cellPosition.x, cellPosition.y, null);

			scaleTween = FlxTween.tween(this.scale, {x : 0.9, y : 0.9}, immediate ? 0 : jumpWaitTime*0.5, {onComplete: function(t:FlxTween) {
				scaleTween.destroy();
				scaleTween = null;
			}});

			new FlxTimer().start(jumpWaitTime, function (_t:FlxTimer) {
				// Do a small jump before falling
				fall(-100);
			});
		}
	}

	public function fall(?vspeed : Float = -100)
	{
		state = Bubble.StatePopping;
		velocity.y = vspeed;
		scale.set(1, 1);
		falling = true;
	}

	public function triggerRot(?immediate : Bool = false)
	{
		state = StateIdling;

		var delay : Float = 1.0;
		var rotTime : Float = (grid.rows - cellPosition.y)*0.35 + (cellPosition.y)*0.10 + (cellPosition.x)*0.04;

		if (immediate)
		{
			delay = 0.5;
			rotTime = 0;
		}

		// Rot quickly
		new FlxTimer().start(delay + rotTime * 0.25, function (_t:FlxTimer) {
			color = 0xFF606060;
		});

		// Fall less quickly
		new FlxTimer().start(delay + rotTime, function (_t:FlxTimer) {
			triggerFall();
			SfxEngine.play(SfxEngine.SFX.BubbleFall);
		});
	}

	/*public function checkCollisionWithTarget() : Bool
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
	}*/

	public function getPresentBubbleMeetingAt(X : Float, Y : Float, ?filter : Bubble -> Bool) : Bubble
	{
		var collidedWith : Bubble = null;

		var tx : Float = x;
		var ty : Float = y;

		x = X;
		y = Y;

		// Note: this only works for finding presents
		var bubbles : FlxTypedGroup<Bubble> = world.presents;
		var iterator : FlxTypedGroupIterator<Bubble> =
										bubbles.iterator(filter);
		while (iterator.hasNext())
		{
			var bubble : Bubble = iterator.next();
			if (bubble.touches(this))
			{
				collidedWith = bubble;
			}
		}

		x = tx;
		y = ty;

		return collidedWith;
	}

	function onlyTargetBubbles(bubble : Bubble) : Bool
	{
		return (bubble != null && bubble.special == BubbleColor.SpecialTarget);
	}

	function onlyPresentBubbles(bubble : Bubble) : Bool
	{
		return (bubble != null && bubble.special == BubbleColor.SpecialPresent);
	}

	public function checkCollisionWithBubblesAt(X : Float, Y : Float) : Bool
	{
		var tx : Float = x;
		var ty : Float = y;

		x = X;
		y = Y;

		var collision : Bool = checkCollisionWithBubbles();

		x = tx;
		y = ty;

		return collision;
	}

	function moveToContact(X : Float, Y : Float) : FlxPoint
	{
		var from : FlxPoint = new FlxPoint(x, y);
		var to : FlxPoint = new FlxPoint(X, Y);

		for (i in 0...101)
		{
			var t : Float = 1 - i/100;
			var position : FlxPoint = interpolatePosition(from, to, t);
			if (!checkCollisionWithBubblesAt(position.x, position.y))
			{
				// trace("Found contact position with t=" + t);
				x = position.x;
				y = position.y;

				var flyingVelocity : FlxPoint = FlxPoint.get(velocity.x, velocity.y);

				velocity.x = 0;
				velocity.y = 0;

				return flyingVelocity;
			}
		}

		return null;
	}

	function interpolatePosition(from : FlxPoint, to : FlxPoint, t : Float) : FlxPoint
	{
		var point : FlxPoint = new FlxPoint();

		point.x = from.x + (to.x - from.x) * t;
        point.y = from.y + (to.y - from.y) * t;

		return point;
	}

	public function checkCollisionWithBubbles() : Bool
	{
		var bubbles : FlxTypedGroup<Bubble> = world.bubbles;
		for (bubble in bubbles)
		{
			if (bubble.touches(this))
			{
				// Store the touched bubble
				touchedBubble = bubble;
				return true;
			}
		}

		// Check presents
		for (bubble in world.presents)
		{
			if (bubble.touches(this))
			{
				// Store the touched bubble
				touchedBubble = bubble;
				return true;
			}
		}

		return false;
	}

	public function touches(bubble : Bubble, ?track : Bool = false) : Bool
	{
		if (state == StatePopping || bubble.state == StatePopping)
			return false;

		var squish : Float = 0.95;

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
		// var oldPos : FlxPoint = new FlxPoint(cellPosition.x, cellPosition.y);

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

	public static function CreateAt(X : Float, Y : Float, Color : BubbleColor, World : PlayState, ?Content : Int = -1) : Bubble
	{
		var cellCenter : FlxPoint = World.grid.getCellCenter(Std.int(X), Std.int(Y));

		var bubble : Bubble = null;
		if (Color.colorIndex == BubbleColor.SpecialPresent)
		{
			bubble = new PresentBubble(cellCenter.x, cellCenter.y - World.grid.cellSize, World, Color);
			// Generate a new content if not provided
			if (Content == -1)
			{
				Content = World.specialBubbleController.getPresentContent();
			}
			cast(bubble, PresentBubble).setContent(Content);
			World.specialBubbleController.onSpecialBubbleGenerated();
		}
		else
		{
			bubble = new Bubble(cellCenter.x, cellCenter.y - World.grid.cellSize, World, Color);
		}

		bubble.cellPosition.set(X, Y);
		bubble.cellCenterPosition.set(cellCenter.x, cellCenter.y);
		bubble.state = StateIdling;

		World.grid.setData(X, Y, bubble);
		if (Color.colorIndex == BubbleColor.SpecialPresent)
			World.presents.add(bubble);
		else
			World.bubbles.add(bubble);

		return bubble;
	}

	public static function GetSprite()
	{
		return "bubbles_sheet";
	}
}
