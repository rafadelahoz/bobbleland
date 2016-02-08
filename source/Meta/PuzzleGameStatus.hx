package;

class PuzzleGameStatus
{
    static var currentPuzzle : String;
    static var nextPuzzle : String;
    
    static var currentScene : String;
    static var nextScene : String;
    
    public static function savegameExists() : Bool
    {
        // Check for savegame
        return false;
    }
    
    public static function loadSavegame()
    {
        // set currentScene?
        // does the game always resume on the pre-scene?
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