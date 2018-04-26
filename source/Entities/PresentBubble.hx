package;

import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;

class PresentBubble extends Bubble
{
    public var content : Int;

    public function new(X : Float, Y : Float, World : PlayState, Color : BubbleColor)
    {
        super(X, Y, World, Color);
    }

    public function setContent(Content : Int)
    {
        content = Content;
        trace("Present with content", Content);
    }

    override public function handleGraphic()
    {
        // TODO: Actual graphic
        makeGraphic(Std.int((Size+1)*2.5), Std.int((Size+1)*2.5), 0x00000000);
        FlxSpriteUtil.drawCircle(this, width/2, height/2, Size * 1.5, 0xFF00FF0A);
    }

    public function onOpen()
    {
        SfxEngine.play(SfxEngine.SFX.BubbleStop);
		SfxEngine.play(SfxEngine.SFX.Accept);

		var neighbours : Array<Bubble> = grid.getNeighbours(this);
		for (neigh in neighbours)
		{
			neigh.triggerRot(true);
			if (grid.isPositionValid(neigh.getCurrentCell()))
				grid.setData(neigh.getCurrentCell().x, neigh.getCurrentCell().y, null);
		}

		new FlxTimer().start(0.7, function(t:FlxTimer) {
			world.handleDisconnectedBubbles();
			world.handlePostShoot();
		});

		var presentCell : FlxPoint = cellPosition;
		trace("Present hit, waiting 2 secs");
		new FlxTimer().start(2, function(t:FlxTimer) {
			trace("DONE WAITING, spawining a target");
			Bubble.CreateAt(presentCell.x, presentCell.y, new BubbleColor(BubbleColor.SpecialTarget), world);
			world.switchState(PlayState.StateAiming);
		});
    }
}
