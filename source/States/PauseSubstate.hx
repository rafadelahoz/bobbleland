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

    var borderTop : FlxSprite;
    var optionsPanel : OptionsPanel;

    var curtain : Curtain;
    public var btnResume : Button;
    public var btnExit : Button;

    var tween : FlxTween;

    public var enabled : Bool;

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

        // Awful sound, avoid
        // SfxEngine.play(SfxEngine.SFX.Curtain, 1);

        // TODO: Randomize a bit the sticker positions
        btnResume = new Button(83 + FlxG.random.int(-8, 8), 92 + FlxG.random.int(-8, 8), onResumeButtonPressed);
        btnResume.loadSpritesheet("assets/ui/pause-btn-continue.png", 58, 35);
        btnResume.visible = false;
        // btnResume.blend = flash.display.BlendMode.MULTIPLY;
        btnExit = new Button(39 + FlxG.random.int(-8, 8), 144 + FlxG.random.int(-8, 8), onExitButtonPressed);
        btnExit.loadSpritesheet("assets/ui/pause-btn-giveup.png", 58, 24);
        btnExit.visible = false;
        // btnExit.blend = flash.display.BlendMode.MULTIPLY;

        add(btnResume);
        add(btnExit);

        borderTop = new FlxSprite(0, -8, "assets/ui/border-top.png");
        borderTop.alpha = 0;
        add(borderTop);
        FlxTween.tween(borderTop, {alpha: 1}, 0.5, {ease : FlxEase.circInOut});

		optionsPanel = new OptionsPanel(true);
		add(optionsPanel);
        FlxTween.tween(optionsPanel.optionsTab, {alpha: 1}, 1, {ease : FlxEase.cubeInOut});

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
        btnResume.angle = FlxG.random.int(-5, 5);
        FlxTween.tween(btnResume.scale, {x: 1, y: 1}, 0.35, {startDelay: 0.1, onComplete: onStickersPasted, ease: FlxEase.expoOut});
        FlxTween.tween(btnResume, {alpha: 0.85}, 0.15, {startDelay: 0.1, ease: FlxEase.expoOut});

        btnExit.scale.set(1.5, 1.5);
        btnExit.visible = true;
        btnExit.alpha = 0.85;
        btnExit.angle = FlxG.random.int(-5, 5);
        FlxTween.tween(btnExit.scale, {x: 1, y: 1}, 0.35, {ease: FlxEase.expoOut});

        new FlxTimer().start(0.2, function(t:FlxTimer) {
            SfxEngine.play(SfxEngine.SFX.StickerA);
        });

        new FlxTimer().start(0.3, function(t:FlxTimer) {
            SfxEngine.play(SfxEngine.SFX.StickerB);
        });
    }

    function onStickersPasted(t : FlxTween)
    {
        enabled = true;
    }

    override public function update(elapsed:Float)
    {
        GamePad.handlePadState();

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

            btnExit.disable();
            btnResume.disable();

            if (tween != null)
                tween.cancel();

            if (optionsPanel.optionsPanel != null)
            {
                optionsPanel.hideOptionsPanel(function(t:FlxTween) {
                    hideCurtain();
                });
            }
            else
                hideCurtain();
        }
    }

    function hideCurtain()
    {
        curtain.hide(onGroupLeave);
        FlxTween.tween(borderTop, {alpha: 0}, 0.45, {startDelay : 0, ease: FlxEase.circOut});
        FlxTween.tween(optionsPanel.optionsTab, {alpha: 0}, 0.45, {startDelay : 0, ease: FlxEase.circOut});
        FlxTween.tween(curtain, {alpha : 0}, 2, {startDelay : 0.3, ease: FlxEase.circOut});
        FlxTween.tween(shader, {alpha: 0}, 0.45, {startDelay : 0, ease: FlxEase.circOut});
    }

    function onExitButtonPressed() : Void
    {
        if (enabled)
        {
            enabled = false;
            btnExit.disable();
            btnResume.disable();
            
            BgmEngine.stopCurrent();

            active = false;
            if (tween != null)
                tween.cancel();

            FlxG.camera.fade(0xFF000000, 1, false, function() {
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
