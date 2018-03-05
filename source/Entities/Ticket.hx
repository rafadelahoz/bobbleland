package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSpriteUtil;

import text.PixelText;
import text.TextUtils;

class Ticket extends FlxSpriteGroup
{
    public function new()
    {
        super(0, 0);
    }

    public function init(data : Dynamic)
    {
        add(new FlxSprite(0, 0, "assets/ui/ticket-top.png"));

        add(new FlxSprite(0, 96, "assets/ui/ticket-bottom.png"));

        var sprite : FlxSprite = new FlxSprite(0, 0);
        sprite.makeGraphic(Std.int(this.width), Std.int(this.height), 0x00FFFFFF);
        sprite.stamp(this);

        var bd : flash.display.Bitmap = new flash.display.Bitmap(sprite.pixels);
        trace(Screenshot.save(bd));
    }

    override public function draw()
    {
        super.draw();
    }
}
