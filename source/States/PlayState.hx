package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup;
import flixel.addons.transition.FlxTransitionableState;

import database.BackgroundDatabase;

class PlayState extends FlxTransitionableState
{
	public static inline var ModeArcade 	: Int = 0;
	public static inline var ModePuzzle 	: Int = 1;

	public static inline var StateStarting : Int = -1;
	public static inline var StateAiming 	: Int = 0;
	public static inline var StateWaiting 	: Int = 1;
	public static inline var StateRemoving : Int = 2;
	public static inline var StateLosing 	: Int = 3;
	public static inline var StateWinning	: Int = 4;

	public static var WaitTime 		: Float = 1;
	public static var AimingTime 	: Float = 10;

	public static var RowDropNotifyTime : Int = 2;

	public var DEBUG_dropDisabled : Bool;

	public var mode : Int;
	public var playSessionData : PlaySessionData;

	public var state : Int;
	public var paused : Bool;

	var afterCleanRowsLeft : Int;
	var afterCleanTimer : FlxTimer;

	public var availableColors : Array<BubbleColor>;
	public var bubbles : FlxTypedGroup<Bubble>;
	public var presents : FlxTypedGroup<Bubble>;
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
	public var dropNoticeTimer : FlxTimer;
	public var waitTimer : FlxTimer;
	public var aimingTimer : FlxTimer;

	public var notifyAiming : Bool;
	public var notifyDrop : Bool;
	public var wasNotifyingDrop : Bool;

	public var scoreDisplay : ScoreDisplay;

	public var flowController : PlayFlowController;
	public var specialBubbleController : SpecialBubbleController;

	public var saveData : Dynamic;

	public function new(Mode : Int, ?SaveData : Dynamic = null)
	{
		super();

		mode = Mode;
		saveData = SaveData;
		if (saveData != null && saveData.session != null)
		{
			trace("Using saved session data");
			trace(saveData.session);
			trace("Colors", saveData.session.usedColors.length);
			playSessionData = saveData.session;
		}
		else
		{
			playSessionData = ArcadeGameStatus.getData();
		}
	}

	override public function create()
	{
		super.create();

		GamePad.init();
		prepareRandomizedSessionData();

		prepareBackground();

		// Init available colors to those available in playSessionData
		// Avoid sharing the same object, though!
		availableColors = [];
		for (color in playSessionData.usedColors)
		{
			availableColors.push(color);
		}

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

		presents = new FlxTypedGroup<Bubble>();
		add(presents);

		var bottomBarPosition : FlxPoint = grid.getBottomBarPosition();
		bottomBar = new FlxSprite(bottomBarPosition.x, bottomBarPosition.y - 1).loadGraphic("assets/images/red-bar.png");
		add(bottomBar);

		cursor = new PlayerCursor(FlxG.width / 2 - 10, 240 - 40, this);
		add(cursor);

		if (playSessionData.guideEnabled)
			cursor.enableGuide();

		notifyAiming = false;
		notifyDrop = false;
		state = StateStarting;

		cursorBubbles = new FlxTypedGroup<Bubble>();
		add(cursorBubbles);

		fallingBubbles = new FlxTypedGroup<Bubble>();
		add(fallingBubbles);

		dropTimer = new FlxTimer();
		dropNoticeTimer = new FlxTimer();
		waitTimer = new FlxTimer();
		aimingTimer = new FlxTimer();

		scoreDisplay = new ScoreDisplay(2, 1, mode, (saveData != null ? saveData.flow.score : 0));
		add(scoreDisplay);

		if (playSessionData.mode == PlaySessionData.ModeHold)
		{
			timeDisplay = new ScreenTimer(112, 0, playSessionData.seconds, onTimeOver);
			add(timeDisplay);
		}

		generator = new BubbleGenerator(this);

		flowController = new PlayFlowController(this, (saveData != null ? saveData.flow : null));
		specialBubbleController = new SpecialBubbleController(this, (saveData != null ? saveData.special : null));

		screenButtons = new ScreenButtons(0, 0, this, 240);
		add(screenButtons);

		handleBgm();

		paused = false;

		afterCleanRowsLeft = 0;
		afterCleanTimer = new FlxTimer();

		handleDebugInit();
	}

	function prepareRandomizedSessionData()
	{
		if (playSessionData.character == null)
		{
			playSessionData.character = getRandomCharacterId();
		}
	}

	function getRandomCharacterId() : String
	{
		var chars = ["pug", "cat", "crab"];
	    return FlxG.random.getObject(chars);
	}

	function handleBgm()
	{
		if (playSessionData.bgm != null)
			BgmEngine.play(BgmEngine.getBgm(playSessionData.bgm));
		else
			BgmEngine.stopCurrent();
	}

