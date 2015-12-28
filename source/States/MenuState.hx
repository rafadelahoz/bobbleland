package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxButtonPlus;

class MenuState extends FlxState
{
	public var btnArcade : FlxButtonPlus;
	public var btnPuzzle : FlxButtonPlus;
	public var btnParse: FlxButtonPlus;

	override public function create():Void
	{
		super.create();
		
		btnArcade = new FlxButtonPlus(32, 32, onArcadeButtonPressed, "Arcade", 96, 32);
		btnPuzzle = new FlxButtonPlus(32, 80, onPuzzleButtonPressed, "Puzzle", 96, 32);
		btnParse = new FlxButtonPlus(32, 128, onParseButtonPressed, "Parse", 96, 32);
		
		decorateButton(btnArcade);
		decorateButton(btnPuzzle);
		decorateButton(btnParse);
		
		add(btnArcade);
		add(btnPuzzle);
		add(btnParse);
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
	
	public function onParseButtonPressed() : Void
	{
		var parser : parser.SceneParser = new parser.SceneParser("sample-script.scene");
		parser.parse();
		trace("Parser finished");
	}
	
	function decorateButton(button : FlxButtonPlus)
	{
		button.updateActiveButtonColors([0xFF202020, 0xFF202020]);
		button.updateInactiveButtonColors([0xFF000000, 0xFF000000]);
	}
}