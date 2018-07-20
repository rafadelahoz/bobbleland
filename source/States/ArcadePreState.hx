package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
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

/*#if android
import Hardware;
#end*/

class ArcadePreState extends BubbleState
{
    /** Play settings screen **/
    var centerScreen : FlxSpriteGroup;
    var sldDifficulty : SliderButton;

    var btnDog : HoldButton;
    var btnCat : HoldButton;
    var btnCrab : HoldButton;
    var btnFrog : HoldButton;
    var btnBear : HoldButton;
    var btnCatbomb : HoldButton;
    var hintButtons : Array<Button>;

    var alternateButton : Button;

    var btnBgmA : HoldButton;
    var btnBgmB : HoldButton;
    var btnBgmOff : HoldButton;

    var ledBgmA : FlxSprite;
    var ledBgmB : FlxSprite;
    var ledBgmOff : FlxSprite;

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

    /** Pomp & Fanfare **/
    var fanfareShader : Entity;

    var target : FlxObject;
    var isCameraMoving : Bool;

    override public function create()
    {
        super.create();

        centerScreen = new FlxSpriteGroup(0, 0);

        background = database.BackgroundDatabase.BuildRandomBackground();
        background.scrollFactor.set(0.35, 0.35);
        background.velocity.set(10, 10);
        add(background);

        hintButtons = [];

        historyScreen = buildHistoryScreen();
        add(historyScreen);

        centerScreen = buildCenterScreen();
        add(centerScreen);

        var specialScreen : FlxSpriteGroup = buildSpecialScreen();
        add(specialScreen);

        btnBack = new HoldButton(0, 0, onBackButtonPressed);
        btnBack.loadSpritesheet("assets/ui/btn-back.png", 32, 24);
        btnBack.scrollFactor.set();
        add(btnBack);

        target = new FlxObject(Constants.Width/2, Constants.Height/2);
        add(target);
        isCameraMoving = false;

        FlxG.camera.setPosition(0, 0);
        FlxG.camera.follow(target);

        initData();

        start();
    }

    function stampText(sprite : FlxSprite, ?color : Int = 0xFF000000, string : String, x : Float, y : Float)
    {
        var t : flixel.text.FlxBitmapText = PixelText.New(0, 0, string);
        t.drawFrame(true);

        var temp : FlxSprite = new FlxSprite(0, 0);
        temp.makeGraphic(Std.int(t.width), Std.int(t.height), 0x00000000);
        temp.pixels.copyPixels(t.framePixels, t.framePixels.rect, new openfl.geom.Point(0,0));
        temp.color = color;

        sprite.stamp(temp, Std.int(x), Std.int(y));
    }

    function start()
    {
        if (ProgressStatus.progressData.fanfare != null && ProgressStatus.progressData.fanfare != "none")
        {
            // Disable interaction
            disableButtons();

            BgmEngine.stopCurrent();
            // SfxEngine.play(SfxEngine.SFX.UnlockHum, 0.5, true);
            BgmEngine.play(BgmEngine.BGM.Unlock, 0.75);

            // Do fanfare!
            fanfareShader = new Entity(0, 0);
            fanfareShader.makeGraphic(Constants.Width, Constants.Height, 0xFFFFFFFF);
            fanfareShader.color = 0xFF000000;
            fanfareShader.ShineTimerBase = 0.5;
            fanfareShader.shine();
            add(fanfareShader);

            new FlxTimer().start(3.5, function(t:FlxTimer) {

                var ticket : Entity = new Entity(0, 0);
                ticket.loadGraphic("assets/ui/unlock-card-" + ProgressStatus.progressData.fanfare + ".png");

                ticket.x = Constants.Width / 2 - ticket.width / 2;

                var printer : GoldenPrinter = new GoldenPrinter();
                printer.backgroundShader = fanfareShader;
                printer.intensityCallback = function() {
                    SfxEngine.play(SfxEngine.SFX.UnlockShine, 1.5);
                    FlxG.camera.flash(Palette.White, 0.5);
                    fanfareShader.color = 0xFF000000;
                    // Show ticket
                    printer.startPrinting();
                    // Fast
                    printer.startPrinting();
                };

                printer.create(ticket, function() {

                    var target : Int = FlxG.random.int(30, 40);
                    var counter : Int = 0;
                    while (counter < target)
                    {
                        new FlxTimer().start(FlxG.random.float(0.2, 1.3), function(t:FlxTimer) {
                            t.destroy();
                            add(new TextNotice(FlxG.random.int(8, Constants.Width-16), FlxG.random.int(8, Constants.Height-16), "/", false, true));
                        });
                        counter++;
                    }

                    /*new FlxTimer().start(0.5, function(t:FlxTimer){
                        t.destroy();
                        SfxEngine.play(SfxEngine.SFX.CleanFanfare);
                    });*/

                    ticket.onTap(function () {
                        FlxTween.tween(ticket, {y : -ticket.height}, 0.25, {ease: FlxEase.circOut});

                        // And later
                        new FlxTimer().start(0.75, function(t) {
                            FlxTween.tween(fanfareShader, {alpha: 0}, 0.4,
                                {onComplete: function(t:FlxTween){
                                    fanfareShader.destroy();
                                }, ease: FlxEase.circOut
                            });

                            // Effects!
                            var shinyButton : Entity = null;
                            switch (ProgressStatus.progressData.fanfare)
                            {
                                case "crab":
                                    shinyButton = btnCrab;
                                case "frog":
                                    shinyButton = btnFrog;
                                case "bear":
                                    // TODO: Add bear button
                                case "catbomb":
                                    shinyButton = btnCatbomb;
                            }

                            if (shinyButton != null)
                            {
                                shinyButton.ShineTimerBase = 0.4;
                                shinyButton.ShineTimerVariation = 0.1;
                                shinyButton.ShineSparkColor = Palette.Yellow;
                                shinyButton.shine();
                            }

                            ProgressStatus.progressData.fanfare = "none";
                            ProgressStatus.save();

                            SfxEngine.stop(SfxEngine.SFX.UnlockHum);

                            // Actually start
                            enableButtons();
                            actuallyStart();
                        });
                    });
                });

                add(printer);
            });

        }
        else
        {
            actuallyStart();
        }
    }

