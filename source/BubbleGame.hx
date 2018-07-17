package;

import flixel.FlxGame;

class BubbleGame extends FlxGame
{
    override public function step() : Void
    {
        try
        {
            super.step();
        }
        catch (someProblem : Dynamic)
        {
            ErrorReporter.handle(someProblem);
        }
    }
}
