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

        #if (work)
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

    function generateCharacterButtons()
    {
        btnDog = new HoldButton(32, 168, onCharDogPressed);
        btnDog.loadSpritesheet("assets/ui/char-dog.png", 32, 32);
        add(btnDog);
        
        btnCat = new HoldButton(72, 168, onCharCatPressed);
        btnCat.loadSpritesheet("assets/ui/char-cat.png", 32, 32);
        add(btnCat);
    }
    
    function onCharDogPressed()
    {
        ArcadeGameStatus.getData().character = "pug";
        // Deactivate other buttons
        btnCat.setPressed(false);
    }
    
    function onCharCatPressed()
    {
        ArcadeGameStatus.getData().character = "cat";
        // Deactivate other buttons
        btnDog.setPressed(false);
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
        GameController.BeginArcade();
    }

    function snapToDifficultyGrid()
    {
        var xx = sldDifficulty.x;
        var snapX = 32 + Math.round((xx-32)/24)*24;

        FlxTween.tween(sldDifficulty, {x : snapX}, 0.1);
    }
}
