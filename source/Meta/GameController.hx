package;

import flixel.FlxG;

class GameController
{
	public static function Init()
	{
		database.BackgroundDatabase.Init();
	}

	public static function ToMenu()
	{
		FlxG.switchState(new MenuState());
	}

	public static function StartArcadeGame()
	{
		FlxG.switchState(new PlayState(PlayState.ModeArcade, null));
	}

	public static function StartPuzzleGame()
	{
		FlxG.switchState(new PlayState(PlayState.ModePuzzle, "sample-puzzle.xml"));
	}

	public static function BeginScene(scene : String)
	{
		FlxG.switchState(new SceneState(scene));
	}

	public static function GameOver(mode : Int, score : Int)
	{
		// TODO: Handle mode or...?
		FlxG.switchState(new GameOverState(score));
	}
}
