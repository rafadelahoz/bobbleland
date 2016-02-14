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
                        if (fast.has.seconds)
                            data.seconds = Std.parseInt(fast.att.seconds);
                }
            case "background":
                data.background = fast.att.id;
            case "bubble-set":
                data.bubbleSet = fast.att.id;
            case "initial":
                data.initialRows = Std.parseInt(fast.att.rows);
                data.usedColors = parseColorList(fast.att.colors);
                if (fast.has.dropdelay)
                    data.dropDelay = Std.parseInt(fast.att.dropdelay);
            case "target":
                data.target = fast.att.graphic;
            case "rows":
                data.rows = parseRows(fast);
        }
    }

    function parseColorList(colorList : String) : Array<BubbleColor>
    {
        var list : Array<BubbleColor> = [];

        if (colorList != null)
        {
            for (color in colorList.split(","))
            {
                list.push(new BubbleColor(Std.parseInt(color)));
            }
        }

        return list;
    }

    function parseRows(fast  : Fast) : Array<Array<BubbleColor>>
    {
        var rows : Array<Array<BubbleColor>> = [];

        for (elem in fast.elements)
        {
            // Special random rows are identified by the random="true" attribute
            if (elem.has.random && elem.att.random == "true")
            {
                var number : Int = 1;
                // Multiple random rows may be specified at once, lets see
                if (elem.has.number)
                    number = Std.parseInt(elem.att.number);

                // Random rows are empty
                for (i in 0...number)
                {
                    rows.push([]);
                }
            }
            else
            {
                rows.push(parseRow(elem));
            }
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
            else if (color == "T")
                row.push(new BubbleColor(BubbleColor.SpecialTarget, true))
            else
                row.push(new BubbleColor(Std.parseInt(color)));
        }

        return row;
    }
}
