package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class PresentBubble extends Bubble
{
    public var content : Int;

    var opened : Bool;

    public function new(X : Float, Y : Float, World : PlayState, Color : BubbleColor)
    {
        super(X, Y, World, Color);

        ShineTimerBase = 1;
        ShineTimerVariation = 0.25;

        opened = false;
    }

    public function setContent(Content : Int)
    {
        content = Content;
        trace("Present with content", Content);

        shine();
    }

    override public function handleGraphic()
    {
        loadGraphic("assets/images/bubble_present_c.png");
        offset.set(1, 1);
    }

    override function getSparkColor() : Int
    {
        switch (content)
        {
            case SpecialBubbleController.PresentContent.Points:
                return Palette.Yellow;
            case SpecialBubbleController.PresentContent.Blocker:
                return Palette.Brown;
            case SpecialBubbleController.PresentContent.Guideline:
                return Palette.Yellow;
            /*case SpecialBubbleController.PresentContent.Bumper:
                return Palette.Blue;
            case SpecialBubbleController.PresentContent.Hole:
                return Palette.Red;*/
            case SpecialBubbleController.PresentContent.Bubbles:
                return Palette.Red;
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

        if (opened)
            vibrate(true);
    }

    public function onOpen()
    {
        if (opened)
            return;

        opened = true;

        world.grid.setData(cellPosition.x, cellPosition.y, null);
        solid = false;

        shineTimer.cancel();

        SfxEngine.play(SfxEngine.SFX.BubbleStop);

        FlxTween.tween(this.scale, {x : 2, y: 2}, 0.4, {ease: FlxEase.cubeOut});
        vibrate(true);
        SfxEngine.play(SfxEngine.SFX.Rumble, 0.8, true);
        new FlxTimer().start(1, handleOpen);
    }

    function handleOpen(t : FlxTimer)
    {
        SfxEngine.stop(SfxEngine.SFX.Rumble);

        world.handleDisconnectedBubbles();

        visible = false;

        for (i in 0...FlxG.random.int(32, 48))
        {
            world.add(new ParticleOpen(this));
        }

        // t.start(0.3, function(t:FlxTimer) {
            // TODO: Open explosion effect
            switch (content)
            {
                case SpecialBubbleController.PresentContent.Points:
                    onOpenPoints();
                case SpecialBubbleController.PresentContent.Blocker:
                    onOpenBlocker();
                case SpecialBubbleController.PresentContent.Guideline:
                    onOpenGuideline();
                /*case SpecialBubbleController.PresentContent.Bumper:
                    return Palette.Blue;
                case SpecialBubbleController.PresentContent.Hole:
                    return Palette.Red;*/
                case SpecialBubbleController.PresentContent.Bubbles:
                    onOpenBubbles();
                default:

            }
        // });
    }

    // TODO: To be removed
    function onOpenDefault()
    {
        SfxEngine.play(SfxEngine.SFX.PresentOpen);
        // SfxEngine.play(SfxEngine.SFX.BubbleStop);
		// SfxEngine.play(SfxEngine.SFX.Accept);

        // Destroy neighbours
        var neighbours : Array<Bubble> = grid.getNeighbours(this);
        for (neigh in neighbours)
        {
            neigh.triggerRot(true);
            if (grid.isPositionValid(neigh.getCurrentCell()))
                grid.setData(neigh.getCurrentCell().x, neigh.getCurrentCell().y, null);
        }

        new FlxTimer().start(0.7, afterOpening);
    }

    function onOpenBlocker()
    {
        new FlxTimer().start(0.7, afterOpening);

        SfxEngine.play(SfxEngine.SFX.BubbleStop);
		SfxEngine.play(SfxEngine.SFX.Blocker);

        Bubble.CreateAt(cellPosition.x, cellPosition.y, new BubbleColor(BubbleColor.SpecialBlocker), world);
    }

    function onOpenPoints()
    {
        new FlxTimer().start(0.7, afterOpening);

        SfxEngine.play(SfxEngine.SFX.PresentOpen);

        // Decide ammount of points
        var points : Int =
            FlxG.random.getObject([1, 50, 100, 1000, 3000, 5000, 7500, 10000, 150000],
                                  [1, 20, 30,   100,   80,   40,    1,  0.01, 0.0001]);

        // Compose a message
        var message : String = "+" + points + " POINTS";
        // +1 POINT?
        if (points == 1)
            message = message.substr(0, message.length-1) + "?";
        // +10000 POINTS!!!
        else if (points > 9999)
            message += "!!!";
        // +5000 POINTS!!!
        else if (points >= 1000)
            message += "!";
        // Default: +50 POINTS

        world.add(new TextNotice(x + width/2, y + height/2, message));

        new FlxTimer().start(0.3, function(t:FlxTimer) {
            world.scoreDisplay.add(points);
            SfxEngine.play(SfxEngine.SFX.Chime);
        });
    }

    function onOpenGuideline()
    {
        // Avoid awarding the guide if the guide is already enabled
        if (world.cursor.guideEnabled)
            onOpenPoints();
        else
        {
            SfxEngine.play(SfxEngine.SFX.PresentOpen);

            new FlxTimer().start(0.7, afterOpening);

            world.add(new TextNotice(x + width/2, y + height/2, "GUIDE ENABLED!"));

            new FlxTimer().start(0.3, function(t:FlxTimer) {
                world.flowController.enableGuide();
                SfxEngine.play(SfxEngine.SFX.Chime);
            });
        }
    }

    function onOpenBubbles()
    {
        SfxEngine.play(SfxEngine.SFX.BubbleStop);
        SfxEngine.play(SfxEngine.SFX.Blocker);

        // TODO: Decide given board status?
        var bubblesToGenerate : Int = FlxG.random.int(3, 5);
        // Overflow effect
        Bubble.CreateAt(cellPosition.x, cellPosition.y, world.generator.getPositiveColor(), world);
        bubblesToGenerate--;
        new FlxTimer().start(0.3, function(t:FlxTimer){
            bubbleFlow(0.3, cellPosition, bubblesToGenerate, false);
        });
    }

    function bubbleFlow(delay : Float, fromCell : FlxPoint, remainingBubbles : Int, repeatingOrigin : Bool)
    {
        var abort : Bool = false;

        var adjacents : Array<FlxPoint> = world.grid.getLowerAdjacentPositions(fromCell);
        FlxG.random.shuffle(adjacents);

        var chosenAdjacents : Array<FlxPoint> = [];
        for (adj in adjacents)
        {
            // Consider only lower positions
            if (remainingBubbles > 0)
            {
                // Avoid generating a bubble under the line
                // so the player can save the situation!
                if (adj.y >= world.grid.bottomRow)
                {
                    abort = true;
                    break;
                }

                if (world.grid.isPositionValid(adj) && world.grid.getData(adj.x, adj.y) == null)
                {
                    // Don't always choose all the adjacents
                    if (FlxG.random.bool(100 - (chosenAdjacents.length / adjacents.length) * 90))
                    {
                        chosenAdjacents.push(adj);
                        remainingBubbles--;
                        var bubble : Bubble = Bubble.CreateAt(adj.x, adj.y, world.generator.getPositiveColor(), world);
                        SfxEngine.play(SfxEngine.SFX.BubbleFall);

                        break;
                    }
                }
            }
        }

        if (!abort && remainingBubbles > 0)
        {
            var nextCell : FlxPoint = FlxG.random.getObject(chosenAdjacents);
            if (nextCell == null)
            {
                // We can't repeat the origin twice: that means something is really wrong
                if (repeatingOrigin)
                {
                    new FlxTimer().start(0.2, afterOpening);
                    return;
                }
                else
                {
                    nextCell = fromCell;
                    repeatingOrigin = true;
                }
            }

            new FlxTimer().start(delay * 0.75, function(t:FlxTimer){
                bubbleFlow(delay * 0.75, nextCell, remainingBubbles, repeatingOrigin);
            });
        }
        else
        {
            new FlxTimer().start(0.2, afterOpening);
        }
    }

    function afterOpening(t : FlxTimer)
    {
        world.handlePostShoot();
        world.switchState(PlayState.StateAiming);
        onDeath();
    }
}

class ParticleOpen extends FlxSprite
{
    public function new(Parent : FlxSprite)
    {
        super(Parent.x + Parent.width / 2, Parent.y + Parent.height / 2);

        var targetX : Float = FlxG.random.float(Parent.x - 14, Parent.x+Parent.width+10);
        var targetY : Float = FlxG.random.float(Parent.y - 14, Parent.y+Parent.height+10);

        loadGraphic("assets/images/fx-part-bubble.png", true, 8, 8);
        animation.add("anim", [FlxG.random.int(0, 1)], 0, true);
        animation.play("anim");

        FlxTween.tween(this, {x : targetX, y : targetY}, FlxG.random.float(0.1, 0.2), {ease: FlxEase.expoOut});

        scale.x = FlxG.random.float(1, 3);
        scale.y = scale.x;

        color = FlxG.random.getObject([Palette.Black/*, Palette.DarkBlue, Palette.DarkPurple, Palette.Brown*/]);

        FlxTween.tween(this.scale, {x: 0, y: 0}, FlxG.random.float(0.2, 0.5), {startDelay: 0.2, ease: FlxEase.bounceInOut});
        FlxTween.tween(this, {alpha: 0}, FlxG.random.float(0.2, 0.5), {startDelay: 0.2, ease: FlxEase.bounceInOut, onComplete: handleDestroy});
    }

    function handleDestroy(t:FlxTween)
    {
        t.destroy();

        destroy();
    }
}
