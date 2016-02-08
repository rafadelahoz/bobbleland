package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxSort;
import flixel.text.FlxText;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;
import flixel.group.FlxTypedGroup;

import database.BackgroundDatabase;

class PlayState extends FlxState
{
	public static var ModeArcade 	: Int = 0;
	public static var ModePuzzle 	: Int = 1;

	public static var StateAiming 	: Int = 0;
	public static var StateWaiting 	: Int = 1;
	public static var StateRemoving : Int = 2;
	public static var StateLosing 	: Int = 3;
	public static var StateWinning	: Int = 4;

	public static var WaitTime 		: Float = 1;
	public static var AimingTime 	: Float = 10;

	public var mode : Int;
	public var puzzleName : String;
	public var puzzleData : puzzle.PuzzleData;

	public var state : Int;

	public var availableColors : Array<BubbleColor>;
	public var bubbles : FlxTypedGroup<Bubble>;
	public var fallingBubbles : FlxTypedGroup<Bubble>;

	public var generator : BubbleGenerator;
	public var grid : BubbleGrid;
	public var cursor : PlayerCursor;
	public var bubble : Bubble;

	public var screenButtons : ScreenButtons;

	public var background : FlxSprite;
	public var baseDecoration : FlxSprite;
	public var character : PlayerCharacter;
	public var lever : Lever;
	public var shadow : FlxSprite;
	public var bottomBar : FlxSprite;
	public var ceiling : Ceiling;
	public var overlay : FlxSprite;

	public var dropDelay : Float;
	public var dropTimer : FlxTimer;
	public var waitTimer : FlxTimer;
	public var aimingTimer : FlxTimer;

	public var notifyAiming : Bool;

	public var scoreDisplay : ScoreDisplay;

	public function new(Mode : Int, PuzzleName : String)
	{
		super();

		mode = Mode;
		puzzleName = PuzzleName;

		parsePuzzle(puzzleName);
	}

	override public function create()
	{
		super.create();

		GamePad.init();

		prepareBackground();

		prepareBaseDecoration();

		shadow = new FlxSprite(FlxG.width / 2 - 64, 16).makeGraphic(128, 240-48, 0xFF000000);
		shadow.alpha = 0.68;
		add(shadow);

		grid = new BubbleGrid(FlxG.width / 2 - 64, 16, 128, 240 - 32, this);
		add(grid);

		ceiling = new Ceiling(this);
		add(ceiling);

		overlay = new FlxSprite(0, 0, "assets/images/play-overlay.png");
		add(overlay);

		bubbles = new FlxTypedGroup<Bubble>();
		add(bubbles);

		var bottomBarPosition : FlxPoint = grid.getBottomBarPosition();
		bottomBar = new FlxSprite(bottomBarPosition.x, bottomBarPosition.y).loadGraphic("assets/images/red-bar.png");
		add(bottomBar);

		fallingBubbles = new FlxTypedGroup<Bubble>();
		add(fallingBubbles);

		cursor = new PlayerCursor(FlxG.width / 2 - 10, 240 - 40, this);
		add(cursor);

		availableColors = puzzleData.usedColors;

		dropDelay = 30;
		dropTimer = new FlxTimer(dropDelay, onDropTimer);
		waitTimer = new FlxTimer();
		aimingTimer = new FlxTimer();

		scoreDisplay = new ScoreDisplay(2, 2, mode);
		add(scoreDisplay);

		generator = new BubbleGenerator(this);
		generator.initalizeGrid();

		generateBubble();
		switchState(StateAiming);

		screenButtons = new ScreenButtons(0, 240, this);
		add(screenButtons);

		handleDebugInit();
	}

	override public function update()
	{
		GamePad.handlePadState();

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
			case PlayState.StateWinning:
				onWinningState();
		}

		handleDebugRoutines();

