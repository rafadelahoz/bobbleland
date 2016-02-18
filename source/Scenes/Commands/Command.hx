package scenes.commands;

import flixel.FlxObject;

class Command extends FlxObject
{
	public var scene : SceneState;
	public var finished : Bool;
	
	public var composite : Bool;

	public function new()
	{
		super();
	}

	public function init(Scene : SceneState)
	{
		scene = Scene;
		finished = false;
		composite = false;
		
		// trace(print());
	}

	public function onComplete()
	{
		scene.onCommandFinish();
	}
	
	public function nextCommand()
	{
		// Override me
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
