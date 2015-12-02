package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.group.FlxTypedGroup;

class PlayState extends FlxState
{
	public static var StateAiming : Int = 0;
	public static var StateWaiting : Int = 1;

	public var state : Int;

	public var bubbleColors : Array<Int>;
	public var bubbles : FlxTypedGroup<Bubble>;
	
	public var grid : BubbleGrid;
	public var cursor : PlayerCursor;
	public var bubble : Bubble;

	public function new()
	{
		super();
	}

	override public function create()
	{
		super.create();
		
		grid = new BubbleGrid(0, 0, FlxG.width, FlxG.height - 32, this);
		add(grid);
		
		bubbles = new FlxTypedGroup<Bubble>();
		add(bubbles);
		
		cursor = new PlayerCursor(FlxG.width / 2 - 16, FlxG.height - 32);
		add(cursor);
		
		bubbleColors = [0xFFFF3131, 0xFF31FF31];
		// bubbleColors = [0xFFFF5151, 0xFF51FF51, 0xFF5151FF, 0xFFFFFF51];
		
		generateBubble();
		state = StateAiming;
		
		handleDebugInit();
	}
	
	override public function update()
	{
		switch (state)
		{
			case PlayState.StateAiming:
				onAimingState();
			case PlayState.StateWaiting:
				onWaitingState();
		}
		
		handleDebugRoutines();
		
		super.update();
	}
	
	public function onAimingState()
	{
		if (FlxG.keys.justPressed.A)
		{
			// Play anim or whatever
			cursor.onShoot();
			
			var aimAngle : Float = cursor.aimAngle;
			
			bubble.x = cursor.x + cursor.aimOrigin.x - (bubble.width / 2);
			bubble.y = cursor.y + cursor.aimOrigin.y - (bubble.height / 2);
			
			bubble.shoot(aimAngle);
			
			state = StateWaiting;
		}
	}
	
	public function onWaitingState()
	{
	}
	
	public function onBubbleStop()
	{
		// Store bubble
		bubbles.add(bubble);
		
		// Check for group of three
		var condemned : Array<Bubble> = grid.locateBubbleGroup(bubble);

		if (condemned.length >= 3)
		{
			for (bub in condemned)
			{
				bub.triggerPop();
			}
			
			// If there was some destruction, check for disconnections
			var disconnected : Array<Bubble> = grid.locateIsolatedBubbles();
			for (bub in disconnected)
			{
				bub.triggerFall();
			}
		}
		
		// And generate a new one
		generateBubble();
		state = StateAiming;
	}
	
	public function generateBubble()
	{
		remove(bubble);
		bubble = null;
		
		var nextColor : Int = getNextColor();
		
		bubble = new Bubble(cursor.x + cursor.aimOrigin.x - 9, 
							cursor.y + cursor.aimOrigin.y - 9, this, nextColor);
		add(bubble);
	}
	
	public function getNextColor()
	{
		return FlxRandom.intRanged(0, bubbleColors.length-1);
	}
	
	var mouseCell : FlxPoint;
	var label : FlxText;
	
	public function handleDebugInit()
	{
		/*var debugBubble : Bubble = new Bubble(0, 0, this, 0xFFFFFFFF);
		debugBubble.state = Bubble.StateDebug;
		add(debugBubble);*/
		
		mouseCell = new FlxPoint();
		label = new FlxText(4, FlxG.height - 16);
		add(label);
		
		// Generate inital row
		for (col in 0...grid.columns)
		{
			Bubble.CreateAt(col, 0, getNextColor(), this);
		}
	}
	
	public function handleDebugRoutines()
	{
		var mouse : FlxPoint = FlxG.mouse.getWorldPosition();
		var cell = grid.getCellAt(mouse.x, mouse.y);
		
		if (FlxG.keys.justPressed.ONE || FlxG.keys.justPressed.TWO)
		{
			if (grid.getData(cell.x, cell.y) != null)
			{
				bubbles.remove(grid.getData(cell.x, cell.y));
				grid.getData(cell.x, cell.y).destroy();
				grid.setData(cell.x, cell.y, null);
			}
			else
			{
				Bubble.CreateAt(cell.x, cell.y, (FlxG.keys.justPressed.ONE ? 0 : 1), this);
			}
		}

		if (FlxG.mouse.justPressed && grid.bounds.containsFlxPoint(mouse))
		{
			var testBub : Bubble = grid.getData(cell.x, cell.y);
			/*if (testBub != null)
			{
				trace("("+testBub.cellPosition.x + ", " + testBub.cellPosition.y + ")=" + testBub.colorIndex);
				var group : Array<Bubble> = grid.locateBubbleGroup(testBub);
				if (group.length > 0)
				{
					trace("group: " + group.length);
					for (bub in group)
					{
						bub.alpha = 0.5;
					}
				}
			}*/
			
			if (testBub != null)
			{
				trace("("+testBub.cellPosition.x + ", " + testBub.cellPosition.y + ")=" + testBub.colorIndex);
				var group : Array<Bubble> = grid.getConnectedBubbles(testBub);
				if (group.length > 0)
				{
					trace("group: " + group.length);
					for (bub in group)
					{
						bub.alpha = 0.5;
					}
				}
			}
		}
		
		if (FlxG.keys.justPressed.D)
		{
			grid.dumpData();
		}
		
		mouseCell.set(cell.x, cell.y);
		label.text = "" + cell;
		FlxG.watch.addQuick("Cell", cell);
	}
}