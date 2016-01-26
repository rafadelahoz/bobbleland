package parser.commands;

class PuzzleCommand extends Command
{
	public var puzzle : String;
	public var nextScene : String;

	public function new(Puzzle : String, Scene : String)
	{
		super();

		puzzle = Puzzle;
		nextScene = Scene;
	}

	override public function print() : String
	{
		return "Next puzzle is: " + puzzle + ", and then scene " + scene;
	}

	public static function parse(line : String) : Command
	{
		var components : Array<String> = line.split(" ");

		if (components.length < 2)
			throw "Invalid puzzle command, missing arguments: " + line;

		var command : Command = new PuzzleCommand(components[0], components[1]);
		return command;
	}
}
