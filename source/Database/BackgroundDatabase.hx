package database;

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
}
