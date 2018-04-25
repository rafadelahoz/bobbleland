package;

import flixel.FlxG;
import PlaySessionData;

class BubbleGenerator
{
    public var world : PlayState;
    public var sessionData : PlaySessionData;
    public var grid : BubbleGrid;

    // For sessionDatas
    public var currentRow : Int;

    public function new(World : PlayState)
    {
        world = World;
        sessionData = world.playSessionData;
        grid = world.grid;
    }

    public function initalizeGrid(?SaveData : BubbleGrid.BubbleGridData = null)
    {
        currentRow = 0;

        if (world.mode == PlayState.ModeArcade)
        {
            if (SaveData == null)
            {
                trace("Starting random grid");
                for (row in 0...sessionData.initialRows)
                {
                    generateRow();
                }
            }
            else
            {
                trace("Loading saved grid");
                generateSaveData(SaveData);
            }
        }
        else if (world.mode == PlayState.ModePuzzle)
        {
            while (currentRow < sessionData.initialRows)
            {
                generateRow();
            }
        }
    }

    /* Returns an appropriate color index for a bubble */
    public function getNextBubbleColor() : BubbleColor
    {
        var color : BubbleColor = getNextGridColor();
        return color;
    }

    public function generateSaveData(data : BubbleGrid.BubbleGridData)
    {
        // Restore padded row data
        grid.padded = data.padded;

        // Restore grid bubbles data
        var lines : Array<String> = data.serializedGrid.split("\n");
        lines.reverse();
        for (line in lines)
        {
            if (line.length == 0)
                continue;
            // line in form [1][2][x][x][3]
            var bubLine : Array<BubbleColor> = [];
            var members : Array<String> = line.split("[");
            // trace("processing: " + line + " as " + members);
            for (member in members) {
                // The first member will be empty, avoid it
                if (member.length == 0)
                    continue;

                // For special chars, detect the minus, then parse the number
                if (member.charAt(0) == "-")
                    bubLine.push(new BubbleColor(-Std.parseInt(member.charAt(1))));
                else if (member.charAt(0) != "x")
                    bubLine.push(new BubbleColor(Std.parseInt(member.charAt(0))));
                else
                    bubLine.push(null);
            }

            grid.generateBubbleRow(bubLine);
        }
    }

    public function generateRow()
    {
        var row : Array<BubbleColor> = [];
        switch (world.mode)
        {
            case PlayState.ModeArcade:
                row = getArcadeRow(row);
            case PlayState.ModePuzzle:
                row = getPuzzleRow(row);
        }

        grid.generateBubbleRow(row);
    }

    function getArcadeRow(row : Array<BubbleColor>) : Array<BubbleColor>
    {
        // Special bubble generation
        var specialBubbleColumn : Int = -1;
        var specialBubbleProbability = world.specialBubbleController.getGenerationProbability();
        if (FlxG.random.bool(specialBubbleProbability * 100))
        {
            specialBubbleColumn = FlxG.random.int(0, grid.columns);
        }

        for (col in 0...grid.columns)
        {
            var bubble : BubbleColor;
            if (col == specialBubbleColumn)
            {
                bubble = new BubbleColor(BubbleColor.SpecialPresent);
            }
            else
                bubble = getRandomColor();

            row.push(bubble);
        }

        return row;
    }

    function getPuzzleRow(row : Array<BubbleColor>) : Array<BubbleColor>
    {
        if (sessionData.mode == PlaySessionData.ModeClear ||
            sessionData.mode == PlaySessionData.ModeTarget)
        {
            if (sessionData.rows.length > 0)
            {
                row = sessionData.rows.pop();
                // If the stored row is empty, it means it is a random row
                if (row.length == 0)
                {
                    row = getArcadeRow(row);
                }
            }
            else
            {
                row = [];
            }

            currentRow++;
        }
        else if (sessionData.mode == PlaySessionData.ModeHold)
        {
            row = getArcadeRow(row);
            currentRow++;
        }

        return row;
    }

	function getNextGridColor() : BubbleColor
	{
		var usedColors : Array<BubbleColor> = grid.getUsedColors();

		if (usedColors.filter(onlyPositiveIndexes).length <= 0)
		{
			return getRandomColor();
		}

		return FlxG.random.getObject(usedColors.filter(onlyPositiveIndexes));
	}

    /* Returns a random color index for a bubble */
	function getRandomColor() : BubbleColor
	{
        var list : Array<BubbleColor> = world.availableColors.filter(onlyPositiveIndexes);
		return list[FlxG.random.int(0, list.length - 1)];
	}

    function onlyPositiveIndexes(color : BubbleColor) : Bool
    {
        return (color != null && color.colorIndex >= 0);
    }
}
