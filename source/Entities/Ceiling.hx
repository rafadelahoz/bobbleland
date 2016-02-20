package;

import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil;

class Ceiling extends FlxSprite
{
    public var world : PlayState;
    public var grid : BubbleGrid;

    public var bottomBar : FlxSprite;

    public var ceilY : Float;

    public function new(World : PlayState)
    {
        world = World;
        grid = world.grid;

        super(grid.x, grid.y);

        bottomBar = new FlxSprite(0, 0, "assets/images/ceiling.png");
        bottomBar.visible = false;

        makeGraphic(Std.int(grid.width),Std.int(grid.height), 0x00FFFFFF);
    }

    override public function update(elapsed:Float)
    {
        // Update the graphic only when necessary
        if (grid.getTop() != ceilY)
        {
            ceilY = grid.getTop();
            FlxSpriteUtil.fill(this, 0x00000000);
            FlxSpriteUtil.drawRect(this, 0, 0, width, ceilY - y, 0xFF2A2632);
            stamp(bottomBar, 0, Std.int(ceilY-y-bottomBar.height));
        }

        super.update(elapsed);
    }

    override public function draw()
    {
        super.draw();
    }
}
