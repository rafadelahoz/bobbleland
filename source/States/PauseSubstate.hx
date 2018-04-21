package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;

import flixel.util.FlxSpriteUtil;

import flixel.addons.ui.FlxButtonPlus;

import text.PixelText;

class PauseSubstate extends FlxSubState
{
    var world : PlayState;

    var shader : FlxSprite;

    var curtain : Curtain;
    public var btnResume : Button;
    public var btnExit : Button;

    var tween : FlxTween;

    var enabled : Bool;

    var callback : Void -> Void;

    public function new(World : PlayState, ?Callback : Void -> Void)
    {
        super();

        world = World;

        shader = new FlxSprite(0, 240).makeGraphic(FlxG.width, FlxG.height-240, 0xFF000000);
        shader.alpha = 0;
        add(shader);

        FlxTween.tween(shader, {alpha : 0.55}, 0.2, {ease : FlxEase.cubeIn});

        curtain = new Curtain(26, 16, this, onCurtainDrawn);
        add(curtain);

        // TODO: Randomize a bit the sticker positions
        btnResume = new Button(83 + FlxG.random.int(-8, 8), 92 + FlxG.random.int(-8, 8), onResumeButtonPressed);
        btnResume.loadSpritesheet("assets/ui/pause-btn-continue.png", 58, 35);
        btnResume.visible = false;
        btnExit = new Button(39 + FlxG.random.int(-8, 8), 144 + FlxG.random.int(-8, 8), onExitButtonPressed);
        btnExit.loadSpritesheet("assets/ui/pause-btn-giveup.png", 58, 24);
        btnExit.visible = false;

        add(btnResume);
        add(btnExit);

        enabled = false;
        callback = Callback;
    }

    public function clean()
    {
        if (tween != null)
            tween.cancel();

        btnResume.destroy();
        btnExit.destroy();
        // tween.destroy();
        shader.destroy();
    }

    override public function create()
    {
    }

    function onCurtainDrawn()
    {
        // tween = FlxTween.tween(group, {y : FlxG.height / 2 - dialogHeight / 2}, 0.75, {onComplete: onGroupPositioned, ease : FlxEase.elasticOut });
        btnResume.scale.set(1.5, 1.5);
        btnResume.alpha = 0;
        btnResume.visible = true;
        FlxTween.tween(btnResume.scale, {x: 1, y: 1}, 0.35, {startDelay: 0.1, onComplete: onStickersPasted, ease: FlxEase.expoOut});
        FlxTween.tween(btnResume, {alpha: 1}, 0.15, {startDelay: 0.1, ease: FlxEase.expoOut});

        btnExit.scale.set(1.5, 1.5);
        btnExit.visible = true;
        FlxTween.tween(btnExit.scale, {x: 1, y: 1}, 0.35, {ease: FlxEase.expoOut});
    }

    function onStickersPasted(t : FlxTween)
    {
        enabled = true;
    }

    override public function update(elapsed:Float)
    {
        GamePad.handlePadState();

        // Disabling click outside of the box to close
        /*for (touch in FlxG.touches.list)
		{
			if (touch.pressed)
			{
				if (!touch.overlaps(group))
                {
                    onResumeButtonPressed();
                    break;
                }
            }
        }*/

        if (enabled)
        {
            if (GamePad.justPressed(GamePad.Pause))
            {
                onResumeButtonPressed();
            }
            else if (GamePad.justPressed(GamePad.Shoot) || FlxG.keys.justPressed.ENTER)
            {
                onExitButtonPressed();
            }
        }

        super.update(elapsed);
    }

    function onGroupLeave() : Void
    {
        clean();

        if (callback != null)
        {
            callback();
        }

        close();
    }

    function onResumeButtonPressed() : Void
    {
        if (enabled)
        {
            enabled = false;
            if (tween != null)
                tween.cancel();

            // FlxTween.tween(shader, {alpha : 0.0}, 0.2, {ease : FlxEase.cubeIn});
            // FlxTween.tween(group, { y : -dialogHeight }, 0.6, { ease: FlxEase.circOut,onComplete: onGroupLeave });
            /*new FlxTimer().start(0.2, function(t:FlxTimer) {
                onGroupLeave(null);
            });*/

            curtain.hide(onGroupLeave);
        }
    }

    function onExitButtonPressed() : Void
    {
        if (enabled)
        {
            BgmEngine.stopCurrent();

            active = false;
            if (tween != null)
                tween.cancel();

            // FlxTween.tween(group, { y : FlxG.height + 16 }, 0.75, {ease: FlxEase.elasticOut});
            FlxG.camera.fade(0xFF000000, 1, function() {
                clean();
                GameController.OnPuzzleGiveup(world.mode, world.flowController.getStoredData());
            });
        }
    }

    function decorateButton(button : FlxButtonPlus)
    {
        button.updateActiveButtonColors([0xFF202020, 0xFF202020]);
        button.updateInactiveButtonColors([0xFF000000, 0xFF000000]);
    }
}
