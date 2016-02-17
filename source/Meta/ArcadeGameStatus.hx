package;

class ArcadeGameStatus
{
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