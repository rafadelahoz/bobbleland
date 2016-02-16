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
            arcadeGameData.initialRows = 4;
            arcadeGameData.dropDelay = 20;
            arcadeGameData.seconds = -1;
            arcadeGameData.usedColors = [];
            for (i in 0...5)
            {
                arcadeGameData.usedColors.push(new BubbleColor(i));
            }
        }
    }
    
    public static function getData() : puzzle.PuzzleData
    {
        return arcadeGameData;
    }
}