package scenes.commands;

import flixel.FlxG;
import flixel.util.FlxTimer;

class WaitCommand extends Command
{
    public var duration : Float;
    var timer : FlxTimer;

	public function new(Duration : Float)
	{
		super();

		duration = Duration;
	}

	override public function init(Scene : SceneState)
	{
		super.init(Scene);

		timer = new FlxTimer().start(duration, onTimerComplete);
	}

	public function onTimerComplete(timer : FlxTimer) : Void
	{
        timer.destroy();
		onComplete();
	}

	/* Parsing and related */

	override public function print() : String
	{
		return "Wait for " + duration + " seconds";
	}

	public static function parse(line : String) : Command
	{
		var durationString : String = StringTools.trim(line);

		var duration : Float = 1.0;
		duration = Std.parseFloat(durationString);

		var command : Command = new WaitCommand(duration);
		return command;
	}
}
