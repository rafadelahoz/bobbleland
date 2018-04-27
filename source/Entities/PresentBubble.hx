package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;

class PresentBubble extends Bubble
{
    var ShineTimerBase : Float = 1;
    var ShineTimerVariation : Float = 0.25;

    public var content : Int;

    var shineTimer : FlxTimer;
    var opened : Bool;

    public function new(X : Float, Y : Float, World : PlayState, Color : BubbleColor)
    {
        super(X, Y, World, Color);

        opened = false;
        shineTimer = new FlxTimer();
    }

    override public function destroy()
    {
        if (shineTimer != null)
        {
            shineTimer.cancel();
            shineTimer.destroy();
        }

        super.destroy();
    }

    public function setContent(Content : Int)
    {
        content = Content;
        trace("Present with content", Content);

        shine(shineTimer);
    }

    override public function handleGraphic()
    {
        loadGraphic("assets/images/bubble_present.png");
    }

    function shine(t : FlxTimer)
    {
        world.add(new PresentSpark(FlxG.random.float(x+2, x+width-10),
                                   FlxG.random.float(y+2, y+width-10),
                                   this,
                                   getSparkColor()));
        t.start(FlxG.random.float(ShineTimerBase * (1-ShineTimerVariation),
                                               ShineTimerBase * (1 + ShineTimerVariation)),
                            shine);
    }

    function getSparkColor() : Int
    {
        switch (content)
        {
            case SpecialBubbleController.PresentContent.Points:
                return Palette.Yellow;
            case SpecialBubbleController.PresentContent.Blocker:
                return Palette.Brown;
            case SpecialBubbleController.PresentContent.Guideline:
                return Palette.Indigo;
            case SpecialBubbleController.PresentContent.Bumper:
                return Palette.Blue;
            case SpecialBubbleController.PresentContent.Hole:
                return Palette.Red;
            case SpecialBubbleController.PresentContent.Bubbles:
                return Palette.Green;
            default:
                return Palette.White;
        }
    }

    override public function update(elapsed : Float)
    {
        super.update(elapsed);

        if (state != Bubble.StateIdling)
        {
            shineTimer.cancel();
        }
    }

    public function onOpen()
    {
        if (opened)
            return;

        opened = true;

        shineTimer.cancel();

        switch (content)
        {
            case SpecialBubbleController.PresentContent.Points:
                onOpenPoints();
            /*case SpecialBubbleController.PresentContent.Blocker:
                return Palette.Brown;
            case SpecialBubbleController.PresentContent.Guideline:
                return Palette.Indigo;
            case SpecialBubbleController.PresentContent.Bumper:
                return Palette.Blue;
            case SpecialBubbleController.PresentContent.Hole:
                return Palette.Red;
            case SpecialBubbleController.PresentContent.Bubbles:
                return Palette.Green;*/
            default:
                onOpenDefault();
        }
    }

    // TODO: To be removed
    function onOpenDefault()
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
            world.switchState(PlayState.StateAiming);
        });
    }

    function onOpenPoints()
    {
        SfxEngine.play(SfxEngine.SFX.BubbleStop);

        new FlxTimer().start(0.7, function(t:FlxTimer) {
            world.handleDisconnectedBubbles();
            world.handlePostShoot();
            world.switchState(PlayState.StateAiming);
        });

        world.add(new TextNotice(x + width/2, y + height/2, "+3000 POINTS!"));

        var presentCell : FlxPoint = cellPosition;
        trace("Awarding points in 0.3 secs");
        new FlxTimer().start(0.3, function(t:FlxTimer) {
            world.scoreDisplay.add(3000);

            SfxEngine.play(SfxEngine.SFX.Chime);
        });
    }
}

class PresentSpark extends FlxSprite
{
    var delta : FlxPoint;
    var owner : FlxSprite;

    public function new(X : Float, Y : Float, Owner : FlxSprite, ?Color : Int = -1)
    {
        super(X, Y);

        owner = Owner;
        delta = FlxPoint.get(X - Owner.x, Y - Owner.y);

        loadGraphic("assets/images/spark_sheet.png", true, 8, 8);
        animation.add("blink", [0, 1, 2, 3, 1, 0], FlxG.random.int(7, 10), false);
        animation.finishCallback = onAnimationFinish;
        animation.play("blink");

        if (Color != -1)
            color = Color;
        else
            color = Palette.White;
    }

    override public function destroy()
    {
        delta.put();
        super.destroy();
    }

    function onAnimationFinish(animName : String)
    {
        destroy();
    }

    override public function draw()
    {
        // Move with your owner entity
        x = owner.x + delta.x;
        y = owner.y + delta.y;

        super.draw();
    }
}
