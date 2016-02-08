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
		// FlxG.switchState(new PlayState(PlayState.ModePuzzle, "puzzle-0.xml"));
		if (PuzzleGameStatus.savegameExists())
		{
			PuzzleGameStatus.loadSavegame();
		}
		else 
		{
			PuzzleGameStatus.startNewGame();
		}
		
		PuzzleGameStatus.next();
		NextScene();
	}
	
	public static function OnSceneCompleted(nextPuzzle : String, nextScene : String)
	{
		PuzzleGameStatus.setNext(nextPuzzle, nextScene);
		PuzzleGameStatus.next();
		
		BeginPuzzle();
	}
	
	public static function BeginPuzzle() 
	{
		FlxG.switchState(
			new PlayState(PlayState.ModePuzzle, PuzzleGameStatus.getCurrentPuzzle())
		);
	}
	
	public static function OnPuzzleCompleted()
	{
		NextScene();
	}
	
	static function NextScene()
	{
		BeginScene(PuzzleGameStatus.getCurrentScene());
	}
	
	public static function OnGameplayEnd()
	{
		// Depending on the state, do things?
		ToMenu();
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
