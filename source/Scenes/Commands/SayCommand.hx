package scenes.commands;

import flixel.FlxG;

class SayCommand extends Command
{
	public var message : String;
	public var actor : String;

	public function new(?Actor : String = null, Message : String)
	{
		super();

		message = Message;
		actor = Actor;
	}

	override public function init(scene : SceneState)
	{
		super.init(scene);

		text.TextBox.Init(scene, 0, FlxG.height-64, FlxG.width, 64);
		text.TextBox.Message(actor, message, onMessageCompletion);
	}

	function onMessageCompletion()
	{
		onComplete();
	}

	override public function print() : String
	{
		return (actor == null ? "" : actor + ": ") + "\"" + message + "\"";
	}

	public static function parse(line : String) : Command
	{
		var actor : String = null;
		var message : String = null;

		var exp : EReg = ~/"(.*?)"/;

		if (exp.match(line))
		{
			line = exp.matchedRight();

			// We don't know yet if this is the message or the actor
			var tmpString : String = exp.matched(1);

			// It there is another match, the first one was the actor
			if (exp.match(line))
			{
				actor = tmpString;
				message = exp.matched(1);
			}
			// Otherwise, it was the message
			else
			{
				message = tmpString;
			}
		}

		var command : Command = new SayCommand(actor, message);
		return command;
	}
}
