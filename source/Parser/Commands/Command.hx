package parser.commands;

import flixel.FlxSprite;

class Command extends FlxSprite
{
	public var scene : SceneState;
	public var finished : Bool;

	public function new()
	{
		super();
	}

	public function init(Scene : SceneState)
	{
		scene = Scene;
		finished = false;
	}

	public function onComplete()
	{
		scene.onCommandFinish();
	}

	public static function parse(line : String) : Command
	{
		return new Command();
	}

	public function print() : String
	{
		return "";
	}
}