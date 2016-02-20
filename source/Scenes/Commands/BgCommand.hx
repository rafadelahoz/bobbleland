package scenes.commands;

import flixel.tweens.FlxTween;

class BgCommand extends Command
{
	public var id : String;
	public var duration : Float;

	public function new(Id : String, ?Immediate : Bool = false)
	{
		super();

		id = Id;
		duration = (Immediate ? 0.0 : 0.5);
	}

	override public function init(Scene : SceneState)
	{
		super.init(Scene);

		// Fade the former background to black (for smooth transition)
		if (duration <= 0)
		{
			onFadeOutComplete(null);
		}
		else 
		{
			FlxTween.tween(scene.background, {alpha : 0}, duration, {onComplete: onFadeOutComplete });	
		}
		
	}

	public function onFadeOutComplete(tween : FlxTween) : Void
	{
		scene.changeBackground(id);
		
		if (duration <= 0)
		{
			onFadeInComplete(null);
		} 
		else 
		{
			FlxTween.tween(scene.background, {alpha : 1}, duration, {onComplete: onFadeInComplete });
		}
	}
	
	public function onFadeInComplete(tween : FlxTween) : Void
	{
		onComplete();
	}

	override public function print() : String
	{
		return "Switch Background to " + id + (duration <= 0 ? " now" : "");
	}

	public static function parse(line : String) : Command
	{
		var comps : Array<String> = line.split(" ");
		var id : String = StringTools.trim(comps[0]);
		var immediate : Bool = false;
		if (comps.length > 1)
		{
			immediate = comps[1] == "now";
		}

		var command : Command = new BgCommand(id, immediate);
		return command;
	}
}
