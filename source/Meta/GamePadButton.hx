package;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import flixel.util.FlxColorUtil;

class GamePadButton extends Sprite
{
	public var id : Int;
	public var color : Int;
	public var sprite : Bitmap;
	public var originalX : Float;
	public var originalY : Float;
	public var originalWidth : Float;
	public var originalHeight : Float;
	
	public var bounds : Rectangle;
	
	public var pressed : Bool;
	
	public function new(Id : Int, X : Float, Y : Float, Width : Float, Height : Float)
	{
		super();
		
		x = X;
		y = Y;
		width = Width;
		height = Height;
		
		id = Id;
		bounds = new Rectangle(X, Y, Width, Height);
		
		pressed = false;
		
		color = FlxColorUtil.getRandomColor(0x75, 0xFF, 0x00);
		
		#if (mobile || vpad)
		
		var spritePath : String = null;
		switch (Id)
		{
			case MetaGamePad.Up:
				spritePath = "assets/gamepad/UP.png";
			case MetaGamePad.Down:
				spritePath = "assets/gamepad/DOWN.png";
			case MetaGamePad.Left:
				spritePath = "assets/gamepad/LEFT.png";
			case MetaGamePad.Right:
				spritePath = "assets/gamepad/RIGHT.png";
			case MetaGamePad.A:
				spritePath = "assets/gamepad/A.png";
			case MetaGamePad.B:
				spritePath = "assets/gamepad/B.png";
			case MetaGamePad.Start:
				spritePath = "assets/gamepad/START.png";
			case MetaGamePad.Select:
				spritePath = "assets/gamepad/SELECT.png";
			default:
				sprite = null;
		}

		if (spritePath != null)
		{
			var bitmapData = Assets.getBitmapData(spritePath);
			sprite = new Bitmap(bitmapData, true);	
			adjustSpriteSize(sprite);
			adjustSpritePosition(sprite);
			
			addChild(sprite);
		}
		
		#end
		
		draw();
	}
	
	public function isPressed(touches : Map<Int, Point>) : Bool
	{
		pressed = false;
		
		for (point in touches.iterator())
		{
			if (bounds.contains(point.x, point.y))
			{
				pressed = true;
				break;
			}
		}
		
		draw();
		
		return pressed;
	}
	
	public function draw()
	{
		#if (mobile || vpad)
		graphics.clear();
		
		if (pressed)
		{
			if (sprite != null)
			{
				sprite.width = originalWidth * 1.2;
				sprite.height = originalHeight * 0.8;
				
				sprite.x = originalX + originalWidth / 2 - sprite.width / 2;
				sprite.y = originalY + originalHeight / 2 - sprite.height / 2 + sprite.height*0.15;
			}
			
			// graphics.beginFill(color, 0.6);
			graphics.beginFill(0x000000, 0.0);
			graphics.drawRect(0, 0, bounds.width, bounds.height);
			graphics.endFill();
		}
		else
		{
			if (sprite != null)
			{
				sprite.width = originalWidth;
				sprite.height = originalHeight;
				
				sprite.x = originalX;
				sprite.y = originalY;
			}
			
			// graphics.beginFill(color, 0.3);
			graphics.beginFill(0x000000, 0.0);
			graphics.drawRect(0, 0, bounds.width, bounds.height);
			graphics.endFill();
		}
		#end
	}
	
	function adjustSpriteSize(sprite : Bitmap)
	{
		if (bounds.width < bounds.height)
		{
			var ratio : Float = sprite.width / sprite.height;
			sprite.width = bounds.width * 0.75;
			sprite.height = bounds.width * 0.75 * ratio;
		}
		else
		{
			var ratio : Float = sprite.width / sprite.height;
			sprite.width = bounds.height * 0.75 * ratio;
			sprite.height = bounds.height * 0.75;
		}
		
		originalWidth = sprite.width;
		originalHeight = sprite.height;
	}
	
	function adjustSpritePosition(sprite : Bitmap)
	{
		sprite.x = bounds.width / 2 - sprite.width / 2;
		sprite.y = bounds.height / 2 - sprite.height / 2;
		
		originalX = sprite.x;
		originalY = sprite.y;
	}
}