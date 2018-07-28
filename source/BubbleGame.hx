package;

import flixel.FlxGame;

class BubbleGame extends FlxGame
{
    override public function step() : Void
    {
        #if !release
        try
        {
            super.step();
        }
        catch (someProblem : Dynamic)
        {
            ErrorReporter.handle(someProblem);
        }
        #else
            super.step();
        #end
    }
}
