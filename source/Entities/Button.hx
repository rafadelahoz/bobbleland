package;

import flixel.FlxG;
import flixel.FlxSprite;

class Button extends FlxSprite
{
    var callback : Void -> Void;

    public function new(X : Float, Y : Float, ?Callback : Void -> Void = null)
    {
        super(X, Y);

        callback = Callback;
    }

    public function loadSpritesheet(Sprite : String, Width : Float, Height : Float)
    {
        loadGraphic(Sprite, true, Std.int(Width), Std.int(Height));

        animation.add("idle", [0]);
        animation.add("pressed", [1]);
        animation.play("idle");
    }

    override public function update()
    {
        animation.play("idle");

        #if desktop
        if (mouseOver())
        {
            if (FlxG.mouse.pressed)
            {
                animation.play("pressed");
            }
            else if (FlxG.mouse.justReleased)
            {
                animation.play("idle");
                if (callback != null)
                    callback();
            }
        }
        #end

        #if mobile
        for (touch in FlxG.touches.list)
		{
            if (touch.overlaps(this))
            {
    			if (touch.pressed)
    			{
    				animation.play("pressed");
                    break;
                }
                else if (touch.justReleased)
                {
                    animation.play("idle");
                    if (callback != null)
                        callback();

                    break ;
                }
            }
        }
        #end

        super.update();
    }

    function mouseOver()
    {
        var mouseX : Float = FlxG.mouse.x;
        var mouseY : Float = FlxG.mouse.y;
        
        if (scrollFactor.x == 0)
            mouseX = FlxG.mouse.screenX;
            
        if (scrollFactor.y == 0)
            mouseY = FlxG.mouse.screenY;
                
        return mouseX >= x && mouseX < (x + width) &&
               mouseY >= y && mouseY < (y + height);
    }
}
