package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;

import text.PixelText;
import text.TextUtils;

#if android
import Hardware;
#end

class ArcadePreState extends FlxTransitionableState
{
    /** Play settings screen **/
    var centerScreen : FlxSpriteGroup;
    var sldDifficulty : SliderButton;
    var btnDog : HoldButton;
    var btnCat : HoldButton;
    var btnStart : Button;

    /** History screen **/
    var historyScreen : FlxSpriteGroup;
    var highScoreDisplay : FlxBitmapText;
    var longestGameDisplay : FlxBitmapText;
    var maxBubblesDisplay : FlxBitmapText;
    var totalBubblesDisplay : FlxBitmapText;
    var totalTimeDisplay : FlxBitmapText;
    var totalCleansDisplay : FlxBitmapText;

    /** Common elements **/
    var background : FlxBackdrop;
    var btnBack : Button;

    var target : FlxObject;
    var isCameraMoving : Bool;

    var swipeManager : SwipeManager;

    override public function create()
    {
        super.create();

        centerScreen = new FlxSpriteGroup(0, 0);

        background = database.BackgroundDatabase.BuildRandomBackground();
        background.scrollFactor.set(0.35, 0.35);
        background.velocity.set(10, 10);
        add(background);

        historyScreen = buildHistoryScreen();
        add(historyScreen);

        centerScreen = buildCenterScreen();
        add(centerScreen);

        btnBack = new HoldButton(0, 0, onBackButtonPressed);
        btnBack.loadSpritesheet("assets/ui/btn-back.png", 32, 24);
        btnBack.scrollFactor.set();
        add(btnBack);

        target = new FlxObject(FlxG.width/2, FlxG.height/2);
        add(target);
        isCameraMoving = false;

        FlxG.camera.follow(target);

        swipeManager = new SwipeManager();
        swipeManager.leftCallback = moveToRightScreen;
        swipeManager.rightCallback = moveToLeftScreen;

        initData();

        BgmEngine.play(BgmEngine.BGM.Menu);
    }

    function initData()
    {
        var data = ArcadeGameStatus.getConfigData();
        var difficulty = data.difficulty;
        sldDifficulty.x = getSlotPosition(difficulty, 24, 32);

        var character = data.character;
        switch (character)
        {
            case "pug":
                btnDog.setPressed(true, true);
            case "cat":
                btnCat.setPressed(true, true);
        }
    }

    override public function destroy()
    {
        super.destroy();
    }

    override public function update(elapsed:Float)
    {
        swipeManager.update(elapsed);

        super.update(elapsed);
    }

    public function onDeactivate()
    {
        updateArcadeConfig();
        ArcadeGameStatus.saveArcadeConfigData();
    }

    function onBackButtonPressed()
    {
        BgmEngine.stopCurrent();

        updateArcadeConfig();

        ArcadeGameStatus.saveArcadeConfigData();
        GameController.ToMenu();
    }

    function onStartButtonPressed()
    {
        BgmEngine.stopCurrent();

        updateArcadeConfig();

        ArcadeGameStatus.saveArcadeConfigData();
        prepareDifficultySetting();
        GameController.BeginArcade();
    }

    function updateArcadeConfig()
    {
        var data = ArcadeGameStatus.getConfigData();
        data.difficulty = getSnapSlot(sldDifficulty.x, 24, 32);
        data.character = ArcadeGameStatus.getCharacter();
        ArcadeGameStatus.setConfigData(data);
        trace(ArcadeGameStatus.getConfigData());
    }

    function prepareDifficultySetting()
    {
        var difficulty : Int = getSnapSlot(sldDifficulty.x, 24, 32);

        switch (difficulty)
        {
            case 0:
                ArcadeGameStatus.setGuideEnabled(true);
                ArcadeGameStatus.setDropDelay(30);
                ArcadeGameStatus.setInitialRows(5);
                ArcadeGameStatus.setUsedColors(4);
            case 1:
                ArcadeGameStatus.setGuideEnabled(true);
                ArcadeGameStatus.setDropDelay(25);
                ArcadeGameStatus.setInitialRows(5);
                ArcadeGameStatus.setUsedColors(4);
            case 2:
                ArcadeGameStatus.setGuideEnabled(true);
                ArcadeGameStatus.setDropDelay(20);
                ArcadeGameStatus.setInitialRows(5);
                ArcadeGameStatus.setUsedColors(5);
            case 3:
                ArcadeGameStatus.setGuideEnabled(true);
                ArcadeGameStatus.setDropDelay(20);
                ArcadeGameStatus.setInitialRows(6);
                ArcadeGameStatus.setUsedColors(6);
            case 4:
                ArcadeGameStatus.setGuideEnabled(false);
                ArcadeGameStatus.setDropDelay(15);
                ArcadeGameStatus.setInitialRows(6);
                ArcadeGameStatus.setUsedColors(6);
        }
    }

    function buildCenterScreen() : FlxSpriteGroup
    {
        var centerScreen : FlxSpriteGroup = new FlxSpriteGroup(0, 0);

        var centerOverlay : FlxSprite = new FlxSprite(0, 0, "assets/ui/arcade-config.png");
        centerScreen.add(centerOverlay);

        sldDifficulty = new SliderButton(32, 88, snapToDifficultyGrid);
        sldDifficulty.loadSpritesheet("assets/ui/slider.png", 16, 32);
        sldDifficulty.setLimits(24, 136);
        centerScreen.add(sldDifficulty);

        generateCharacterButtons(centerScreen);

        centerScreen.add(buildScrollButton(0, 144, true));
        // centerScreen.add(buildScrollButton(FlxG.width - 12, 144, false));

        btnStart = new Button(40, 264, onStartButtonPressed);
        btnStart.loadSpritesheet("assets/ui/btn-start.png", 96, 40);
        centerScreen.add(btnStart);

        return centerScreen;
    }

