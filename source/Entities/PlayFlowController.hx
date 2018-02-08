package;

import flixel.FlxG;
import flixel.util.FlxTimer;

class PlayFlowController
{
    var world : PlayState;
    var grid : BubbleGrid;
    var puzzle : puzzle.PuzzleData;

    var trackMetrics : Bool;
    var updateDifficulty : Bool;

    /** Metrics **/
    var playTime : Float;
    var timer : FlxTimer;

    var score : Int;
    var bubbleCount : Int;
    var screenCleanCount : Int;
    var rowCount : Int;

    /** Internal operation variables **/
    var lastBubbleCount : Int;
    var lastIncreaseTime : Float;
    var timesIncreased : Int;

    // Maximum time allowed without a difficulty increase (in seconds)
    var MaxIdleTime : Float = 120;
    // Factor to apply to current world dropDelay for substraction
    var DropDelayFactor : Float = 0.2;

    public function new(World : PlayState, ?SaveData : PlayFlowSaveData = null)
    {
        world = World;
        puzzle = world.puzzleData;
        grid = world.grid;

        trackMetrics = true;

        if (world.mode == PlayState.ModeArcade)
        {
            updateDifficulty = true;
        }
        else if (world.mode == PlayState.ModePuzzle)
        {
            // TODO. Increase difficulty depending on the puzzle mode?
            updateDifficulty = false;
        }

        if (SaveData != null)
        {
            playTime = SaveData.playTime;
            score = SaveData.score;
            bubbleCount = SaveData.bubbleCount;
            screenCleanCount = SaveData.screenCleanCount;
            rowCount = SaveData.rowCount;

            lastBubbleCount = SaveData.lastBubbleCount;
            lastIncreaseTime = SaveData.lastIncreaseTime;
            timesIncreased = SaveData.timesIncreased;
        }
        else
        {
            playTime = 0;
            score = 0;
            bubbleCount = 0;
            screenCleanCount = 0;
            rowCount = 0;

            lastBubbleCount = 0;
            lastIncreaseTime = 0;
            timesIncreased = 0;
        }

        FlxG.watch.add(this, "playTime");
        FlxG.watch.add(this, "bubbleCount");
        FlxG.watch.add(this, "rowCount");
        FlxG.watch.add(this, "screenCleanCount");

        timer = new FlxTimer().start(1, onPlayTimeTimer, 0);
    }

    public function pause()
    {
        timer.active = false;
    }

    public function resume()
    {
        timer.active = true;
    }

    public function onPlayStep()
    {
        if (updateDifficulty)
        {
            if (bubbleCount - lastBubbleCount > 100)
            {
                increaseDifficulty();
                lastBubbleCount = bubbleCount;
            }
        }
    }

    function onPlayTimeTimer(timer : FlxTimer)
    {
        playTime++;

        if (updateDifficulty)
        {
            // Increase difficulty when we have not for some time
            if (playTime - lastIncreaseTime > MaxIdleTime)
            {
                increaseDifficulty();
            }
        }
    }

    function increaseDifficulty()
    {
        if (!updateDifficulty)
            return;

        trace("Increasing difficulty...");

        lastIncreaseTime = playTime;

        // Some times, add a bubble color (this should be revisited)
        if ([2, 6, 10, 14, 20, 30].indexOf(timesIncreased) > -1)
        {
            // Add a color
            if (!addColor())
                lowerDropDelay();
        }
        // Generally, make things drop quicker
        else
        {
            lowerDropDelay();
        }

        timesIncreased++;

        disableGuide();
        // TODO: Remove this
        // Notify the user!
        // FlxG.camera.flash(0xFFFFFFFF, 0.5);
    }

    function lowerDropDelay()
    {
        // Reduce the delay between drops
        world.dropDelay -= Std.int(world.dropDelay*DropDelayFactor);
    }

    function addColor() : Bool
    {
        var added : Bool = false;

        var currentColors = world.availableColors.length;
        if (currentColors < 8)
        {
            world.availableColors.push(new BubbleColor(currentColors));
        }

        return added;
    }

    public function onRowGenerated()
    {
        rowCount++;
    }

    public function onBubbleDestroyed(?ammount : Int = 1)
    {
        bubbleCount += ammount;
    }

    public function onScreenCleared()
    {
        screenCleanCount++;

        // When the screen is cleared, increase difficulty
        increaseDifficulty();
    }

    public function getStoredData() : Dynamic
    {
        return {score : world.scoreDisplay.realScore, time : playTime, bubbles : bubbleCount, cleans: screenCleanCount};
    }

    public function disableGuide()
    {
        trace("Disabling guide, was " + (world.cursor.guideEnabled ? "enabled":"disabled"));
        if (world.cursor.guideEnabled)
            world.cursor.disableGuideAfterShots(10);
    }

    public function getSaveData() : PlayFlowSaveData
    {
        var data : PlayFlowSaveData = {
            playTime: playTime,
            score: world.scoreDisplay.realScore,
            bubbleCount: bubbleCount,
            screenCleanCount: screenCleanCount,
            rowCount: rowCount,
            lastBubbleCount: lastBubbleCount,
            lastIncreaseTime: lastIncreaseTime,
            timesIncreased: timesIncreased
        };

        return data;
    }
}

typedef PlayFlowSaveData = {
    /** Metrics **/
    var playTime : Float;

    var score : Int;
    var bubbleCount : Int;
    var screenCleanCount : Int;
    var rowCount : Int;

    /** Internal operation variables **/
    var lastBubbleCount : Int;
    var lastIncreaseTime : Float;
    var timesIncreased : Int;
}
