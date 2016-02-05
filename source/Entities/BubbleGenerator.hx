package;

import puzzle.PuzzleData;

class BubbleGenerator
{
    public var world : PlayState;
    public var puzzle : PuzzleData;
    public var grid : BubbleGrid;

    public function new(World : PlayState)
    {
        world = World;
        puzzle = world.puzzleData;
        grid = world.grid;
    }
}
