package parser.commands;

class Command
{
	public function new()
	{
	}
	
	public function execute()
	{
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