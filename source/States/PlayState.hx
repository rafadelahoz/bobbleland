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
	public static var ModeArcade 	: Int = 0;
	public static var ModePuzzle 	: Int = 1;

	public static var StateAiming 	: Int = 0;
	public static var StateWaiting 	: Int = 1;
	public static var StateRemoving : Int = 2;
	public static var StateLosing 	: Int = 3;

	public static var WaitTime 		: Float = 1;
	public static var AimingTime 	: Float = 10;
	
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
	public var aimingTimer : FlxTimer;
	
	public var notifyAiming : Bool;
	
	public var scoreDisplay : ScoreDisplay;

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
		
		cursor = new PlayerCursor(FlxG.width / 2 - 16, FlxG.height - 32, this);
		add(cursor);
		
		// bubbleColors = [0xFFFF3131, 0xFF31FF31];
		bubbleColors = [0xFFFF5151, 0xFF51FF51, 0xFF5151FF, 0xFFFFFF51];
		
		dropDelay = 30;
		dropTimer = new FlxTimer(dropDelay, onDropTimer);
		waitTimer = new FlxTimer();
		aimingTimer = new FlxTimer();
		
		scoreDisplay = new ScoreDisplay(0, 0, mode);
		add(scoreDisplay);
		
		generateBubble();
		switchState(StateAiming);
		
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
			case PlayState.StateLosing:
				onLosingState();
		}		
		
		handleDebugRoutines();
		
		super.update();
	}
	
	/* State handling */
	
	public function switchState(State : Int)
	{
		if (state == StateLosing)
			return;
	
		state = State;
		
		switch (state)
		{
			case PlayState.StateAiming:
				aimingTimer.start(AimingTime, onForcedShot);
			
			case PlayState.StateLosing:
				
				// Prepare for losing
				
				// Cancel timers
				dropTimer.cancel();
				waitTimer.cancel();
				aimingTimer.cancel();
				
				// Disable cursor
				cursor.disable();
				
			default:
				aimingTimer.cancel();
		}
	}
	
	function onAimingState()
	{
		scoreDisplay.active = true;
	
		if (!notifyAiming && aimingTimer.timeLeft < AimingTime / 2)
		{
			notifyAiming = true;
			trace("HURRY UP!");
		}
	
		if (FlxG.keys.justPressed.A)
		{
			scoreDisplay.add(Constants.ScBubbleShot);
		
			shoot();
		}
	}
	
	function onWaitingState()
	{
		scoreDisplay.active = false;
	}
	
	function onRemovingState()
	{
	}
	
	function onLosingState()
	{
		scoreDisplay.active = true;
		
		if (bubbles.countLiving() <= 0)
		{
			GameController.GameOver(mode, scoreDisplay.score);
		}
	}
	
	/* Private methods */
	
	// Handler for the forced shot timer
	function onForcedShot(_t:FlxTimer)
	{
		if (state == StateAiming)
		{
			shoot();
		}
	}
	
	// Shoot function: sets the current bubble in motion and changes to wait state
	function shoot()
	{
		// Play anim or whatever
		cursor.onShoot();
		
		var aimAngle : Float = cursor.aimAngle;
		
		bubble.x = cursor.x + cursor.aimOrigin.x - (bubble.width / 2);
		bubble.y = cursor.y + cursor.aimOrigin.y - (bubble.height / 2);
		
		bubble.shoot(aimAngle);
		
		switchState(StateWaiting);
		
		notifyAiming = false;
	}
	
	// Handler for the drop more bubbles timer
	function onDropTimer(t : FlxTimer) : Void
	{
		if (state == StateLosing)
		{
			// Do nothing and stop already
		}
		else if (state == StateRemoving)
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
	
	// Generates a new shootable bubble
	function generateBubble()
	{
		remove(bubble);
		bubble = null;
		
		var nextColor : Int = getNextColor();
		
		bubble = new Bubble(cursor.x + cursor.aimOrigin.x - grid.cellSize / 2, 
							cursor.y + cursor.aimOrigin.y - grid.cellSize / 2, this, nextColor);
		add(bubble);
	}
	
	/* Public API for others */
	
	// Handler for when losing happens :(
	public function handleLosing()
	{
		switchState(StateLosing);
		
		grid.forEach(function (bubble : Bubble) {
			bubble.triggerRot();
		});
	}
	
	// Handler for bubble stopped event (triggered from Bubble)
	public function handleBubbleStop()
	{	
		// Store bubble
		bubbles.add(bubble);
		
		// Check for group of three
		var condemned : Array<Bubble> = grid.locateBubbleGroup(bubble);

		if (condemned.length >= 3)
		{
			for (bub in condemned)
			{
				scoreDisplay.add(bub.getPopPoints());
				bub.triggerFall();
			}
			
			// If there was some destruction, check for disconnections
			var disconnected : Array<Bubble> = grid.locateIsolatedBubbles();
			for (bub in disconnected)
			{
				scoreDisplay.add(bub.getFallPoints());
				bub.triggerFall();
			}
			
			grid.forEach(function (bubble : Bubble) {
				bubble.onBubblesPopped();
			});

			// Check whether the field is empty to award bonuses
			if (grid.getCount() == 0)
			{
				scoreDisplay.add(Constants.ScClearField);
			}

			// Things are happing, so wait!
			switchState(StateRemoving);
			waitTimer.start(WaitTime, function(_t:FlxTimer) {
				scoreDisplay.active = true;
				switchState(StateAiming);
			});
		}
		else
		{
			switchState(StateAiming);
		}
		
		// And generate a new one
		generateBubble();
	}
	
	/* Returns a random color index for a bubble */
	public function getRandomColor() : Int
	{
		return FlxRandom.intRanged(0, bubbleColors.length - 1);	
	}

	/* Returns an appropriate color index for a bubble */
	public function getNextColor() : Int
	{
		var usedColors : Array<Int> = grid.getUsedColors();
		
		if (usedColors.length <= 0)
		{
			return getRandomColor();
		}

		return FlxRandom.getObject(usedColors);
	}

	/* Debug things */
	
	var mouseCell : FlxPoint;
	var label : FlxText;
	
	function handleDebugInit()
	{
		mouseCell = new FlxPoint();
		label = new FlxText(4, FlxG.height - 16);
		add(label);
		
		// Generate inital row
		for (row in 0...5)
		{
			for (col in 0...grid.columns)
			{
				Bubble.CreateAt(col, row, getRandomColor(), this);
			}
		}
	}
	
	function handleDebugRoutines()
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
					
					Bubble.CreateAt(pos.x, pos.y, getRandomColor(), this);
				}
			}
		}
		
		if (FlxG.keys.justPressed.UP)
		{
			dropDelay += 1;
		}
		else if (FlxG.keys.justPressed.DOWN)
		{
			dropDelay -= 1;
		}
		
		if (FlxG.keys.justPressed.D)
		{
			grid.dumpData();
		}
		
		mouseCell.set(cell.x, cell.y);
		// label.text = "" + cell + " | " + dropDelay;
		label.text = grid.getUsedColors().toString();
		FlxG.watch.addQuick("Cell", cell);
	}
}