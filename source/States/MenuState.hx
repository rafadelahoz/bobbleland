package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxButtonPlus;

class MenuState extends FlxState
{
	public var btnArcade : FlxButtonPlus;
	public var btnPuzzle : FlxButtonPlus;

	override public function create():Void
	{
		super.create();
		
		btnArcade = new FlxButtonPlus(32, 32, onArcadeButtonPressed, "Arcade", 96, 32);
		btnPuzzle = new FlxButtonPlus(32, 80, onPuzzleButtonPressed, "Puzzle", 96, 32);
		
		btnArcade.updateActiveButtonColors([0xFF202020, 0xFF101010]);
		btnArcade.updateInactiveButtonColors([0xFF101010, 0xFF000000]);
		
		btnPuzzle.updateActiveButtonColors([0xFF202020, 0xFF101010]);
		btnPuzzle.updateInactiveButtonColors([0xFF101010, 0xFF000000]);
		
		add(btnArcade);
		add(btnPuzzle);
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
}