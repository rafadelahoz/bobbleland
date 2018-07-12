package;

import flixel.FlxG;
import flixel.util.FlxTimer;

class SpecialBubbleController
{
    var world : PlayState;
    var grid : BubbleGrid;

    /** The thing **/
    var generationProbabilityBase : Float;
    var contentProbability : Array<Float>;

    /** Metrics **/
    var playTime : Float;
    var timer : FlxTimer;

    var score : Int;
    var bubbleCount : Int;
    var screenCleanCount : Int;
    var rowCount : Int;

    /** Internal operation variables **/
    var lastScore : Int;
    var lastBubbleCount : Int;
    var lastIncreaseTime : Float;

    public function new(World : PlayState, ?SaveData : SpecialBubbleSaveData = null)
    {
        world = World;
        grid = world.grid;

        if (SaveData != null)
        {
            trace("Loaded SpecialBubbleData");

            playTime = SaveData.playTime;
            score = SaveData.score;
            bubbleCount = SaveData.bubbleCount;
            screenCleanCount = SaveData.screenCleanCount;
            rowCount = SaveData.rowCount;

            lastScore = SaveData.lastScore;
            lastBubbleCount = SaveData.lastBubbleCount;
            lastIncreaseTime = SaveData.lastIncreaseTime;

            contentProbability = SaveData.contentProbability;

            // load generationProbabilityBase
            generationProbabilityBase = 0;
        }
        else
        {
            trace("Reset SpecialBubbleData");

            playTime = 0;
            score = 0;
            bubbleCount = 0;
            screenCleanCount = 0;
            rowCount = 0;

            lastScore = 0;
            lastBubbleCount = 0;
            lastIncreaseTime = 0;

            generationProbabilityBase = 0;
            switch (World.playSessionData.initialDifficulty)
            {
                case 0:
                    contentProbability = [30, 70, 30, 30];
                case 1:
                    contentProbability = [50, 50, 30, 30];
                case 2:
                    contentProbability = [50, 50, 30, 30];
                case 3:
                    contentProbability = [25, 25, 25, 25];
                case 4:
                    contentProbability = [25, 25, 25, 25];
                default:
                    trace("NO INITIAL DIFFICULTY PROVIDED");
                    contentProbability = [50, 50, 30, 30];
            }

            trace("SpecialBubbleGenerator data reset");
        }

        timer = new FlxTimer().start(1, onPlayTimeTimer, 0);
    }

    public function getGenerationProbability() : Float
    {
        var probability : Float = generationProbabilityBase;

        // Bubbles
        if (bubbleCount - lastBubbleCount > 200)
        {
            var diff : Int = (bubbleCount - lastBubbleCount) - 200;
            var deltas : Int = Std.int(diff / 50);
            probability += deltas * 0.1;
        }

        // Score
        score = world.scoreDisplay.realScore;
        if (score - lastScore > 5000)
        {
            var diff : Int = (score - lastScore) - 5000;
            var deltas : Int = Std.int(diff / 1000);
            probability += deltas * 0.1;
        }

        // Others metrics go here

        return probability;
    }

    public function setContentProbability(Content : Int, Probability : Float)
    {
        contentProbability[Content] = Probability;
    }

    public function getPresentContent() : Int
    {
        return FlxG.random.weightedPick(contentProbability);
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

    }

    function onPlayTimeTimer(timer : FlxTimer)
    {
        playTime++;
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
    }

    public function onSpecialBubbleGenerated()
    {
        // DEBUG: Don't reset
        // return;

        // When a bubble is generated, use the current values as threshold
        lastScore = score;
        lastBubbleCount = bubbleCount;
        lastIncreaseTime = playTime;
    }

    public function getSaveData() : SpecialBubbleSaveData
    {
        var data : SpecialBubbleSaveData = {
            playTime: playTime,

            score: world.scoreDisplay.realScore,
            bubbleCount: bubbleCount,
            screenCleanCount: screenCleanCount,
            rowCount: rowCount,

            lastBubbleCount: lastBubbleCount,
            lastIncreaseTime: lastIncreaseTime,
            lastScore: lastScore,

            contentProbability: contentProbability
        };

        return data;
    }
}

typedef SpecialBubbleSaveData = {
    /** Metrics **/
    var playTime : Float;

    var score : Int;
    var bubbleCount : Int;
    var screenCleanCount : Int;
    var rowCount : Int;

    /** Internal operation variables **/
    var lastBubbleCount : Int;
    var lastIncreaseTime : Float;
    var lastScore : Int;

    var contentProbability : Array<Float>;
}

class PresentContent
{
    public static inline var Points    : Int = 0;
    public static inline var Guideline : Int = 1;
    public static inline var Blocker   : Int = 2;
    public static inline var Bubbles   : Int = 3;

    public static var Contents : Array<Int> = [Points, Guideline, Blocker, Bubbles];
}
