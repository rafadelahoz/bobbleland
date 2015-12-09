package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;
import flixel.group.FlxTypedGroup;

class PlayState extends FlxState
{
	public static var ModeArcade : Int = 0;
	public static var ModePuzzle : Int = 1;

	public static var StateAiming : Int = 0;
	public static var StateWaiting : Int = 1;
	public static var StateRemoving : Int = 2;

	public static var WaitTime : Float = 1;
	
	public var mode : Int;
	
	public var state : Int;

	public var bubbleColors : Array<Int>;
	public var bubbles : FlxTypedGroup<Bubble>;
	
	public var grid : BubbleGrid;
	public var cursor : PlayerCursor;
	public var bubble : Bubble;
	
	public var dropDelay : Float;
	public var dropTimer : FlxTimer;
	public var waitTimer : FlxTimer;

	public function new(Mode : Int)
	{
		super();
		
		mode = Mode;
	}

	override public function create()
	{
		super.create();
		
		grid = new BubbleGrid(FlxG.width / 2 - 64, 16, 128, FlxG.height - 32, this);
		add(grid);
		
		bubbles = new FlxTypedGroup<Bubble>();
		add(bubbles);
		
		cursor = new PlayerCursor(FlxG.width / 2 - 16, FlxG.height - 32);
		add(cursor);
		
		// bubbleColors = [0xFFFF3131, 0xFF31FF31];
		bubbleColors = [0xFFFF5151, 0xFF51FF51, 0xFF5151FF, 0xFFFFFF51];
		
		dropDelay = 20;
		dropTimer = new FlxTimer(dropDelay, onDropTimer);
		waitTimer = new FlxTimer();
		
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
			case PlayState.StateRemoving:
				onRemovingState();
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
	
	public function onRemovingState()
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
				bub.triggerFall();
			}
			
			// If there was some destruction, check for disconnections
			var disconnected : Array<Bubble> = grid.locateIsolatedBubbles();
			for (bub in disconnected)
			{
				bub.triggerFall();
			}
			
			grid.forEach(function (bubble : Bubble) {
				bubble.onBubblesPopped();
			});
			
			// Things are happing, so wait!
			state = StateRemoving;
			waitTimer.start(WaitTime, function(_t:FlxTimer) {
				state = StateAiming;
			});
		}
		else
		{
			state = StateAiming;
		}
		
		// And generate a new one
		generateBubble();
	}
	
	public function onDropTimer(t : FlxTimer) : Void
	{
		if (state == StateRemoving)
		{
			// If there are bubbles being removed, wait a second!
			dropTimer.start(0.5, onDropTimer);
		}
		else
		{
			// Generate new bubble row, move all others down or something
			grid.generateBubbleRow(mode == ModePuzzle);
			
			// Set drop timer again
			dropTimer.start(dropDelay, onDropTimer);
		}
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
			// Create an anchor
			var anchor : Bubble = Bubble.CreateAt(cell.x, cell.y, -1, this);
			var adjacentCells : Array<FlxPoint> = grid.getAdjacentPositions(cell);
			for (pos in adjacentCells)
			{
				if (pos.x >= 0 && pos.y >= 0 && pos.x < grid.columns && pos.y < grid.rows)
				{
					var old : Bubble = grid.getData(pos.x, pos.y);
					if (old != null)
					{
						old.triggerPop();
					}
					
					Bubble.CreateAt(pos.x, pos.y, getNextColor(), this);
				}
			}
		}
		
		if (FlxG.keys.justPressed.UP)
		{
			dropDelay += 2;
		}
		else if (FlxG.keys.justPressed.DOWN)
		{
			dropDelay -= 2;
		}
		
		if (FlxG.keys.justPressed.D)
		{
			grid.dumpData();
		}
		
		mouseCell.set(cell.x, cell.y);
		label.text = "" + cell + " | " + dropDelay;
		FlxG.watch.addQuick("Cell", cell);
	}
}