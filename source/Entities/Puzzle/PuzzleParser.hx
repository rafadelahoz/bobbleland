package puzzle;

import haxe.xml.Fast;
import openfl.Assets;

class PuzzleParser
{
    var basePath : String = "assets/data/";
    var filename : String;

    var data : PuzzleData;

    public function new(puzzleName : String)
    {
        filename = puzzleName;
    }

    public function parse() : PuzzleData
    {
        data = new PuzzleData();

        // Read the file contents
        var fileContents : String = Assets.getText(basePath + filename);
        // Parse the contents as XML
        var xmlContents : Xml = Xml.parse(fileContents);
        // Wrap with Fast for cleaner code :)
        var fast = new Fast(xmlContents.firstElement());

        // Start processing!
        for (element in fast.elements)
        {
            parseElement(element);
        }

        return data;
    }

    function parseElement(fast : Fast)
    {
        var name : String = fast.name;
        switch (name)
        {
            case "mode":
                switch (fast.att.name)
                {
                    case "clear":
                        data.mode = PuzzleData.ModeClear;
                    case "hold":
                        data.mode = PuzzleData.ModeHold;
                        data.seconds = Std.parseInt(fast.att.seconds);
                    case "target":
                        data.mode = PuzzleData.ModeTarget;
                        data.seconds = Std.parseInt(fast.att.seconds);
                }
            case "background":
                data.background = fast.att.id;
            case "bubble-set":
                data.bubbleSet = fast.att.id;
            case "initial":
                data.initialRows = Std.parseInt(fast.att.rows);
                data.usedColors = parseColorList(fast.att.colors);
            case "rows":
                data.rows = parseRows(fast);
        }
    }

    function parseColorList(colorList : String) : Array<BubbleColor>
    {
        var list : Array<BubbleColor> = [];

        for (color in colorList.split(","))
        {
            list.push(new BubbleColor(Std.parseInt(color)));
        }

        return list;
    }

    function parseRows(fast  : Fast) : Array<Array<BubbleColor>>
    {
        var rows : Array<Array<BubbleColor>> = [];

        for (elem in fast.elements)
        {
            rows.push(parseRow(elem));
        }

        return rows;
    }

    function parseRow(fast : Fast) : Array<BubbleColor>
    {
        var row : Array<BubbleColor> = [];

        var rowString : String = fast.att.colors;
        for (color in rowString.split(","))
        {
            if (color == "x")
                row.push(null);
            else
                row.push(new BubbleColor(Std.parseInt(color)));
        }

        return row;
    }
}