    function actuallyStart()
    {
        BgmEngine.play(BgmEngine.BGM.Menu);
        // btnStart.shine();
    }

    function initData()
    {
        var data = ArcadeGameStatus.getConfigData();
        var difficulty = data.difficulty;
        sldDifficulty.x = getSlotPosition(difficulty, 24, 40);

        var character = data.character;
        switch (character)
        {
            case null:
                btnDog.setPressed(true, true);
            case "pug":
                btnDog.setPressed(true, true);
            case "cat":
                btnCat.setPressed(true, true);
            case "crab":
                if (btnCrab != null)
                    btnCrab.setPressed(true, true);
            case "frog":
                if (btnFrog != null)
                    btnFrog.setPressed(true, true);
            case "bear":
                if (btnBear != null)
                    btnBear.setPressed(true, true);
            case "catbomb":
                if (btnCatbomb != null)
                    btnCatbomb.setPressed(true, true);
        }
    }

    override public function destroy()
    {
        super.destroy();
    }

    override public function update(elapsed:Float)
    {
        handleBgmLeds();

        if (FlxG.keys.justPressed.O)
            Screenshot.take();

        super.update(elapsed);
    }

    function handleBgmLeds()
    {
        ledBgmA.animation.play("off");
        ledBgmB.animation.play("off");
        ledBgmOff.animation.play("off");

        switch (ArcadeGameStatus.getBgm())
        {
            case "GameA":
                ledBgmA.animation.play("on");
            case "GameC":
                ledBgmB.animation.play("on");
            default:
                ledBgmOff.animation.play("on");
        }
    }

    public function onDeactivate()
    {
        updateArcadeConfig();
        ArcadeGameStatus.saveArcadeConfigData();
    }

    function disableButtons()
    {
        var buttons : Array<Button> =
        hintButtons.concat([sldDifficulty,
                        btnDog, btnCat, btnCrab,
                        btnFrog, btnBear, btnCatbomb,
                        btnBgmA, btnBgmB, btnBgmOff,
                        btnStart, btnBack,
                       ]);
        for (button in buttons)
        {
            if (button != null)
            {
                button.alive = false;
                button.active = false;
            }
        }
    }

