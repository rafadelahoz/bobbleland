package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxBitmapTextField;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxSpriteUtil;

import flixel.addons.ui.FlxButtonPlus;

import text.PixelText;

class PauseSubstate extends FlxSubState
{
    var shader : FlxSprite;
    
    var group : FlxSpriteGroup;    
    var dialogWidth : Int;
    var dialogHeight : Int;
    
    var btnResume : FlxButtonPlus;
    var btnExit : FlxButtonPlus;
    
    var tween : FlxTween;
    
    var enabled : Bool;
    
    public function new()
    {
        super();
        
        shader = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        shader.alpha = 0;
        add(shader);
        
        FlxTween.tween(shader, {alpha : 0.77}, 0.2, {ease : FlxEase.cubeIn});
        
        dialogWidth = Std.int(FlxG.width*0.7);
        dialogHeight = Std.int(FlxG.height*0.5);
        
        group = new FlxSpriteGroup(FlxG.width/2 - dialogWidth/2, -dialogHeight);
        add(group);
        
        var bg : FlxSprite = new FlxSprite(0, 0).makeGraphic(dialogWidth, dialogHeight, 0xFF000000/*0xFF1D2B53*/);
        FlxSpriteUtil.drawRect(bg, 0, 0, Std.int(bg.width-2), Std.int(bg.height-1), 0xFF000000, {thickness : 2, color : 0xFFFFFFFF});
        group.add(bg);
        
        var text : FlxBitmapTextField = PixelText.New(dialogWidth/2 - 16, 8, "PAUSED");
        group.add(text);
        
        var bw : Int = Std.int(dialogWidth * 0.8);
        var bh : Int = 24;
        
        btnResume = new FlxButtonPlus(dialogWidth/2-bw/2, 2*Std.int(dialogHeight / 4)-8, onResumeButtonPressed, "Resume", bw, bh);
        btnExit = new FlxButtonPlus(dialogWidth/2-bw/2, 3*Std.int(dialogHeight / 4)-8, onExitButtonPressed, "Give up", bw, bh);
        
        decorateButton(btnResume);
        decorateButton(btnExit);
        
        group.add(btnResume);
        group.add(btnExit);
        
        enabled = false;
    }
    
    public function clean() 
    {
        if (tween != null)
            tween.cancel();
            
        btnResume.destroy();
        btnExit.destroy();
        tween.destroy();
        group.destroy();
        shader.destroy();
    }
    
    override public function create()
    {
        tween = FlxTween.tween(group, {y : FlxG.height / 2 - dialogHeight / 2}, 0.75, { complete: onGroupPositioned, ease : FlxEase.elasticOut });
    }
    
    override public function update()
    {
        for (touch in FlxG.touches.list)
		{
			if (touch.pressed)
			{
				if (!touch.overlaps(group))
                {
                    onResumeButtonPressed();
                    break;
                }
            }
        }
        
        super.update();
    }
    
    function onGroupPositioned(_t:FlxTween) : Void
    {
        enabled = true;
        tweenToNewPosition();
    }
    
    function tweenToNewPosition()
    {
        var newPos : FlxPoint = getValidPosition();
        if (tween != null)
            tween.cancel();
            
        tween = FlxTween.tween(group, {x : newPos.x, y : newPos.y}, 2, { ease: FlxEase.circInOut, complete: function(_t:FlxTween) {
            tweenToNewPosition();
        }});
    }
    
    function getValidPosition() : FlxPoint
    {
        var baseX : Float = FlxG.width/2 - dialogWidth/2;
        var baseY : Float = FlxG.height/2 - dialogHeight/2;
        var xx : Float = FlxRandom.floatRanged(baseX-8, baseX+8);
        var yy : Float = FlxRandom.floatRanged(baseY-10, baseY+10);
        return new FlxPoint(xx, yy);
    }
    
    function onGroupLeave(_t:FlxTween) : Void
    {
        clean();
        close();
    }
    
    function onResumeButtonPressed() : Void
    {
        if (enabled)
        {
            enabled = false;
            if (tween != null)
                tween.cancel();
                
            FlxTween.tween(shader, {alpha : 0.0}, 0.2, {ease : FlxEase.cubeIn});
            FlxTween.tween(group, { y : -dialogHeight }, 0.6, { ease: FlxEase.circOut, complete: onGroupLeave });
        }
    }
    
    function onExitButtonPressed() : Void
    {
        if (enabled)
        {
            active = false;
            if (tween != null)
                tween.cancel();
                
            FlxTween.tween(group, { y : FlxG.height + 16 }, 0.75, {ease: FlxEase.elasticOut});
            FlxG.camera.fade(0xFF000000, 1, function() {
                clean();
                GameController.OnPuzzleGiveup();
            });
        }
    }
    
    function decorateButton(button : FlxButtonPlus)
    {
        button.updateActiveButtonColors([0xFF202020, 0xFF202020]);
        button.updateInactiveButtonColors([0xFF000000, 0xFF000000]);
    }
}