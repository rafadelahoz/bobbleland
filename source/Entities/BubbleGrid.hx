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
	public var world : PlayState;

	public var bounds : FlxRect;
	
	public var columns : Int;
	public var rows : Int;
	
	public var cellSize : Float;
	public var halfCell : Float;

	public var canvas : FlxSprite;
	
	public var data : Array<Array<Bubble>>;
	
	public function new(X : Float, Y : Float, Width : Float, Height : Float, World : PlayState)
	{
		super(X, Y, Width, Height);
		
		world = World;
		
		bounds = new FlxRect(X, Y, Width, Height);
		columns = 8;
		rows = 10;
		
		cellSize = Width / (columns+0.5);
		halfCell = cellSize / 2;
		
		highlightedCell = new FlxPoint(-1, -1);
		
		data = [];
		clearData();
		
		renderCanvas();
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
		var yy : Int = Std.int((Y - bounds.y) / cellSize);
		var xx : Int = Std.int(((X - bounds.x) - (yy % 2)*halfCell)/ cellSize);
		
		xx = Std.int(FlxMath.bound(xx, 0, columns));
		yy = Std.int(FlxMath.bound(yy, 0, rows));
		
		highlightedCell.set(xx, yy);
		
		var cell : FlxPoint = FlxPoint.get(xx, yy);
		return cell;
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
				else if (getData(col, row) != null)
				{
					ccolor = world.bubbleColors[getData(col, row).colorIndex];
					ccolor &= 0x00FFFFFF;
					ccolor |= 0x40000000;
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
				data[row][col] = null;
			}
		}
	}
	
	public function setData(col : Float, row : Float, bubble : Bubble)
	{
		if (col >= 0 && col < columns && row >= 0 && row < rows)
			data[Std.int(row)][Std.int(col)] = bubble;
		else
			throw("Trying to set invalid grid position (" + col + ", " + row + ")");
	}
	
	public function getData(col : Float, row : Float) : Bubble
	{
		if (col >= 0 && col < columns && row >= 0 && row < rows)
			return data[Std.int(row)][Std.int(col)];
		else
			return null;
	}
	
	public function locateBubbleGroup(bubble : Bubble) : Array<Bubble>
	{
		var bubbles : Array<Bubble> = [bubble];
		var processed : Array<Bubble> = [bubble];
		
		var set : Array<Bubble> = [bubble];
		var targetColorIndex : Int = bubble.colorIndex;

		// Temporary variables
		var current : Bubble;
		var neighbour : Bubble;
		var adjacentPositions : Array<FlxPoint>;
		var position : FlxPoint;
		var colorIndex : Int;

		trace("\n======= Begin from " + bubble.cellPosition + "# " + bubble.colorIndex + " =======");
		
		while (set.length > 0)
		{
			current = set.shift();

			processed.push(current);
			
			position = current.cellPosition;
			colorIndex = current.colorIndex;

			trace(">>> Bubble@(" + position.x + ", " + position.y + "): " + colorIndex);
			
			adjacentPositions = getAdjacentPositions(position);
			
			for (adjPos in adjacentPositions)
			{
				neighbour = getData(adjPos.x, adjPos.y);
				var deltaX : Float = adjPos.x - position.x;
				var deltaY : Float = adjPos.y -  position.y;

				if (neighbour != null)
				{
					var msg : String = "At " + adjPos.x + ", " + adjPos.y + ": " + (neighbour == null ? "null" : "" + neighbour.colorIndex);

					if (neighbour.colorIndex == targetColorIndex)
					{
						msg += " [Colour matches] ";
						
						if (bubbles.indexOf(neighbour) < 0)
						{
							msg += "[Collected] ";
							bubbles.push(neighbour);
						}
						
						if (processed.indexOf(neighbour) < 0)
						{
							msg += "[ToBeProc]";
							set.push(neighbour);
						}
					}
					
					trace(msg);
				}
				else
					trace("Ignoring position (" + adjPos.x + ", " + adjPos.y + ")");
			}

			trace("<<< - " + set);
			
			clearAdjacentPositions(adjacentPositions);
		}

		trace("==============\n");
		
		return bubbles;
	}
	
	function getAdjacentPositions(pos : FlxPoint) : Array<FlxPoint>
	{
		var x : Int = Std.int(pos.x);
		var y : Int = Std.int(pos.y);
		
		if (y % 2 == 1)
			return [FlxPoint.get(x  , y-1), FlxPoint.get(x+1, y-1), 
					FlxPoint.get(x-1, y  ), FlxPoint.get(x+1, y  ),	
					FlxPoint.get(x  , y+1), FlxPoint.get(x+1, y+1)];
		else
			return [FlxPoint.get(x-1, y-1), FlxPoint.get(x  , y-1), 
					FlxPoint.get(x-1, y  ), FlxPoint.get(x+1, y  ),	
					FlxPoint.get(x-1, y+1), FlxPoint.get(x  , y+1)];
		
	}

	function clearAdjacentPositions(positions : Array<FlxPoint>)
	{
		for (point in positions)
		{
			point.put();
		}
	}
	
	public function dumpData()
	{
		var dump : String = "\n";
		for (row in 0...rows)
		{
			for (col in 0...columns)
			{
				var cell : Bubble = getData(col, row);
				if (cell == null)
				{
					dump += "[ ]";
				}
				else
				{
					dump += "[" + cell.colorIndex + "]";
				}
			}
			
			dump += "\n";
		}
		
		trace(dump);
	}
}