    function enableButtons()
    {
        var buttons : Array<Button> =
        hintButtons.concat([sldDifficulty,
                        btnDog, btnCat, btnCrab,
                        btnFrog, btnBear, btnCatbomb,
                        btnBgmA, btnBgmB, btnBgmOff,
                        btnStart, btnBack,
                       ]);
        for (button in buttons)
        {
            if (button != null)
            {
                button.alive = true;
                button.active = true;
            }
        }
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

    function buildSpecialScreen() : FlxSpriteGroup
    {
        var specialScreen : FlxSpriteGroup = new FlxSpriteGroup(Constants.Width, 0);

        if (ProgressStatus.progressData.secretScreen)
        {
            var specialOverlay : FlxSprite = new FlxSprite(0, 0, "assets/ui/special-screen.png");
            specialScreen.add(specialOverlay);

            var specialText : FlxBitmapText = PixelText.New(24, 48, "DODO", Palette.White);
                                //|                |
            var lipsum : String = "Thank you so\n" +
                                  "much for playing\n" +
                                  "SOAP ALLEY!\n\n" +
                                  "I hope you\n" +
                                  "enjoyed the game\n\n" +
                                  "      \\\\      \n\n" +
                                //|                |
                                  "a game by\n" +
                                  "      @thegraffo\n\n\n" +
                                  "Additional\n" +
                                  "design\n" +
                                  "         @crljmb\n\n\n" +
                                  "additional\n" +
                                  "illustration\n" +
                                  "       @evt1905\n\n" +
                                  "      \\\\      \n\n" +
                                //|                |
                                  "Presented by\n"+
                                  " the Badladns\n\n" +
                                  "      \\\\      \n\n" +
                                //|                |
                                  "the Badladns are\n\n" +
                                  " @crljmb\n" +
                                  "     &\n" +
                                  "   @thegraffo\n" +
                                  "\n" +
                                  "      \\\\      \n\n" +
                                  "Special thanks\n\n" +
                                  " / emechan\n" +
                                  " / pferv\n" +
                                  " / alwarr\n" +
                                  " / beadarkelf\n" +
                                  " / bronsonio\n" +
                                  " / jr\n" +
                                  " / manzanita\n" +
                                  " / vero8a\n" +
                                  // " / gsux\n" +
                                  "\n      \\\\      \n\n" +
                                  "for laura with /\n\n" +
                                  "      \\\\      \n\n";
                    if (ProgressStatus.progressData.alternate)
                        lipsum += "/ YOU ARE \n"+
                                  "  SUPER PLAYER /\n\n" +
                                //|                |
                                  "";

            // specialText.text = sanitizeWidth(lipsum, 16);
            specialText.text = lipsum;

            specialScreen.add(specialText);

            var finalButton : Button = new Button(136, specialText.y + specialText.height + 32, onFinalButtonReleased);
            finalButton.loadSpritesheet("assets/ui/btn-debug.png", 24, 21);
            specialScreen.add(finalButton);

            var totalHeight : Int = Std.int(specialText.height);
            if (!ProgressStatus.progressData.alternate)
                totalHeight += Std.int(32 + finalButton.height);

            var scrollButton : ScrollButton = null;
            scrollButton = new ScrollButton(160, 48, function() {
                specialText.y = Std.int(48 - scrollButton.progress * (totalHeight - 256));
                finalButton.y = specialText.y + specialText.height + 32;
                finalButton.active = false;
                finalButton.visible = false;
            });
            scrollButton.unboundCallback = function() {
                if (!ProgressStatus.progressData.alternate)
                {
                    finalButton.active = true;
                    finalButton.visible = true;
                }
            };

            scrollButton.setLimits(48, 272);
            specialScreen.add(scrollButton);

            specialScreen.add(new FlxSprite(16, 0, "assets/ui/special-fg-top.png"));
            specialScreen.add(new FlxSprite(16, 304, "assets/ui/special-fg-bottom.png"));
        }

        specialScreen.add(buildScrollButton(0, 144, true));

        return specialScreen;
    }

    function onFinalButtonReleased()
    {
        FlxG.camera.flash(Palette.White);
        ProgressStatus.progressData.alternate = true;
        ProgressStatus.save();
        onBackButtonPressed();
    }

    function buildCenterScreen() : FlxSpriteGroup
    {
        var centerScreen : FlxSpriteGroup = new FlxSpriteGroup(0, 0);

        var centerOverlay : FlxSprite = new FlxSprite(0, 0, "assets/ui/arcade-config.png");
        centerScreen.add(centerOverlay);

        if (ProgressStatus.progressData.alternate)
        {
            centerScreen.add(new FlxSprite(144, 112, "assets/ui/alternate-bg.png"));
            alternateButton = new Button(152, 116, onAlternateButton);
            alternateButton.loadSpritesheet("assets/ui/btn-debug.png", 24, 21);
            centerScreen.add(alternateButton);
        }

        sldDifficulty = new SliderButton(40, 64, snapToDifficultyGrid);
        sldDifficulty.loadSpritesheet("assets/ui/slider.png", 16, 32);
        sldDifficulty.setLimits(28, 140);
        centerScreen.add(sldDifficulty);

        generateCharacterButtons(centerScreen);
        generateBgmButtons(centerScreen);

        centerScreen.add(buildScrollButton(0, 144, true));
        if (ProgressStatus.progressData.secretScreen)
            centerScreen.add(buildScrollButton(Constants.Width - 12, 144, false));

        btnStart = new Button(40, 276, onStartButtonPressed);
        btnStart.loadSpritesheet("assets/ui/btn-start.png", 96, 32);
        centerScreen.add(btnStart);

        return centerScreen;
    }

    function onAlternateButton()
    {
        alternateButton.active = false;
        FlxG.camera.flash(Palette.White, 0.6, function() {
            alternateButton.active = true;
        });
        ArcadeGameStatus.getConfigData().alternate = !ArcadeGameStatus.getConfigData().alternate;
        ArcadeGameStatus.saveArcadeConfigData();

        handleCharacterButtonGraphics();
    }

    function handleCharacterButtonGraphics()
    {
        var alt : Bool = (ArcadeGameStatus.getConfigData().alternate);
        for (char in ["dog", "cat", "crab", "frog", "bear", "catbomb"])
        {
            var btn : Button = null;
            switch (char)
            {
                case "dog": btn = btnDog;
                case "cat": btn = btnCat;
                case "crab": btn = btnCrab;
                case "frog": btn = btnFrog;
                case "bear": btn = btnBear;
                case "catbomb": btn = btnCatbomb;
            }

            if (btn != null)
                btn.loadSpritesheet("assets/ui/char-" + char + (alt ? "-alternate" : "") + ".png", 32, 32);
        }
    }

    function buildHistoryScreen() : FlxSpriteGroup
    {
        var white : Int = 0xFFFF1E8;

        var screen : FlxSpriteGroup = new FlxSpriteGroup(-Constants.Width, 0);

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

        #if (!release)
            var btnClearData : HoldButton = new HoldButton(56+32, 282, null, onClearDataReleased);
            btnClearData.loadSpritesheet("assets/ui/btn-cleardata.png", 96, 24);
            screen.add(btnClearData);
        #end

        screen.add(buildScrollButton(Constants.Width - 12, 144, false));

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
        if (true || target.x >= 0)
        {
            isCameraMoving = true;
            FlxTween.tween(target, {x : target.x + -1*Constants.Width}, 0.5, { ease : FlxEase.cubeInOut, onComplete: onFinishedMoving });
        }
    }

    function moveToRightScreen()
    {
        // Don't allow moving right of right
        if (true || target.x <= 0)
        {
            isCameraMoving = true;
            FlxTween.tween(target, {x : target.x + Constants.Width}, 0.5, { ease : FlxEase.cubeInOut, onComplete: onFinishedMoving });
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
        btnDog.allowRelease = false;
        group.add(btnDog);

        btnCat = new HoldButton(80, 128, onCharCatPressed, onCharReleased);
        btnCat.loadSpritesheet("assets/ui/char-cat.png", 32, 32);
        btnCat.allowRelease = false;
        group.add(btnCat);

        if (ProgressStatus.progressData.crabChar)
        {
            btnCrab = new HoldButton(120, 128, onCharCrabPressed, onCharReleased);
            btnCrab.loadSpritesheet("assets/ui/char-crab.png", 32, 32);
            btnCrab.allowRelease = false;
            group.add(btnCrab);
        }
        else if (ProgressStatus.progressData.crabHint)
        {
            // Instantiate crab hint over his button
            var btnCrabHint : HintButton = new HintButton(120, 128, this, "Try getting a\nhigh score!");
            group.add(btnCrabHint);
            hintButtons.push(btnCrabHint);
        }

        if (ProgressStatus.progressData.frogChar)
        {
            btnFrog = new HoldButton(40, 168, onCharFrogPressed, onCharReleased);
            btnFrog.loadSpritesheet("assets/ui/char-frog.png", 32, 32);
            btnFrog.allowRelease = false;
            group.add(btnFrog);
        }
        else if (ProgressStatus.progressData.frogHint)
        {
            // Instantiate frog hint over his button
            var btnFrogHint : HintButton = new HintButton(40, 168, this, "This can't be easy:\nGet lots of bubbles\nin a single session");
            group.add(btnFrogHint);
            hintButtons.push(btnFrogHint);
        }

        if (ProgressStatus.progressData.bearChar)
        {
            btnBear = new HoldButton(80, 168, onCharBearPressed, onCharReleased);
            btnBear.loadSpritesheet("assets/ui/char-bear.png", 32, 32);
            btnBear.allowRelease = false;
            group.add(btnBear);
        }
        else if (ProgressStatus.progressData.bearHint)
        {
            // Instantiate bear hint over his button
            var btnBearHint : HintButton = new HintButton(80, 168, this, "This must be hard:\nHold on, baby,\nas long as you can");
            group.add(btnBearHint);
            hintButtons.push(btnBearHint);
        }

        if (ProgressStatus.progressData.catbombChar)
        {
            btnCatbomb = new HoldButton(120, 168, onCharCatbombPressed, onCharReleased);
            btnCatbomb.loadSpritesheet("assets/ui/char-catbomb.png", 32, 32);
            btnCatbomb.allowRelease = false;
            group.add(btnCatbomb);
        }
        else if (ProgressStatus.progressData.catbombHint)
        {
            // Instantiate catbomb hint over his button
            var btnCatbombHint : HintButton = new HintButton(120, 168, this, "Oh, you lazy cat\\");
            group.add(btnCatbombHint);
            hintButtons.push(btnCatbombHint);
        }

        handleCharacterButtonGraphics();
    }

    function generateBgmButtons(group : FlxSpriteGroup)
    {
        var baseY : Int = 224;

        btnBgmA = new HoldButton(40, baseY, onBgmAPressed, onBgmReleased);
        btnBgmA.loadSpritesheet("assets/ui/btn-bgmA.png", 32, 32);
        group.add(btnBgmA);

        ledBgmA = new FlxSprite(48, baseY-8);
        ledBgmA.loadGraphic("assets/ui/led-selector-sheet.png", true, 16, 8);
        ledBgmA.animation.add("off", [0]);
        ledBgmA.animation.add("on", [1]);
        ledBgmA.animation.play("off");
        group.add(ledBgmA);

        btnBgmB = new HoldButton(80, baseY, onBgmBPressed, onBgmReleased);
        btnBgmB.loadSpritesheet("assets/ui/btn-bgmB.png", 32, 32);
        group.add(btnBgmB);

        ledBgmB = new FlxSprite(88, baseY-8);
        ledBgmB.loadGraphic("assets/ui/led-selector-sheet.png", true, 16, 8);
        ledBgmB.animation.add("off", [2]);
        ledBgmB.animation.add("on", [3]);
        ledBgmB.animation.play("off");
        group.add(ledBgmB);

        btnBgmOff = new HoldButton(120, baseY, onBgmOffPressed, onBgmReleased);
        btnBgmOff.loadSpritesheet("assets/ui/btn-bgm-off.png", 32, 32);
        group.add(btnBgmOff);

        ledBgmOff = new FlxSprite(128, baseY-8);
        ledBgmOff.loadGraphic("assets/ui/led-selector-sheet.png", true, 16, 8);
        ledBgmOff.animation.add("off", [4]);
        ledBgmOff.animation.add("on", [5]);
        ledBgmOff.animation.play("off");
        group.add(ledBgmOff);
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
        releaseCharButtons("pug");
    }

    function onCharCatPressed()
    {
        ArcadeGameStatus.setCharacter("cat");
        // Deactivate other buttons
        releaseCharButtons("cat");
    }

    function onCharCrabPressed()
    {
        ArcadeGameStatus.setCharacter("crab");
        // Deactivate other buttons
        releaseCharButtons("crab");
    }

    function onCharFrogPressed()
    {
        ArcadeGameStatus.setCharacter("frog");
        // Deactivate other buttons
        releaseCharButtons("frog");
    }

    function onCharBearPressed()
    {
        ArcadeGameStatus.setCharacter("bear");
        // Deactivate other buttons
        releaseCharButtons("bear");
    }

    function onCharCatbombPressed()
    {
        ArcadeGameStatus.setCharacter("catbomb");
        // Deactivate other buttons
        releaseCharButtons("catbomb");
    }

    function releaseCharButtons(except : String)
    {
        if (except != "pug")
            btnDog.setPressed(false);
        if (except != "cat")
            btnCat.setPressed(false);
        if (except != "crab" && btnCrab != null)
            btnCrab.setPressed(false);
        if (except != "frog" && btnFrog != null)
            btnFrog.setPressed(false);
        if (except != "bear" && btnBear != null)
            btnBear.setPressed(false);
        if (except != "catbomb" && btnCatbomb != null)
            btnCatbomb.setPressed(false);
    }

    function onBgmReleased()
    {
        // ArcadeGameStatus.setBgm(null);
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
        ProgressStatus.clearData();
        FlxG.camera.flash(0xFFFF5151);
        // updateHistoryDisplays();
        onBackButtonPressed();
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
