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
    var btnCrab : HoldButton;

    var btnBgmA : HoldButton;
    var btnBgmB : HoldButton;
    var btnBgmOff : HoldButton;

    var btnStart : Button;

    /** History screen **/
    var historyScreen : FlxSpriteGroup;
    var highScoreDisplay : FlxBitmapText;
    var longestGameDisplay : FlxBitmapText;
    var maxBubblesDisplay : FlxBitmapText;
    var totalBubblesDisplay : FlxBitmapText;
    var totalTimeDisplay : FlxBitmapText;
    var totalCleansDisplay : FlxBitmapText;

    var creditsRafa : HoldButton;
    var creditsCarlos : HoldButton;
    var creditsRafaCard : FlxSprite;
    var creditsCarlosCard : FlxSprite;

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
        sldDifficulty.x = getSlotPosition(difficulty, 24, 40);

        var character = data.character;
        switch (character)
        {
            case "pug":
                btnDog.setPressed(true, true);
            case "cat":
                btnCat.setPressed(true, true);
            case "crab":
                btnCrab.setPressed(true, true);
        }
    }

    override public function destroy()
    {
        super.destroy();
    }

    override public function update(elapsed:Float)
    {
        swipeManager.update(elapsed);

        if (FlxG.keys.justPressed.O)
            Screenshot.take();

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
        // data.bgm = "GameC";
        ArcadeGameStatus.setConfigData(data);
        trace("arcade data: " + ArcadeGameStatus.getConfigData());
    }

    function prepareDifficultySetting()
    {
        var difficulty : Int = getSnapSlot(sldDifficulty.x, 24, 32);
        ArcadeGameStatus.setupDifficulty(difficulty);
    }

    function buildCenterScreen() : FlxSpriteGroup
    {
        var centerScreen : FlxSpriteGroup = new FlxSpriteGroup(0, 0);

        var centerOverlay : FlxSprite = new FlxSprite(0, 0, "assets/ui/arcade-config.png");
        centerScreen.add(centerOverlay);

        sldDifficulty = new SliderButton(40, 64, snapToDifficultyGrid);
        sldDifficulty.loadSpritesheet("assets/ui/slider.png", 16, 32);
        sldDifficulty.setLimits(28, 140);
        centerScreen.add(sldDifficulty);

        generateCharacterButtons(centerScreen);
        generateBgmButtons(centerScreen);

        centerScreen.add(buildScrollButton(0, 144, true));
        // centerScreen.add(buildScrollButton(FlxG.width - 12, 144, false));

        btnStart = new Button(40, 276, onStartButtonPressed);
        btnStart.loadSpritesheet("assets/ui/btn-start.png", 96, 32);
        centerScreen.add(btnStart);

        return centerScreen;
    }

    function buildHistoryScreen() : FlxSpriteGroup
    {
        var white : Int = 0xFFFF1E8;

        var screen : FlxSpriteGroup = new FlxSpriteGroup(-FlxG.width, 0);

        var background : FlxSprite = new FlxSprite(0, 0, "assets/ui/arcade-history.png");
        screen.add(background);

        // screen.add(PixelText.New(16, 92, "HIGH SCORE", white, 128));
        highScoreDisplay = PixelText.New(80, 84, "", white, 128);
        screen.add(highScoreDisplay);

        // screen.add(PixelText.New(16, 116, "LONGEST GAME", white, 128));
        longestGameDisplay = PixelText.New(72, 108, "", white, 128);
        screen.add(longestGameDisplay);

        // screen.add(PixelText.New(16, 140, "Max BUBBLES", white, 128));
        maxBubblesDisplay = PixelText.New(80, 132, "", white, 128);
        screen.add(maxBubblesDisplay);

        // screen.add(PixelText.New(16, 200, "BUBBLES ", white, 128));
        totalBubblesDisplay = PixelText.New(72, 184, "", white, 128);
        screen.add(totalBubblesDisplay);

        // screen.add(PixelText.New(16, 212, "TIME ", white, 128));
        totalTimeDisplay = PixelText.New(72, 208, "", white, 128);
        screen.add(totalTimeDisplay);

        // screen.add(PixelText.New(16, 224, "CLEAN SCS", white, 128));
        totalCleansDisplay = PixelText.New(72, 232, "", white, 128);
        screen.add(totalCleansDisplay);

        /*var btnClearData : HoldButton = new HoldButton(40, 272, null, onClearDataReleased);
        btnClearData.loadSpritesheet("assets/ui/btn-cleardata.png", 96, 24);
        screen.add(btnClearData);*/

        screen.add(buildScrollButton(FlxG.width - 12, 144, false));

        creditsRafa = new HoldButton(16, 280, onRafaPressed, onRafaReleased);
        creditsRafa.loadSpritesheet("assets/ui/credits-man-a.png", 32, 32);
        screen.add(creditsRafa);

        creditsCarlos = new HoldButton(56, 280, onCarlosPressed, onCarlosReleased);
        creditsCarlos.loadSpritesheet("assets/ui/credits-man-b.png", 32, 32);
        screen.add(creditsCarlos);

        creditsRafaCard = new FlxSprite(96, 280, "assets/ui/credits-rafa-card.png");
        creditsRafaCard.alpha = 0;
        screen.add(creditsRafaCard);

        creditsCarlosCard = new FlxSprite(96, 280, "assets/ui/credits-carlos-card.png");
        creditsCarlosCard.alpha = 0;
        screen.add(creditsCarlosCard);

        updateHistoryDisplays();

        return screen;
    }

    function updateHistoryDisplays()
    {
        var data : Dynamic = ArcadeGameStatus.getConfigData();

        highScoreDisplay.text = TextUtils.padWith("" + clamp(data.highScore, 99999999), 8);
        longestGameDisplay.text = TextUtils.padWith(TextUtils.formatTime(data.longestGame), 10);
        maxBubblesDisplay.text = TextUtils.padWith("" + clamp(data.maxBubbles, 99999999), 8);

        totalBubblesDisplay.text = TextUtils.padWith("" + clamp(data.totalBubbles, 99999999), 9);
        totalTimeDisplay.text = TextUtils.padWith(TextUtils.formatTime(data.totalTime), 10);
        totalCleansDisplay.text = TextUtils.padWith("" + clamp(data.totalCleans, 9999), 9);
    }

    function clamp(value : Int, max : Int) : Int
    {
        if (value < max)
            return value;
        else
            return max;
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
        btnDog = new HoldButton(40, 128, onCharDogPressed, onCharReleased);
        btnDog.loadSpritesheet("assets/ui/char-dog.png", 32, 32);
        group.add(btnDog);

        btnCat = new HoldButton(80, 128, onCharCatPressed, onCharReleased);
        btnCat.loadSpritesheet("assets/ui/char-cat.png", 32, 32);
        group.add(btnCat);

        btnCrab = new HoldButton(120, 128, onCharCrabPressed, onCharReleased);
        btnCrab.loadSpritesheet("assets/ui/char-crab.png", 32, 32);
        group.add(btnCrab);
    }

    function generateBgmButtons(group : FlxSpriteGroup)
    {
        btnBgmA = new HoldButton(40, 224, onBgmAPressed, onBgmReleased);
        btnBgmA.loadSpritesheet("assets/ui/btn-bgmA.png", 32, 32);
        group.add(btnBgmA);

        btnBgmB = new HoldButton(80, 224, onBgmBPressed, onBgmReleased);
        btnBgmB.loadSpritesheet("assets/ui/btn-bgmB.png", 32, 32);
        group.add(btnBgmB);

        btnBgmOff = new HoldButton(120, 224, onBgmOffPressed, onBgmReleased);
        btnBgmOff.loadSpritesheet("assets/ui/btn-bgm-off.png", 32, 32);
        group.add(btnBgmOff);
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
        btnCrab.setPressed(false);
    }

    function onCharCatPressed()
    {
        ArcadeGameStatus.setCharacter("cat");
        // Deactivate other buttons
        btnDog.setPressed(false);
        btnCrab.setPressed(false);
    }

    function onCharCrabPressed()
    {
        ArcadeGameStatus.setCharacter("crab");
        // Deactivate other buttons
        btnDog.setPressed(false);
        btnCat.setPressed(false);
    }

    function onBgmReleased()
    {
        ArcadeGameStatus.setBgm(null);
        BgmEngine.play(BgmEngine.BGM.Menu);
        // Deactivate other buttons
        btnBgmA.setPressed(false);
        btnBgmB.setPressed(false);
        btnBgmOff.setPressed(false);
    }

    function onBgmAPressed()
    {
        ArcadeGameStatus.setBgm("GameA");
        BgmEngine.play(BgmEngine.BGM.GameA, true);
        // Deactivate other buttons
        btnBgmB.setPressed(false);
        btnBgmOff.setPressed(false);
    }

    function onBgmOffPressed()
    {
        ArcadeGameStatus.setBgm(null);//"GameB");
        BgmEngine.stopCurrent();//.play(BgmEngine.BGM.GameB);
        // Deactivate other buttons
        btnBgmA.setPressed(false);
        btnBgmB.setPressed(false);
    }

    function onBgmBPressed()
    {
        ArcadeGameStatus.setBgm("GameC");
        BgmEngine.play(BgmEngine.BGM.GameC, true);
        // Deactivate other buttons
        btnBgmA.setPressed(false);
        btnBgmOff.setPressed(false);
    }

    function onClearDataReleased()
    {
        ArcadeGameStatus.clearHistoryData();
        FlxG.camera.flash(0xFFFF5151);
        updateHistoryDisplays();
    }

    function snapToDifficultyGrid()
    {
        var snapX = snapToSlots(sldDifficulty.x, 24, 40);
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

    function onRafaPressed()
    {
        var delay : Float = 0;
        if (creditsCarlos.isPressed())
            delay = 0.5;
        creditsCarlos.setPressed(false, true);
        FlxTween.tween(creditsRafaCard, {alpha: 1}, 0.5, {startDelay: delay, ease: FlxEase.bounceOut});
    }

    function onRafaReleased()
    {
        FlxTween.tween(creditsRafaCard, {alpha: 0}, 0.5, {ease: FlxEase.bounceIn});
    }

    function onCarlosPressed()
    {
        var delay : Float = 0;
        if (creditsRafa.isPressed())
            delay = 0.5;
        creditsRafa.setPressed(false, true);
        FlxTween.tween(creditsCarlosCard, {alpha: 1}, 0.5, {startDelay: delay, ease: FlxEase.bounceOut});
    }

    function onCarlosReleased()
    {
        FlxTween.tween(creditsCarlosCard, {alpha: 0}, 0.5, {ease: FlxEase.bounceIn});
    }
}
