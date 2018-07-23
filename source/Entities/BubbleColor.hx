package;

import flixel.FlxG;
import flixel.util.FlxColor;

class BubbleColor
{
    public static inline var SpecialNone : Int = 0;
    public static inline var SpecialTarget : Int = -1;
    public static inline var SpecialAnchor : Int = -2;

    public static inline var SpecialPresent : Int = -3;
    public static inline var SpecialBlocker : Int = -4;

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
        if (colorIndex > -1)
            color = getColorList()[colorIndex];
        else
            color = 0xFFFF00FF;

        isTarget = IsTarget;
    }

    public function getColor() : Int
    {
        return color;
    }

    function getColorList() : Array<Int>
    {
        var colors = [Palette.Red, Palette.Green, Palette.Yellow, Palette.Blue, Palette.Pink, Palette.LightGray];

        return colors;
    }

    public function clone() : BubbleColor
    {
        return new BubbleColor(colorIndex, isTarget);
    }

    public function isBlocker() : Bool
    {
        return colorIndex == SpecialBlocker;
    }
}
