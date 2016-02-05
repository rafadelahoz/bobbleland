package puzzle;

class PuzzleData
{
    public static var ModeClear    : Int = 0;
    public static var ModeHold     : Int = 1;
    public static var ModeTarget   : Int = 2;

    public var mode : Int;
    public var background : String;
    public var bubbleSet : String;

    public var seconds : Int;
    public var initialRows : Int;
    public var usedColors : Array<Int>;
    public var rows : Array<Array<Int>>;

    public function new()
    {
        mode = -1;
        background = null;
        bubbleSet = null;
        seconds = -1;
        initialRows = 0;
        usedColors = [];
        rows = [];
    }
}