	override public function finishTransIn()
	{
		if (playSessionData.dropDelay > 0)
			dropDelay = playSessionData.dropDelay;
		else
			dropDelay = 30;
		startDropTimer(dropDelay);

		generator.initalizeGrid((saveData != null ? saveData.grid : null));
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

		bubbles.sort(sortBubbles);

		super.update(elapsed);
	}

	function sortBubbles(Order : Int, one : Bubble, two : Bubble) : Int
	{
		if (one == null)
			return -1;
		else if (two == null)
			return 1;
		else
		{
			if (one.special != BubbleColor.SpecialNone && two.special != BubbleColor.SpecialNone)
				return 0;
			else if (one.special != BubbleColor.SpecialNone)
				return 1;
			else if (two.special != BubbleColor.SpecialNone)
				return -1;
			else
				return 0;
		}

		return 0;
	}

	override public function draw()
	{
		super.draw();
	}

	function onPauseStart()
	{
		paused = true;

		BgmEngine.pauseCurrent();

		dropTimer.active = false;
		dropNoticeTimer.active = false;
		waitTimer.active = false;
		aimingTimer.active = false;

		wasNotifyingDrop = notifyDrop;
		notifyDrop = false;

		if (wasNotifyingDrop)
		{
			stopDropNotice();
		}

		flowController.pause();
		specialBubbleController.pause();
	}

