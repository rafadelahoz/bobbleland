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
	
	public static function ToOptions()
	{
		FlxG.switchState(new OptionsState());
	}

	public static function StartArcadeGame()
	{
		ArcadeGameStatus.init();
		FlxG.switchState(new PlayState(PlayState.ModeArcade, null));
	}

	public static function StartAdventureGame()
	{
		// FlxG.switchState(new PlayState(PlayState.ModePuzzle, "puzzle-0.xml"));
		if (AdventureGameStatus.savegameExists())
		{
			trace("Save game found!");
			AdventureGameStatus.loadSavegame();
		}
		else 
		{
			trace("Starting new game");
			AdventureGameStatus.startNewGame();
		}
		
		AdventureGameStatus.next();
		NextScene();
	}
	
	public static function OnSceneCompleted(nextPuzzle : String, nextScene : String)
	{
		AdventureGameStatus.setNext(nextPuzzle, nextScene);
		AdventureGameStatus.next();
		
		BeginPuzzle();
	}
	
	public static function BeginPuzzle() 
	{
		FlxG.switchState(
			new PlayState(PlayState.ModePuzzle, AdventureGameStatus.getCurrentPuzzle())
		);
	}
	
	public static function OnPuzzleCompleted()
	{
		AdventureGameStatus.save();
		NextScene();
	}
	
	static function NextScene()
	{
		BeginScene(AdventureGameStatus.getCurrentScene());
	}
	
	public static function OnGameplayEnd()
	{
		// Depending on the state, do things?
		ToMenu();
	}
	
	public static function OnPuzzleGiveup()
	{
		GameOver(-1, 0);
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
	
	public static function ClearSaveData() 
	{
		AdventureGameStatus.clearData();
	}
}
