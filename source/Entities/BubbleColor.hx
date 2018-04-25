package;

import flixel.FlxG;
import flixel.util.FlxColor;

class BubbleColor
{
    public static var SpecialNone : Int = 0;
    public static var SpecialTarget : Int = -1;
    public static var SpecialAnchor : Int = -2;

    public static var SpecialPresent : Int = -3;
    public static var SpecialBlocker : Int = -4;

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
        color = getColorList()[colorIndex];

        isTarget = IsTarget;
    }

    public function getColor() : Int
    {
        return color;
    }

    function getColorList() : Array<Int>
    {
        // var colors = [0xFFFF5151, 0xFF5151FF, 0xFF51FF51, 0xFF414471, 0xFF250516];

        var colors : Array<Int> = [];

        for (index in 0...6)
            colors.push(0xFFFFFFFF);

        for (index in 0...15)
            colors.push(FlxColor.fromRGB(FlxG.random.int(0x66, 0xFF), FlxG.random.int(0x66, 0xFF), FlxG.random.int(0x66, 0xFF)));

        return colors;
    }
}
