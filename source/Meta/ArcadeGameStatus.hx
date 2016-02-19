package;

import flixel.util.FlxSave;

class ArcadeGameStatus
{
    static var savefile : String = "savefile";

    static var arcadeConfigData : ArcadeData;
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

        if (arcadeConfigData == null)
        {
            arcadeConfigData = loadArcadeConfigData();
            if (arcadeConfigData == null)
            {
                arcadeConfigData = {difficulty: 3, character: null};
                saveArcadeConfigData();
            }
        }
    }

    public static function getConfigData() : ArcadeData
    {
        return arcadeConfigData;
    }

    public static function setConfigData(data : ArcadeData)
    {
        arcadeConfigData = data;
    }

    static function loadArcadeConfigData() : ArcadeData
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        return save.data.arcadeConfig;
    }

    public static function saveArcadeConfigData()
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        save.data.arcadeConfig = arcadeConfigData;

        save.close();
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
}
