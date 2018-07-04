package;

import flixel.util.FlxSave;

class ProgressStatus
{
    static var savefile : String = "progress";

    static var CrabHintBubbles : Int = 1500;
    static var FrogHintBubbles : Int = 5000;
    static var BearHintBubbles : Int = 15000;
    static var CatbombHintBubbles : Int = 20000; // Or 3000?

    public static var progressData : ProgressData;

    public static function init()
    {
        if (progressData == null)
        {
            progressData = load();
            
            if (progressData == null) {
                // Init first progressData if required
                progressData = {
                    crabHint: false, crabChar: false,
                    frogHint: false, frogChar: false,
                    bearHint: false, bearChar: false,
                    catbombHint: false, catbombChar: false
                }

                save();
            }

            progressData.crabChar = true;
            // progressData.frogHint = true;
            // progressData.bearHint = true;
            // progressData.catbombHint = true;
        }
    }

    public static function check()
    {
        var arcadeData : ArcadeGameStatus.ArcadeData = ArcadeGameStatus.getConfigData();
        
        // Check conditions for each char hint
        if (!progressData.crabHint)
        {            
            if (arcadeData.totalBubbles > CrabHintBubbles)
            {
                progressData.crabHint = true;
            }
        } 
        else if (progressData.crabChar && !progressData.frogHint)
        {
            if (arcadeData.totalBubbles > FrogHintBubbles)
            {
                progressData.frogHint = true;
            }
        }
        else if (progressData.frogChar && !progressData.bearHint)
        {
            if (arcadeData.totalBubbles > BearHintBubbles)
            {
                progressData.bearHint = true;
            }
        }
        else if (progressData.bearChar && !progressData.catbombHint)
        {
            if (arcadeData.totalBubbles > CatbombHintBubbles)
            {
                progressData.catbombHint = true;
            }
        }

        save();
    }

    public static function save()
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        save.data.progress = progressData;

        save.close();
    }

    public static function load() : ProgressData
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        return save.data.progress;
    }
}

typedef ProgressData = {
    var crabHint : Bool;
    var frogHint : Bool;
    var bearHint : Bool;
    var catbombHint : Bool;

    var crabChar : Bool;
    var frogChar : Bool;
    var bearChar : Bool;
    var catbombChar : Bool;
}