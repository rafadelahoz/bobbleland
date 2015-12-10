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
	
	public var padded : Int = 0;
	
	public var columns : Int;
	public var rows : Int;
	public var topRow : Int;
	
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
		
		topRow = 0;
		
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
		var xx : Int = Std.int(((X - bounds.x) - padRow(yy)*halfCell)/ cellSize);
		
		xx = Std.int(FlxMath.bound(xx, 0, columns));
		yy = Std.int(FlxMath.bound(yy, 0, rows));
		
		highlightedCell.set(xx, yy);
		
		var cell : FlxPoint = FlxPoint.get(xx, yy);
		return cell;
	}
	
	public function getCellCenter(column : Int, row : Int) : FlxPoint
	{
		var cellOffset : Float = padRow(row)*halfCell;
		var center : FlxPoint = new FlxPoint(bounds.x + Std.int(column * cellSize + cellOffset), bounds.y + Std.int(row * cellSize));
		return center;
	}
	
	public function getCenterOfCellAt(X : Float, Y : Float) : FlxPoint
	{
		var cell : FlxPoint = getCellAt(X, Y);
		return getCellCenter(Std.int(cell.x), Std.int(cell.y));
	}
	
	public function renderCanvas()
	{
		return;
		
		if (canvas == null)
			canvas = new FlxSprite(bounds.x, bounds.y).makeGraphic(Std.int(bounds.width), Std.int(bounds.height), 0xFF250516);
		else
			FlxSpriteUtil.fill(canvas, 0x00000000);
			
		var lineStyle : flixel.util.LineStyle = { color : 0x50FFFFFF, thickness : 1 };
		
		var cellOffset : Float;
		var cellColor : Int = 0x20FFFFFF;
		
		for (row in topRow...rows)
		{
			cellOffset = padRow(row)*halfCell;
			for (col in 0...columns)
			{
				var ccolor : Int = cellColor;
				
				if (highlightedCell.x == col && highlightedCell.y == row)
				{
					ccolor = 0xFFFF5151;
				}
				else if (getData(col, row) != null)
				{
					if (getData(col, row).colorIndex >= 0)
					{
						ccolor = world.bubbleColors[getData(col, row).colorIndex];
						ccolor &= 0x00FFFFFF;
						ccolor |= 0x40000000;
					}
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
	
	public function isPositionValid(position : FlxPoint) : Bool
	{
		return isValid(position.x, position.y);
	}
	
	public function isValid(col : Float, row : Float) : Bool
	{
		return (col >= 0 && row >= topRow && col < columns && row < rows);
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
	
	public function generateBubbleRow(emptyRow : Bool)
	{
		var lostGame : Bool = false;
	
		switchPadding();
	
		// Shift bubble rows down
		for (r in -(rows-1) ...1)
		{
			var row : Int = -r;
			for (col in 0...columns)
			{
				var bubble : Bubble = getData(col, row);
				
				// Bubbles that overflow from the bottom mean gameover
				if (row >= rows-1)
				{
					if (bubble != null)
					{
						bubble.reposition(col, row+1);
						bubble.triggerRot();
						lostGame = true;
					}
				}
				else // Move the bubble (or the space!) down
				{
					setData(col, row+1, bubble);
					if (bubble != null)
						bubble.reposition(col, row+1);
				}
			}
		}
	
		if (!emptyRow)
		{
			// Generate inital row
			for (col in 0...columns)
			{
				Bubble.CreateAt(col, 0, world.getNextColor(), world);
			}
		}
		else
		{
			for (col in 0...columns)
			{
				setData(col, 0, null);
			}
			
			topRow++;
		}
		
		if (lostGame)
		{
			world.handleLosing();
		}
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

		// trace("\n======= Begin from " + bubble.cellPosition + "# " + bubble.colorIndex + " =======");
		
		while (set.length > 0)
		{
			current = set.shift();

			processed.push(current);
			
			position = current.cellPosition;
			colorIndex = current.colorIndex;

			// trace(">>> Bubble@(" + position.x + ", " + position.y + "): " + colorIndex);
			
			adjacentPositions = getAdjacentPositions(position);
			
			for (adjPos in adjacentPositions)
			{
				neighbour = getData(adjPos.x, adjPos.y);
				var deltaX : Float = adjPos.x - position.x;
				var deltaY : Float = adjPos.y -  position.y;

				if (neighbour != null)
				{
					/*var msg : String = "At " + adjPos.x + ", " + adjPos.y + ": " + (neighbour == null ? "null" : "" + neighbour.colorIndex);*/

					if (neighbour.colorIndex == targetColorIndex)
					{
						// msg += " [Colour matches] ";
						
						if (bubbles.indexOf(neighbour) < 0)
						{
							// msg += "[Collected] ";
							bubbles.push(neighbour);
						}
						
						if (processed.indexOf(neighbour) < 0)
						{
							// msg += "[ToBeProc]";
							set.push(neighbour);
						}
					}
					
					// trace(msg);
				}
				/*else
					trace("Ignoring position (" + adjPos.x + ", " + adjPos.y + ")");*/
			}

			// trace("<<< - " + set);
			
			clearAdjacentPositions(adjacentPositions);
		}

		// trace("==============\n");
		
		return bubbles;
	}
	
	public function locateIsolatedBubbles() : Array<Bubble>
	{
		var isolated : Array<Bubble> = [];
		var safe : Array<Bubble> = [];
		
		// Temporary variables
		var current : Bubble;
		
		for (row in 0...rows)
		{
			for (col in 0...columns)
			{
				current = getData(col, row);
				if (current != null && !contains(safe, current) && !contains(isolated, current))
				{
					var connected : Array<Bubble> = getConnectedBubbles(current);
					connected.push(current);
					
					if (isGroupSafe(connected))
					{
						safe = safe.concat(connected);
					}
					else
					{
						isolated = isolated.concat(connected);
					}
				}
			}
		}
		
		return isolated;
	}
	
	function isGroupSafe(group : Array<Bubble>) : Bool
	{
		for (bubble in group)
		{
			if (bubble.isSafe() || bubble.cellPosition.y == topRow)
				return true;
		}
		
		return false;
	}
	
	public function getConnectedBubbles(bubble : Bubble, ?connected : Array<Bubble> = null) : Array<Bubble>
	{
		if (connected == null)
			connected = [];
	
		var tab : String = "";
		for (i in 0...connected.length)
			tab += " ";
	
		var position : FlxPoint = bubble.cellPosition;
		
		var adjacentPositions : Array<FlxPoint> = getAdjacentPositions(position);
		
		for (adjPos in adjacentPositions)
		{
			var neighbour : Bubble = getData(adjPos.x, adjPos.y);
			var deltaX : Float = adjPos.x - position.x;
			var deltaY : Float = adjPos.y -  position.y;

			if (neighbour != null && !contains(connected, neighbour))
			{
				connected.push(neighbour);
			
				getConnectedBubbles(neighbour, connected);
			}
		}
	
		return connected;
	}
	
	// Applies the provided method to every bubble (that complies with the provided filter)
	public function forEach(handler : Bubble -> Void, ?filter : Bubble -> Bool = null)
	{
		for (row in 0...rows)
		{
			for (col in 0...columns)
			{
				var bubble : Bubble = getData(col, row);
				
				if (bubble != null && 
					(filter == null || filter(bubble)))
				{
					handler(bubble);
				}
			}
		}
		
	}
	
	public function getNeighbours(bubble : Bubble) : Array<Bubble>
	{
		var neighbours : Array<Bubble> = [];
		
		var position : FlxPoint = bubble.cellPosition;
		var adjacentPositions : Array<FlxPoint> = getAdjacentPositions(position);
		
		for (adjPos in adjacentPositions)
		{
			var neighbour : Bubble = getData(adjPos.x, adjPos.y);
			if (neighbour != null)
				neighbours.push(neighbour);
		}
		
		return neighbours;
	}
	
	public function contains(list : Array<Bubble>, bubble : Bubble) : Bool
	{
		for (bub in list)
		{
			if (Bubble.compare(bubble.cellPosition, bub.cellPosition) && bubble.colorIndex == bub.colorIndex)
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function getAdjacentPositions(pos : FlxPoint) : Array<FlxPoint>
	{
		var x : Int = Std.int(pos.x);
		var y : Int = Std.int(pos.y);
		
		if (isPadded(y))
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
	
	public function switchPadding()
	{
		// Switches the padded row
		padded = (padded + 1) % 2;
	}
	
	public function isPadded(row : Int) : Bool
	{
		return padRow(row) == 1;
	}
	
	public function padRow(row : Int) : Int
	{
		return (row+padded) % 2;
	}
	
	public function getLeft() : Float
	{
		return bounds.left;
	}
	
	public function getRight() : Float
	{
		return bounds.right;
	}
	
	public function getTop() : Float
	{
		return bounds.y + topRow * cellSize;
	}
	
	public function printList(bubbles : Array<Bubble>) : String
	{
		var list : String = "";
		
		for (bubble in bubbles)
		{
			list += "(" + bubble.cellPosition.x + ", " + bubble.cellPosition.y + ")#" + bubble.colorIndex + ", ";
		}
		
		return list;
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