    function buildHistoryScreen() : FlxSpriteGroup
    {
        var white : Int = 0xFFFF1E8;

        var screen : FlxSpriteGroup = new FlxSpriteGroup(-FlxG.width, 0);

        var background : FlxSprite = new FlxSprite(0, 0, "assets/ui/arcade-history.png");
        screen.add(background);

        screen.add(PixelText.New(16, 92, "HIGH SCORE", white, 128));
        highScoreDisplay = PixelText.New(24, 104, "", white, 128);
        screen.add(highScoreDisplay);

        screen.add(PixelText.New(16, 116, "LONGEST GAME", white, 128));
        longestGameDisplay = PixelText.New(24, 128, "", white, 128);
        screen.add(longestGameDisplay);

        screen.add(PixelText.New(16, 140, "Max BUBBLES", white, 128));
        maxBubblesDisplay = PixelText.New(24, 152, "", white, 128);
        screen.add(maxBubblesDisplay);

        screen.add(PixelText.New(16, 200, "BUBBLES ", white, 128));
        totalBubblesDisplay = PixelText.New(80, 200, "", white, 128);
        screen.add(totalBubblesDisplay);

        screen.add(PixelText.New(16, 212, "TIME ", white, 128));
        totalTimeDisplay = PixelText.New(80, 212, "", white, 128);
        screen.add(totalTimeDisplay);

        screen.add(PixelText.New(16, 224, "CLEAN SCS", white, 128));
        totalCleansDisplay = PixelText.New(120, 224, "", white, 128);
        screen.add(totalCleansDisplay);

        var btnClearData : HoldButton = new HoldButton(40, 272, null, onClearDataReleased);
        btnClearData.loadSpritesheet("assets/ui/btn-cleardata.png", 96, 24);
        screen.add(btnClearData);

        screen.add(buildScrollButton(FlxG.width - 12, 144, false));

        updateHistoryDisplays();

        return screen;
    }

    function updateHistoryDisplays()
    {
        var data : Dynamic = ArcadeGameStatus.getConfigData();

        highScoreDisplay.text = "" + data.highScore;
        longestGameDisplay.text = TextUtils.formatTime(data.longestGame);
        maxBubblesDisplay.text = "" + data.maxBubbles;

        totalBubblesDisplay.text = TextUtils.padWith("" + data.totalBubbles, 8);
        totalTimeDisplay.text = TextUtils.padWith(TextUtils.formatTime(data.totalTime), 9);
        totalCleansDisplay.text = TextUtils.padWith("" + data.totalCleans, 3);
    }

    function buildScrollButton(x : Float, y : Float, left : Bool) : Button
    {
        var button : Button = new Button(x, y, function() {
            if (!isCameraMoving)
            {
                if (left) moveToLeftScreen();
                else moveToRightScreen();
            }
        });
        button.loadSpritesheet("assets/ui/btn-side.png", 12, 32);
        button.flipX = left;

        return button;
    }

    function moveToLeftScreen()
    {
        // Don't allow moving left of left
        if (target.x > 0)
        {
            isCameraMoving = true;
            FlxTween.tween(target, {x : target.x + -1*FlxG.width}, 0.5, { ease : FlxEase.cubeInOut, onComplete: onFinishedMoving });
        }
    }

    function moveToRightScreen()
    {
        // Don't allow moving right of right
        if (target.x < FlxG.width)
        {
            isCameraMoving = true;
            FlxTween.tween(target, {x : target.x + FlxG.width}, 0.5, { ease : FlxEase.cubeInOut, onComplete: onFinishedMoving });
        }
    }

    function onFinishedMoving(_t:FlxTween)
    {
        isCameraMoving = false;
    }

    function generateCharacterButtons(group : FlxSpriteGroup)
    {
        btnDog = new HoldButton(32, 168, onCharDogPressed, onCharReleased);
        btnDog.loadSpritesheet("assets/ui/char-dog.png", 32, 32);
        group.add(btnDog);

        btnCat = new HoldButton(72, 168, onCharCatPressed, onCharReleased);
        btnCat.loadSpritesheet("assets/ui/char-cat.png", 32, 32);
        group.add(btnCat);
    }

    function onCharReleased()
    {
        // btnDog.clock();
        ArcadeGameStatus.setCharacter(null);
    }

    function onCharDogPressed()
    {
        ArcadeGameStatus.setCharacter("pug");
        // Deactivate other buttons
        btnCat.setPressed(false);
    }

    function onCharCatPressed()
    {
        ArcadeGameStatus.setCharacter("cat");
        // Deactivate other buttons
        btnDog.setPressed(false);
    }

    function onClearDataReleased()
    {
        ArcadeGameStatus.clearHistoryData();
        FlxG.camera.flash(0xFFFF5151);
        updateHistoryDisplays();
    }

    function snapToDifficultyGrid()
    {
        var snapX = snapToSlots(sldDifficulty.x, 24, 32);
        FlxTween.tween(sldDifficulty, {x : snapX}, 0.1);
    }

    function snapToSlots(value : Float, slotWidth : Int, ?offset : Int = 0) : Float
    {
        return offset + Math.round((value-offset)/slotWidth)*slotWidth;
    }

    function getSnapSlot(value : Float, slotWidth : Int, ?offset : Int = 0) : Int
    {
        return Std.int(Math.round(value-offset)/slotWidth);
    }

    function getSlotPosition(slot : Int, slotWidth : Int, ?offset : Int = 0) : Int
    {
        return offset + slot*slotWidth;
    }
}
