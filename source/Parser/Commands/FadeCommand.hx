package parser.commands;

import flixel.FlxG;

class FadeCommand extends Command
{
	public static var MODE_IN : Int = 0;
	public static var MODE_OUT : Int = 1;

	public var mode : Int;
	public var duration : Float;
	public var _color : Int;

	public function new(Mode : Int, ?Duration : Float = 1, ?Color : Int = 0xFF000000)
	{
		super();

		mode = Mode;
		duration = Duration;
		_color = Color;
	}

	override public function init(Scene : SceneState)
	{
		super.init(Scene);

		FlxG.camera.fade(_color, duration, (mode == MODE_IN), onFadeComplete, true);
	}

	public function onFadeComplete() : Void
	{
		onComplete();
	}

	/* Parsing and related */

	override public function print() : String
	{
		return "Fade " + (mode == MODE_IN ? "in to " : "out from ") + _color + " in " + duration + " seconds";
	}

	public static function parse(line : String) : Command
	{
		var components : Array<String> = line.split(" ");

		var mode : Int = -1;
		var duration : Float = 1.0;
		var color : Int = 0xFF000000;

		for (comp in components)
		{
			comp = StringTools.trim(comp);
			
			switch (comp)
			{
				case "in":
					mode = MODE_IN;
				case "out":
					mode = MODE_OUT;
				default:
					if (comp.indexOf("0x") == 0)
					{
						color = Std.parseInt(comp);
					}
					else
						duration = Std.parseFloat(comp);
			}
		}

		var command : Command = new FadeCommand(mode, duration, color);
		return command;
	}
}
