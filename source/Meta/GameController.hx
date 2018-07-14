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

		// FlxG.autoPause = false;
		#if (!mobile)
			FlxG.scaleMode = new flixel.system.scaleModes.PixelPerfectScaleMode();

			var sprite : flixel.FlxSprite= new flixel.FlxSprite();
			sprite.makeGraphic(20, 20, 0x00FFFFFF);
			flixel.util.FlxSpriteUtil.drawCircle(sprite, 10, 10, 8, 0x00FFFFFF, {color: Palette.White, thickness: 2});

			// Load the sprite's graphic to the cursor
			FlxG.mouse.load(sprite.pixels, 1, -10, -10);
		#end
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
			// Delete stored game
			SaveStateManager.loadAndErase();
			
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
		// You can't get catbomb by quitting
		data.catSleeping = false;
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
