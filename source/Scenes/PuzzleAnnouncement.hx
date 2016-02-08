package scenes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxBitmapTextField;

import text.PixelText;

class PuzzleAnnouncement extends FlxSpriteGroup
{
    var w : Int;
    var h : Int;
    
    var background : FlxSprite;
    var message : FlxBitmapTextField;
    var warning : FlxBitmapTextField;
    
    var completionHandler : Void -> Void;
    
    public function new(X : Float, Y : Float)
    {
        super(X, Y);
        
        w = 16+2526+16;
        h = 16+20+16;
        
        x = FlxG.width / 2 - w/2;
        y = -h;
        
        background = new FlxSprite(x, y).makeGraphic(w, h, 0xFF000000);
        message = PixelText.New(16, 16, "A PUZZLE CHALLENGE IS COMING");
        warning = PixelText.New(16, 26, "     !PREPARE YOURSELF!     ");
        
        add(background);
        add(message);
        add(warning);
    }
    
    public function init(?Speed : Float = 300, ?OnComplete : Void -> Void = null) : Void
    {
        velocity.y = Speed;
        completionHandler = OnComplete;
    }
    
    override public function update()
    {
        if (velocity.y > 0 && y >= 240 - height/2) 
        {
            velocity.y = 0;
            y = 240 - height/2;
            if (completionHandler != null)
                completionHandler();
        }
        
        super.update();
    }
}