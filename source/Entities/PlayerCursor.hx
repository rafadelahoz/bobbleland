package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class PlayerCursor extends Entity
{
	public var Length : Float;
	public var AngleDelta : Float;

	public var world : PlayState;
	public var enabled : Bool;

	public var moving : Bool;
	public var aimAngle : Float;
	public var aimOrigin : FlxPoint;

	public var label : FlxText;

	public var shots : Int;
	public var guideEnabled : Bool;
	var canvas : FlxSprite;
	var deltaOffset : Float;
	var tiny : FlxSprite;
	var tester : Bubble;

	public var isSleeping : Bool;

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y);

		world = World;
		enabled = true;

		loadGraphic("assets/images/cursor" + (world.character.characterId == "catbomb" ? "-catbomb" : "") + ".png");
		centerOffsets();
		centerOrigin();

		Length = 16;
		AngleDelta = 1;

		aimAngle = 90;
		aimOrigin = FlxPoint.get(width / 2, height / 2);
		moving = false;

		updateSpriteAngle();

		label = new FlxText(x + width, y - 16, -1, "");

		guideEnabled = false;

		canvas = new FlxSprite(0, 0);
		canvas.makeGraphic(Constants.Width, Constants.Height, 0x00FFFFFF);
		deltaOffset = 0;
		tiny = new FlxSprite(0, 0, "assets/images/tiny-bubble.png");
		tiny.centerOffsets(true);

		tester = new Bubble(0, 0, world, world.availableColors[0]);

		shots = 0;

		isSleeping = true;
	}

	override public function update(elapsed:Float)
	{
		moving = false;

		if (enabled)
		{
			var oldAngle : Float = aimAngle;

			if (GamePad.checkButton(GamePad.Left))
				aimAngle += AngleDelta;
			else if (GamePad.checkButton(GamePad.Right))
				aimAngle -= AngleDelta;

			aimAngle = FlxMath.bound(aimAngle, 30, 150);

			if (oldAngle != aimAngle)
			{
				moving = true;
				updateSpriteAngle();
				label.text = "" + aimAngle;

				isSleeping = false;
			}

			if (world.notifyAiming && world.state != PlayState.StateLosing)
				vibrate();
			else
				vibrate(false);

			label.update(elapsed);
		}
		else
		{
			if (world.state == PlayState.StateLosing)
				vibrate(false);
		}

		if (world.baseDecoration != null)
			world.baseDecoration.animation.paused = !moving;

		if (guideEnabled)
		{
			tiny.update(elapsed);
			canvas.update(elapsed);
		}

		redraw();

		super.update(elapsed);
	}

	function resetGuideAspect()
	{
		tiny.color = 0xFFFFFFFF;
		tiny.alpha = 1;
	}

	public function enableGuide(?activeShots : Int = -1)
	{
		guideEnabled = true;
		if (activeShots < 0)
			activeShots = PlayFlowController.InitialGuideEnabledShots;

		resetGuideAspect();

		disableGuideAfterShots(activeShots);
	}

	public function disableGuideAfterShots(number : Int)
	{
		if (number > 0)
			shots = number;
		else
			guideEnabled = false;
	}

	public function onShoot(?forced : Bool = false)
	{
		// ??
		if (shots > 0)
		{
			shots--;
			if (shots <= 0)
			{
				shots = 0;
				guideEnabled = false;
			}
		}

		if (!forced)
			isSleeping = false;

		scale.set(0.75, 0.75);
		FlxTween.tween(this.scale, {x : 1, y : 1}, 0.25, {ease: FlxEase.expoOut});
	}

	override public function draw()
	{
		canvas.draw();
		// Disable vibration when paused
		if (world.paused)
			vibrationEnabled = false;

		super.draw();
		if (world.grid.DEBUG_diplayGrid)
			label.draw();
	}

	public function redraw() : Void
	{
		FlxSpriteUtil.fill(canvas, 0x00000000);

		if (!guideEnabled || world.state == PlayState.StateLosing)
			return;

		var left : Float = world.grid.getLeft();
		var right : Float = world.grid.getRight();
		var halfSize : Float = world.grid.cellSize * 0.25;

		var tinyOffset : Float = 5;

		var length : Float = 2000;
		var delta : Float = 15;
		var alpha : Float = aimAngle;

		switch (shots)
		{
			case 4:
				tiny.color = 0xFFFFF1E8;
			case 3:
				tiny.color = 0xFFC2C3C7;
			case 2:
				tiny.alpha = 0.5;
		}

		deltaOffset += 0.1;
		if (deltaOffset > delta)
			deltaOffset = 0;

		var origin : FlxPoint = FlxPoint.get(x + aimOrigin.x, y + aimOrigin.y);

		var cos : Float = Math.cos(alpha * (Math.PI/180));
		var sin : Float = Math.sin(alpha * (Math.PI/180));

		var targetX : Float = cos * length + origin.x;
		var targetY : Float = -sin * length + origin.y;

		// label.text = "" + alpha;

		var current : Float = deltaOffset;
		while (current < length)
		{
			current += delta;
			targetX = Math.floor(cos * current + origin.x);
			targetY = Math.floor(-sin * current + origin.y);

			if (targetY < world.grid.getTop())
				break;

			if (tester.checkCollisionWithBubblesAt(targetX-tester.width/2, targetY-tester.height/2))
				break;

			if (cos < 0 && targetX - halfSize < left)
			{
				var deltaUsed = delta;
				// Find amplitude that gives touching boundary
				while (targetX - halfSize < left) {
					current -= 1;
					deltaUsed -= 1;
					targetX = Math.floor(cos * current + origin.x);
					targetY = Math.floor(-sin * current + origin.y);
				}
				length -= current;
				current = 0;
				// Use the contact point as new source
				origin.set(targetX, targetY);
				// Reflect the angle
				alpha = 180 - alpha;
				cos = Math.cos(alpha * (Math.PI/180));
				sin = Math.sin(alpha * (Math.PI/180));

				current += (delta - deltaUsed);
				targetX = Math.floor(cos * current + origin.x);
				targetY = Math.floor(-sin * current + origin.y);
				// continue;
			}
			else if (cos > 0 && targetX + halfSize > right)
			{
				var deltaUsed = delta;
				// Find amplitude that gives touching boundary
				while (targetX + halfSize > right) {
					current -= 1;
					deltaUsed -= 1;
					targetX = Math.floor(cos * current + origin.x);
					targetY = Math.floor(-sin * current + origin.y);
				}
				length -= current;
				current = 0;
				// Use the contact point as new source
				origin.set(targetX, targetY);
				// Reflect the angle
				alpha = 180 - alpha;
				cos = Math.cos(alpha * (Math.PI/180));
				sin = Math.sin(alpha * (Math.PI/180));

				current += (delta - deltaUsed);
				targetX = Math.floor(cos * current + origin.x);
				targetY = Math.floor(-sin * current + origin.y);
				// continue;
			}

			// canvas.stamp(tiny, Std.int(targetX), Std.int(targetY));
			canvas.stamp(tiny, Std.int(targetX-tinyOffset), Std.int(targetY-tinyOffset));
			// FlxSpriteUtil.drawCircle(canvas, targetX, targetY, 2, 0xFFFFFFFF);
		}
	}

	public function disable()
	{
		if (enabled)
		{
			enabled = false;

			// Do something with the graphic
		}
	}

	function updateSpriteAngle()
	{
		angle = -1*(aimAngle - 270);
	}
}
