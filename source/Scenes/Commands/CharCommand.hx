package scenes.commands;

class CharCommand extends Command
{
	public var character : String;
	public var expression : String;

	public function new(Character : String, ?Expression : String = null)
	{
		super();

		character = Character;
		expression = Expression;
	}

	override public function print() : String
	{
		return "Character " + character + " appears" + (expression == null ? "" : ", " + expression);
	}

	public static function parse(line : String) : Command
	{
		var tokens : Array<String> = line.split(",");
		var char : String = StringTools.trim(tokens[0]);
		var expr : String = null;
		if (tokens.length > 1)
			expr = StringTools.trim(tokens[1]);

		var command : Command = new CharCommand(char, expr);
		return command;
	}
}
