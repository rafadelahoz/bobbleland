package;

class BubbleColor
{
    public static var SpecialNone : Int = 0;
    public static var SpecialAnchor : Int = -1;

    public var colorIndex : Int;
    public var color : Int;

    public var isSpecial (get, null) : Bool;
    public function get_isSpecial() : Bool {
        return colorIndex < 0;
    }

    public function new(Color : Int)
    {
        colorIndex = Color;
        // TODO
        var colors = [0xFFFF5151, 0xFF5151FF, 0xFF51FF51, 0xFF414471, 0xFF250516];
        color = colors[colorIndex];
    }

    public function getColor() : Int
    {
        return color;
    }
}
