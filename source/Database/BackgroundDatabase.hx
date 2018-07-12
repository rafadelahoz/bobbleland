package database;

import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

class BackgroundDatabase
{
    static var assetsPath : String = "assets/backgrounds/";

    public static function Init()
    {
        // nop!
    }

    public static function GetRandomBackgroundAsset() : String
    {
        var bgs : Array<String> = [];
        for (i in 0...8)
        {
            bgs.push("bg" + i + ".png");
        }

        var bg : String = "assets/backgrounds/" + FlxG.random.getObject(bgs);
        return bg;
    }

    public static function BuildRandomBackground() : FlxBackdrop
    {
        var bg : String = GetRandomBackgroundAsset();

        return new FlxBackdrop(bg);
    }
}
