package parser.commands;

class BgCommand extends Command
{
	public var id : String;

	public function new(Id : String)
	{
		super();

		id = Id;
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
