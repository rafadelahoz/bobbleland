package;

import flixel.util.FlxSave;

class ProgressStatus
{
    static var savefile : String = "progress";

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

            // progressData.crabHint = true;
            // progressData.frogHint = true;
            // progressData.bearHint = true;
            // progressData.catbombHint = true;
        }
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