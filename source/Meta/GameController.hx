package;

import flixel.FlxG;

class GameController
{
	public static function Init()
	{
		database.BackgroundDatabase.Init();
		database.SceneCharacterDatabase.Init();
	}

	public static function ToMenu()
	{
		FlxG.switchState(new MenuState());
	}

	public static function StartArcadeGame()
	{
		ArcadeGameStatus.init();
		FlxG.switchState(new ArcadePreState());
	}

	public static function BeginArcade()
	{
		FlxG.switchState(new PlayState(PlayState.ModeArcade, null));
	}

	public static function OnGameplayEnd()
	{
		// Depending on the state, do things?
		ToMenu();
	}

	public static function OnPuzzleGiveup(mode : Int, data : Dynamic)
	{
		GameOver(mode, data);
	}

	public static function GameOver(mode : Int, data : Dynamic)
	{
		if (mode == PlayState.ModeArcade)
		{
			ArcadeGameStatus.storePlayData(data);
		}

		FlxG.switchState(new GameOverState(mode, data));
	}
}
