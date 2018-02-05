package;

import flixel.util.FlxSave;

class ArcadeGameStatus
{
    static var savefile : String = "savefile";

    static var arcadeData : ArcadeData;
    static var arcadeGameData : puzzle.PuzzleData;

    public static function init()
    {
        if (arcadeGameData == null)
        {
            arcadeGameData = new puzzle.PuzzleData();

            arcadeGameData.mode = puzzle.PuzzleData.ModeEndless;

            arcadeGameData.background = null;
            arcadeGameData.bubbleSet = null;
            arcadeGameData.character = null;

            arcadeGameData.initialRows = 4;
            arcadeGameData.dropDelay = 20;
            arcadeGameData.seconds = -1;
            arcadeGameData.usedColors = generateColorSet(5);
        }

        if (arcadeData == null)
        {
            trace("No arcadeData, loading");
            arcadeData = loadArcadeConfigData();

            if (arcadeData == null)
            {
                trace("Nothing to load, init");
                arcadeData = {
                    difficulty: 2, character: null,
                    highScore: 0, maxBubbles: 0, longestGame: 0,
                    totalBubbles: 0, totalTime: 0, totalCleans: 0
                };

                saveArcadeConfigData();
            }

            trace(arcadeData);
        }
    }

    public static function getConfigData() : ArcadeData
    {
        return arcadeData;
    }

    public static function setConfigData(data : ArcadeData)
    {
        arcadeData = data;
    }

    public static function storePlayData(playData : Dynamic)
    {
        if (playData.score > arcadeData.highScore)
            arcadeData.highScore = playData.score;

        if (playData.bubbles > arcadeData.maxBubbles)
            arcadeData.maxBubbles = playData.bubbles;

        if (playData.time > arcadeData.longestGame)
            arcadeData.longestGame = playData.time;

        arcadeData.totalBubbles += playData.bubbles;
        arcadeData.totalTime += playData.time;
        arcadeData.totalCleans += playData.cleans;
    }

    static function loadArcadeConfigData() : ArcadeData
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        return save.data.arcadeData;
    }

    public static function saveArcadeConfigData()
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        save.data.arcadeData = arcadeData;

        save.close();
    }

    public static function clearConfigData()
    {
        trace("Clearing config data...");

        arcadeData.difficulty = 3;
        arcadeData.character = null;

        saveArcadeConfigData();
    }

    public static function clearHistoryData()
    {
        trace("Clearing history data...");

        arcadeData.highScore = 0;
        arcadeData.longestGame = 0;
        arcadeData.maxBubbles = 0;
        arcadeData.totalTime = 0;
        arcadeData.totalBubbles = 0;
        arcadeData.totalCleans = 0;

        saveArcadeConfigData();
    }

    public static function setInitialRows(rows : Int)
    {
        arcadeGameData.initialRows = rows;
    }

    public static function setDropDelay(seconds : Int)
    {
        arcadeGameData.dropDelay = seconds;
    }

    public static function setUsedColors(number : Int)
    {
        arcadeGameData.usedColors = generateColorSet(number);
    }

    public static function setGuideEnabled(enabled : Bool)
    {
        arcadeGameData.guideEnabled = enabled;
    }

    public static function getCharacter() : String
    {
        return arcadeGameData.character;
    }

    public static function setCharacter(id : String)
    {
        arcadeGameData.character = id;
    }

    static function generateColorSet(number : Int) : Array<BubbleColor>
    {
        var usedColors : Array<BubbleColor> = [];
        for (index in 0...number)
        {
            usedColors.push(new BubbleColor(index));
        }

        return usedColors;
    }

    public static function getData() : puzzle.PuzzleData
    {
        return arcadeGameData;
    }
}

typedef ArcadeData = {
    var difficulty : Int;
    var character : String;

    var highScore : Int;
    var longestGame : Int;
    var maxBubbles : Int;

    var totalBubbles: Int;
    var totalTime : Int;
    var totalCleans : Int;
}
