package scenes.commands;

import flixel.tweens.FlxTween;

class BgCommand extends Command
{
	public var id : String;

	public function new(Id : String)
	{
		super();

		id = Id;
	}

	override public function init(Scene : SceneState)
	{
		super.init(Scene);

		// Fade the former background to black (for smooth transition)
		FlxTween.tween(scene.background, {alpha : 0}, 0.5, { complete : onFadeOutComplete });
	}

	public function onFadeOutComplete(tween : FlxTween) : Void
	{
		scene.changeBackground(id);
		FlxTween.tween(scene.background, {alpha : 1}, 0.5, { complete : onFadeInComplete });
	}
	
	public function onFadeInComplete(tween : FlxTween) : Void
	{
		onComplete();
	}

	override public function print() : String
	{
		return "Switch Background to " + id;
	}

	public static function parse(line : String) : Command
	{
		var id : String = StringTools.trim(line);

		var command : Command = new BgCommand(id);
		return command;
	}
}
