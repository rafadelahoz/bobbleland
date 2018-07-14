package;

import flixel.util.FlxSave;

class ArcadeGameStatus
{
    static var savefile : String = "savefile";

    static var arcadeData : ArcadeData;
    static var playSessionData : PlaySessionData;

    static var MAX_TIME : Int = 3599999;
    static var MAX_COUNT : Int = 99999999;
    static var MAX_SCS : Int = 9999;

    public static function init()
    {
        if (playSessionData == null)
        {
            playSessionData = new PlaySessionData();

            playSessionData.mode = PlaySessionData.ModeEndless;

            playSessionData.background = null;
            playSessionData.bubbleSet = null;
            playSessionData.character = null;
            playSessionData.bgm = "GameA";

            playSessionData.initialRows = 4;
            playSessionData.dropDelay = 20;
            playSessionData.seconds = -1;
            playSessionData.usedColors = generateColorSet(5);
        }

        if (arcadeData == null)
        {
            trace("Loading arcadeData");
            arcadeData = loadArcadeConfigData();
            if (arcadeData == null)
            {
                trace("Arcade data reset");
                arcadeData = {
                    difficulty: 2, character: null, bgm: "GameA",
                    highScore: 0, maxBubbles: 0, longestGame: 0, maxCleans: 0,
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

    public static function storePlayData(playData : Dynamic) : Dynamic
    {
        playData.scoreRecord = false;
        if (playData.score > arcadeData.highScore)
        {
            arcadeData.highScore = clamp(playData.score, MAX_COUNT);
            playData.scoreRecord = true;
        }

        playData.bubbleRecord = false;
        if (playData.bubbles > arcadeData.maxBubbles)
        {
            arcadeData.maxBubbles = clamp(playData.bubbles, MAX_COUNT);
            playData.bubbleRecord = true;
        }

        playData.timeRecord = false;
        if (playData.time > arcadeData.longestGame)
        {
            arcadeData.longestGame = clamp(playData.time, MAX_TIME);
            playData.timeRecord = true;
        }

        playData.cleansRecord = false;
        if (playData.cleans > arcadeData.maxCleans)
        {
            arcadeData.maxCleans = playData.cleans;
            playData.cleansrecord = true;
        }

        arcadeData.totalBubbles += clamp(playData.bubbles, MAX_COUNT);
        arcadeData.totalTime += clamp(playData.time, MAX_TIME);
        arcadeData.totalCleans += clamp(playData.cleans, MAX_SCS);

        saveArcadeConfigData();

        return playData;
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

    public static function setupDifficulty(difficulty : Int)
    {
        playSessionData.initialDifficulty = difficulty;

        switch (difficulty)
        {
            case 0:
                setGuideEnabled(true);
                setDropDelay(30);
                setInitialRows(5);
                setUsedColors(4);
            case 1:
                setGuideEnabled(true);
                setDropDelay(25);
                setInitialRows(5);
                setUsedColors(4);
            case 2:
                setGuideEnabled(true);
                setDropDelay(20);
                setInitialRows(5);
                setUsedColors(5);
            case 3:
                setGuideEnabled(true);
                setDropDelay(20);
                setInitialRows(6);
                setUsedColors(6);
            case 4:
                setGuideEnabled(false);
                setDropDelay(18);
                setInitialRows(6);
                setUsedColors(6);
        }
    }

    public static function setInitialRows(rows : Int)
    {
        playSessionData.initialRows = rows;
    }

    public static function setDropDelay(seconds : Int)
    {
        playSessionData.dropDelay = seconds;
    }

    public static function setUsedColors(number : Int)
    {
        playSessionData.usedColors = generateColorSet(number);
    }

    public static function setGuideEnabled(enabled : Bool)
    {
        playSessionData.guideEnabled = enabled;
    }

    public static function getCharacter() : String
    {
        return playSessionData.character;
    }

    public static function setCharacter(id : String)
    {
        playSessionData.character = id;
    }

    public static function getBgm() : String
    {
        return playSessionData.bgm;
    }

    public static function setBgm(id : String)
    {
        playSessionData.bgm = id;
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

    public static function setData(data : PlaySessionData)
    {
        playSessionData = data;
    }

    public static function getData() : PlaySessionData
    {
        return playSessionData;
    }
}

typedef ArcadeData = {
    var difficulty : Int;
    var character : String;
    var bgm : String;

    var highScore : Int;
    var longestGame : Int;
    var maxBubbles : Int;
    var maxCleans : Int;

    var totalBubbles: Int;
    var totalTime : Int;
    var totalCleans : Int;
}
