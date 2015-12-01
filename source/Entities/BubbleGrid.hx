package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxRect;
import flixel.util.FlxSpriteUtil;

class BubbleGrid extends FlxObject
{
	public var bounds : FlxRect;
	
	public var columns : Int;
	public var rows : Int;
	public var cellSize : Float;
	public var halfCell : Float;

	public var canvas : FlxSprite;
	
	public function new(X : Float, Y : Float, Width : Float, Height : Float)
	{
		super(X, Y, Width, Height);
		
		bounds = new FlxRect(X, Y, Width, Height);
		columns = 8;
		rows = 10;
		
		cellSize = Width / (columns+0.5);
		halfCell = cellSize / 2;
		
		trace(bounds.width + "/" + columns + "+0.5 = " + cellSize);
		
		renderCanvas();
	}
	
	override public function draw()
	{
		super.draw();
		
		if (canvas != null)
			canvas.draw();
	}
	
	public function renderCanvas()
	{
		if (canvas == null)
			canvas = new FlxSprite(bounds.x, bounds.y).makeGraphic(Std.int(bounds.width), Std.int(bounds.height), 0xFF250516);
		else
			FlxSpriteUtil.fill(canvas, 0x00000000);
			
		var lineStyle : flixel.util.LineStyle = { color : 0x50FFFFFF, thickness : 1 };
			
		for (row in 0...rows)
		{
			for (col in 0...columns)
			{
				FlxSpriteUtil.drawRect(canvas, col * cellSize + (row % 2)*halfCell, row * cellSize, cellSize, cellSize, 0x50FFFFFF, lineStyle);
			}
		}
	}
}