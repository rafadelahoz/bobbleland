package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxButtonPlus;

class MenuState extends FlxState
{
	public var btnArcade : FlxButtonPlus;
	public var btnPuzzle : FlxButtonPlus;
	public var btnOptions : FlxButtonPlus;

	override public function create():Void
	{
		super.create();

		GameController.Init();

		var w : Int = Std.int(FlxG.width - 64);
		var h : Int = 32;

		btnArcade = new FlxButtonPlus(32, 32, onArcadeButtonPressed, "Arcade", w, h);
		btnPuzzle = new FlxButtonPlus(32, 80, onPuzzleButtonPressed, "Adventure", w, h);
		btnOptions = new FlxButtonPlus(32, FlxG.height / 2, onOptionsButtonPressed, "Options", w, h);

		decorateButton(btnArcade);
		decorateButton(btnPuzzle);
		decorateButton(btnOptions);

		add(btnArcade);
		add(btnPuzzle);
		add(btnOptions);
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		if (FlxG.keys.justPressed.G)
		{
			var announcement = new scenes.PuzzleAnnouncement(FlxG.width/2, 0);
			add(announcement);
			announcement.init(function() {
				// haha
			});
		}

		super.update();
	}

	public function onArcadeButtonPressed() : Void
	{
		GameController.StartArcadeGame();
	}

	public function onPuzzleButtonPressed() : Void
	{
		GameController.StartAdventureGame();
	}

	public function onOptionsButtonPressed() : Void
	{
		GameController.ToOptions();
	}

	function decorateButton(button : FlxButtonPlus)
	{
		button.updateActiveButtonColors([0xFF202020, 0xFF202020]);
		button.updateInactiveButtonColors([0xFF000000, 0xFF000000]);
	}
}
