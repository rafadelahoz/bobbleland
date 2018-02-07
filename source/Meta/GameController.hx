package;

import flixel.FlxG;

class GameController
{
	public static var currentState : GameState;

	public static function Init()
	{
		currentState = Loading;

		database.BackgroundDatabase.Init();
		database.SceneCharacterDatabase.Init();
	}

	public static function ToMenu()
	{
		currentState = Title;

		FlxG.switchState(new MenuState());
	}

	public static function StartArcadeGame()
	{
		currentState = Menu;

		ArcadeGameStatus.init();
		FlxG.switchState(new ArcadePreState());
	}

	public static function BeginArcade()
	{
		currentState = Play;

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
		currentState = GameState.GameOver;

		if (mode == PlayState.ModeArcade)
		{
			ArcadeGameStatus.storePlayData(data);
		}

		FlxG.switchState(new GameOverState(mode, data));
	}
}

enum GameState { Loading; Title; Menu; Play; GameOver; }
