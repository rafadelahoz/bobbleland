package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxButtonPlus;

class MenuState extends FlxState
{
	public var btnArcade : FlxButtonPlus;
	public var btnPuzzle : FlxButtonPlus;
	public var btnScene: FlxButtonPlus;
	public var btnParsePuzzle : FlxButtonPlus;

	override public function create():Void
	{
		super.create();

		GameController.Init();

		var w : Int = Std.int(FlxG.width - 64);
		var h : Int = 32;

		btnArcade = new FlxButtonPlus(32, 32, onArcadeButtonPressed, "Arcade", w, h);
		btnPuzzle = new FlxButtonPlus(32, 80, onPuzzleButtonPressed, "Puzzle", w, h);
		btnScene = new FlxButtonPlus(32, 128, onSceneButtonPressed, "Scene", w, h);
		
		decorateButton(btnArcade);
		decorateButton(btnPuzzle);
		decorateButton(btnScene);
		
		add(btnArcade);
		add(btnPuzzle);
		add(btnScene);
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
	}

	public function onArcadeButtonPressed() : Void
	{
		GameController.StartArcadeGame();
	}

	public function onPuzzleButtonPressed() : Void
	{
		GameController.StartPuzzleGame();
	}

	public function onSceneButtonPressed() : Void
	{
		GameController.BeginScene("wait.scene");
	}

	function decorateButton(button : FlxButtonPlus)
	{
		button.updateActiveButtonColors([0xFF202020, 0xFF202020]);
		button.updateInactiveButtonColors([0xFF000000, 0xFF000000]);
	}
}