		super.update();
	}

	/* State handling */

	public function switchState(State : Int)
	{
		if (state == StateLosing || state == StateWinning)
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
				
			case PlayState.StateWinning:
				// Prepare for winning

				// Cancel timers
				dropTimer.cancel();
				waitTimer.cancel();
				aimingTimer.cancel();

				// Disable cursor
				cursor.disable();
				
				add(new FlxText(FlxG.width/2 - 32, grid.y + grid.height/2, "Clear!", 16));

				FlxG.camera.fade(0xFF000000, 3, onGameplayEnd);

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

		if (GamePad.justPressed(GamePad.Shoot))
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

		if (bubbles.countLiving() <= 0 && fallingBubbles.countLiving() <= 0)
		{
			GameController.GameOver(mode, scoreDisplay.score);
		}
	}
	
	function onWinningState()
	{
		
	}
	
	function onGameplayEnd() 
	{
		if (mode == ModeArcade)
			GameController.OnGameplayEnd();
		else if (mode == ModePuzzle)
			GameController.OnPuzzleCompleted();
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
			generator.generateRow();

			// Set drop timer again
			dropTimer.start(dropDelay, onDropTimer);
		}
	}

	// Generates a new shootable bubble
	function generateBubble()
	{
		remove(bubble);
		bubble = null;

		var nextColor : BubbleColor = generator.getNextBubbleColor();

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
			bubbles.remove(bubble);
			fallingBubbles.add(bubble);
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
				bubbles.remove(bub);
				fallingBubbles.add(bub);
			}

			// If there was some destruction, check for disconnections
			var disconnected : Array<Bubble> = grid.locateIsolatedBubbles();
			for (bub in disconnected)
			{
				scoreDisplay.add(bub.getFallPoints());
				bub.triggerFall();
				bubbles.remove(bub);
				fallingBubbles.add(bub);
			}

			grid.forEach(function (bubble : Bubble) {
				bubble.onBubblesPopped();
			});

			// Check whether the field is empty to award bonuses
			if (grid.getCount() == 0 && mode == ModeArcade)
			{
				scoreDisplay.add(Constants.ScClearField);
			}

			// Things are happing, so wait!
			switchState(StateRemoving);
			waitTimer.start(WaitTime, function(_t:FlxTimer) {
				if (puzzleData.mode == puzzle.PuzzleData.ModeClear && 
					grid.getCount() == 0)
				{
					switchState(StateWinning);
				}
				else
				{
					scoreDisplay.active = true;
					switchState(StateAiming);
				}
			});
		}
		else
		{
			switchState(StateAiming);
		}

		// And generate a new one
		generateBubble();
	}

	public function parsePuzzle(puzzleName : String)
	{
		if (mode == ModePuzzle)
		{
			var parser : puzzle.PuzzleParser = new puzzle.PuzzleParser(puzzleName);
			puzzleData = parser.parse();
		}
		else
		{
			puzzleData = new puzzle.PuzzleData();
			puzzleData.mode = puzzle.PuzzleData.ModeEndless;
			puzzleData.background = null;
			puzzleData.bubbleSet = null;
			puzzleData.initialRows = 5;
			puzzleData.usedColors = [];
			for (i in 0...5)
			{
				puzzleData.usedColors.push(new BubbleColor(i));
			}
			puzzleData.seconds = -1;
		}
	}

	function prepareBackground()
	{
		var bg : String = null;

		#if !work
		if (puzzleData == null || puzzleData.background == null)
			bg = "assets/backgrounds/" + (FlxRandom.chanceRoll(50) ? "bg0.png" : "bg1.png");
		else
			bg = BackgroundDatabase.GetBackground(puzzleData.background);
		#end

		background = new FlxSprite(0, 0, bg);
		add(background);
	}

	function prepareBaseDecoration()
	{
		#if work
		#else
		baseDecoration = new FlxSprite(FlxG.width / 2 - 64, 181).loadGraphic("assets/images/base-decoration.png", true, 128, 60);
		// baseDecoration.animation.add("idle", [0]);
		baseDecoration.animation.add("move", [0, 1], 10, true);
		baseDecoration.animation.play("move");
		baseDecoration.animation.paused = true;
		add(baseDecoration);

		character = new PlayerCharacter(baseDecoration.x + 24, baseDecoration.y + 32, this);
		add(character);

		lever = new Lever(baseDecoration.x + 24, baseDecoration.y + 40, this);
		add(lever);
		#end
	}

	/* Debug things */

	var mouseCell : FlxPoint;
	var label : FlxText;

	function handleDebugInit()
	{
		mouseCell = new FlxPoint();
		label = new FlxText(4, FlxG.height - 16);
		add(label);
	}

	function handleDebugRoutines()
	{
		var mouse : FlxPoint = FlxG.mouse.getWorldPosition();
		var cell = grid.getCellAt(mouse.x, mouse.y);

		/*if (FlxG.keys.justPressed.ONE || FlxG.keys.justPressed.TWO)
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
		}*/

		/*if (FlxG.mouse.justPressed && grid.bounds.containsFlxPoint(mouse))
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
		}*/

		if (FlxG.keys.justPressed.DOWN)
		{
			generator.generateRow();
		}

		if (FlxG.keys.justPressed.D)
		{
			grid.dumpData();
		}

		mouseCell.set(cell.x, cell.y);
		// label.text = "" + cell + " | " + dropDelay;
		// label.text = grid.getUsedColors().toString();
		FlxG.watch.addQuick("Cell", cell);
	}
}
