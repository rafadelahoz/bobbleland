package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxSort;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;

import database.BackgroundDatabase;

class PlayState extends FlxTransitionableState
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
	public var cursorBubbles : FlxTypedGroup<Bubble>;
	public var bubble : Bubble;
	public var nextBubble : Bubble;

	public var screenButtons : ScreenButtons;

	public var background : FlxSprite;
	public var baseDecoration : FlxSprite;
	public var character : PlayerCharacter;
	public var lever : Lever;
	public var shadow : FlxSprite;
	public var bottomBar : FlxSprite;
	public var ceiling : Ceiling;
	public var overlay : FlxSprite;
	public var timeDisplay : ScreenTimer;

	public var dropDelay : Float;
	public var dropTimer : FlxTimer;
	public var waitTimer : FlxTimer;
	public var aimingTimer : FlxTimer;

	public var notifyAiming : Bool;

	public var scoreDisplay : ScoreDisplay;

	public var flowController : PlayFlowController;

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

		shadow = new FlxSprite(FlxG.width / 2 - 64, 16).makeGraphic(128, 240-48, 0xFF000000);
		shadow.alpha = 0.68;
		add(shadow);

		grid = new BubbleGrid(FlxG.width / 2 - 64, 16, 128, 240 - 32, this);
		add(grid);

		ceiling = new Ceiling(this);
		add(ceiling);

		overlay = new FlxSprite(0, 0, "assets/images/play-overlay.png");
		add(overlay);

		prepareBaseDecoration();

		bubbles = new FlxTypedGroup<Bubble>();
		add(bubbles);

		var bottomBarPosition : FlxPoint = grid.getBottomBarPosition();
		bottomBar = new FlxSprite(bottomBarPosition.x, bottomBarPosition.y - 1).loadGraphic("assets/images/red-bar.png");
		add(bottomBar);

		cursor = new PlayerCursor(FlxG.width / 2 - 10, 240 - 40, this);
		add(cursor);

		cursorBubbles = new FlxTypedGroup<Bubble>();
		add(cursorBubbles);

		fallingBubbles = new FlxTypedGroup<Bubble>();
		add(fallingBubbles);

		availableColors = puzzleData.usedColors;

		if (puzzleData.dropDelay > 0)
			dropDelay = puzzleData.dropDelay;
		else
			dropDelay = 30;
		dropTimer = new FlxTimer().start(dropDelay, onDropTimer);
		waitTimer = new FlxTimer();
		aimingTimer = new FlxTimer();

		scoreDisplay = new ScoreDisplay(2, 1, mode);
		add(scoreDisplay);

		if (puzzleData.mode == puzzle.PuzzleData.ModeHold)
		{
			timeDisplay = new ScreenTimer(112, 0, puzzleData.seconds, onTimeOver);
			add(timeDisplay);
			// trace("Added timer");
		}

		generator = new BubbleGenerator(this);


		// trace("Grid initialized");

		flowController = new PlayFlowController(this);



		// trace("First bubbles");

		screenButtons = new ScreenButtons(0, 0, this, 240);
		add(screenButtons);

		// trace("Buttons initialized");

		handleDebugInit();
	}

	override public function finishTransIn()
	{
		generator.initalizeGrid();
		generateBubble();
		switchState(StateAiming);
		super.finishTransIn();
	}

	override public function update(elapsed:Float)
	{
		GamePad.handlePadState();

		if (state != PlayState.StateLosing)
		{
			if (GamePad.justReleased(GamePad.Pause))
			{
				onPauseStart();
				openSubState(new PauseSubstate(this, onPauseEnd));
			}
		}

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

		super.update(elapsed);
	}

	function onPauseStart()
	{
		dropTimer.active = false;
		waitTimer.active = false;
		aimingTimer.active = false;

		flowController.pause();
	}

	function onPauseEnd()
	{
		dropTimer.active = true;
		waitTimer.active = true;
		aimingTimer.active = true;

		flowController.resume();
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
				// Compute a flow controller play step
				flowController.onPlayStep();

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

				var clearMessage : PuzzleClear = new PuzzleClear(FlxG.width/2, 0);
				add(clearMessage);
				clearMessage.init(function() {
					new FlxTimer().start(1.5, function(_t:FlxTimer){
						FlxG.camera.fade(0xFF000000, 1.5, onGameplayEnd);
					});
				});

			default:
				aimingTimer.cancel();
		}
	}

	function onAimingState()
	{
		if (!notifyAiming && aimingTimer.timeLeft < AimingTime / 2)
		{
			notifyAiming = true;
		}

		if (GamePad.justPressed(GamePad.Shoot))
		{
			scoreDisplay.add(Constants.ScBubbleShot);

			shoot();
		}
	}

	function onWaitingState()
	{
	}

	function onRemovingState()
	{
	}

	function onLosingState()
	{
		if (bubbles.countLiving() <= 0 && fallingBubbles.countLiving() <= 0)
		{
			GameController.GameOver(mode, flowController.getStoredData());
		}
	}

	function onWinningState()
	{

	}

	function onGameplayEnd()
	{
		if (mode == ModeArcade)
			GameController.OnGameplayEnd();
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
		else if (state == StateRemoving || state == StateWaiting)
		{
			// If there are bubbles being removed, wait a second!
			dropTimer.start(0.5, onDropTimer);
		}
		else
		{
			// Generate new bubble row, move all others down or something
			generateRow();

			// Set drop timer again
			dropTimer.start(dropDelay, onDropTimer);
		}
	}

	function generateRow()
	{
		generator.generateRow();

		flowController.onRowGenerated();
	}

	// Generates a new shootable bubble
	function generateBubble()
	{
		cursorBubbles.remove(bubble);
		bubble = null;

		if (nextBubble == null)
		{
			generateNextBubble();
		}

		bubble = nextBubble;
		FlxTween.tween(bubble, {
				x: cursor.x + cursor.aimOrigin.x - grid.cellSize / 2,
				y: cursor.y + cursor.aimOrigin.y - grid.cellSize / 2
			}, 0.1, {});

		generateNextBubble();
	}

	function generateNextBubble()
	{
		var nextColor : BubbleColor = generator.getNextBubbleColor();

		nextBubble = new Bubble(cursor.x + cursor.aimOrigin.x - grid.cellSize / 2 + 20,
							cursor.y + cursor.aimOrigin.y - grid.cellSize / 2 + 8, this, nextColor);
		nextBubble.scale.x = 0;
		nextBubble.scale.y = 0;
		FlxTween.tween(nextBubble.scale, {x : 1, y : 1}, 0.3, {startDelay : 0.05, ease: FlxEase.elasticOut});
		cursorBubbles.add(nextBubble);
	}

	/* Public API for others */

	// Handler for when losing happens :(
	public function handleLosing()
	{
		if (state == StateWaiting)
		{
			// There is a flying bubble
			bubble.triggerRot();
		}

		switchState(StateLosing);

		grid.forEach(function (bubble : Bubble) {
			bubble.triggerRot();
			bubbles.remove(bubble);
			fallingBubbles.add(bubble);
		});
	}

	// Handler for bubble stopped event (triggered from Bubble)
	public function handleBubbleStop(?mayHaveLost : Bool = false)
	{
		// Store bubble
		bubbles.add(bubble);

		// Check for group of three
		var condemned : Array<Bubble> = grid.locateBubbleGroup(bubble);

		// If we have not achieved the group of three
		if (condemned.length < 3)
		{
			// And the bubble was bellow the line
			if (mayHaveLost)
			{
				// We have lost :(
				bubble.triggerRot();
				handleLosing();
			}
			// Otherwise just continue
			else
			{
				switchState(StateAiming);
			}
		}
		// Else if we have achieved the group
		else
		{
			// Start making things fall
			for (bub in condemned)
			{
				scoreDisplay.add(bub.getPopPoints());
				bub.triggerFall();
				bubbles.remove(bub);
				fallingBubbles.add(bub);

				flowController.onBubbleDestroyed();
			}

			// If there was some destruction, check for disconnections
			var disconnected : Array<Bubble> = grid.locateIsolatedBubbles();
			for (bub in disconnected)
			{
				scoreDisplay.add(bub.getFallPoints());
				bub.triggerFall();
				bubbles.remove(bub);
				fallingBubbles.add(bub);

				flowController.onBubbleDestroyed();
			}

			grid.forEach(function (bubble : Bubble) {
				bubble.onBubblesPopped();
			});

			// Things are happing, so wait!
			switchState(StateRemoving);
			waitTimer.start(WaitTime, function(_t:FlxTimer) {
				afterRemoving();
			});
		}

		// And generate a new one
		generateBubble();
	}

	public function afterRemoving()
	{
		if (puzzleData.mode == puzzle.PuzzleData.ModeClear &&
			grid.getCount() == 0)
		{
			handlePuzzleCompleted();
		}
		// Check whether the field is empty to award bonuses
		else if (mode == ModeArcade && grid.getCount() == 0)
		{
			flowController.onScreenCleared();

			scoreDisplay.add(Constants.ScClearField);
			var congratsSign : ArcadeClear = new ArcadeClear(FlxG.width/2, 0);
			add(congratsSign);
			congratsSign.init(function() {

				// Exit after appearing
				congratsSign.exit(function() {
					// Destroying yourself in the process
					congratsSign.destroy();
				});

				dropTimer.cancel();

				// Generate a row while exiting
				generateRow();
				// Generate a row after a while
				new FlxTimer().start(0.7, function(_t:FlxTimer) {
					generateRow();
				});
				// Generate another row after a while more
				new FlxTimer().start(1.4, function(_t:FlxTimer) {
					generateRow();
					// And resume playing
					switchState(StateAiming);

					dropTimer.start(dropDelay, onDropTimer);
				});
			});
		}
		else
		{
			switchState(StateAiming);
		}
	}

	public function onTargetBubbleHit()
	{
		handlePuzzleCompleted();
	}

	function onTimeOver()
	{
		handlePuzzleCompleted();
	}

	function handlePuzzleCompleted()
	{
		// Pause bubbles moving here or something!

		switchState(StateWinning);
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
			puzzleData = ArcadeGameStatus.getData();
		}
	}

	function prepareBackground()
	{
		background = BackgroundDatabase.BuildRandomBackground();
		add(background);
	}

	function prepareBaseDecoration()
	{
		baseDecoration = new FlxSprite(FlxG.width / 2 - 64, 181);
		baseDecoration.loadGraphic("assets/images/base-decoration.png",
									true, 128, 60);
		baseDecoration.animation.add("move", [0, 1], 10, true);
		baseDecoration.animation.play("move");
		baseDecoration.animation.paused = true;
		add(baseDecoration);

		var characterId : String = puzzleData.character;
		character = new PlayerCharacter(baseDecoration.x + 16,
										baseDecoration.y + 24,
										this, characterId);
		add(character);
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
			generateRow();
		}

		if (FlxG.keys.justPressed.W)
		{
			handlePuzzleCompleted();
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
