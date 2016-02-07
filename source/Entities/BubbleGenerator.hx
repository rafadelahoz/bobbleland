package;

import flixel.util.FlxRandom;

import puzzle.PuzzleData;

class BubbleGenerator
{
    public var world : PlayState;
    public var puzzle : PuzzleData;
    public var grid : BubbleGrid;

    // For puzzles
    public var currentRow : Int;

    public function new(World : PlayState)
    {
        world = World;
        puzzle = world.puzzleData;
        grid = world.grid;
    }

    public function initalizeGrid()
    {
        currentRow = 0;

        if (world.mode == PlayState.ModeArcade)
        {
            for (row in 0...5)
            {
                generateRow();
            }
        }
        else if (world.mode == PlayState.ModePuzzle)
        {
            while (currentRow < puzzle.initialRows)
            {
                generateRow();
            }
        }
    }

    /* Returns an appropriate color index for a bubble */
    public function getNextBubbleColor() : BubbleColor
    {
        return getNextGridColor();
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
        for (col in 0...grid.columns)
        {
            var bubble : BubbleColor = getRandomColor();

            row.push(bubble);
        }

        return row;
    }

    function getPuzzleRow(row : Array<BubbleColor>) : Array<BubbleColor>
    {
        if (puzzle.mode == PuzzleData.ModeClear ||
            puzzle.mode == PuzzleData.ModeTarget)
        {
            if (puzzle.rows.length > 0)
            {
                row = puzzle.rows.pop();
            }
            else
            {
                row = [];
            }

            currentRow++;
        }
        else if (puzzle.mode == PuzzleData.ModeHold)
        {
            row = getArcadeRow(row);
        }

        return row;
    }

	function getNextGridColor() : BubbleColor
	{
		var usedColors : Array<BubbleColor> = grid.getUsedColors();

		if (usedColors.length <= 0)
		{
			return getRandomColor();
		}

		return FlxRandom.getObject(usedColors);
	}

    /* Returns a random color index for a bubble */
	function getRandomColor() : BubbleColor
	{
		return world.availableColors[FlxRandom.intRanged(0, world.availableColors.length - 1)];
	}


}