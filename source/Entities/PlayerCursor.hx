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

	public var aimAngle : Float;
	public var aimOrigin : FlxPoint;
	
	public var label : FlxText;

	public function new(X : Float, Y : Float)
	{
		super(X, Y);
		
		makeGraphic(32, 32, 0x00000000);
		
		Length = 16;
		AngleDelta = 2.5;
		
		aimAngle = 0;
		aimOrigin = FlxPoint.get(width / 2, height / 2);
		
		label = new FlxText(x + width, y + aimOrigin.y + 2, "");
	}
	
	override public function update()
	{
		var oldAngle : Float = aimAngle;
	
		if (FlxG.keys.pressed.LEFT)
			aimAngle -= AngleDelta;
		else if (FlxG.keys.pressed.RIGHT)
			aimAngle += AngleDelta;
			
		aimAngle = FlxMath.bound(aimAngle, 30, 150);
		
		if (oldAngle != aimAngle)
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
		
		label.update();
		
		super.update();
	}
	
	public function onShoot()
	{
		// ??
	}
	
	override public function draw()
	{
		super.draw();
		label.draw();
	}
}