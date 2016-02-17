package;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.addons.display.FlxBackdrop;

class ArcadePreState extends FlxState
{
    var background : FlxBackdrop;
    var bgOverlay : FlxSprite;

    var sldDifficulty : SliderButton;
    
    var btnDog : HoldButton;
    var btnCat : HoldButton;
    
    var btnStart : Button;

    override public function create()
    {
        super.create();

        #if !work
        var bg : String = "assets/backgrounds/" +
                        (FlxRandom.chanceRoll(50) ? "bg0.png" : "bg1.png");
        background = new FlxBackdrop(bg, 2, 2);
        background.velocity.set(10, 10);
        add(background);
        #end

        bgOverlay = new FlxSprite(0, 0, "assets/ui/arcade-config.png");
        add(bgOverlay);

        sldDifficulty = new SliderButton(32, 88, snapToDifficultyGrid);
        sldDifficulty.loadSpritesheet("assets/ui/slider.png", 16, 32);
        sldDifficulty.setLimits(24, 136);
        add(sldDifficulty);
        
        generateCharacterButtons();

        btnStart = new Button(40, 264, onStartButtonPressed);
        btnStart.loadSpritesheet("assets/ui/btn-start.png", 96, 40);
        add(btnStart);
    }

    override public function destroy()
    {
        super.destroy();
    }

    override public function update()
    {
        super.update();
    }

    function onStartButtonPressed()
    {
        prepareDifficultySetting();
        GameController.BeginArcade();
    }
    
    function prepareDifficultySetting()
    {
        var difficulty : Int = getSnapSlot(sldDifficulty.x, 24, 32);

        switch (difficulty)
        {
            case 0:
                ArcadeGameStatus.setDropDelay(30);
                ArcadeGameStatus.setInitialRows(5);
                ArcadeGameStatus.setUsedColors(4);
            case 1:
                ArcadeGameStatus.setDropDelay(25);
                ArcadeGameStatus.setInitialRows(5);
                ArcadeGameStatus.setUsedColors(4);
            case 2:
                ArcadeGameStatus.setDropDelay(20);
                ArcadeGameStatus.setInitialRows(5);
                ArcadeGameStatus.setUsedColors(5);
            case 3:
                ArcadeGameStatus.setDropDelay(20);
                ArcadeGameStatus.setInitialRows(6);
                ArcadeGameStatus.setUsedColors(6);
            case 4:
                ArcadeGameStatus.setDropDelay(15);
                ArcadeGameStatus.setInitialRows(6);
                ArcadeGameStatus.setUsedColors(6);
        }
    }

    function generateCharacterButtons()
    {
        btnDog = new HoldButton(32, 168, onCharDogPressed, onCharReleased);
        btnDog.loadSpritesheet("assets/ui/char-dog.png", 32, 32);
        add(btnDog);
        
        btnCat = new HoldButton(72, 168, onCharCatPressed, onCharReleased);
        btnCat.loadSpritesheet("assets/ui/char-cat.png", 32, 32);
        add(btnCat);
    }
    
    function onCharReleased()
    {
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

    function snapToDifficultyGrid()
    {
        var snapX = snapToSlots(sldDifficulty.x, 24, 32);
        FlxTween.tween(sldDifficulty, {x : snapX}, 0.1);
    }
    
    function snapToSlots(value : Float, slotWidth : Int, ?offset : Int = 0) : Float
    {
        return offset + getSnapSlot(value, slotWidth, offset)*slotWidth;
    }
    
    function getSnapSlot(value : Float, slotWidth : Int, ?offset : Int = 0) : Int
    {
        return Std.int(Math.round(value-offset)/slotWidth);
    }
}
