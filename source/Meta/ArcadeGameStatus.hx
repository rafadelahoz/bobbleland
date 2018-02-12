package;

import flixel.util.FlxSave;

class ArcadeGameStatus
{
    static var savefile : String = "savefile";

    static var arcadeData : ArcadeData;
    static var arcadeGameData : puzzle.PuzzleData;

    static var MAX_TIME : Int = 3599999;
    static var MAX_COUNT : Int = 99999999;
    static var MAX_SCS : Int = 9999;

    public static function init()
    {
        if (arcadeGameData == null)
        {
            arcadeGameData = new puzzle.PuzzleData();

            arcadeGameData.mode = puzzle.PuzzleData.ModeEndless;

            arcadeGameData.background = null;
            arcadeGameData.bubbleSet = null;
            arcadeGameData.character = null;
            arcadeGameData.bgm = "GameA";

            arcadeGameData.initialRows = 4;
            arcadeGameData.dropDelay = 20;
            arcadeGameData.seconds = -1;
            arcadeGameData.usedColors = generateColorSet(5);
        }

        if (arcadeData == null)
        {
            arcadeData = loadArcadeConfigData();

            if (arcadeData == null)
            {
                arcadeData = {
                    difficulty: 2, character: null, bgm: "GameA",
                    highScore: 0, maxBubbles: 0, longestGame: 0,
                    totalBubbles: 0, totalTime: 0, totalCleans: 0
                };

                saveArcadeConfigData();
            }
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
            arcadeData.highScore = clamp(playData.score, MAX_COUNT);

        if (playData.bubbles > arcadeData.maxBubbles)
            arcadeData.maxBubbles = clamp(playData.bubbles, MAX_COUNT);

        if (playData.time > arcadeData.longestGame)
            arcadeData.longestGame = clamp(playData.time, MAX_TIME);

        arcadeData.totalBubbles += clamp(playData.bubbles, MAX_COUNT);
        arcadeData.totalTime += clamp(playData.time, MAX_TIME);
        arcadeData.totalCleans += clamp(playData.cleans, MAX_SCS);
    }

    static function clamp(value : Int, max : Int) : Int
    {
        if (value < max)
            return value;
        else
            return max;
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
        arcadeData.difficulty = 3;
        arcadeData.character = null;

        saveArcadeConfigData();
    }

    public static function clearHistoryData()
    {
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

    public static function getBgm() : String
    {
        return arcadeGameData.bgm;
    }

    public static function setBgm(id : String)
    {
        arcadeGameData.bgm = id;
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
    var bgm : String;

    var highScore : Int;
    var longestGame : Int;
    var maxBubbles : Int;

    var totalBubbles: Int;
    var totalTime : Int;
    var totalCleans : Int;
}