	function onPauseEnd()
	{
		paused = false;

		BgmEngine.resumeCurrent();

		dropTimer.active = true;
		dropNoticeTimer.active = true;
		waitTimer.active = true;
		aimingTimer.active = true;

		notifyDrop = wasNotifyingDrop;
		wasNotifyingDrop = false;
		if (notifyDrop)
		{
			beginDropNotice(null);
		}

		flowController.resume();
		specialBubbleController.resume();
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
				specialBubbleController.onPlayStep();

				aimingTimer.start(AimingTime, onForcedShot);

				dropTimer.active = true;
				dropNoticeTimer.active = true;

			case PlayState.StateWaiting:
				dropTimer.active = false;
				dropNoticeTimer.active = false;

			case PlayState.StateLosing:
				// Prepare for losing

				// Cancel timers
				dropTimer.cancel();
				waitTimer.cancel();
				aimingTimer.cancel();

				// Disable cursor
				cursor.disable();

				// Disable drop notice
				stopDropNotice();

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
						FlxG.camera.fade(0xFF000000, 1.5, true, onGameplayEnd);
					});
				});

			default:
				aimingTimer.cancel();
		}
	}

	function onAimingState()
	{
		if (!DEBUG_dropDisabled)
		{
			if (!notifyAiming && aimingTimer.timeLeft < AimingTime / 2)
			{
				notifyAiming = true;
			}
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
		if (bubbles.countLiving() <= 0 && fallingBubbles.countLiving() <= 0 && presents.countLiving() <= 0)
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
		if (DEBUG_dropDisabled)
			return;

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
		stopDropNotice();

		if (state == StateLosing)
		{
			// Do nothing and stop already
		}
		else if (state == StateRemoving || state == StateWaiting)
		{
			// If there are bubbles being removed, wait a second!
			startDropTimer(0.5);
		}
		else
		{
			// Generate new bubble row, move all others down or something
			if (!DEBUG_dropDisabled)
				generateRow();

			// Set drop timer again
			startDropTimer(dropDelay);
		}
	}

	function generateRow(?allowPresents : Bool = true)
	{
		SfxEngine.play(SfxEngine.SFX.RowGeneration);
		generator.generateRow(allowPresents);
		flowController.onRowGenerated();
		specialBubbleController.onRowGenerated();
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
		var nextColor : BubbleColor = generator.getPositiveColor();

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
		SfxEngine.play(SfxEngine.SFX.Lost);
		BgmEngine.stopCurrent();

		if (state == StateWaiting)
		{
			// There is a flying bubble
			bubble.triggerRot();
		}

		switchState(StateLosing);

		grid.forEach(function (bubble : Bubble) {
			bubble.triggerRot();
			bubbles.remove(bubble);
			presents.remove(bubble);
			fallingBubbles.add(bubble);
		});
	}

	// Handler for bubble stopped event (triggered from Bubble)
	public function handleBubbleStop(?mayHaveLost : Bool = false)
	{
		SfxEngine.play(SfxEngine.SFX.BubbleStop);

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
			SfxEngine.play(SfxEngine.SFX.NiceSmall);

			// Start making things fall
			for (bub in condemned)
			{
				scoreDisplay.add(bub.getPopPoints());
				bub.triggerFall();
				bubbles.remove(bub);
				presents.remove(bub);
				fallingBubbles.add(bub);

				flowController.onBubbleDestroyed();
				specialBubbleController.onBubbleDestroyed();
			}

			// If there was some destruction, check for disconnections
			var disconnected : Array<Bubble> = handleDisconnectedBubbles();

			if (condemned.length + disconnected.length > 5)
			{
				SfxEngine.play(SfxEngine.SFX.NiceBig);
			}

			handlePostShoot();
		}

		// And generate a new one
		generateBubble();
	}

	public function handleDisconnectedBubbles() : Array<Bubble>
	{
		var disconnected : Array<Bubble> = grid.locateIsolatedBubbles();
		for (bub in disconnected)
		{
			scoreDisplay.add(bub.getFallPoints());
			bub.triggerFall();
			bubbles.remove(bub);
			presents.remove(bub);
			fallingBubbles.add(bub);

			flowController.onBubbleDestroyed();
			specialBubbleController.onBubbleDestroyed();
		}

		return disconnected;
	}

	public function handlePostShoot()
	{
		grid.forEach(function (bubble : Bubble) {
			bubble.onBubblesPopped();
		});

		// Things are happing, so wait!
		switchState(StateRemoving);

		if (grid.getCount() <= 0)
		{
			// If the grid has been cleaned
			// Four rows are to be generated
			// This is declared here
			// 			to avoid problems on deactivation
			afterCleanRowsLeft = 4;
		}

		waitTimer.start(WaitTime, function(_t:FlxTimer) {
			afterRemoving();
		});
	}

	public function afterRemoving()
	{
		if (playSessionData.mode == PlaySessionData.ModeClear &&
			grid.getCount() == 0)
		{
			handlePuzzleCompleted();
		}
		// Check whether the field is empty to award bonuses
		else if (mode == ModeArcade && grid.getCount() == 0)
		{
			flowController.onScreenCleared();
			specialBubbleController.onScreenCleared();

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
				stopDropNotice();

				// Generate a row while exiting
				afterCleanRowsLeft--;
				generateRow(false);
				// And generate 3 more rows
				afterCleanTimer.start(0.7, handleAfterCleanGeneration);
			});
		}
		else
		{
			switchState(StateAiming);
		}
	}

	function handleAfterCleanGeneration(t : FlxTimer)
	{
		afterCleanRowsLeft -= 1;
		generateRow(false);

		if (afterCleanRowsLeft > 0)
		{
			afterCleanTimer.start(0.7, handleAfterCleanGeneration);
		}
		else
		{
			// And resume playing
			switchState(StateAiming);
			startDropTimer(dropDelay);
		}
	}

	function finishAfterCleanGeneration()
	{
		afterCleanTimer.cancel();
		while (afterCleanRowsLeft > 0)
		{
			afterCleanRowsLeft -= 1;
			generateRow(false);
		}
	}

	public function onPresentBubbleHit(present : Bubble)
	{
		// Generate the next bubble
		generateBubble();

		cast(present, PresentBubble).onOpen();
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

		var characterId : String = playSessionData.character;
		character = new PlayerCharacter(baseDecoration.x + 16,
										baseDecoration.y + 24,
										this, characterId);
		add(character);
	}

	public function onDeactivate()
    {
        /* TODO: Save status! */
		switch (state)
		{
			case PlayState.StateStarting,
				 PlayState.StateAiming,
				 PlayState.StateWaiting,
				 PlayState.StateRemoving:

				// Special case when the deactivation happens
				// after a clean screen, while rows are generating
				trace("AfterCleanRowsLeft", afterCleanRowsLeft);
				if (afterCleanRowsLeft > 0)
				{
					finishAfterCleanGeneration();
				}

				// Store play state
				// Update colors!
				playSessionData.usedColors = availableColors;
				SaveStateManager.savePlayStateData(this);
			case PlayState.StateLosing, PlayState.StateWinning:
				// Add the session data to totals
				if (mode == PlayState.ModeArcade)
				{
					ArcadeGameStatus.storePlayData(flowController.getStoredData());
				}
		}

    }

	// Drop timer
	function startDropTimer(delay : Float)
	{
		// Start the drop timer, with the appropriate callback
		dropTimer.start(delay, onDropTimer);
		// Start the drop notifier for long waits
		if (delay > RowDropNotifyTime)
		{
			dropNoticeTimer.start(delay - RowDropNotifyTime, beginDropNotice);
		}
	}

	function beginDropNotice(t : FlxTimer)
	{
		if (t != null) {
			t.cancel();
		}

		// Play a low hummm
		SfxEngine.play(SfxEngine.SFX.Print, 0.18, true);
		// Vibrate bubble grid or something
		notifyDrop = true;
	}

	function stopDropNotice()
	{
		// Stop vibration sound
		SfxEngine.stop(SfxEngine.SFX.Print);
		// Stop vibration
		notifyDrop = false;
	}

	/* Debug things */

	var mouseCell : FlxPoint;
	var label : FlxText;

	function handleDebugInit()
	{
		mouseCell = new FlxPoint();
		label = new FlxText(4, FlxG.height - 16);
		// add(label);

		DEBUG_dropDisabled = false;

		// Avoid generating debug buttons
		/*var btnDebugLine : HoldButton = new HoldButton(156, 220,
			function() {
				cursor.enableGuide(10000);
			}, function () {
				cursor.disableGuideAfterShots(-1);
			});
		btnDebugLine.loadSpritesheet("assets/ui/btn-debug.png", 24, 21);
		add(btnDebugLine);

		var btnDebugGrid : HoldButton = new HoldButton(0, 220,
			function() {
				grid.DEBUG_diplayGrid = true;
			}, function () {
				grid.DEBUG_diplayGrid = false;
				trace("grid: " + grid.DEBUG_diplayGrid);
			});
		btnDebugGrid.loadSpritesheet("assets/ui/btn-debug.png", 24, 21);
		add(btnDebugGrid);*/
	}

	var contentIndex : Int = -1;
	function handleDebugRoutines()
	{
		// Avoid debug on android
		#if mobile
			return;
		#end

		var mouse : FlxPoint = FlxG.mouse.getWorldPosition();
		var cell = grid.getCellAt(mouse.x, mouse.y);

		if (FlxG.keys.justPressed.TAB)
		{
			DEBUG_dropDisabled = !DEBUG_dropDisabled;
			trace("Drop " + (DEBUG_dropDisabled ? "disabled" : "enabled"));
		}

		if (FlxG.keys.justPressed.G)
		{
			cursor.guideEnabled = !cursor.guideEnabled;
			cursor.shots = -1;
		}

		if (FlxG.keys.justPressed.ONE || FlxG.keys.justPressed.TWO)
		{
			spawnDebugBubble(cell, (FlxG.keys.justPressed.ONE ? availableColors[0] : availableColors[1]));
		}

		if (FlxG.keys.justPressed.THREE)
		{
			spawnDebugBubble(cell, new BubbleColor(BubbleColor.SpecialBlocker));
		}

		if (FlxG.keys.justPressed.FOUR)
		{
			var Color : BubbleColor = new BubbleColor(BubbleColor.SpecialPresent);


			if (grid.getData(cell.x, cell.y) != null)
			{
				bubbles.remove(grid.getData(cell.x, cell.y));
				presents.remove(grid.getData(cell.x, cell.y));
				grid.getData(cell.x, cell.y).destroy();
				grid.setData(cell.x, cell.y, null);
			}
			else
			{
				contentIndex += 1;
				if (contentIndex >= SpecialBubbleController.PresentContent.Contents.length)
				{
					contentIndex = 0;
				}

				var cellCenter : FlxPoint = grid.getCellCenter(Std.int(cell.x), Std.int(cell.y));

				var bubble : Bubble = null;
				bubble = new PresentBubble(cellCenter.x, cellCenter.y - grid.cellSize, this, Color);
				cast(bubble, PresentBubble).setContent(contentIndex);

				bubble.cellPosition.set(cell.x, cell.y);
				bubble.cellCenterPosition.set(cellCenter.x, cellCenter.y);
				bubble.state = Bubble.StateIdling;

				grid.setData(cell.x, cell.y, bubble);
				presents.add(bubble);
			}
		}

		if (FlxG.keys.justPressed.C)
		{
			for (c in 0...grid.columns)
			{
				for (r in 1...grid.rows)
				{
					if (grid.getData(c, r) != null) 
					{
						bubbles.remove(grid.getData(c, r));
						grid.setData(c, r, null);
					}
					
				}
			}
		}

		if (FlxG.keys.pressed.B)
		{
			flowController.onBubbleDestroyed(100);
		}

		if (FlxG.keys.justReleased.B)
		{
			add(new TextNotice(16, 100, "Bubbles " + flowController.getSaveData().bubbleCount));
		}

		if (FlxG.keys.justPressed.S)
		{
			var filename : String = Screenshot.take();
			trace(filename);
		}

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

		if (FlxG.keys.justPressed.O)
		{
			flowController.increaseDifficulty();
		}

		mouseCell.set(cell.x, cell.y);
		// label.text = "" + cell + " | " + dropDelay;
		// label.text = grid.getUsedColors().toString();
		// FlxG.watch.addQuick("Cell", cell);
	}

	function spawnDebugBubble(cell : FlxPoint, color : BubbleColor)
	{
		if (grid.getData(cell.x, cell.y) != null)
		{
			bubbles.remove(grid.getData(cell.x, cell.y));
			grid.getData(cell.x, cell.y).destroy();
			grid.setData(cell.x, cell.y, null);
		}
		else
		{
			Bubble.CreateAt(cell.x, cell.y, color, this);
		}
	}
}
