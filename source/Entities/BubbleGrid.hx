package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxMath;
import flixel.util.FlxRect;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;

class BubbleGrid extends FlxObject
{
	public var bounds : FlxRect;
	
	public var columns : Int;
	public var rows : Int;
	
	public var cellSize : Float;
	public var halfCell : Float;

	public var canvas : FlxSprite;
	
	public var data : Array<Array<Int>>;
	
	public function new(X : Float, Y : Float, Width : Float, Height : Float)
	{
		super(X, Y, Width, Height);
		
		bounds = new FlxRect(X, Y, Width, Height);
		columns = 8;
		rows = 10;
		
		cellSize = Width / (columns+0.5);
		halfCell = cellSize / 2;
		
		highlightedCell = new FlxPoint(-1, -1);
		
		// trace(bounds.width + "/" + columns + "+0.5 = " + cellSize);
		
		renderCanvas();
		
		data = [];
		
		clearData();
	}
	
	override public function update()
	{
		renderCanvas();
		
		super.update();
	}
	
	override public function draw()
	{
		super.draw();
		
		if (canvas != null)
			canvas.draw();
	}
	
	public var highlightedCell : FlxPoint;
	
	public function getCellAt(X : Float, Y : Float) : FlxPoint
	{
		var yy : Int = Std.int((Y - bounds.y + halfCell) / cellSize);
		var xx : Int = Std.int(((X - bounds.x + halfCell) - (yy % 2)*halfCell)/ cellSize);
		
		xx = Std.int(FlxMath.bound(xx, 0, columns-1));
		yy = Std.int(FlxMath.bound(yy, 0, rows-1));
		
		var highlightedCell : FlxPoint = FlxPoint.get(xx, yy);
		
		return highlightedCell;
	}
	
	public function getCellCenter(column : Int, row : Int) : FlxPoint
	{
		var cellOffset : Float = (row % 2)*halfCell;
		var center : FlxPoint = new FlxPoint(Std.int(column * cellSize + cellOffset), Std.int(row * cellSize));
		return center;
	}
	
	public function getCenterOfCellAt(X : Float, Y : Float) : FlxPoint
	{
		var cell : FlxPoint = getCellAt(X, Y);
		return getCellCenter(Std.int(cell.x), Std.int(cell.y));
	}
	
	public function renderCanvas()
	{
		if (canvas == null)
			canvas = new FlxSprite(bounds.x, bounds.y).makeGraphic(Std.int(bounds.width), Std.int(bounds.height), 0xFF250516);
		else
			FlxSpriteUtil.fill(canvas, 0x00000000);
			
		var lineStyle : flixel.util.LineStyle = { color : 0x50FFFFFF, thickness : 1 };
		
		var cellOffset : Float;
		var cellColor : Int = 0x20FFFFFF;
		
		for (row in 0...rows)
		{
			cellOffset = (row % 2)*halfCell;
			for (col in 0...columns)
			{
				var ccolor : Int = cellColor;
				if (highlightedCell.x == col && highlightedCell.y == row)
				{
					ccolor = 0xFFFF5151;
				}
			
				FlxSpriteUtil.drawRect(canvas, col * cellSize + cellOffset, row * cellSize, cellSize, cellSize, ccolor, lineStyle);
			}
		}
	}
	
	public function clearData()
	{
		data = [];
		for (row in 0...rows)
		{
			data[row] = [];
			
			for (col in 0...columns)
			{
				data[row][col] = 0x0;
			}
		}
	}
	
	public function setData(col : Float, row : Float, value : Int)
	{
		trace("data[" + row + ", " + col + "]");
		data[Std.int(row)][Std.int(col)] = value;
	}
	
	public function getData(col : Float, row : Float) : Int
	{
		return data[Std.int(row)][Std.int(col)];
	}
}