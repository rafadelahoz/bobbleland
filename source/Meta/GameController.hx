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

		// FlxG.scaleMode = new flixel.system.scaleModes.PixelPerfectScaleMode();
	}

	public static function ToMenu()
	{
		currentState = Title;

		FlxG.switchState(new MenuState());
	}

	public static function StartArcadeGame(?DontLoad : Bool = false)
	{
		ArcadeGameStatus.init();
		ProgressStatus.init();

		ProgressStatus.check();

		if (!DontLoad && SaveStateManager.savestateExists())
		{
			trace("Savestate data exists!");
			BeginArcade(true);
		}
		else
		{
			currentState = Menu;
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

		// This will also save
		if (mode == PlayState.ModeArcade)
		{
			ArcadeGameStatus.storePlayData(data);
		}

		// Check for unlocks
		ProgressStatus.checkForCharacterUnlock(data);

		FlxG.switchState(new GameOverState(mode, data));
	}
}

enum GameState { Loading; Title; Menu; Play; GameOver; }
