package;

import flixel.FlxG;
import flixel.util.FlxTimer;

class PlayFlowController
{
    var world : PlayState;
    var grid : BubbleGrid;

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

    var forcedShots : Int;

    // Maximum time allowed without a difficulty increase (in seconds)
    var MaxIdleTime : Float = 120;
    // Factor to apply to current world dropDelay for substraction
    var DropDelayFactor : Float = 0.2;

    public static var InitialGuideEnabledShots : Int = 5;
    public static var PresentGuideEnabledShots : Int = 20;

    public function new(World : PlayState, ?SaveData : PlayFlowSaveData = null)
    {
        world = World;
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
            trace("Loaded playFlowData");

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
            trace("Reset playFlowData");

            playTime = 0;
            score = 0;
            bubbleCount = 0;
            screenCleanCount = 0;
            rowCount = 0;

            lastBubbleCount = 0;
            lastIncreaseTime = 0;
            timesIncreased = 0;
        }

        // Forced shots are resetted each time
        forcedShots = 0;

        // trace("Current PlayFlowData", {playTime: playTime, score: score, bubbleCount: bubbleCount, screenCleanCount: screenCleanCount, rowCount: rowCount, lastBubbleCount: lastBubbleCount, lastIncreaseTime: lastIncreaseTime, timesIncreased: timesIncreased});
        // trace("Colors: " + world.availableColors.length);

        /*FlxG.watch.add(this, "playTime");
        FlxG.watch.add(this, "bubbleCount");
        FlxG.watch.add(this, "rowCount");
        FlxG.watch.add(this, "screenCleanCount");*/

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

    public function increaseDifficulty()
    {
        if (!updateDifficulty)
            return;

        trace("Increasing difficulty...");

        lastIncreaseTime = playTime;

        // Some times, add a bubble color (this should be revisited)
        if ([2, 6, 10, 14, 20, 30, 50].indexOf(timesIncreased) > -1)
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
        if (currentColors < 6)
        {
            world.availableColors.push(new BubbleColor(currentColors));
            added = true;
            trace("Included new color");
        }
        else if (currentColors >= 6)
        {
            world.availableColors.push(new BubbleColor(BubbleColor.SpecialBlocker));
            added = true;
            trace("Included blocker");
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

    public function onForcedShot()
    {
        forcedShots++;
    }

    public function getStoredData() : Dynamic
    {
        return {score : world.scoreDisplay.realScore, 
                time : playTime, bubbles : bubbleCount, 
                cleans: screenCleanCount, 
                level: world.playSessionData.initialDifficulty + 1,
                character: world.playSessionData.character,
                forcedShots: forcedShots};
    }

    public function enableGuide()
    {
        world.cursor.enableGuide(PresentGuideEnabledShots);
    }

    public function disableGuide()
    {
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

        // trace("PlayFlowController saved data", data);
        // trace("Current colors", world.availableColors.length);

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
