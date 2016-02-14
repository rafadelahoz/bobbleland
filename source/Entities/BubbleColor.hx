package;

class BubbleColor
{
    public static var SpecialNone : Int = 0;
    public static var SpecialTarget : Int = -1;
    public static var SpecialAnchor : Int = -2;

    public var colorIndex : Int;
    public var color : Int;

    public var isSpecial (get, null) : Bool;
    public function get_isSpecial() : Bool {
        return colorIndex < 0;
    }

    public var isTarget : Bool;

    public function new(?Color : Int = -1, ?IsTarget : Bool = false)
    {
        colorIndex = Color;
        // TODO
        var colors = [0xFFFF5151, 0xFF5151FF, 0xFF51FF51, 0xFF414471, 0xFF250516];
        if (colorIndex >= 0)
            color = colors[colorIndex];
        else
            color = 0xFFFFFFFF;

        isTarget = IsTarget;
    }

    public function getColor() : Int
    {
        return color;
    }
}
