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

	public static function StartArcadeGame(?DontLoad : Bool = false)
	{
		if (!DontLoad && SaveStateManager.savestateExists())
		{
			trace("Savestate data exists!");
			ArcadeGameStatus.init();
			BeginArcade(true);
		}
		else
		{
			currentState = Menu;

			ArcadeGameStatus.init();
			FlxG.switchState(new ArcadePreState());
		}
	}

	public static function BeginArcade(?Continue : Bool = false)
	{
		currentState = Play;
		var data : Dynamic = null;
		if (Continue)
		{
			data = SaveStateManager.loadAndErase();
			trace("Save data is " + (SaveStateManager.savestateExists() ? "present" : "not present") + " after loading");
	 	}

		FlxG.switchState(new PlayState(PlayState.ModeArcade, data));
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
