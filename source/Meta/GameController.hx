package;

import flixel.FlxG;

class GameController
{
	public static function ToMenu()
	{
		FlxG.switchState(new MenuState());
	}

	public static function StartArcadeGame()
	{
		FlxG.switchState(new PlayState(PlayState.ModeArcade));
	}
	
	public static function StartPuzzleGame()
	{
		FlxG.switchState(new PlayState(PlayState.ModePuzzle));
	}
	
	public static function GameOver(mode : Int, score : Int)
	{
		// TODO: Handle mode or...?
		FlxG.switchState(new GameOverState(score));
	}
}