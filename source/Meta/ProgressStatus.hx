package;

import flixel.util.FlxSave;

class ProgressStatus
{
    static var savefile : String = "progress";

    static var CrabHintBubbles : Int = 1500;
    static var FrogHintBubbles : Int = 5000;
    static var BearHintBubbles : Int = 15000;
    static var CatbombHintBubbles : Int = 1500; // Or 2000?

    static var CrabUnlockScore : Int = 50000;
    static var FrogUnlockBubbles : Int = 500;
    static var FrogUnlockLevel : Int = 3;
    static var BearUnlockScore : Int = 50000;
    static var BearUnlockLevel : Int = 5;

    public static var progressData : ProgressData;

    public static function init()
    {
        if (progressData == null)
        {
            progressData = load();

            if (progressData == null) {
                // Init first progressData if required
                progressData = {
                    crabHint: false,    crabChar: false,
                    frogHint: false,    frogChar: false,
                    bearHint: false,    bearChar: false,
                    catbombHint: false, catbombChar: false,
                    fanfare: "none"
                }

                save();
            }

            // progressData.fanfare = "none";
            // progressData.crabChar = false;

            // progressData.fanfare = "crab";
            // progressData.crabChar = true;

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
        
        if (!progressData.catbombHint)
        {
            if (arcadeData.totalBubbles > CatbombHintBubbles)
            {
                progressData.catbombHint = true;
            }
        }

        save();
    }

    public static function checkForCharacterUnlock(playSessionData : Dynamic)
    {
        if (progressData.crabHint && !progressData.crabChar)
        {
            if (playSessionData.score > CrabUnlockScore)
            {
                progressData.crabChar = true;
                progressData.fanfare = "crab";
            }
        }
        else if (progressData.crabChar && progressData.frogHint && !progressData.frogChar)
        {
            if (playSessionData.bubbles > FrogUnlockBubbles &&
                playSessionData.level >= FrogUnlockLevel)
            {
                progressData.frogChar = true;
                progressData.fanfare = "frog";
            }
        }
        else if (progressData.frogChar && progressData.bearHint && !progressData.bearChar)
        {
            if (playSessionData.score > BearUnlockScore &&
                playSessionData.time < BearUnlockScore &&
                playSessionData.level >= BearUnlockLevel)
            {
                progressData.bearChar = true;
                progressData.fanfare = "bear";
            }
        }
        
        if (progressData.catbombHint && !progressData.catbombChar)
        {
            if (playSessionData.character == "cat" && playSessionData.catSleeping)
            {
                progressData.catbombChar = true;
                progressData.fanfare = "catbomb";
            }
        }

        save();
    }

    public static function clearData()
    {
        progressData = null;
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

    var fanfare : String;

    var crabChar : Bool;
    var frogChar : Bool;
    var bearChar : Bool;
    var catbombChar : Bool;
}
