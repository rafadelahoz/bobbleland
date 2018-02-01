package database;

import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

class BackgroundDatabase
{
    static var assetsPath : String = "assets/backgrounds/";

    // Load from file?
    // Store in code?
    static var database : Map<String, String> ;

    public static function Init()
    {
        if (database == null)
        {
            database = new Map<String, String>();
            database.set("day", "bg.png");
            database.set("dawn", "bg-red.png");
            database.set("pink", "bg0.png");
            database.set("dark", "bg1.png");
            database.set("squares", "bg2.png");
            database.set("park", "park.png");
        }
    }

    public static function GetBackground(backgroundId : String)
    {
        if (database == null)
        {
            throw "The Background Database has not yet been Initialized";
        }
        else if (database.get(backgroundId) == null)
        {
            throw "No background with Id \"" + backgroundId + "\" found on the Background Database?";
        }
        else
        {
            return assetsPath + database.get(backgroundId);
        }
    }

    public static function BuildRandomBackground() : FlxBackdrop
    {
        var bgs : Array<String> = [];
        for (i in 0...6)
        {
            bgs.push("bg" + i + ".png");
        }

        var bg : String = "assets/backgrounds/" + FlxG.random.getObject(bgs);

        return new FlxBackdrop(bg);
    }
}
