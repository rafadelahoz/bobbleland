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

    public function generateSaveData(data : BubbleGrid.BubbleGridData)
    {
        // trace("GRID DATA", data);
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

            grid.generateBubbleRow(bubLine, data.presentContents);
        }
    }

    public function generateRow(?allowPresents : Bool = true)
    {
        var row : Array<BubbleColor> = [];
        switch (world.mode)
        {
            case PlayState.ModeArcade:
                row = getArcadeRow(row, allowPresents);
            case PlayState.ModePuzzle:
                row = getPuzzleRow(row);
        }

        grid.generateBubbleRow(row);
    }

    function getArcadeRow(row : Array<BubbleColor>, allowPresents : Bool) : Array<BubbleColor>
    {
        // Special bubble generation
        var specialBubbleColumn : Int = -1;
        if (allowPresents)
        {
            var specialBubbleProbability = world.specialBubbleController.getGenerationProbability();
            if (FlxG.random.bool(specialBubbleProbability * 100))
            {
                specialBubbleColumn = FlxG.random.int(0, grid.columns);
            }
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

        // Find blockers
        var blockers : Array<BubbleColor> = row.filter(filterOnlyBlockers);
        // Limit to max three blockers
        var maxBlockers : Int = world.availableColors.filter(filterOnlyBlockers).length;
        trace("Max blockers", maxBlockers);
        while (blockers.length > maxBlockers)
        {
            blockers[FlxG.random.int(0, blockers.length)].colorIndex = getPositiveColor().colorIndex;
            blockers = row.filter(filterOnlyBlockers);
        }

        return row;
    }

    function filterOnlyBlockers(c : BubbleColor) : Bool {
        return (c.colorIndex == BubbleColor.SpecialBlocker);
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
                    row = getArcadeRow(row, true);
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
            row = getArcadeRow(row, true);
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

    public function getPositiveColor() : BubbleColor
    {
        var list : Array<BubbleColor> = world.availableColors.filter(onlyPositiveIndexes);
        return list[FlxG.random.int(0, list.length - 1)];
    }

    /* Returns a random color index for a bubble */
	function getRandomColor() : BubbleColor
	{
        var list : Array<BubbleColor> = world.availableColors;
		return list[FlxG.random.int(0, list.length - 1)];
	}

    function onlyPositiveIndexes(color : BubbleColor) : Bool
    {
        return (color != null && color.colorIndex >= 0);
    }
}
