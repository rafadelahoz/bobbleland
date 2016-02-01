package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxMath;
import flixel.util.FlxAngle;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;

class PlayerCursor extends FlxSprite
{
	public var Length : Float;
	public var AngleDelta : Float;

	public var world : PlayState;
	public var enabled : Bool;
	
	public var aimAngle : Float;
	public var aimOrigin : FlxPoint;
	
	public var label : FlxText;

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y);
		
		world = World;
		enabled = true;
		
		makeGraphic(32, 32, 0x00000000);
		
		Length = 16;
		AngleDelta = 1;
		
		aimAngle = 90;
		aimOrigin = FlxPoint.get(width / 2, height / 2);
		
		label = new FlxText(x + width, y + aimOrigin.y + 2, "");
		
		redraw();
	}
	
	override public function update()
	{
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
				redraw();
			}
			
			if (world.notifyAiming)
				color = 0xFFFF5151;
			else
				color = 0xFFFFFFFF;
			
			label.update();
		}
		
		super.update();
	}
	
	public function onShoot()
	{
		// ??
	}
	
	override public function draw()
	{
		super.draw();
		// label.draw();
	}
	
	public function redraw() : Void
	{
		var cos : Float = Math.cos(aimAngle * (Math.PI/180));
		var sin : Float = Math.sin(aimAngle * (Math.PI/180));

		var targetX : Float = cos * Length + aimOrigin.x;
		var targetY : Float = -sin * Length + aimOrigin.y;
		
		label.text = "" + aimAngle;
		FlxSpriteUtil.fill(this, 0x00000000);
		FlxSpriteUtil.drawCircle(this, aimOrigin.x, aimOrigin.y, Length * 0.3, 0xFFFFFFFF);
		FlxSpriteUtil.drawLine(this, aimOrigin.x, aimOrigin.y, targetX, targetY, { color : 0xFFFFFFFF, thickness: 3 });
	}
	
	public function disable()
	{
		if (enabled)
		{
			enabled = false;
			
			// Do something with the graphic
		}
	}
}