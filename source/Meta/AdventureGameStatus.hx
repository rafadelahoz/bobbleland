package;

import flixel.util.FlxSave;

class AdventureGameStatus
{
    static var savefile : String = "savefile";
    
    static var currentPuzzle : String;
    static var nextPuzzle : String;
    
    static var currentScene : String;
    static var nextScene : String;
    
    public static function savegameExists() : Bool
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);
        
        return (save.data.scene != null);
    }
    
    public static function save()
    {
        trace("Saving...");
        
        var save : FlxSave = new FlxSave();
        save.bind(savefile);
        save.data.scene = currentScene;
        save.close();
    }
    
    public static function clearData()
    {
        trace("Clearing data...");
        
        var save : FlxSave = new FlxSave();
        save.bind(savefile);
        save.data.scene = null;
        save.close();
    }
    
    public static function loadSavegame()
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);
        
        nextScene = save.data.scene;        
    }
    
    public static function startNewGame()
    {
        nextScene = "0.scene";
    }
    
    public static function getCurrentPuzzle() : String
    {
        return currentPuzzle;
    }
    
    public static function getCurrentScene() : String
    {
        return currentScene;
    }
    
    public static function setNext(puzzle : String, scene : String)
    {
        nextPuzzle = puzzle;
        nextScene = scene;        
    }
    
    public static function next() : Void
    {
        currentPuzzle = nextPuzzle;
        currentScene = nextScene;
        
        nextPuzzle = null;
        nextScene = null;
    }
}