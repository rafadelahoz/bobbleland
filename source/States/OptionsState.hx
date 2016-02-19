package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxButtonPlus;

class OptionsState extends FlxState
{
	public var btnClearData : FlxButtonPlus;
	public var btnBack : FlxButtonPlus;

	override public function create():Void
	{
		super.create();

		var w : Int = Std.int(FlxG.width - 64);
		var h : Int = 32;

		btnClearData = new FlxButtonPlus(32, 96, onClearDataPressed, "Clear Adventure Data", w, h);
		btnBack = new FlxButtonPlus(FlxG.width/2 - w/4, FlxG.height/2 + 32, onBackButtonPressed, "Back", Std.int(w / 2), Std.int(h / 2));

		decorateButton(btnClearData);
		decorateButton(btnBack);

		add(btnClearData);
		add(btnBack);
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
	}

	public function onClearDataPressed() : Void
	{
		GameController.ClearSaveData();
	}

	public function onBackButtonPressed() : Void
	{
		GameController.ToMenu();
	}

	function decorateButton(button : FlxButtonPlus)
	{
		button.updateActiveButtonColors([0xFF202020, 0xFF202020]);
		button.updateInactiveButtonColors([0xFF000000, 0xFF000000]);
	}
}
